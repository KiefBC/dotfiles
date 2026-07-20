# C++ Ecosystem Reference (verified July 2026)

Version-sensitive facts backing SKILL.md. Baseline: **C++20 is the safe cross-platform target; C++23 *library* features are broadly usable on current toolchains; C++26 is finalized (March 2026) but not a deployment target.** Consult this before making toolchain/compiler-support claims.

## Standards landscape

| Standard | Status (July 2026) | Notes |
|---|---|---|
| C++20 | Universal | Safe default everywhere; `span`, concepts, ranges, designated initializers, `<=>` |
| C++23 | Library broadly usable; *language* needs MSVC caution | `expected`, `print`, monadic `optional`, `ranges::to` usable on current GCC/Clang/MSVC |
| C++26 | **Finalized at Croydon (London), Mar 28 2026** | Reflection, Contracts, `std::execution`, library hardening. DIS ballot → ISO publication within months. **Not a production target yet.** |

## Compiler / stdlib support matrix (C++23 features)

| Feature | GCC (libstdc++) | Clang (libc++) | MSVC (STL) |
|---|---|---|---|
| `std::expected` | 12+ | 16+ | 19.33+ |
| `std::print`/`println` | 14+ | 18+ (libc++) | 19.37+ (VS 17.7) |
| `ranges::to` | 14+ | 17+ | ~2024 |
| `std::generator` | 14+ | **lagging in libc++** | ~2024 |
| C++23 *language* (`-std=c++23`) | GCC 14 (complete) | Clang 18–19 (deducing `this` in 18) | **laggard**: `/std:c++23preview` in Build Tools 14.51; full `/std:c++23` in 14.52 (VS 2026 Insiders) |

Practical rule: cross-platform code assumes C++20 everywhere; C++23 *library* features (`expected`, `print`, `optional` monadic ops, `ranges::to`) are safe now; C++23 *language* features need MSVC caution until 14.52 is default.

## C++26 feature status (experiment, don't ship)

- **Reflection (P2996)** — compile-time introspection, `^^` operator + splicing; "biggest change since templates." Usable on **GCC 16.1** (released April 2026): `-std=c++26 -freflection` (P2996R13). Clang partial (Bloomberg clang-p2996 upstreaming).
- **Contracts (P2900)** — `pre`/`post`/`contract_assert`, four semantics. Contentious: final plenary vote 114–12–3. On GCC 16.1 (P2900R14).
- **`std::execution` (P2300)** — senders/receivers. **No mainstream stdlib ships it** — use NVIDIA `stdexec` reference impl for senders today.
- **Safety-without-code-changes that landed in C++26**: erroneous behavior for uninitialized local reads (no longer UB) + **hardened standard library** (opt-in bounds checking for `vector`/`span`/`string`/`string_view`). GCC 16.1 exposes these switches. GCC 16 also flips the default to C++20.

## Modules — status (official-vs-folklore)

**Verdict: real but early-adopter — do NOT present as the default idiom** (Ropert Apr 2026 + Meeting C++ polls confirm low adoption six years on). Headers + `#pragma once` remain default advice.
- Build: **CMake 3.28+ (ideally 4.x) + Ninja** works without esoteric flags; named modules on MSVC, Clang 16+, GCC 14+ with version quirks.
- `import std;` (C++23): works on MSVC (VS 17.10+) and libc++; CMake support gated/experimental (`CMAKE_CXX_COMPILER_IMPORT_STD`, **Ninja generators only** — VS generators can't build BMIs for imported targets). **Viral**: mixing `import std` and `#include` in one TU causes redeclaration pain → all-or-nothing per project.
- Tooling gaps: IntelliSense for modules still experimental in VS 2026; clangd partial; almost no third-party libs ship module definitions ({fmt} the notable exception).
- Adopt only for isolated heavy-to-parse internal libs where you control the whole build (CMake 4.x + Ninja + one compiler).

## Safety posture (2026)

- **Government pressure is concrete**: CISA/FBI memory-safety roadmap deadline **Jan 1, 2026** passed — lacking a roadmap is framed as elevated national-security risk; driving real procurement questions.
- **Safe C++ (P3390, Baxter borrow checking) is DEAD** — abandoned by its lead author late 2025 after committee/community resistance. Don't recommend waiting for it.
- **Profiles (P3081, Stroustrup) did NOT make C++26** — continues targeting **C++29**.
- What to do today: (1) stdlib hardening now — `-D_GLIBCXX_ASSERTIONS`, `-D_LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_FAST|EXTENSIVE`, MSVC `/sdl` + checked iterators (~0.3% avg overhead at Google/Apple, credited with preventing 1,000+ bugs); (2) sanitizers in CI (ASan+UBSan; TSan for concurrent; `-fhardened`, CFI/`_FORTIFY_SOURCE=3`); (3) bug-class-deleting idioms; (4) be honest — C++ has no memory-safety story equivalent to Rust; interop with a memory-safe language is legitimate for hard-safety components. Hardening flags do NOT make C++ "memory safe."

## Tooling landscape

- **Warnings**: `-Wall -Wextra` alone is not a serious baseline; `-Wconversion`/`-Wshadow` are the highest-value additions. Full set: `-Wall -Wextra -Wpedantic -Wshadow -Wconversion -Wsign-conversion -Wnon-virtual-dtor -Wold-style-cast -Woverloaded-virtual -Wcast-align -Wnull-dereference -Wdouble-promotion -Wformat=2 -Wimplicit-fallthrough`; MSVC `/W4 /permissive-`. `-Werror` in CI only.
- **clang-tidy**: enable `bugprone-*, performance-*, modernize-*, cppcoreguidelines-*, clang-analyzer-*, portability-*`; opt out `-modernize-use-trailing-return-type`, `-*-avoid-magic-numbers`, `-*-avoid-c-arrays`. Ship `.clang-tidy` + `compile_commands.json` (`CMAKE_EXPORT_COMPILE_COMMANDS=ON`) + `.clang-format`. Newer high-value: `modernize-use-std-print`, `modernize-use-ranges` (clang-tidy 18/19+).
- **CMake**: target-based everything (`target_link_libraries`, `target_compile_features(tgt PUBLIC cxx_std_23)`); never global `include_directories`/`CMAKE_CXX_FLAGS`. **CMakePresets.json** standard; 3.28+ min if modules. Deps — **no single winner, split by size**: `FetchContent` for small; **vcpkg or Conan** for teams (lockfiles, binary caching, Qt/Boost/OpenSSL); forward-compatible pattern = `find_package`-consumable + dependency providers (`CMAKE_PROJECT_TOP_LEVEL_INCLUDES`). Craig Scott (CMake maintainer): dependency provisioning isn't CMake's job.

## Canonical reference (official)

**C++ Core Guidelines** (isocpp.github.io/CppCoreGuidelines; repo isocpp/CppCoreGuidelines, ~42k stars, 330+ contributors) — actively maintained, safe to cite; content tracks C++17/20, **predates `std::expected`/C++23 idioms in places**. Key rules: P.8, R.1 (RAII), R.11 (avoid new/delete), R.21 (`unique_ptr` default), R.30/F.7 (`T*`/`T&` for non-owning params), C.20/C.21 (rule of zero/five), ES.20 (always initialize), ES.23 (`{}` init), I.11 (never transfer ownership via raw pointer), F.15, CP.1, E.6, SL.str. GSL companion: `gsl::not_null`, `gsl::span` (now `std::span`).

## Key sources

- herbsutter.com "C++26 is done!" trip report (Croydon, Mar 2026); infoq.com/news/2026/04/cpp-26-reflection-safety-async
- isocpp.org/blog/2026/04/gcc-16.1; gcc.gnu.org/projects/cxx-status.html; clang.llvm.org/cxx_status.html
- devblogs.microsoft.com/cppblog C++23-support-in-MSVC-Build-Tools-14-51; MSVC optional/expected blog
- mropert.github.io/2026/04/13/modules_in_2026; cmake.org cmake-cxxmodules.7
- theregister.com Safe-C++-ditched (Sep 2025); open-std.org P3081 (Profiles); lemire.me 2025/10/05 std::ranges-performance
- isocpp.github.io/CppCoreGuidelines; clang.llvm.org/extra/clang-tidy/checks/list.html
