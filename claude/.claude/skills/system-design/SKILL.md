---
name: system-design
description: Use when about to build a new component, service, module, or feature from scratch, or when a task hands over requirements with open decisions about storage, state, interfaces, or failure behavior — especially under "just start coding", "we can figure it out as we go", or "don't overthink it" framing.
---

# System Design

## Overview

Design quality is not the risk — silent design is. Decisions about dependencies, durability, and failure policy made mid-implementation get disclosed as faits accomplis instead of reviewed as choices. The fix is cheap: externalize the design BEFORE the first line of implementation code.

<HARD-GATE>
Before implementation code, write the design down IN THE REPO — `DESIGN.md`, `docs/design/<topic>.md`, or the issue/PR body. Sized to the problem: 5–15 lines for a module, pages only for systems. It must cover the six slots below. "The code documents itself" and "I'll write crate docs after" do not satisfy this — post-hoc docs describe what was built; a design is reviewable before it is load-bearing.
</HARD-GATE>

## The six slots (short is fine; missing is not)

1. **Requirements + non-goals** — what must be true, and what you are deliberately NOT building (the YAGNI list is a deliverable, not an afterthought).
2. **Data flow** — what enters, what is stored, what leaves.
3. **State ownership** — for each piece of state: who is the source of truth, and what survives a restart.
4. **Interface sketch** — the signatures/endpoints the caller sees. Write the caller's code first.
5. **Failure modes** — for each dependency: what happens when it lies or dies, and WHO owns the policy (fail-open vs fail-closed is the caller's decision to make — surface it, don't bury it in a return type).
6. **Decisions needing eyes** — new dependency, durability/consistency level, storage schema, protocol: each is an automatic "surface before building" item. If one is hard to reverse or cross-cutting, it is ADR-shaped — record it per the architecture-decisions skill.

## Design-first vs prototype-first

Choose by RISK TYPE, not project size:

| Dominant risk | Move |
|---|---|
| Coordination (interfaces, other people/components depend on shape) | Design first |
| Feasibility (will this approach work at all?) | Throwaway spike first — value is the lesson, DELETE the code — then a short design |
| Both | Tracer bullet: production-quality thin slice end-to-end, kept — not the same thing as a prototype |

## Anti-patterns

| Anti-pattern | Reality |
|---|---|
| "Implementation manual" doc — how, without why/alternatives | The why and the rejected options ARE the design; the how is the code's job |
| Doc sized by template, not problem | Google's own guidance: 1–3 page mini-docs are the norm; 10–20 pages for genuinely large projects only |
| Designing in chat and building from memory | Chat evaporates. The repo artifact is the design |
| Resolving a requirements ambiguity by API shape alone | Name the ambiguity in the design so the requester can veto |

Tool/practice facts (spec-driven development, C4 status, doc sizing sources): see [references/ecosystem.md](references/ecosystem.md).
