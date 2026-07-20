---
name: architecture-decisions
description: Use when making or reversing a technical decision that is hard to undo, affects multiple components, adds or rejects a dependency, chooses a storage format or protocol, or overrides a requester's suggested approach — and when anyone asks "why did we do it this way?"
---

# Architecture Decisions

## Overview

Decision quality is not the risk — decision *evaporation* is. Excellent reasoning delivered in a chat reply or PR comment is gone the moment the session ends; the next engineer re-litigates it or, worse, silently violates an invariant it established.

<HARD-GATE>
If the deserves-an-ADR test says yes, the ADR is part of the change — same commit/PR as the code, not a follow-up. Reasoning that lives only in the conversation does not count as recorded.
</HARD-GATE>

## Deserves-an-ADR test (any yes → write it)

- **Hard to reverse?** Storage formats, on-disk/wire protocols, public API shapes, dependency adoption or rejection.
- **Cross-cutting?** Establishes an invariant future code must honor (e.g. "all config writes go through the locked `update()` path — bypassing it reintroduces the race").
- **Surprising?** A future reader would ask "why?" — including every time you reject the obvious option or the requester's named suggestion ("SQLite probably?" → declined = automatic yes).

Low-stakes but worth a trace → one-sentence Y-statement in the ADR index instead of a full record.

## The record

`docs/adr/NNNN-title.md` (create the directory + `0000-record-architecture-decisions.md` meta-ADR on first use). Nygard shape, ~1 page max:

```markdown
# NNNN. Use advisory file locking instead of SQLite for config storage
Status: Accepted        Date: 2026-07-06
## Context      <!-- the problem + forces, 2-5 lines -->
## Decision     <!-- what we chose, active voice -->
## Alternatives considered  <!-- each named option + why rejected — this is the section people come back for -->
## Consequences <!-- good AND bad, plus invariants future code must honor -->
```

- **Immutable once accepted.** Change of mind = new ADR that supersedes, with bidirectional links ("Supersedes 0003" / "Superseded by 0007"). Statuses: Proposed / Accepted / Rejected / Deprecated / Superseded.
- **Link from the code** where the decision manifests: `// Locking protocol: see docs/adr/0004-file-locking-over-sqlite.md`. The ADR explains the code; the comment makes it findable.
- ADR ≠ design doc: a design doc proposes forward; an ADR records one decision after it is made. A design doc's contested choices often become ADRs.

## Rationalization table

| Excuse | Reality |
|---|---|
| "My report explains the reasoning" | The report is not in the repo. The next engineer never sees it. |
| "The code comments cover it" | Comments say what the code does; they don't preserve the rejected alternatives — which is the part that stops re-litigation. |
| "Too small for the ceremony" | The record is ~15 lines. Re-deriving "why not SQLite?" in six months costs more. |
| "I'll write it after merge" | After merge is never. Same commit or it doesn't exist. |

Tooling and template facts (MADR 4.0, adr-tools frozen, log4brains, cloud-vendor guidance): see [references/ecosystem.md](references/ecosystem.md).
