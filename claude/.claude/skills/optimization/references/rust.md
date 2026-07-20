# Rust optimization tooling (verified 2026-07)

## Timing (whole program)

- `hyperfine './target/release/tool args'` — repetitions, warmup, statistics built in (v1.20+). If unavailable: loop `/usr/bin/time -p` ≥3 runs, report median + spread.
- Always `--release`. Debug numbers are fiction.

## Profiling

- **samply** (v0.13+) — the macOS-native default: `samply record ./target/release/tool args` → Firefox Profiler UI. Preferred over cargo-flamegraph on Darwin; also fine on Linux.
- cargo-flamegraph still works (`cargo flamegraph -- args`) for SVG flamegraphs.
- Since Rust 1.77, release builds strip std debuginfo — add a profiling profile:

```toml
[profile.profiling]
inherits = "release"
debug = true
```

Build with `cargo build --profile profiling` when profiling; symbols without losing optimization.

## Micro/function benchmarks

- **criterion 0.8** (maintained under the criterion-rs org; divan is dormant — don't reach for it). `[dev-dependencies] criterion = "0.8"`; compare with `cargo bench -- --save-baseline before` / `--baseline before`.
- `std::hint::black_box` to defeat dead-code elimination in hand-rolled loops.
- `#[bench]` is a hard error on stable (≥1.88) — criterion is the path.

## Common Rust wins (verify with measurement first)

- Work hoisted out of loops (regex/format compilation, allocations).
- O(n·m) scans → HashMap/HashSet index.
- Per-item `String` allocation → borrow `&str` from the source buffer; reuse one buffer.
- Unbuffered stdout in a loop → `BufWriter` around a locked handle.
- `collect` chains that materialize intermediates → iterate lazily.
