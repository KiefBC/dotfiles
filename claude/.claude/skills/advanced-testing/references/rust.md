# Rust advanced-testing tools (verified 2026-07)

## Property-based: proptest (the default; quickcheck revived Feb 2026 but proptest remains standard)

```toml
[dev-dependencies]
proptest = "1"
```

```rust
use proptest::prelude::*;
proptest! {
    #[test]
    fn roundtrip(key in ".*", value in ".*") {
        let line = encode(&key, &value);
        prop_assert_eq!(decode(&line), Some((key, value)));
    }
}
```

`".*"` generates arbitrary Unicode strings. Failing cases auto-persist to `proptest-regressions/` — COMMIT that directory. Shrinking is automatic; the reported failure is minimal.

## Fuzzing: cargo-fuzz (untrusted input parsers)

```bash
cargo install cargo-fuzz
cargo fuzz init && cargo fuzz add parse_target
cargo +nightly fuzz run parse_target
```

Corpus lives in `fuzz/corpus/<target>/` — keep it across runs; commit minimized entries.

## Snapshot: insta

```toml
[dev-dependencies]
insta = "1"
```
`assert_snapshot!(output)`; review diffs with `cargo insta review`. Snapshots live in `src/snapshots/` — commit them.

## Concurrency model checking: loom

Wrap lock-free/atomic code in `loom::model(|| ...)` tests; loom explores interleavings exhaustively. Dev-dependency + `#[cfg(loom)]` type aliases.

## Benchmarks: criterion (maintained under criterion-rs org, 0.8.x; divan dormant since ~2025)

```toml
[dev-dependencies]
criterion = "0.8"
```
`#[bench]` is a hard error on stable (≥1.88) — criterion is the way. Compare runs with `cargo bench` + saved baselines (`--save-baseline`).
