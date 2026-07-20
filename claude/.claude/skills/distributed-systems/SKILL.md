---
name: distributed-systems
description: Use when splitting a service, adding a network call between owned components, introducing a queue or message broker, designing service boundaries, or when a task mentions microservices, "extract this into a service", or moving work off a monolith.
---

# Distributed Systems

## Overview

The expensive mistakes are made before any code: distributing what should stay in-process, then wiring network calls that assume the network is reliable. Turning a function call into a network call adds partial failure, latency, and ordering problems that did not exist a moment ago.

<HARD-GATE>
1. **Split-decision test FIRST — don't-distribute is the default answer.** Before extracting anything into a service, name the concrete driver: an independent *scaling* need, an independent *deployment* cadence, or a separate *team* that must own it end-to-end. "We want microservices" / "it's a different domain" is not a driver. Absent one, the boundary is a **module in the monolith** — same isolation, zero network failure modes. Creating a synchronous cross-service call with no driver is the distributed-monolith anti-pattern (worse than the monolith: coupled *and* over the network).
2. **Every network call between owned services states all three:** a **timeout** (a deadline, not the default infinity), a **retry policy** (full-jitter backoff, bounded by a retry budget), and an **idempotency story** (safe to run twice). Two of three is a latent outage.
</HARD-GATE>

## If you do split

- **Idempotency key** stored in the same DB transaction as the business write (dedup by insert, not check-then-act). Replay the stored response — including errors — on a duplicate key.
- **Retries** with full jitter, at exactly ONE layer (retrying at every hop multiplies load). Bound with a retry budget (~10–20% of traffic) + a circuit breaker, or retries cause the cascading failure they were meant to survive.
- **Timeout budget** is one end-to-end deadline propagated per hop (gRPC `grpc-timeout`, a `context.Context` deadline), not independent per-service constants that sum to minutes.
- **Delivery is at-least-once.** Exactly-once *delivery* is impossible; the real target is at-least-once + idempotent consumer = effectively-once. Vendor "exactly-once" (incl. Kafka EOS) stops at their boundary — your external DB/API side effects are not covered.
- **Never dual-write** (commit DB, then publish to a broker — the second can fail). Use the transactional **outbox**: write the event to an outbox table in the same transaction; a relay (CDC) publishes it. Consumers stay idempotent because the relay is at-least-once too.

## Red flags

| Flag | Reality |
|---|---|
| "It's a different domain, so a different service" | Domain nouns aren't a distribution driver. Modules split domains without the network. |
| A network call with no timeout | Default is infinite wait; one slow dependency hangs every caller. |
| Idempotency present, retry absent (or vice versa) | The trio is atomic — safe-to-retry is useless if nothing retries; retry is dangerous if not idempotent. |
| Synchronous call chain A→B→C→D | Every hop multiplies failure probability and latency; question the topology. |
| "We'll add reliability later" | The failure modes ship with the first call, not later. |
| DB write then broker publish | Dual write — use the outbox pattern. |

Monolith-first cases, jitter formulas, outbox tooling (Debezium/CDC), service-mesh status, idempotency-key spec: see [references/ecosystem.md](references/ecosystem.md).
