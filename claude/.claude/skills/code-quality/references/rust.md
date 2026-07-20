# Rust gate commands (verified 2026-07)

## The gate (all three before any "done" claim)

```bash
cargo test                                   # quote the unit-test "test result:" line
cargo clippy --all-targets -- -D warnings    # zero warnings tolerated
cargo fmt --check
```

Advisory pass (read the output, apply judgment, do not blind-fix):

```bash
cargo clippy --all-targets -- -W clippy::pedantic
```

Persistent lint policy belongs in `Cargo.toml` `[lints.rust]` / `[lints.clippy]` (group entries need `priority = -1`), not in CI flags.

## Output pitfalls

- `cargo test` prints MULTIPLE sections (unit tests, then doc-tests). The doc-test section reads "running 0 tests" even when unit tests exist — `| tail` shows only that. Use `cargo test 2>&1 | grep -E "^test result"` and quote the line counting your tests (`N passed` where N > 0).
- `cargo build` succeeding proves type-correctness only.

## Panic-path audit targets

- `.unwrap()` / `.expect()` — justify each or convert to `?` / handling.
- Indexing `[i]` and slicing — prefer `.get()` where input-driven.
- Integer arithmetic — overflows panic in debug, wrap in release; input-driven arithmetic uses `checked_*` / `saturating_*`.
- `parse()` results — malformed input must surface an error, never a default.

## Authority

Rust API Guidelines: https://rust-lang.github.io/api-guidelines/
