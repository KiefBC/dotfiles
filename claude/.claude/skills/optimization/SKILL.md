---
name: optimization
description: Use when asked to make code faster, reduce latency or resource usage, investigate slowness, or when a change is claimed to improve performance — including when the requester supplies their own diagnosis of what's slow.
---

# Optimization

## Overview

Performance work is measurement work. The requester's diagnosis — and yours — is a hypothesis until a measurement confirms it. Speed claims without numbers are stories.

<HARD-GATE>
No optimization edit until a written baseline measurement exists (tool, input, build profile, numbers). The final report must show before/after from the SAME harness. Applies even when the fix looks obvious.
</HARD-GATE>

## Workflow

1. **Reproduce & baseline:** measure the complaint on a realistic input. Release/optimized build. At least 3 runs — report median and spread, not one "~" number. Note cold vs warm.
2. **Diagnose:** if the bottleneck is readable in the code, say why you believe it dominates (complexity argument). If it is not readable within a few minutes of reading, PROFILE (see references/) — do not guess-edit.
3. **Change one thing** — or, if you bundle changes, either measure incrementally or label the attribution explicitly as reasoning, not measurement.
4. **Re-measure** on the same harness. Verify output/behavior unchanged (diff outputs, run tests).
5. **Report:** before/after numbers, harness description, what was changed and why it was the bottleneck, attribution honesty for bundles.

## Stopping rule

"Fast enough" is a number agreed with the requester (or stated by you and confirmable), not a feeling. When the number is met, stop — further optimization is unrequested complexity.

## Traps

| Trap | Rule |
|---|---|
| Debug-build timing | Optimized build only; debug numbers are fiction. |
| Single-run timing | ≥3 runs; median + spread. One run measures the OS, not the code. |
| Requester's diagnosis | A hypothesis like any other — verify before honoring it. |
| Microbenchmark DCE | The compiler deletes unused results; use black_box / real benchmark harnesses. |
| Aggregate attribution | Bundled changes measured once = unknown per-change effect. Say so, or measure each. |
| Cold-start conflation | Separate first-run (startup, IO cache) from steady-state numbers. |

## Red flags

- An edit to "hot" code with no baseline number written down anywhere.
- "Roughly/should be/probably faster" in a final report.
- Optimizing the code the requester pointed at without confirming it dominates.
- A speedup claim on a benchmark whose output nothing consumes.

## Per-language tooling

See `references/<language>.md` for profilers, benchmark harnesses, and build-profile setup.
