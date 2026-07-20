# Rust API tooling & mechanics (verified 2026-07)

## Breaking-change detection

- `cargo semver-checks` — the standard (v0.48, ~245 lints). Still a STANDALONE tool (`cargo install cargo-semver-checks`); merging into cargo is an active rust-lang goal but not done. Run before any release claiming minor/patch.
- `cargo public-api` (~0.52) — diff the rendered public API surface between versions.
- Known limits: semver-checks misses some behavioral breaks and cross-crate re-export cases — it supplements the classification table, never replaces it.

## Evolvability mechanics

- `#[non_exhaustive]` on public enums/structs others might match/construct — variants can be added in minors.
- Sealed traits (private supertrait) — implementable-by-you-only, so adding methods isn't breaking.
- Builder pattern for options-bearing constructors; `impl Into<T>` / `AsRef` at boundaries for caller ergonomics.
- `#[deprecated(since = "x.y.z", note = "use `new_fn` instead")]` — rustc warns for you; remove at next major.
- `#[must_use]` on results that are errors to ignore.

## Authority

- Cargo's semver reference (what counts as breaking, precisely): https://doc.rust-lang.org/cargo/reference/semver.html
- Rust API Guidelines checklist: https://rust-lang.github.io/api-guidelines/

## Cross-language quick map

- Go: `apidiff` / `gorelease` (still x/exp, experimental); deprecations via `// Deprecated:` comments, enforced by staticcheck SA1019.
- Python: `griffe check` (v2.1+, can check PyPI packages directly); deprecations via PEP 702 `warnings.deprecated` (3.13+, enforced by type checkers).
- TypeScript: api-extractor (pinned to the TS 6 compiler API until TS 7.1 ships the stable Go-native API); `@typescript-eslint/no-deprecated` replaces the dead eslint-plugin-deprecation.
