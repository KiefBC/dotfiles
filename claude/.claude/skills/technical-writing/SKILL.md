---
name: technical-writing
description: Use when writing prose a human will read to decide or act — design docs, proposals, PR descriptions, issue reports, announcements, postmortems, explanations — or when turning rough notes, bullets, or a chat thread into a document.
---

# Technical Writing

## Overview

Sentence-level prose is not the risk — structure is. The recurring failure: template-ordered documents where the reader's decision is buried at the bottom, sections exist because a template has them, and contradictions in the source material ship unresolved.

## The shape of a decision document

A proposal/design doc IS this, in order:

1. **Top block: conclusion + ask.** What you propose AND what the reader must approve/decide/do (headcount, review, access, sign-off) — on the first screen, not in section 7. If the reader stops after one paragraph they should still know what you want from them.
2. **Supporting sections, each earning its place for THIS reader.** If two sections carry the same fact (Estimate repeating Summary repeating Asks), delete all but one. A section the reader doesn't need for the decision is cut, however traditional.
3. **Alternatives with rejection reasons** — one line each is enough.

Turning notes into a doc is editing, not transcription:
- **Contradictions get resolved or flagged, never shipped.** Notes saying "maybe 2–3 weeks" and "1 eng for 3 weeks" become one number, or an explicit "estimate range: 2–3 weeks; ask is 3" — a doc requesting approval cannot carry two versions of its own ask.
- Missing load-bearing facts (owner, date, success criterion) get asked for or marked TBD-with-owner, not silently smoothed over.

## Other document anatomies

- **PR description:** lead with WHY (the diff already shows what); note anything a reviewer can't infer — tradeoffs, rejected approaches, follow-ups.
- **Issue/bug report:** numbered repro from a known state, expected vs actual, environment, reproduction rate. No narrative.
- **Review comments:** label intent (`suggestion:` / `issue (blocking):` / `nitpick:` / `question:`) so severity is machine- and human-parseable.

## Sentence-level pass (after the structure is right)

- One idea per paragraph; concrete numbers over abstractions ("2,880 calls/day, 98% empty" beats "inefficient"); define terms at first use; delete hedges ("fairly", "quite", "arguably") unless the uncertainty is the point.
- Slop tells to cut on sight: "delve", "crucial", "pivotal", "tapestry", "serves as", rule-of-three runs, negative parallelism ("not just X, but Y"), puffery, formulaic conclusions ("In conclusion, ..."), bold/bullet abuse where prose flows. (Em-dash frequency is contested — don't treat it as an AI tell; just punctuate normally.)
- Sentence-case headings, active voice, second person — the settled house style of both Google and Microsoft guides.

## Revision gate

Before sending, reread AS THE TARGET READER: can they make the decision from the first screen? Is every number in the doc consistent with every other occurrence of it? Does any section exist only because templates usually have one?

Style-guide and linter facts (Vale, ISO plain-language, guide status): see [references/ecosystem.md](references/ecosystem.md).
