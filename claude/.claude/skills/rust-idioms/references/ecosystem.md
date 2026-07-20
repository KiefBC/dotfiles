# Rust Ecosystem Reference (verified July 2026)

Version-sensitive facts backing SKILL.md. Current stable: **Rust 1.96.1** (2026-06-30); 6-week cadence unchanged. Skill targets **edition 2024** (stabilized 1.85.0, 2025-02-20 — the largest edition ever; `cargo fix --edition` automates most migration). Mention a feature's version only when it gates an idiom.

## Version landscape

| Version | Date | Idiom-relevant additions |
|---|---|---|
| 1.70 | 2023 | `OnceLock` (std lazy init) |
| 1.75 | 2023 | async fn in traits (AFIT/RPITIT) — static dispatch only |
| 1.80 | 2024 | `LazyLock` (std) — replaces `lazy_static`/`once_cell` for basics |
| 1.81 | 2024 | `core::error::Error` (relevant for no_std libs) |
| 1.82 | 2024 | `use<>` precise capturing stable in free fns |
| 1.85 | 2025-02-20 | **Edition 2024**: RPIT capture-all, `if let` temp scope, `unsafe_op_in_unsafe_fn` warn, unsafe attrs/extern, `static mut` refs = hard error, `set_var`/`remove_var` now `unsafe fn`, `Future`/`IntoFuture` in prelude, `gen` reserved; **async closures** (`async ||`, `AsyncFn*`) |
| 1.87 | 2025 | `use<>` on trait-method RPITIT; `std::io::pipe` |
| 1.88 | 2025-06-26 | **Let-chains** (`if let ... && ...`) — **edition 2024 only**; naked functions `#[unsafe(naked)]`; `cfg(true)`/`cfg(false)` |
| 1.89 | 2025 | `File::lock` — replaces fs2 for basic locking |
| 1.90 | 2025 | inferred const args (`_` in const generics) |
| 1.95 | 2026-04-16 | **`if let` guards in match arms**; **`cfg_select!` macro** — replaces the `cfg-if` crate |
| 1.96.1 | 2026-06-30 | current stable; `LazyLock` gained `From<T>`/accessors through 1.94–1.96 |

## Feature status notes

- **Let-chains** (1.88): stable but **edition-2024-only** — needs the new `if let` drop order. This is the key gating fact; do not show them as usable on edition 2021.
- **`if let` guards in match arms** (1.95): `Some(x) if let Ok(y) = f(x) =>`, bindings usable in the arm body.
- **AFIT / async fn in traits** (1.75): stable, static dispatch only. `dyn` + async trait methods is **NOT stable** (AFIT traits not dyn-compatible) → `async-trait` crate (boxing) or `dynosaur` (proc-macro, v0.3+). **Return-type notation** (`T::method(..): Send`) is **NOT stable** (FCP blocked on next-gen trait solver) → use `trait-variant` for a `Send` variant.
- **Do NOT present as stable** (all unstable July 2026): `try` blocks / `Try` trait (accepted as a 2026 project goal "stabilize-try", design open) → use `?` + helpers; `gen` blocks (RFC 3513, keyword reserved in 2024) → `iter::from_fn`/`iter::successors`/manual `Iterator`; TAIT (`type Alias = impl Trait`, blocked on next-gen trait solver) → newtype wrappers.
- **Lazy statics**: `LazyLock` (std 1.80) / `OnceLock` (1.70). `lazy_static!` is effectively deprecated; dropping `once_cell`/`lazy_static` deps is itself an idiom.
- **std-over-crate migrations**: `cfg_select!` (1.95) → replaces `cfg-if`; `File::lock` (1.89) → replaces fs2; `std::io::pipe` (1.87).

## Error-handling landscape

- **`thiserror` (libraries) + `anyhow` (applications)** — still the canonical pair, no dethroning. thiserror is on **2.x** (since Nov 2024, supports struct-style errors well); both dtolnay-maintained. `?` remains the bubbling idiom (no `try` blocks yet).
- Others, by niche: **snafu** — large multi-crate systems wanting per-call-site context selectors (GreptimeDB); **eyre/color-eyre** — anyhow fork with pluggable report handlers when end-user error *presentation* matters; **miette** — CLI/compiler-style diagnostics (spans, graphical), pairs with thiserror types. None is the default.

## Clippy / tooling conventions

- **Official**: rust-lang.github.io/api-guidelines (naming C-CONV `as_`/`to_`/`into_`, C-GETTER no `get_` prefix, C-ITER, `From`-not-`Into`, `#[must_use]` with reason, C-BUILDER, C-SEALED, C-DEREF) and rust-lang.github.io/rust-clippy. API Guidelines content is stable and still authoritative.
- **Clippy config idiom**: workspace lints in root `Cargo.toml` — `pedantic = { level = "warn", priority = -1 }` then targeted `allow`s (`module_name_repetitions`, `similar_names`, `too_many_lines`, `missing_errors_doc`, cast lints). Deny in CI: `clippy::dbg_macro`, `clippy::todo`, `clippy::unwrap_used` (apps prefer `expect` with message).
- **`uninlined_format_args` reversal (verify-sensitive folklore)**: promoted to style/warn-by-default in 1.67, then **moved back to `pedantic` (allow-by-default) in 2025** (clippy PR #15287) — because field access `{x.y}` is unsupported. Inline captures `format!("{name}")` are still preferred style, but clippy no longer warns by default. Do not tell users clippy enforces it.

## Ecosystem defaults (assumed-standard, don't relitigate)

tokio (async runtime, ships LTS: 1.47.x to Sep 2026, 1.51.x to Mar 2027); serde + serde_json (bincode for binary); clap 4 (derive); reqwest (rustls); axum (web); tracing + tracing-subscriber; sqlx (sea-orm/diesel for ORM); thiserror/anyhow. Modern picks: **jiff** (burntsushi, 2024) for new time code over chrono; tikv-jemallocator/mimalloc as the perf allocator lever. **async-std is dead** (deprecated/discontinued) — never suggest it; smol for niche embedded.

## Key sources

- blog.rust-lang.org/2025/02/20/Rust-1.85.0 (edition 2024); doc.rust-lang.org/edition-guide/rust-2024
- blog.rust-lang.org/2025/06/26/Rust-1.88.0 (let-chains); blog.rust-lang.org/2026/04/16/Rust-1.95.0 (if-let guards, cfg_select!)
- rust-lang.github.io/api-guidelines; rust-lang.github.io/rust-clippy/master; clippy PR #15287
- github.com/rust-lang/rust-project-goals — 2026/stabilize-try.md; gen tracking rust#117078; RTN PR rust#138424
- nrc.github.io/error-docs/ecosystem.html; ohadravid.github.io state-of-the-crates
