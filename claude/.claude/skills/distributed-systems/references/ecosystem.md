# Distributed Systems Ecosystem Reference (verified July 2026)

Version-sensitive facts backing SKILL.md. Facts checked against primary sources (Fowler/Newman, AWS Builder's Library, Google SRE book, Stripe, gRPC, Prime Video). Vendor/survey numbers are directional — flagged inline. Treat as "as of early July 2026." Backs the two gates: don't-distribute-by-default, and every hop needs timeout + retry + idempotency.

## Monolith-first — named cases (the consensus has hardened)

The 2015–2020 "microservices = maturity" framing has **flipped** among thought leaders. The default answer to "should this be a separate service?" is **no** — a network call is a method call made slower, less reliable, and harder to debug.

| Source | Position |
|---|---|
| **Martin Fowler**, `MonolithFirst` (bliki) | "almost all the successful microservice stories have started with a monolith that got too big… almost all the cases where a system was built as a microservice system from scratch has ended up in serious trouble." Hosts the counterpoint (`dont-start-monolith`) too — the tension is deliberate |
| **Sam Newman** (*Building Microservices* 2e) | "Don't start with microservices. Start with a monolith you understand." Microservices are primarily an *organizational* scaling tool, not a maturity level |
| **DHH** (Oct 2025, X) | "The majestic monolith remains undefeated for the vast majority of web apps… It should be the absolute last resort" |
| **Shopify** | ~2.8M-line Rails "majestic monolith", >$100M/hr at peak, kept sane via **Packwerk** (enforced module boundaries / "packs") — a **modular monolith**. Existence proof that scale ≠ microservices |
| **Prime Video** (VQA team, 2023) | Moved a monitoring pipeline *from* distributed serverless (Step Functions + S3 intermediate storage) *to* a single process, cutting cost **~90%** (frame data passed in-memory instead of via S3) |

**Prime Video caveat (must state, don't overclaim):** this was **one team recollapsing one over-decomposed pipeline** — not Amazon abandoning microservices, not proof monoliths always win. Evidence that decomposition has real, sometimes dominant, per-hop cost; Prime Video's own conclusion was "case-by-case basis."

### Legitimate forcing functions for a real service boundary (require ≥1, named)
Independent **scaling** of a genuinely different resource profile (GPU/ML, memory-hungry batch); **team autonomy at org scale** (Conway; rough threshold ~100+ engineers); independent **fault isolation / blast-radius**; **divergent tech/compliance** (runtime, data-residency, regulatory); **independent lifecycle**. NOT valid: "might need to scale later," "best practice," "feels cleaner," "different domain."

### Survey/cost numbers — directional only, cite with a hedge
Circulating 2025–2026 figures: a claimed "CNCF 2025 survey" that **~42%** of orgs are consolidating services back; microservices infra cost **3.75–6x** a monolith; **~20–40%** feature-delivery slowdown for small/mid teams. **These are secondary blog aggregation, not verified primary survey PDFs** — cite as "widely reported" color, never as hard fact. The *qualitative* consolidation trend is well-attested; the *precise percentages* are not.

### Distributed monolith — the failure mode to prevent
Services split over the network but still tightly coupled: "the heaviness of monoliths, the complexity of microservices, few of the benefits of either." Smells: must **deploy together**; **shared database/schema** (biggest tell); **synchronous chains** N deep; one change **forces coordinated changes**; "lift-and-shift" split along layers (UI service, DAO service) not business domains. Meta-point: **if you can't cleanly separate the data, you found a module, not a service.**

## Retry / backoff / full jitter (AWS still canonical in 2026)

Primary: AWS Architecture Blog "Exponential Backoff And Jitter" (Marc Brooker) + Builder's Library. Exponential backoff **alone is not enough** — synchronized clients retry in lockstep (thundering herd); **jitter is the fix.**

| Variant | Formula | Verdict |
|---|---|---|
| **Full jitter** | `sleep = random(0, min(cap, base * 2^attempt))` | **Default** — what AWS SDKs ship; minimizes contention |
| Equal jitter | half backoff + jitter the rest | Slightly more total work; usually not worth it |
| Decorrelated jitter | `sleep = min(cap, random(base, prev*3))` | Comparable to full; fine choice |
| No jitter | — | Wrong |

Retry **only** transient/network/5xx/throttling. **Never retry non-retryable** (validation, 4xx, card declines) — burns budget.

### Retry budget (the under-taught guardrail — retries cause the outage without it)
Per-call retry policy is necessary but **not sufficient**. Uncoordinated retries turn partial degradation into a **retry storm / cascading failure**. Primary: **Google SRE book, "Addressing Cascading Failures."** Required guardrails at scale:
- **Retry budget / token bucket:** cap retries at a fraction of normal traffic (SRE: **~10–20%**, e.g. "60 retries/min per process"). Bucket empty → **fail fast**. The single most important safeguard beyond jitter.
- **Retry at exactly ONE layer** — multiple layers **multiply** (3 layers × 3 retries = up to 27 attempts).
- **Circuit breakers** — open on systemic failure, stop retrying, let downstream recover.

"Added retries with backoff+jitter" on a hot path *without* a budget/breaker is an availability risk, not a resilience win.

## Timeouts & deadline propagation (settled, under-taught)

- **Deadlines > timeouts.** A timeout is a per-hop duration; a **deadline** is an absolute point in time that **propagates across the whole call chain**. **gRPC** implements this natively — the caller's deadline travels through the context; converts absolute deadline → remaining-time duration per hop (sidesteps clock skew).
- **Budget model:** the top-level deadline is spent partly by each hop, which passes the remainder down, reserving time for its own work. Without propagation, inner services keep working on doomed requests (resource leak, cascading latency).
- **Evidence:** gRPC Deadlines guide; **Dropbox** reported that forcing every service to define deadlines "fixed whole classes of reliability problems."

## Idempotency (the load-bearing concept for gate #2)

Because exactly-once *delivery* is impossible, **idempotency is what makes retries and at-least-once safe.** No idempotency story → retries are a data-corruption engine.

### Stripe-style idempotency-key pattern (current canonical form)
- Client generates a unique key per logical operation — **V4 UUID or high-entropy random string** (Stripe: up to 255 chars), sent in an `Idempotency-Key` header.
- Server, **on first request, saves status code + response body keyed by that key regardless of success or failure**, and replays the stored response for any duplicate (including replaying 500s).
- **Mutating (POST) only** — meaningless on GET/DELETE.
- **Keys expire — Stripe drops them after 24h.** The retention window **must exceed your maximum retry horizon**.
- **Don't use sensitive/PII data as the key.**
- **IETF `Idempotency-Key` HTTP header draft** exists (generalizing Stripe's convention) — mention as "converging toward a standard header," **not yet an RFC** to cite as final.

### Robust server-side implementation (the part training data skips)
Store the idempotency key **in the same DB transaction as the business write** (dedup table, unique constraint on the key). On replay the unique-constraint violation short-circuits to the stored response. This makes "did the write happen?" and "have I seen this key?" **one atomic decision**, closing the check-then-act race where two concurrent retries both proceed. "We retry on failure" without a key + transactional dedup is a **latent double-charge/double-write bug**.

## Effectively-once framing (teach verbatim)

- **Exactly-once *delivery* is impossible** over an unreliable network — the **Two Generals Problem**: any ack can itself be lost.
- What you build is **at-least-once delivery + idempotent processing = effectively-once** ("exactly-once processing"). For idempotent ops there's *no observable difference* from exactly-once, and at-least-once is far easier.
- **Vendor "exactly-once" is at-least-once + idempotent/transactional processing on the consumer.** **Kafka EOS** (transactions + idempotent producer) is exactly-once *within Kafka's processing boundary* (read-process-write inside Kafka), **not** end-to-end across external side effects (payment, email). The moment the effect leaves the transactional boundary you're back to needing an idempotency key. Rewrite any "exactly-once" design as "at-least-once + idempotent consumer" and ask where the key lives.

## Outbox + CDC / Debezium (answer to the dual-write problem)

**Dual-write problem:** a service that must both commit local state and publish an event can't do both atomically across a DB and a broker — a crash between them leaves them inconsistent. 2PC/XA is the old, largely-rejected answer (poor availability, coupling).

**Transactional outbox:** write the event into an **`outbox` table in the same local DB transaction** as the business change — one atomic local transaction. A relay publishes outbox rows:
- **Polling** — simple, higher latency.
- **CDC** — read the DB transaction log. **Debezium is the de-facto standard** (2.5+ as of 2025; connectors for Postgres, MySQL, MongoDB, SQL Server), publishing to Kafka within single-digit ms of commit; ships a dedicated **outbox event router**.

**Critical caveat:** the relay is **at-least-once, not exactly-once → consumers must be idempotent** (ties back to gate #2). Also plan **outbox cleanup** (e.g. daily delete of rows older than N days). Any `db.save(); broker.publish()` as two separate ops is a dual-write bug → recommend outbox.

## Saga (settled pattern, evolving tooling)

Business transaction across multiple services (no shared DB, no 2PC) → **saga** = local transactions each with a **compensating transaction**. **Choreography** (event-driven, no coordinator; decoupled but emergent/hard to debug) vs **orchestration** (central orchestrator; clearer but a coupling point/SPOF). 2026 movement: **hybrid recovery is the recommended default** — retry transient failures first, compensate only on exhaustion/permanent failure. **Durable-execution engines (Temporal + peers) are eating hand-rolled sagas** — model the saga as a durable workflow in ordinary code (Go/Java/TS/Python). A single business op needing a saga across 3 services is a strong signal the boundary was drawn wrong.

## Service mesh in 2026 (contested — do not reflexively recommend)

Training data answers "service mesh?" with "Istio (sidecars) or Linkerd." The 2026 landscape:
- **Sidecars on the way out; sidecarless/eBPF ascendant.** **Istio Ambient mode** (sidecarless: shared per-node **ztunnel** for L4 mTLS + optional per-namespace **waypoint** Envoy for L7) reached **GA in 2025**, ~70% resource savings vs sidecars; commentary predicts >50% of new Istio installs on Ambient by end of 2026. **Cilium** (eBPF, no sidecar) is a major consolidation force.
- **Linkerd narrowing** — still sidecar-based, positioned on operational simplicity and eBPF-wary audit environments; legitimate but shrinking niche.
- **Stance:** a mesh is **infrastructure you adopt once you already have enough services to justify it — not a starting point.** For small/early systems it's premature complexity; get mTLS/retries/timeouts more cheaply in libraries/gateways. Meshes provide *transport* retries/timeouts but **not idempotency** — the app still owns gate #2. (Market-share predictions are vendor-adjacent — directional.)

## Deltas vs common (stale) training-data assumptions

1. **Microservices are NOT the modern default** — Fowler/Newman/DHH and industry practice swung to **modular-monolith-first**; distribution must be justified.
2. **"Exactly-once delivery" is impossible** (Two Generals). Correct: at-least-once + idempotent consumer = effectively-once. Kafka EOS is bounded to Kafka's boundary.
3. **Retries need a global budget / circuit breaker**, not just backoff+jitter — else they *cause* cascading failures.
4. **Timeouts must propagate as deadlines** across the chain (gRPC-style), decremented per hop.
5. **Full jitter is the default** (what AWS SDKs ship); the 2015 AWS post is still canonical.
6. **Dual writes need the transactional outbox** (local txn + Debezium/CDC), not 2PC and not `save(); publish()`. Relay is at-least-once → consumers still need idempotency.
7. **Idempotency keys stored in the same transaction as the business write** (transactional dedup), not check-then-act; Stripe's 24h retention + POST-only scope are the reference details; IETF header is a **draft**, not final.
8. **Service mesh shifting sidecar → sidecarless/eBPF** (Istio Ambient GA 2025, Cilium rising, Linkerd narrowing) and is **not a starting-point recommendation**.
9. **Prime Video case is real but narrow** (~90% savings on one recollapsed pipeline) — not proof monoliths always win.
10. **Circulating cost/% stats (42% consolidating, 3.75–6x cost)** are secondary-source — cite as "widely reported," never primary fact.

## Key sources

- Fowler *MonolithFirst* + counterpoint `dont-start-monolith`; Newman on when (not) to use microservices; DHH majestic monolith (Oct 2025)
- Shopify engineering "Under Deconstruction" / "Deconstructing the Monolith"; Prime Video "Return of the Monolith" coverage (The New Stack, DevClass)
- Stripe idempotency docs + blog; IETF Idempotency-Key header draft (httptoolkit)
- bravenewgeek "You Cannot Have Exactly-Once Delivery"; AWS "Exponential Backoff And Jitter" + Builder's Library
- Google SRE "Addressing Cascading Failures"; gRPC Deadlines guide
- Transactional outbox: Conduktor, Auth0, SeatGeek; Debezium docs; AWS Prescriptive Guidance (saga); Temporal
- Service mesh 2026: Linkerd benchmarks, Jimmy Song sidecar-vs-sidecarless, Istio Ambient GA coverage
