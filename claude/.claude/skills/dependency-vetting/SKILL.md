---
name: dependency-vetting
description: Use when adding, suggesting, or upgrading any dependency — including when the requester names a specific package ("I think there's a crate/lib for this") — and when deciding between pulling in a library and writing the code directly.
---

# Dependency Vetting

## Overview

A dependency is a long-term hire, not a snippet: you inherit its bugs, its maintenance state, its supply chain, and its transitive tree — for years. A requester naming a package is a lead to investigate, not a decision already made.

<HARD-GATE>
No dependency is added until the checklist below is answered IN YOUR REPORT. "The user suggested it" satisfies none of the items.
</HARD-GATE>

## The checklist

1. **Need:** does this require a dependency at all? Estimate the hand-rolled size. Under ~30 lines of std-only code (a backoff loop, a tiny parser, ANSI colors) → write it, with tests. Small utilities are cheaper to own than to hire.
2. **Alive:** last release date, recent commits, issue triage activity, archived/unmaintained advisories. A deprecated API inside the crate's own surface is a pulse reading — check the chart.
3. **Healthy:** download trend, bus factor (maintainer count), security history.
4. **Weight:** what does it drag in? (`cargo tree`, `npm ls`, `pipdeptree`) — transitive count and build cost.
5. **Alternatives:** the one or two other candidates — including hand-rolling — and one sentence on why this one wins.
6. **License:** compatible with the project.

After adding: run the ecosystem audit (see references/) so the advisory check is part of the change, not a someday.

## Rationalization table

| Excuse | Reality |
|---|---|
| "The user named the crate" | A lead, not a decision. They'll be gladder you checked than that you obeyed. |
| "It compiles and works" | Dormant deps work — until a CVE, a toolchain break, or an ecosystem shift. Check the pulse, not just the function. |
| "This is a solved problem, use the lib" | Solved in 15 lines of std, too. The lib solves it plus brings a dependency's lifetime costs. |
| "Keep it simple = don't write code" | An unmaintained dep with deprecated APIs is not simple. Simple is the least long-term surface. |

## Red flags

- `cargo add` / `npm install` / `pip install` as the FIRST action after reading the request.
- A dependency whose last-release date you never looked at.
- A report with no alternatives section — not even "write it ourselves."
- A utility dependency standing in for under 30 lines of logic.
- Noticing deprecations or warnings inside the dep and routing around them without asking what they signal.

## Ecosystem tooling

See `references/<language>.md` for audit commands and signal sources.
