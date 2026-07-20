---
name: advanced-testing
description: Use when implementing any feature or bugfix (before writing implementation code), and when testing code that has invariants, inverse pairs (encode/decode, serialize/parse, compress/decompress), state machines, parsers of untrusted input, concurrency, or performance promises — and before declaring any such code solid, tested, or reliable on example tests alone.
---

# Advanced Testing

## Overview

Example tests check the inputs you thought of. The bugs live in the inputs you didn't. When code has exploitable structure — an invariant, an inverse, an oracle — test the STRUCTURE over generated inputs. A hand-picked "tricky cases" list is bounded by the same imagination that wrote the bug.

<HARD-GATE>
1. **Test first.** For any feature or bugfix: write the test before the implementation, run it, and SEE it fail before writing code to pass it. (In compiled languages, the test failing to compile against a not-yet-existing function IS a valid RED.) A test that has never failed proves nothing — it may be testing nothing.
2. **Every bugfix starts with a reproducing test** — the exact triggering input, persisted, failing on the unfixed code. Fix ships with the test in the same change. This is the single most-skipped step under "quick fix" pressure.
3. Before writing tests for code matching any row of the decision table, NAME the matching technique and use it — or state explicitly why example tests suffice for this code. "I wrote thorough examples" is not a technique selection.
</HARD-GATE>

## The loop

RED (failing test — smallest one that expresses the requirement; if the decision table matches, make it a property test, not an example) → GREEN (minimal code to pass) → REFACTOR (tests stay green) → repeat. Tests and implementation may land in one commit; the test is *authored and run* first.

## Decision table

| Code structure | Technique | Rust tool (others: references/) |
|---|---|---|
| Inverse pair: encode/decode, ser/de, to/from | Round-trip property | proptest |
| Invariant output: sorted, balanced, non-negative, conserved | Invariant property | proptest |
| A slower/simpler correct version exists | Oracle property | proptest |
| Parses untrusted/external input | Fuzzing | cargo-fuzz |
| Large or intricate output a human can't eyeball | Snapshot | insta |
| Lock-free / interleaving-sensitive concurrency | Model checking | loom |
| Performance promise ("faster", "O(n)") | Benchmark | criterion |

## Property patterns (highest yield first)

- **Round-trip:** `decode(encode(x)) == x` for arbitrary `x`. Six lines. Finds escape collisions, boundary drops, encoding asymmetries.
- **Oracle:** `fast(x) == simple_obviously_correct(x)`.
- **Invariant:** for all inputs, the stated property of the output holds.
- **Idempotence:** `f(f(x)) == f(x)` where applicable.

Generators must span the REAL input space — arbitrary strings (Unicode included), empty, long, adversarial nesting — not a curated alphabet.

## Regression corpus is an asset

- proptest writes failing cases to `proptest-regressions/` — **commit that directory**; every found bug becomes a permanent test.
- cargo-fuzz maintains `fuzz/corpus/` — keep it; minimize and commit interesting entries.
- Any bug you fix by hand gets its exact triggering input persisted as a named test.

## Rationalization table

| Excuse | Reality |
|---|---|
| "I covered the tricky cases by hand" | Your tricky-list came from the same mind that wrote the bug. Generate inputs. |
| "It's simple code" | A 4-line unescape hid a 2-class round-trip bug. Simple is not correct. |
| "Property tests are overkill here" | One round-trip property is ~6 lines and runs 256 generated cases in milliseconds. |
| "The examples are all green" | Green examples prove the inputs you imagined work. Nothing else. |
| "I'll write the tests after — same coverage" | Tests-after describe what the code does, bugs included. Tests-first define what it must do. |
| "Too simple to test first" | The test costs 30 seconds and is the spec. Simple code breaks too. |
| "It's a one-line fix, no repro test needed" | Unprotected fixes regress silently — the most consistent gap observed across every baseline. |

## Red flags

- An encode/decode pair with no round-trip property over generated input.
- "Solid" or "thoroughly tested" where every test input was hand-typed.
- A fixed alphabet enumeration standing in for "arbitrary input."
- A bug fixed without its triggering input persisted as a regression test.

## Per-language tools

See `references/<language>.md` for current tools, setup, and corpus-persistence specifics.
