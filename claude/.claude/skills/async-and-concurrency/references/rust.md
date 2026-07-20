# Rust / tokio concurrency reference (verified 2026-07)

## Primitives (current)

- **JoinSet** — the default for dynamic task groups: spawn into it, `join_next()` until None. **JoinMap** is now in stable tokio-util (≥0.7.16, no tokio_unstable needed); **JoinQueue** (0.7.17) for completion-in-spawn-order.
- **Bounded concurrency:** `Arc<Semaphore>` + `acquire_owned()` before spawn, permit moved into the task; or `futures::stream::iter(..).buffer_unordered(N)`.
- **Panic policy:** `join_next()` yields `Err(JoinError)` for panicked tasks — match on it and decide (count as failure / abort). `.expect()` = abort-all policy, fine but SAY it.
- **Cancellation:** `tokio_util::sync::CancellationToken` for graceful shutdown; `tokio::select!` on token + work. Cancellation-safety: not all futures are safe to drop mid-await — check docs before `select!`-ing over them.

## Blocking rules

- `tokio::fs`, `tokio::time::sleep`, `tokio::process` replace std equivalents in async contexts.
- Chunky sync/CPU work: `tokio::task::spawn_blocking` (owns data) — `block_in_place` only as a last resort on multi-thread runtimes.
- **No clippy lint catches blocking-in-async** (still, as of mid-2026) — this is a human/review lens only.

## Serialized IO idiom

One writer task owning the `File`, fed by `tokio::sync::mpsc` — beats `Arc<Mutex<File>>` when writer count or throughput grows; Mutex is acceptable for low-rate logs.

## Diagnosis

- tokio-console: `console-subscriber` 0.5 + `RUSTFLAGS="--cfg tokio_unstable"` — busy/idle/stuck task view.
- Hangs: `sample <pid>` / lldb attach → `bt all`.

## Model checking

- **loom is frozen (no commits since Apr 2024)** — still works for std-primitive interleavings.
- **shuttle** (AWS, 0.9.x) is the actively maintained randomized model checker — prefer it for new concurrency-critical tests.

## Test patterns

- Invariant test: run the concurrent path in `#[tokio::test]`, assert exact partition of results.
- Cap test: `Arc<AtomicUsize>` incremented on entry/decremented on exit inside the operation; track high-water mark; assert ≤ N.
- Virtual time: `#[tokio::test(start_paused = true)]` makes sleep-heavy tests instant (`tokio::time::advance`).
