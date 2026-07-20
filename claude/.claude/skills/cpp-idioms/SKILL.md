---
name: cpp-idioms
description: Use when writing or reviewing C++ code — new files, refactors, PR review, or advising on C++ style, error handling, ownership, ranges, modules, build flags, or memory-safety posture. Covers C++20/23-era idiom decisions and their contested edges.
---

# Modern C++ Idioms (C++20/23 baseline)

## Overview

Modern C++ as actually written in 2026: C++20 is the safe cross-platform target; C++23 library features (`expected`, `print`, monadic `optional`, `ranges::to`) are broadly usable; C++26 exists but is not a deployment target. Version-sensitive facts (compiler support matrix, modules status, safety-debate status) live in [references/ecosystem.md](references/ecosystem.md) — consult it before making toolchain claims.

## Core idioms

### 1. RAII / rule of zero (CG C.20, R.1)

```cpp
// WRONG: manual resource management, hand-written special members
class Widget {
  int* data_;
public:
  Widget() : data_(new int[100]) {}
  ~Widget() { delete[] data_; }   // forgot copy ctor/assign → double free
};

// RIGHT: rule of zero — members manage resources
class Widget {
  std::vector<int> data_ = std::vector<int>(100);
};
```

If you must write ANY of the five special members, `=default`/`=delete` all five explicitly (rule of five, CG C.21).

### 2. unique_ptr default; shared_ptr only for genuinely shared lifetime (CG R.21, R.11)

```cpp
// WRONG: shared_ptr as the reflexive "safe pointer"; naked new; smart-ptr params for mere use
std::shared_ptr<Session> s(new Session());
void render(std::shared_ptr<Session> s);   // taxes every caller with refcount churn

// RIGHT
auto s = std::make_unique<Session>();
void render(const Session& s);             // use = ref/raw ptr, non-owning (CG F.7, R.30)
void adopt(std::unique_ptr<Session> s);    // by-value unique_ptr = ownership transfer (R.32)
```

Signature conventions: `T*`/`T&` = "I don't own this"; `unique_ptr` by value = ownership transfer; `shared_ptr` by value = shared ownership; `make_unique`/`make_shared` always; `weak_ptr` to break cycles.

### 3. std::expected for recoverable errors (C++23) — coexists with exceptions

```cpp
// WRONG: exceptions for routine expected failures; or bool + out-param
bool parse(std::string_view in, Config& out);
Config parse(std::string_view in);   // throws on every malformed input

// RIGHT: expected + monadic composition
std::expected<Config, ParseError> parse(std::string_view in);
auto port = parse(text)
    .and_then(validate)
    .transform([](const Config& c) { return c.port; })
    .value_or(8080);
```

Judgment: `expected` is now the idiomatic choice for recoverable, *expected* failures — especially exception-banned/embedded/games/perf-critical code. Exceptions remain idiomatic for truly exceptional, non-local failures (constructor failure, OOM-ish, contract violations at API boundaries). This is coexistence, not replacement — do not declare exceptions dead, and do not mechanically convert a codebase's error style.

### 4. string_view / span — parameters and locals ONLY

```cpp
// WRONG: const string& params (allocates for literals); storing a view
void log(const std::string& msg);
struct Cache { std::string_view key; };   // dangling time bomb

// RIGHT: view for non-owning read-only params; own with string in members
void log(std::string_view msg);           // accepts literal, string, view — zero copies
struct Cache { std::string key; };
```

Dangling rules: never store a view in a member, never return a view of a temporary. `string_view` is **not null-terminated** — no `.c_str()`, don't pass `.data()` to C APIs expecting NUL. `std::span<T>` (C++20) is the same deal for "contiguous buffer + length" params, replacing `(T*, size_t)` pairs — non-owning, same lifetime discipline.

### 5. std::optional = absence isn't an error

```cpp
// WRONG: optional plus a separate error channel; sentinel values
std::optional<Config> parse(std::string_view in, Error& err);

// RIGHT: optional when absence is fine (lookup, config); expected when absence has a reason
std::optional<User> find_user(UserId id);
std::expected<Config, ParseError> parse(std::string_view in);
```

C++23 gave `optional` the same monadic ops (`and_then`/`transform`/`or_else`) — use them over `has_value()` ladders.

### 6. Ranges: algorithms everywhere; view pipelines with restraint

```cpp
// WRONG: iterator-pair boilerplate
std::sort(v.begin(), v.end(), [](auto& a, auto& b){ return a.id < b.id; });

// RIGHT: constrained algorithms + projections — table stakes
std::ranges::sort(v, {}, &Item::id);
auto names = items | std::views::filter(&Item::active)
                   | std::views::transform(&Item::name)
                   | std::ranges::to<std::vector>();   // C++23
```

Honest status: pipelines are mainstream for cold paths but genuinely contested for hot paths — measured pipeline performance can miss expectations (Lemire, Oct 2025), and Google avoids `std::ranges` (performance, compile time, iterator-invalidation semantics). Benchmark before shipping a pipeline in a hot inner loop; a plain loop is not a code smell there. Gotchas: `views::filter` caches `begin()` (mutating through it is UB-adjacent; const-iteration doesn't compile the way people expect); views are lazy and non-owning → dangling if the underlying range dies.

### 7. std::print / std::println over iostream and printf (C++23)

```cpp
// WRONG
std::cout << "user " << id << ": " << name << "\n";
printf("user %d: %s\n", id, name.c_str());

// RIGHT: type-safe, compile-time format check
std::println("user {}: {}", id, name);
```

Shipped in all three stdlibs (see ecosystem.md for versions). Stuck on C++20: `std::format` + the {fmt} library (drop-in superset).

### 8. enum class over plain enum

```cpp
// WRONG: leaks enumerators into scope, implicitly converts to int
enum Color { Red, Green };
int x = Red;

// RIGHT: scoped, no implicit conversion; specify underlying type when it matters
enum class Color : std::uint8_t { Red, Green };
auto c = Color::Red;
```

### 9. Structured bindings

```cpp
// WRONG
auto it = m.find(key);
if (it != m.end()) use(it->first, it->second);

// RIGHT
if (auto it = m.find(key); it != m.end()) {
  const auto& [k, v] = *it;
  use(k, v);
}
auto [ok, inserted] = m.insert({key, val});
```

### 10. constexpr where it earns it

```cpp
// WRONG: macros or runtime init for compile-time-knowable values
#define MAX_RETRIES 5
static const auto table = build_table();   // runtime init, SIOF risk

// RIGHT
inline constexpr int max_retries = 5;
constexpr auto table = build_table();      // if build_table is constexpr
consteval auto hash(std::string_view s);   // must run at compile time
```

Use `constexpr` for values and functions that plausibly evaluate at compile time; don't `constexpr`-ify everything reflexively — it's an interface promise you then have to keep.

### Also table stakes (one line each)

`[[nodiscard]]` on error-returning/factory functions; designated initializers over comment-annotated positional init (C++20); `auto` when the type is obvious from the right-hand side; concepts over SFINAE (`template <std::integral T>`); `= default` spaceship `<=>` instead of six comparison operators; brace-init `{}` to block narrowing (CG ES.23); always initialize (ES.20).

## Anti-patterns (C-with-classes tells)

| Anti-pattern | Replace with |
|---|---|
| Raw `new`/`delete`/`malloc` | `make_unique`/`make_shared`, containers (CG R.11) |
| Out-params for results (`bool f(T& out)`) | Return by value; `optional`/`expected`; structured bindings |
| C arrays (`T buf[N]`, `T* + size_t`) | `std::array`, `std::vector`, `std::span` params |
| Macros for constants/functions | `inline constexpr`, `constexpr` functions, templates |
| `shared_ptr` "just to be safe" | `unique_ptr` default; refs/raw ptrs for non-owning use |
| C-style casts | `static_cast` etc.; no cast at all if design allows |
| `typedef` | `using` alias |
| `0`/`NULL` | `nullptr` |
| Hand-rolled loops where an algorithm exists | `std::ranges::` algorithm + projection |
| Owning raw pointer in an API | `unique_ptr` (never transfer ownership via raw pointer, CG I.11) |

## Safety posture (2026)

Regulator pressure is concrete (CISA/FBI memory-safety roadmap deadline passed Jan 1, 2026); Safe C++ borrow checking is dead; Profiles slipped to C++29. What actually landed and what to do — details and exact switches in [references/ecosystem.md](references/ecosystem.md). Practical stance:

1. **Turn on stdlib hardening now**: `-D_GLIBCXX_ASSERTIONS` (libstdc++), `-D_LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_FAST` (or `EXTENSIVE`) (libc++), `/sdl` + checked iterators (MSVC). ~0.3% average overhead at Google/Apple scale; it's the closest thing to free safety.
2. **Sanitizers in CI**: ASan+UBSan on tests; TSan for concurrent code; consider `-fhardened` (GCC) and CFI/`-D_FORTIFY_SOURCE=3` in release.
3. **Idioms that delete bug classes**: no naked `new`/`delete`; `span`/`string_view` over pointer+length; `at()` or hardened `[]` at trust boundaries; no C-style casts; initialize everything; `gsl::not_null` or references for non-null.
4. **Be honest**: C++ has no memory-safety story equivalent to Rust. For new components with hard safety requirements, interop with a memory-safe language is a legitimate recommendation even from within the C++ community. Don't tell users hardening flags make C++ "memory safe."

## Modules policy

Real but early-adopter — **do not present modules as the default idiom**; headers + `#pragma once` + include-what-you-use-clean headers remain the default advice in 2026. Adopt modules only for isolated, heavy-to-parse internal libraries where you control the whole build (CMake 4.x + Ninja + one compiler). `import std;` is all-or-nothing per project (mixing with `#include <...>` in one TU causes redeclaration pain). Support matrix and tooling gaps: [references/ecosystem.md](references/ecosystem.md).

## Tooling defaults

**Warnings** — `-Wall -Wextra` alone is not a serious baseline; `-Wconversion`/`-Wshadow` are the highest-value additions:

```
GCC/Clang: -Wall -Wextra -Wpedantic -Wshadow -Wconversion -Wsign-conversion
           -Wnon-virtual-dtor -Wold-style-cast -Woverloaded-virtual -Wcast-align
           -Wnull-dereference -Wdouble-promotion -Wformat=2 -Wimplicit-fallthrough
MSVC:      /W4 /permissive-
CI:        -Werror in CI only (never in exported build config)
```

**clang-tidy** — ship `.clang-tidy` at repo root + `compile_commands.json` (`CMAKE_EXPORT_COMPILE_COMMANDS=ON`); pair with `.clang-format`:

```yaml
Checks: >
  bugprone-*, performance-*, modernize-*, cppcoreguidelines-*,
  clang-analyzer-*, portability-*,
  -modernize-use-trailing-return-type, -*-avoid-magic-numbers, -*-avoid-c-arrays
```

High-value mechanical migrations: `modernize-use-override`, `use-nullptr`, `loop-convert`, `use-emplace`, `make-unique`, `use-designated-initializers`, `use-starts-ends-with`, and `modernize-use-std-print` / `modernize-use-ranges` (clang-tidy 18/19+) for printf/cout→`println` and iterator-pair→ranges.

**CMake** — target-based everything: `target_link_libraries`, `target_compile_features(tgt PUBLIC cxx_std_23)`; never global `include_directories`/`CMAKE_CXX_FLAGS` surgery. `CMakePresets.json` is the standard way to encode configurations; 3.28+ minimum if modules are in play. Dependencies — no single winner, split by size: `FetchContent` for small projects; **vcpkg or Conan** for teams (lockfiles, binary caching, hard deps like Qt/Boost/OpenSSL); forward-compatible pattern is `find_package`-consumable + dependency providers (`CMAKE_PROJECT_TOP_LEVEL_INCLUDES`) so consumers choose.

**Canonical reference**: the C++ Core Guidelines (isocpp.github.io/CppCoreGuidelines) — actively maintained, safe to cite; note it predates `std::expected`/C++23 idioms in places.
