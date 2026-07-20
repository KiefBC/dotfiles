---
name: code-quality
description: Use when writing or modifying code under time pressure, urgency, or "just make it work" framing, and before claiming any code change is done, ready, working, or verified — especially quick fixes, demos, prototypes, hotfixes, and requests to not gold-plate or keep it minimal.
---

# Code Quality Under Pressure

## Overview

**Urgency changes scope, never verification.** A deadline is a reason to build less, not to check less. Cut features openly; never cut the proof that what remains works.

<HARD-GATE>
No "done", "ready", or "working" claim until ALL of:
1. Tests exercising the new behavior exist and pass.
2. The test-result line counting YOUR tests is quoted in your report.
3. The language's lint gate has been run (see references/).

This applies REGARDLESS of stated urgency. "Demo in 15 minutes" does not waive it — a 3-case test takes under one minute to write.
</HARD-GATE>

## Silently-wrong is worse than loudly-broken

Malformed or unexpected input must produce an unmistakable failure — an error, a panic with a message, a None. Never a plausible-looking default (0, empty, silently skipped input).

Failure-path audit before claiming done — for every unwrap/expect/index/unchecked arithmetic/parse:
- What input reaches this malformed?
- What does the caller observe when it does?

If the answer is "a value that looks like success," fix it or convert it to an explicit error before reporting.

## Signature check — before implementing

If the operation can fail but the requested signature cannot represent failure (returns a bare value, no Result/Option/error channel), flag it and propose the honest signature FIRST. Shipping the failure-blind signature is the requester's decision to make before code exists — not a caveat to disclose after.

If you cannot ask the requester (non-interactive run): implement the requested signature with loud failure (panic/exception with a message naming the input) — never a plausible default — and make this the leading caveat of your report, with the honest signature offered.

## Completion report — required shape, in order

1. **Verdict line:** DONE / DONE WITH CAVEATS / BLOCKED.
2. **Defects and limitations** — before any feature summary. Known-broken semantics lead the report.
3. What was built, briefly.
4. **Verification evidence:** the quoted test-result line and lint result.

## Verification evidence rules

- Quote the result line that counts *your* tests. Beware truncated output: e.g. `cargo test | tail` shows only the doc-test section, which is always "0 tests" — see references/ for per-language pitfalls.
- Build/compile success is type-checking, not verification.
- If no artifact executed the behavior, it is not verified — mental tracing does not count.

## Rationalization table

| Excuse | Reality |
|---|---|
| "Demo crunch — I kept it minimal" | Minimal means fewer features, not fewer checks. Shrink scope, keep proof. |
| "It's lenient rather than strict" | Lenient parsing that returns wrong values is not lenient. It is broken. |
| "Fine for a demo; harden later" | The demo is exactly where wrong output gets seen. "Later" is never scheduled. |
| "cargo build / tsc succeeds" | Compilation proves types, not behavior. |
| "Behavior checks out" (nothing ran) | No executed artifact = not verified. |
| "The user asked for this signature" | Then the user decides on the honest one — before you implement, not after. |

## Red flags — STOP and fix before reporting

- About to write "it's ready" with no test-result line to quote.
- A default value returned on bad input.
- A caveat being drafted to go *after* the good news.
- The word "later" attached to a correctness issue.

## Per-language gate commands

See `references/<language>.md` for the exact lint/test gate invocations and output pitfalls.
