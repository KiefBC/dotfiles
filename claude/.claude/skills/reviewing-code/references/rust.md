# Rust review lenses (verified 2026-07)

## Probe targets in any Rust diff

- **Panic paths introduced:** `.unwrap()`, `.expect()`, indexing/slicing, integer arithmetic on input-driven values (panics in debug, wraps in release — silent-wrong in production). A library panicking on user-supplied input is a finding.
- **Needless clones:** must be a HUMAN lens — clippy's `redundant_clone` was demoted to the allow-by-default nursery group over false positives; the tool will not catch these for you.
- **`unsafe` blocks:** each needs a stated invariant justifying it; absence of the justification is itself a finding.
- **Silent conversions:** `as` casts on input-driven integers (truncation), `unwrap_or_default()` hiding failures.
- **Regressions:** diff removes or restructures old behavior — probe the old happy paths, not just the new feature.

## Tools

- `cargo test` / `cargo clippy --all-targets -- -D warnings` — run both yourself.
- Public API changed? `cargo semver-checks` (standalone tool; not merged into cargo) verifies breaking-change claims against the version bump.

## Ecosystem notes

- Go comparison lens (if reviewing Go too): the loop-variable capture footgun is FIXED for modules declaring `go >= 1.22` — check go.mod before flagging it.
