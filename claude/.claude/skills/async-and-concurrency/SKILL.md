---
name: async-and-concurrency
description: Use when writing or modifying async code, spawning tasks or threads, adding concurrency or parallelism, sharing state across tasks, or investigating hangs, races, deadlocks, or "works sometimes" behavior in concurrent code.
---

# Async & Concurrency

## Overview

Concurrent code has invariants that sequential code gets for free: nothing is lost, nothing is duplicated, limits hold, shutdown is clean. Every one of those is now YOUR job — and each needs a stated policy and a test, because concurrency bugs don't show up in the happy-path run.

<HARD-GATE>
Before claiming concurrent code done, state in your report:
1. **Ownership:** who awaits every spawned task (no fire-and-forget without written justification).
2. **Panic policy:** what happens when one task panics — abort all, count as failure, or restart — chosen, not defaulted.
3. **Cancellation story:** what happens on ctrl-c / caller cancellation mid-run.
4. **Invariant tests:** the concurrency invariants (exact counts, cap respected, no lost items) exist as persisted tests.
</HARD-GATE>

## Blocking in async is corruption, not slowness

In an async context, these block the runtime and must not appear: synchronous file/network IO, `std::thread::sleep`, long CPU work (> ~100µs), synchronous channel recv. Route them: async equivalents (`tokio::fs`, `tokio::time::sleep`) → `spawn_blocking` for chunky sync work → a dedicated writer task fed by a channel for serialized IO.

## Bounded concurrency

Enforce the cap where tasks are CREATED (owned semaphore permit acquired before spawn, held for the operation's duration) or via a bounded combinator (`buffer_unordered`). A cap checked anywhere else is decorative.

## Shared state discipline

- Lock scope minimal; never hold a guard across an `.await` (even where it compiles).
- Two writers to one resource → prefer a single owner task fed by a channel over a shared lock; locks are for short critical sections, not workflows.
- Every piece of shared mutable state names its synchronization mechanism in a comment or type.

## Test the invariants

- Counts: results exactly partition inputs (ok + failed == total), asserted in a test, not a manual run.
- Cap: track concurrent-entries high-water mark in a test double; assert ≤ limit.
- Determinism of aggregates despite nondeterministic completion order.

## Rationalization table

| Excuse | Reality |
|---|---|
| "It's a batch CLI, no cancellation needed" | Then SAY that in the report — it's a policy, and stating it costs one line. |
| "The counts looked right across my runs" | Completion-order bugs are timing-dependent. Runs prove nothing; a test pins it. |
| "One quick std::fs write won't hurt" | Every blocked worker thread stalls every task scheduled on it. Route it properly. |
| "spawn and move on — errors are logged" | Unawaited tasks swallow panics silently. Someone owns every task. |

## Red flags

- A `spawn` whose handle nothing awaits.
- A lock guard alive across an `.await`.
- `std::fs`/`std::thread::sleep` inside `async fn`.
- A concurrency cap that isn't attached to task creation.
- "Done" with zero tests exercising concurrent execution.

## Per-language notes

See `references/<language>.md`.
