---
name: rust-idioms
description: Use when writing or reviewing Rust code — new crates, functions, APIs, error types, async traits, unsafe blocks, Cargo/clippy configuration, or when Rust code reads like translated Java/C/Python (index loops, getters/setters, stringly-typed errors, clone-to-compile).
---

# Rust Idioms

## Overview

Encodes current (Rust 1.96, edition 2024) idiom and judgment — the layer that makes Rust code native rather than translated. Assume `edition = "2024"` in all new code.

## Core idioms

### 1. Accept borrows, generalize owned inputs

```rust
// wrong: forces callers to allocate/give up ownership
fn greet(name: String) -> String { format!("hello {name}") }
fn total(v: Vec<u32>) -> u32 { v.iter().sum() }
```
```rust
// right: &str / &[T] for reads; impl Into<_> when you store it
fn greet(name: &str) -> String { format!("hello {name}") }
fn total(v: &[u32]) -> u32 { v.iter().sum() }
fn set_name(&mut self, name: impl Into<String>) { self.name = name.into(); }
```

### 2. Return iterators, not collected Vecs

```rust
// wrong: allocates eagerly, freezes the return type
fn evens(v: &[u32]) -> Vec<u32> {
    v.iter().copied().filter(|n| n % 2 == 0).collect()
}
```
```rust
// right: caller decides whether to collect (2024 RPIT captures '_ automatically)
fn evens(v: &[u32]) -> impl Iterator<Item = u32> {
    v.iter().copied().filter(|n| n % 2 == 0)
}
```

### 3. Iterate values, not indices

```rust
// wrong: C accent; clippy::needless_range_loop
for i in 0..v.len() {
    process(&v[i]);
}
```
```rust
// right
for x in &v {
    process(x);
}
// need the index too: for (i, x) in v.iter().enumerate()
```

Combinator fixups: `.filter(p).next()` → `.find(p)`; `.map(f).flatten()` → `.flat_map(f)`; `.fold(0, |a, b| a + b)` → `.sum()`; copying a Vec via `iter().cloned().collect()` → `.to_vec()`. Fail-fast over fallible maps: `collect::<Result<Vec<_>, _>>()`.

Judgment: iterator chains when the transformation is the point; a plain `for` loop when side effects dominate, early-exit turns into `try_fold` gymnastics, or you mutate two things at once. Both compile to the same code — readability decides.

### 4. Exhaustive match over if-else chains

```rust
// wrong: compiler can't check coverage; silent on new variants
if state == State::Idle { start() }
else if state == State::Running { poll() }
else { cleanup() }
```
```rust
// right: adding a variant becomes a compile error, not a bug
match state {
    State::Idle => start(),
    State::Running => poll(),
    State::Done => cleanup(),
}
```
Avoid `_ =>` catch-alls on enums you own.

### 5. Newtype for domain values

```rust
// wrong: three u64s, any argument order compiles
fn transfer(from: u64, to: u64, amount: u64) { /* ... */ }
```
```rust
// right: invariants live in the constructor; misuse won't compile
struct AccountId(u64);
struct Cents(u64);
fn transfer(from: AccountId, to: AccountId, amount: Cents) { /* ... */ }
```
Expose `as_str()`/`get()`-style accessors; implement `Deref` only for smart-pointer-like types.

### 6. let-else and let-chains for guard clauses

```rust
// wrong: nesting pyramid
if let Some(user) = find(id) {
    if user.active {
        notify(&user);
    }
}
```
```rust
// right: let-else for early exit; let-chains (1.88, edition-2024-only) to flatten
let Some(user) = find(id) else { return };
if let Some(cfg) = load() && cfg.enabled {
    apply(&cfg);
}
```
Match arms can also take `if let` guards since 1.95: `Some(s) if let Ok(n) = s.parse::<u32>() => n,`.

### 7. Errors: thiserror for libraries, anyhow for binaries

```rust
// wrong (library): erases the error type from your public API
pub fn load(path: &Path) -> Result<Config, Box<dyn std::error::Error>> { /* ... */ }
```
```rust
// right (library)
#[derive(Debug, thiserror::Error)]
#[non_exhaustive]
pub enum ConfigError {
    #[error("io error reading config")]
    Io(#[from] std::io::Error),
    #[error("invalid key {0:?}")]
    InvalidKey(String),
}
```
```rust
// right (application): anyhow + .context, all the way up through main
fn main() -> anyhow::Result<()> {
    let cfg = load(&path).context("loading config")?;
    run(cfg)
}
```
Bubble with `?`; in apps prefer `.expect("invariant: ...")` over `.unwrap()` — the message documents the precondition.

### 8. LazyLock/OnceLock from std — no lazy_static, no once_cell

```rust
// wrong: dep for something std does (lazy_static is effectively deprecated)
lazy_static::lazy_static! {
    static ref RE: Regex = Regex::new(r"^\d+$").unwrap();
}
```
```rust
// right: std since 1.80 / 1.70
static RE: LazyLock<Regex> = LazyLock::new(|| Regex::new(r"^\d+$").unwrap());
static CONFIG: OnceLock<Config> = OnceLock::new(); // when init needs runtime input
```

### 9. Async traits: plain `async fn`, boxing only when forced

```rust
// wrong as a default: #[async_trait] boxes every call
#[async_trait::async_trait]
trait Store { async fn get(&self, k: &str) -> Option<Vec<u8>>; }
```
```rust
// right: stable since 1.75, zero-cost with static dispatch
trait Store {
    async fn get(&self, k: &str) -> Option<Vec<u8>>;
}
```
Reach for `async-trait` or `dynosaur` only when you need `dyn Store`; use `trait-variant` when spawned/generic code needs `+ Send` futures.

### 10. Combinators vs match — a judgment call, not a rule

```rust
// wrong: match for a one-step transformation
let n = match name { Some(s) => s.len(), None => 0 };
// wrong: combinator soup where control flow branches
let v = opt.and_then(|x| x.checked_mul(2)).map(|x| x + 1).unwrap_or_else(|| { log(); 0 });
```
```rust
// right: single transformation -> combinator; real branching -> match / let-else
let n = name.map_or(0, str::len);
let Some(x) = opt else { log(); return 0 };
match x.checked_mul(2) { Some(y) => y + 1, None => { log(); 0 } }
```

## Anti-patterns: written like another language

| Smell | Origin | Native form |
| --- | --- | --- |
| `get_name()` / trivial `set_x()` pairs | Java | `name()` accessor (no `get_` prefix, C-GETTER); pub fields or a builder for >3 optional params |
| `for i in 0..v.len()` with `v[i]` | C | `for x in &v`, `.iter().enumerate()` |
| `Result<T, String>` / `Err("bad input".into())` | scripting | Typed error enum (thiserror) or `anyhow::bail!` in apps |
| `.clone()` sprinkled until borrowck passes | GC languages | Restructure ownership: borrow, split structs, move the value, or `Rc`/`Arc` deliberately |
| `impl Into for Mine` | — | Implement `From`; `Into` comes free |
| Constructor throwing via `panic!` on bad input | Java/C++ | `TryFrom` / `fn new(...) -> Result<Self, E>` |
| `null`-substitute sentinel values (`-1`, `""`) | C | `Option<T>` |

## Edition 2024 notes

- **Unsafe hygiene**: `unsafe_op_in_unsafe_fn` warns by default. Put an explicit `unsafe {}` block inside `unsafe fn`, each with a `// SAFETY:` comment:
  ```rust
  unsafe fn read(p: *const u8) -> u8 {
      // SAFETY: caller guarantees p is valid and aligned
      unsafe { *p }
  }
  ```
- Attributes must be marked: `#[unsafe(no_mangle)]`, `#[unsafe(export_name)]`, `#[unsafe(link_section)]` — bare forms are edition errors. FFI: `unsafe extern "C" { ... }` with `safe fn`/`unsafe fn` item qualifiers.
- **References to `static mut` are hard errors.** Use `Mutex`, atomics, `OnceLock`, or `LazyLock`.
- `std::env::set_var` / `remove_var` are now `unsafe fn` — don't call them casually in examples or tests.
- **RPIT capture**: `-> impl Trait` captures all in-scope lifetimes by default (matches async fn). Opt out with precise capturing: `-> impl Iterator<Item = u32> + use<>` (works on trait methods too since 1.87).
- `if let` temporaries drop at the end of the `if let` (this is what makes let-chains sound). `Future`/`IntoFuture` are in the prelude. Async closures `async || {}` with `AsyncFn*` traits are stable — prefer them over `|| async {}` when the callee accepts them.

## What NOT to use yet (do not present as stable)

- **`try` blocks / `Try` trait** — still unstable (2026 project goal, not landed). Use `?` and helper functions.
- **`gen` blocks** — keyword reserved, feature unstable. Use `iter::from_fn`, `iter::successors`, or a manual `Iterator` impl.
- **TAIT** (`type Alias = impl Trait;`) — unstable. Name types via newtype wrappers.
- **Return-type notation** (`T::method(..): Send`) — unstable. Use the `trait-variant` crate for Send-bounded async traits.
- **`dyn` dispatch on `async fn` traits** — AFIT traits are not dyn-compatible. Use `async-trait` (boxing) or `dynosaur`.

## Tooling defaults

Clippy via workspace lints in the root `Cargo.toml` — pedantic wholesale at warn, then targeted allows:

```toml
[workspace.lints.clippy]
pedantic = { level = "warn", priority = -1 }
module_name_repetitions = "allow"
must_use_candidate = "allow"
missing_errors_doc = "allow"
```

Deny in CI: `clippy::dbg_macro`, `clippy::todo`, `clippy::unwrap_used` (apps: allow `expect` with a message). Prefer inline format captures (`format!("{name}")`) even though clippy no longer warns about the old style by default.

`#[must_use]` on builders, pure combinators, and guard-like types — with a reason string: `#[must_use = "streams do nothing unless polled"]`.

Assumed-standard crates (don't relitigate): tokio, serde + serde_json, clap 4 (derive), reqwest (rustls), axum, tracing + tracing-subscriber, sqlx, thiserror + anyhow. Modern picks: jiff for new time-handling code; `cfg_select!` instead of the cfg-if crate; `File::lock` instead of fs2. async-std is dead — never suggest it.

Deeper version facts (stabilization versions, crate status, edition timeline): see references/ecosystem.md.
