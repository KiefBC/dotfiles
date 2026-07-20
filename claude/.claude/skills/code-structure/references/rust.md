# Rust structure reference (verified 2026-07)

## Binary crates: the thin-main pattern

Testability in a bin crate = move logic into `src/lib.rs` (same package), keep `src/main.rs` as: parse args → call lib → print/exit. Unit tests live in the lib; `tests/` integration tests exercise the public surface. For a single-file tool, the lighter version: pure functions above `main()`, `#[cfg(test)] mod tests` in the same file — no lib split needed until the file outgrows one screenful of functions.

## Visibility discipline

- Default private; `pub(crate)` for package-internal sharing; `pub` only for a deliberate external surface.
- `pub(super)` / `pub(in path)` for tighter scoping inside module trees.

## Boundary tooling

- Dependency cycles between crates are impossible (compiler-enforced); between modules they hide as tangled call graphs. `cargo modules dependencies --acyclic` (cargo-modules ≥0.26) fails on cycles — usable in CI.
- Visualize: `cargo modules dependencies --lib | dot -Tsvg`.

## Layout conventions

- One concept per module file; `mod.rs` vs `name.rs` — prefer `name.rs` + `name/` directory (modern style).
- Re-export a curated surface at the crate root (`pub use`) rather than making consumers reach into module paths.
