# ADR Ecosystem Reference (verified July 2026)

Version-sensitive and settled-vs-contested facts backing SKILL.md. The skill's timeless rules (immutable-and-supersede, one decision each, ~1 page) stand on their own; this file pins tool maintenance state and template versions, which is exactly where training data misleads.

## Tooling maintenance state (the #1 thing to get right)

| Tool | State | Detail |
|---|---|---|
| **adr-tools** (npryce) | **Frozen, NOT maintained** | Last master commit **30 Mar 2020**; release **3.0.0 (2020)**. Repo not archived, so search/LLMs wrongly infer "active" from stray issue activity. Still works (numbered md files + index symlink). Fine to use — describe as "stable/frozen," never "actively maintained." |
| **log4brains** (thomvaill) | **Maintained** | Node CLI + static-site generator; searchable knowledge base; interactive `log4brains adr new`. Latest **1.1.0 (17 Dec 2024)**, ~1.5k stars. Current recommendation for a *published/browsable* ADR site. MADR-derived default template. |
| **adr-log** | Maintained | Generates `index.md`. |
| **ADR Manager** | Maintained | Web + VS Code extension, form-based editing, GitHub integration. |
| **Backstage ADR plugin** | Maintained | Org-wide ADR search in the Backstage portal — the enterprise/discoverability play. |
| **pyadr / dotnet-adr / adr.zone / ADG** | Various | Language-specific CLIs; adr.zone emits Nygard/MADR/Y-Statement/ISO-42010. Most MADR ecosystem tools pinned at **2.1.2-era** templates, lagging 4.0. |

**No tool is required at all:** `mkdir docs/adr && $EDITOR docs/adr/0001-title.md`. Recommend by intent: files-in-git for most repos; log4brains for a published site; Backstage for org-wide discoverability. Don't reflexively reach for adr-tools because it's famous.

## Template families (settled: multiple coexist by design — no single winner)

| Template | Version / origin | Shape | Best for |
|---|---|---|---|
| **Nygard classic** | 2011, the original | Title · Status · Context · Decision · Consequences (both +/−) | High-volume, low-ceremony. Endorsed on Fowler's bliki ("typically a single page"). This skill's default. |
| **MADR** | **4.0.0, 17 Sept 2024** | YAML frontmatter + Context/Problem · Decision Drivers · Considered Options · Decision Outcome · Consequences · **Confirmation** · Pros/Cons per option · More Info | Contested/expensive decisions; teams that write weak Consequences sections. |
| **Y-statement** (Zimmermann) | complement, not replacement | one sentence (below) | The lightweight high-volume end; often a one-line summary *inside* an ADR. |

**Y-statement grammar** (the "Y" = wh**y**; forces rationale + rejected alternatives):
> In the context of \<use case\>, facing \<concern\>, we decided for \<option\> and against \<alternatives\>, to achieve \<benefits\>, accepting that \<downsides\>.

Also extant but rarer: Tyree & Akerman (heavyweight), ISO/IEC/IEEE 42010-aligned (formal/regulated).

### MADR version lineage (don't cite stale structure)
- **2.x → 3.0.0 (Oct 2022):** merged separate "Positive Consequences"/"Negative Consequences" into **one Consequences list**. Do not cite the old split.
- **4.0.0 (Sept 2024):** mostly template hygiene — HTML-comment placeholders `<!-- -->` instead of `{curly}`, re-added quotes around the chosen option — **plus the rename "Architectural" → "Any" Decision Records** (MADR now positions for any decision). *Not* a structural overhaul. Ships 4 files: `-template` (full+guidance), `-minimal`, `-bare`, `-bare-minimal`.
- **Confirmation** section (how compliance is verified/enforced) is MADR's distinguishing section, absent from Nygard.

**Contested edge:** MADR's extra structure (Decision Drivers, per-option Pros/Cons, Confirmation) is **discipline or bureaucracy depending on team maturity** — helps teams with weak Consequences sections, overhead for teams already writing good Nygard ADRs. A genuine trade-off, not "MADR is better." Default to Nygard-minimal or MADR-minimal; reach for MADR-full only when genuinely contested.

## Granularity (contested but converging)

Write an ADR when the decision is **architecturally significant**: costly to reverse, affects structure / cross-cutting qualities / external interfaces / dependencies, or a future maintainer asks "why on earth is it like this?" Google Cloud triggers: no documented solution exists, reasoning isn't recorded, multiple viable options existed. **One decision per record** is near-universal.

Contested — *how low to go*: some teams log a handful of structural choices; **AWS reports 200+ ADRs** logging liberally including config/product choices. No right number; failure modes are symmetric (too coarse loses rationale, too fine goes unread/unmaintained). Bias toward more/smaller ADRs captured cheaply (Y-statements/minimal templates), reserve full templates for the significant.

## Lifecycle (settled convention)

- **Immutable once accepted** — never edit an accepted ADR's decision; supersede with a new one. The most common thing done wrong.
- Status flow: **Proposed → Accepted / Rejected**; **Deprecated** (no longer applies, nothing replaces); **Superseded by ADR-NNNN**. MADR spells it literally: `superseded by ADR-0123`.
- **Link both directions:** new ADR "Supersedes ADR-0007"; old ADR "Superseded by ADR-0012." Never delete/rewrite obsoleted or Rejected ADRs — the historical "why we changed our mind" / "we rejected X" is the whole point (stops re-litigation).

## Storage (settled, minor variation)

- **`docs/adr/`** (also `doc/adr/`, `docs/decisions/`), one md per decision, `NNNN-title-with-dashes.md`. 4-digit zero-padding common; **3-digit `NNN-` is fine and what this skill names.**
- Keep ADRs **close to the code they govern** (same repo/VCS) — docs-as-code, echoed by Google Cloud, AWS, log4brains. Monorepo may scope per-service.
- Index/log (`docs/adr/README.md` or `index.md`) listing all with status is standard (hand-maintained or `adr-log`/log4brains).
- First ADR conventionally **0000 or 0001 "Record architecture decisions"** — the meta-ADR (MADR's own `0000` template).
- **Linking from code:** reference the *number* at the non-obvious site (`// See ADR-0007: we poll instead of webhook because …`) — highest-value link, catches the reader at confusion. Also PR/commit messages (`Implements ADR-0012`). Number is a durable identifier (immutable); prefer it over line/path that drifts.

## Vendor guidance is mainstream and current (ADRs are settled, not fringe)

- **AWS Prescriptive Guidance** full ADR guide + 2024 Architecture Blog "best practices" drawn from 200+ ADRs.
- **Azure Well-Architected Framework** added ADRs as recommended practice (Nov 2024).
- **Google Cloud Architecture Center** standing ADR overview (markdown-near-code, living-document framing).
- All are minor Nygard/MADR variations — nothing proprietary to learn.

## AI/agent shift (genuinely new, still shaking out)

- **AGENTS.md ≠ ADR** — some 2026 commentary calls it "the new ADR," **overclaimed**. AGENTS.md is prescriptive current-state instruction for agents; ADRs are immutable historical *why*. Complementary; don't conflate.
- **LLM-generated ADRs** (adr-agent, AgenticAKM pipelines, vendor writeups) draft ADRs from diffs/codebases. Value of an ADR was always the *thinking* — auto-generation can shortcut it; **human remains decider/approver**, AI is drafting aid.
- **Machine-readable ADRs** (`structured-madr`: YAML frontmatter + JSON Schema + CI validator) — emerging, not standard.

## Notable deltas vs stale assumptions

1. **adr-tools frozen since 2020** (last commit 30 Mar 2020) — don't call it maintained; commit history is ground truth.
2. **MADR is 4.0.0 (Sept 2024)** and means **"Any"** Decision Records; don't cite 2.x split-consequences structure.
3. **MADR 3.0 merged Positive/Negative into one Consequences**; MADR adds **Confirmation** (absent from Nygard).
4. **log4brains v1.1.0 (Dec 2024)** is the maintained published-site tool, not adr-tools.
5. **No single canonical template** — Nygard, MADR, Y-statements coexist; picking is a stakes/maturity trade-off.
6. Major clouds (AWS, Azure WAF, Google Cloud) publish **current** ADR guidance.
7. **AGENTS.md ≠ ADR**; AI can draft ADRs but can't own the decision.

## Key sources (all consulted July 2026)

- github.com/adr/madr + adr.github.io/madr/ (4.0.0 = 17 Sept 2024; 3.0.0 = 9 Oct 2022)
- adr.github.io/adr-tooling/ ; github.com/npryce/adr-tools (last commit 30 Mar 2020)
- github.com/thomvaill/log4brains (v1.1.0, 17 Dec 2024)
- martinfowler.com/bliki/ArchitectureDecisionRecord.html (Nygard)
- ozimmer.ch + medium.com/olzzio/y-statements (Y-statements)
- AWS Prescriptive Guidance ADR guide + 2024 "Master ADRs" blog (200+ ADRs)
- Azure WAF (ADRs, Nov 2024); Google Cloud Architecture Center ADR page
- joelparkerhenderson/architecture-decision-record (template catalog)
- AI evolution: AgenticAKM (arXiv 2602.04445), adr-agent, zircote/structured-madr
