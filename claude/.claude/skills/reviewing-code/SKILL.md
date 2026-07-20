---
name: reviewing-code
description: Use when reviewing a diff, pull request, patch, or another agent's code output, before approving, merging, or reporting review findings — especially when told it looks fine, the tests are green, or the merge is urgent.
---

# Reviewing Code

## Overview

A review is a verdict backed by **executed evidence**, not an impression. The changed lines are half the job; the other half is the input space of everything the change made possible.

<HARD-GATE>
No verdict until ALL of:
1. The change's intent is understood (description, tests, or asking) before reading the diff.
2. You ran the test suite yourself — regardless of who says it's green.
3. Every new or changed public function has been probed with executed adversarial inputs.
4. The working tree is restored to exactly how you found it.
</HARD-GATE>

## Process

1. **Intent pass** — what is this change supposed to do? What would break if it's wrong?
2. **Line pass** — data flow, error paths, edge cases, and regressions: what did the old code do that the new code doesn't?
3. **Input-space pass** — for every new/changed public surface, enumerate and EXECUTE probes: malformed input, boundary values, and semantically ambiguous cases (case variants, typos, missing vs. present-but-invalid). "This function is fine" without an executed probe is a guess, not a finding.
4. **Coverage pass** — green tests cover what they cover. State what they don't: which of your probe cases has no test?
5. **Restore** — leave the tree as you found it.

## Silent-wrong lens

The highest-yield probe target: new accessors, defaults, and fallbacks that collapse distinct situations into one answer (missing key vs. invalid value vs. legitimately false/zero). Ask: can the caller distinguish these? If not, that is a finding, even when each individual line looks correct.

## Findings report — required shape

1. **Verdict line first:** MERGE / MERGE AFTER FIXES / DON'T MERGE.
2. Findings ranked by severity (blocking / should-fix / nit), each with a **concrete, executed failure scenario** (this input → this observed wrong behavior) and the smallest fix direction.
3. **Doc links per finding:** every finding that involves a library, framework, or language API cites the canonical docs for that API (docs.rs for a crate like sqlx, MDN for web APIs, the library's official reference) so the reader can click through and understand the issue. Links must be resolved during this review — via context7 or a web fetch — and match the version the project actually uses (check the lockfile/manifest). Never cite a URL from memory. If no external API is involved, no links; do not pad.
4. What was checked and found sound — so "no blocking issues" is evidence-backed, not absence of effort.

"Nothing blocking" is a valid review. Do not invent findings to appear thorough, and do not pad with style nits when correctness findings exist.

## Red flags

- About to write "X is fine" without having executed a probe against X.
- Reviewing only the lines that changed, not the input space the change created.
- The requester's "looks good to me / tests are green / we're in a hurry" appearing in your reasoning about correctness.
- More style comments than executed probes.
- A doc URL in a finding that was not fetched and verified this session.

## Rationalization table

| Excuse | Reality |
|---|---|
| "It has tests and they pass" | Tests cover what they cover. Enumerate what they don't. |
| "Small helper, obviously fine" | Small helpers hide semantic collapses (TRUE parsing as false). Probe them. |
| "My job is the diff" | Your job is what the diff does to the system — including its new input space. |
| "They already skimmed it / they're in a hurry" | Their urgency is a constraint on scope, not evidence of correctness. |

## Per-language lenses

See `references/<language>.md` for language-specific review targets.
