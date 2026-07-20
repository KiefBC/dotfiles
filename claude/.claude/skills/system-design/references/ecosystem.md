# System-Design Ecosystem Reference (verified July 2026)

Version-sensitive and settled-vs-contested facts backing SKILL.md. The skill's timeless advice (six slots, YAGNI) stands on its own; this file pins the *current-practice* claims and the places training data is stale.

## The load-bearing rule (sourced numbers)

"As short as possible and as long as necessary" — **over-ceremony is the more common real-world failure, not under-ceremony.** Google's *Design Docs at Google* (industrialempathy.com — still canonical, unchanged) gives numbers to quote precisely:

| Artifact size | When |
|---|---|
| **1–3 pp "mini design doc"** | incremental improvement / subtask |
| **10–20ish pp** | genuinely *large* project only |
| **20+ pp** | named anti-pattern ("nobody reads it, big surface for opposition"), not an aspiration |
| **No doc** | solution obvious with minimal trade-offs, OR rapid prototyping is the faster answer |

Scoping rule (drmorr / Stripe-lineage): a good doc **answers 1–3 closely related technical questions**. The **"implementation manual"** (all *how*, no *why / what-else / what-if*) is Google's named signal you should be coding, not writing.

## Artifact hierarchy — distinct, not interchangeable

Per Pragmatic Engineer survey (80+ companies incl. Google, Uber, Amazon, Stripe, Shopify; **Meta is the deliberate holdout** that minimizes this documentation):

| Artifact | Written | Scope | Length |
|---|---|---|---|
| One-pager / mini design doc | before code | one question | ≤1–3 pp |
| Design doc / RFC | before code | non-trivial design, solicit feedback | 1–20 pp |
| ADR | at/after decision | one decision + rationale, immutable | ~1 pp |
| Amazon PR/FAQ (6-pager) | before build | product "working backwards" narrative | 6 pp hard cap |

- **RFC vs design doc**: effectively synonyms; "RFC" connotes broad cross-team/company-wide solicitation, "design doc" a single team's plan. RFC flavor triggers when the change crosses team boundaries or many stakeholders.
- **ADR ≠ design doc** (models routinely conflate): a design doc explores/proposes *forward*; an ADR records *why one call was made*, immutably, after the fact. Design doc's "Alternatives Considered" can graduate into ADRs. Full ADR facts: architecture-decisions skill.

## Google's canonical section set

Context/Scope → **Goals & Non-Goals** → The Actual Design (organized around trade-offs, not a component tour) → **Alternatives Considered** (the single best signal separating a design doc from an implementation manual) → Cross-Cutting Concerns (security, privacy, observability, + today: data residency, cost, operability/on-call).

- **Non-Goals is the highest-leverage, most-skipped section** — where scope/YAGNI is discharged cheaply.
- **Google's list does NOT call out state ownership explicitly** — a real gap the skill adds value on.

## Prototype vs tracer bullet — precise terms, don't blur

| Term | Kept? | Use when dominant risk is |
|---|---|---|
| **Prototype / spike** | No — throwaway; the *lesson* is the value | Feasibility / unknown-unknowns (is this UX/algorithm/library viable?) |
| **Tracer bullet / walking skeleton** | Yes — production-quality thin end-to-end slice | Architecture/integration risk |

Decision rule is **risk type, not project size**. Named failure ("the prototype pitfall", Atwood): throwaway prototypes get shipped because they "already work." Many real tasks want a spike *and* a 1-page doc.

## C4 — current and rising, not legacy

- Four levels: **Context, Container, Component, Code.** De-facto lightweight standard ("thousands of teams"). **Simon Brown's C4 book republished via O'Reilly July 2026** — actively maintained, cite as current.
- **Contested edges to surface:** (1) **Level 4 (Code) diagrams widely considered not worth maintaining** — they drift instantly; most stop at Container + Component. (2) C4 is **diagrams-only** — deliberately omits quality requirements, cross-cutting concerns, risk; not a complete doc method. Common 2025 pattern: **arc42 (doc structure) + C4 (diagrams inside it)**, per arc42 FAQ B-17 — complementary, not competing.
- Diagrams-as-code route: Structurizr (Brown's own "C4 as code"), PlantUML, Mermaid — but the C4 FAQ stresses any drawing tool is fine; don't oversell tooling. Full diagram-tool facts: diagramming skill.

## Failure-mode design (current framing)

Table-stakes design-time pairing: **retries + idempotency** on any write path. Also: timeouts/partial failure, backpressure, blast radius (degrade vs hard-fail), observability designed in not bolted on. **Pre-mortem** ("it's six months later and this failed — why?") is the standard lightweight surfacing technique, cheaper than formal FMEA.

## Over-designing critique — the corrective a model most needs

- **YAGNI governs.** Recurring operational rule: **Rule of 3** — don't introduce an abstraction until the third real use case (Yusuf Aytas 2026 and many).
- Over-engineering ≡ designing for hypothetical futures / speculative scalability / "just in case." A too-long doc *institutionalizes* it. DRY taken too far → "code so abstracted it's unmaintainable."
- The eager-model failure mode is adding speculative generality; the Non-Goals section is where that pressure discharges cheaply.

## Spec-driven development (SDD) — the 2025–2026 shift likely missing from training data

- **What:** spec/design is the durable artifact; code is the *build output* ("like .c compiling to binaries"). Emerged **2025 as the answer to "vibe coding"** (agents produce plausible code that drifts from intent). Thoughtworks named it a key 2025 practice.
- **Tooling (fast-moving, July 2026):** **GitHub Spec Kit** (launched Sept 2025, **>90k stars, 30+ agent integrations**), AWS Kiro, Claude Code, Cursor, OpenSpec, BMAD, Tessl, Google Antigravity. Typical shape: requirements → design/plan → tasks as Markdown files the agent consumes.
- **Why it matters here:** *raises* the value of upfront interface sketch + acceptance criteria + non-goals when an agent (context-blind) writes the code — same discipline this skill teaches. Right-sizing still applies: a spec for a one-line change is the same over-ceremony mistake.
- **Do not overclaim:** vendor ROI (GitHub "~order-of-magnitude fewer regenerate cycles"; AWS Kiro "40-hour features in <8 hours") is **self-reported, not independent benchmark** — cite as vendor claims.

## Notable deltas vs stale assumptions

1. Consensus is **"often skip the doc,"** not "always write one." Obvious-solution / rapid-prototype escape hatch is in Google's own guide.
2. Quote **10–20 pp large, 1–3 pp mini, 1–3 questions**; 20+ pp is an anti-pattern.
3. **ADR ≠ design doc** — models merge them.
4. **C4 current and rising** (O'Reilly book July 2026), but stop at Container/Component; diagrams-only (pair with arc42).
5. **Prototype (throwaway) ≠ tracer bullet (kept, production-quality)** — choose by risk type.
6. **SDD is the major shift** and likely absent from training data; vendor ROI numbers are self-reported.

## Key sources (all consulted July 2026)

- industrialempathy.com/posts/design-docs-at-google/ (page counts, when-to-write)
- blog.pragmaticengineer.com/rfcs-and-design-docs/ (80+ companies; Meta holdout)
- blog.appliedcomputing.io/p/writing-better-design-docs (1–3 questions; "implementation manual")
- c4model.com + c4model.com/faq; O'Reilly C4 book (July 2026); arc42 FAQ B-17
- Atwood "The Prototype Pitfall"; Pragmatic Programmer (tracer bullet / walking skeleton)
- Thoughtworks & Microsoft SDD writeups; GitHub Spec Kit; arXiv SDD survey (2602.00180)
- workingbackwards.com (Amazon PR/FAQ 6-pager); Yusuf Aytas "Why Over-Engineering Happens" (Rule of 3)
