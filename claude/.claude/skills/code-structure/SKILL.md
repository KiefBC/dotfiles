---
name: code-structure
description: Use when adding code to an existing file or function, adding a feature, flag, mode, or output format to working code, or when a file keeps growing — especially in small tools, internal scripts, and requests framed as "nothing fancy," "quick addition," or "don't over-engineer."
---

# Code Structure

## Overview

**"Small" constrains the feature, not the shape.** Structure is not modules and traits — it is separability: computation you can call without I/O, and variants that meet at one seam.

<HARD-GATE>
Before adding code to an existing function, state that function's current responsibility in ONE sentence. If your addition does not fit the sentence, extract first — a named function in the same file is enough — then add.
</HARD-GATE>

## The second-variant rule

The SECOND variant of anything — output format, input source, backend, protocol — is the moment the seam must appear: one function computes the result; variant-specific functions render or handle it. Adding an `if mode {...} else {...}` branch inside an already-multi-purpose function is structural debt taken at the exact moment it is cheapest to avoid.

## Separability test

After your change, all three must hold:

1. The core computation can be called without argv/env/filesystem/network.
2. Each variant can be exercised against a fixed input in a persisted test.
3. No function needs the word "and" to describe what it does.

Extraction means a pure function and maybe a plain struct — NOT traits, generics, or new modules. Those wait for a third variant or a second caller. Over-abstraction is the same failure in the other direction.

## Machine-consumed output is a contract

If another program parses your output, that format is an API. It gets a persisted test (round-trip through a real parser, or a golden file) that fails when the format drifts. One-off manual verification protects nothing after this session ends.

## Rationalization table

| Excuse | Reality |
|---|---|
| "It's a small internal tool" | Small tools live longest and grow forever. The seam costs one function extraction now. |
| "They said nothing fancy — don't restructure" | "Nothing fancy" constrains the feature. A 100-line main() doing six jobs IS the fancy version. |
| "I verified it end-to-end manually" | Unrepeatable verification dies with your session. A consumed format needs a test that persists. |
| "Extracting is over-engineering" | A named pure function in the same file is not architecture. A trait with one impl would be. |

## Red flags

- A function whose honest description contains "and": parses args AND reads AND computes AND formats.
- A mode flag's if/else spanning dozens of lines inside a larger function.
- A binary where nothing can be tested without executing the binary.
- Output another program parses, with no test asserting its shape.

## Per-language layout

See `references/<language>.md` for idiomatic layout and boundary tooling.
