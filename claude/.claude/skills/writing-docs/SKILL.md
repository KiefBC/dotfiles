---
name: writing-docs
description: Use when creating or updating READMEs, doc comments, API documentation, or onboarding docs, when code is about to be shared, published, or handed to a team, or when a task is "done" but public items or the project front door are undocumented.
---

# Writing Docs

## Overview

API-doc-comment instinct is reliable; the front door is what gets skipped. Rendered API docs answer "how do I use item X" — they never answer "what is this, why does it exist, is it maintained, how do I try it in 30 seconds." Those are different documents.

<HARD-GATE>
Code that will be shared, published, or handed to a team gets a README (or equivalent index page) with all four slots:
1. **What** — one sentence, no jargon.
2. **Why** — the problem it solves / when to reach for it (and when not).
3. **Quickstart** — copy-paste runnable: install + smallest working example.
4. **Status** — maintained? stable? experimental? who to ask.
"The rustdoc/godoc/typedoc is the idiomatic documentation, no separate files needed" does not satisfy this — the teammate browsing the repo never runs the doc generator.
</HARD-GATE>

## Doc comments (every public item)

- First line = one-sentence summary (tools truncate to it in listings).
- Document what the SIGNATURE cannot say: errors (`# Errors`), panics, invariants, units, byte-vs-char semantics, unicode behavior, complexity, thread-safety. A doc that restates the signature is noise.
- Examples must RUN. Doctests where the language supports them (Rust doctests, Go `Example` funcs with `// Output:`, `pytest --doctest-modules`); where there's no native runner (TypeScript, C++), the example is untested code — copy it from a real test.
- Enforce mechanically, not by review: `#![deny(missing_docs)]` (Rust), revive `exported` (Go), ruff `D` rules (Python), TypeDoc `--validation.notDocumented` (TS), `WARN_IF_UNDOCUMENTED` (Doxygen).

## Mode discipline (Diátaxis as a lens, not a folder tree)

Tutorial (learning), how-to (task), reference (lookup), explanation (understanding) — don't blend modes in one document; a quickstart that detours into design rationale serves neither reader. Don't impose the four-folder tree on a small project; a README + API docs is a complete doc set for most libraries.

## Placement and staleness

- Docs live next to what they document — doc comments over wiki pages, `docs/` in-repo over external tools. Doc updates ride the same PR as the code change.
- A stale example is worse than no example. Runnable examples (doctests) are the staleness defense: they break in CI when the API changes.

## Red flags

| Flag | Fix |
|---|---|
| "Done" and public items lack docs | Not done. Run the mechanical check. |
| README missing while API docs polished | The front door is the gate, not a bonus |
| Example was never executed | Make it a doctest or copy from a passing test |
| Doc restates the signature ("Returns the name" on `name()`) | Document the non-obvious or nothing |
| Adding `llms.txt` unprompted | Contested, low-fetch in practice — only on explicit request |

Per-language doc tooling versions and flags: see [references/ecosystem.md](references/ecosystem.md).
