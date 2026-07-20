---
name: debugging-toolchain
description: Use when investigating a bug, crash, flake, or unexpected output — especially "sometimes fails", "only in CI", reports that come with a suggested cause ("probably X"), or requests for a quick fix to unblock something.
---

# Debugging

## Overview

A fix without a demonstrated root cause is a guess that compiled. The reporter's hypothesis ("probably the file reading?") is part of the symptom description, not a diagnosis — weight it accordingly.

<HARD-GATE>
1. Reproduce the failure yourself before editing anything. Flaky? Run it in a loop (N ≥ 10) and capture outputs. Cannot reproduce = that IS the finding; do not fix blind.
2. The bug's exact trigger becomes a persisted regression test — one that FAILS on the old code — before "fixed" is claimed.
</HARD-GATE>

## Process

1. **Reproduce** — see it fail with your own run, and record what you saw.
2. **Root-cause the mechanism** — not the location: the sequence of events that produces the wrong output. Instrument deliberately (targeted logging at boundaries, a debugger at the suspect point) — never shotgun prints without a hypothesis each one tests.
3. **Fix the mechanism, not the symptom.** If the root cause exposes a requirements ambiguity (a tie with no defined winner, an undefined ordering), fix deterministically AND surface the ambiguity as a question — silently choosing semantics is how "fixed" bugs return as behavior disputes.
4. **Regression test** — the trigger, persisted, failing-on-old-code.
5. **Verify** — the original reproduction now passes; keep the evidence.

## Report shape

1. Root cause: the mechanism in one paragraph, with the evidence that confirmed it (including how you reproduced it, and how many runs).
2. The fix, and why it kills the mechanism.
3. Regression test: name + result, and that it fails against the old code.
4. Verification evidence.
5. Anything the bug exposed: ambiguities, sibling bugs, missing invariants.

## Instrument selection

| Situation | Instrument |
|---|---|
| Wrong value at a known point | Debugger breakpoint / targeted `dbg!` |
| Unknown location | Boundary logging: log at layer seams, halve the search space |
| "Used to work" | `git bisect run` with the reproduction script (exit 125 = skip) |
| Nondeterministic output | Run-loop capture; usual suspects: hash-order, time, uninitialized state, races |
| Hang | Stack sample / debugger attach; async: tokio-console |
| Memory / UB | Sanitizers — with platform caveats (see references/) |

## Rationalization table

| Excuse | Reality |
|---|---|
| "The cause is obvious from reading the code" | Then reproducing costs one minute and upgrades a theory to a fact. |
| "It's flaky — hard to reproduce" | Flaky means run it 20 times in a loop. That IS the reproduction. |
| "A regression test is overkill here" | This code already regressed once — that's why you're here. |
| "Quick fix now, understand later" | Symptom fixes return with interest, usually at a worse time. |

## Red flags

- Editing before reproducing.
- "Fixed" with no new failing-on-old-code test.
- The reporter's guess steering the fix without evidence for it.
- Print statements that no hypothesis asked for.

## Per-language instruments

See `references/<language>.md`.
