# Rust debugging instruments (verified 2026-07, macOS arm64)

## Fast evidence

- `RUST_BACKTRACE=1` (or `full`) on any panic.
- `dbg!(expr)` — prints file:line + value, returns the value; targeted, greppable, easy to remove.
- `RUST_LOG=my_crate=debug` with tracing 0.1 + `EnvFilter` (tracing 0.2 still unreleased — don't wait for it).

## Debugger

- `rust-lldb ./target/debug/bin` works natively on Apple Silicon; `b file.rs:LINE`, `run`, `p var`.
- Under tests: `cargo nextest run --debugger rust-lldb <testname>` (nextest ≥0.9.113) runs a test under the debugger with env preserved.

## Async

- tokio-console requires `RUSTFLAGS="--cfg tokio_unstable"` + the `console-subscriber` crate; shows stuck/busy tasks.
- Hangs without console: `sample <pid>` (macOS) or lldb attach → `bt all`.

## Nondeterminism suspects (Rust-specific)

- **HashMap/HashSet iteration order is randomized per process** — the canonical "different output each run" cause. Any "first/last/max-tie" selection over a HashMap is nondeterministic. Fix with defined ordering (file order, BTreeMap, sort with total tie-break), and test the tie case.
- `SystemTime`/thread scheduling/ptr addresses as incidental inputs.

## Regressions

- `git bisect start <bad> <good>` then `git bisect run ./repro.sh` — script exits 0 good, 1–124 bad, **125 skip**.

## Sanitizers on macOS (caveats matter)

- ASan + UBSan: work with Apple Clang and rustc (`-Zsanitizer` needs nightly for Rust).
- **No LSan with Apple Clang** — use `leaks`/Instruments for leak hunting.
- **TSan cannot combine with ASan**; MSan is Linux-only. **rr does not run on macOS at all** — time-travel debugging requires a Linux VM.
