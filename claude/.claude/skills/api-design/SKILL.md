---
name: api-design
description: Use when adding, changing, or removing anything on a public surface — library APIs, service endpoints, CLI flags, config formats, machine-consumed output schemas — or when choosing the version number for a release containing such changes.
---

# API Design

## Overview

A public surface is a promise. Every change gets classified before it ships — break, extend, or fix — and the version number IS that classification, not a counter. Requested urgency ("ship it in this week's patch") never changes what bucket a change belongs to.

## Change classification — decide FIRST

| The change | Bucket | Version |
|---|---|---|
| Alters existing documented/tested behavior | BREAKING | major |
| New API or opt-in behavior; old paths byte-identical | Additive | minor |
| Restores documented behavior (bug fix) | Fix | patch |
| "Make X the default" where X changes existing outputs | BREAKING, however small | major — or deliver opt-in now (minor) and leave the default flip as major work |

The standing escape hatch when a breaking change is requested on a patch/minor timeline: **deliver the capability additively** (new function, option, builder), keep the old path untouched, and return the default-change decision to the requester as explicit major-version work.

## Design rules

- Smallest surface that serves the need — adding later is cheap, removing is a major version.
- Failure is part of the contract: error types, exit codes, and error messages that scripts match on are documented like return values.
- Build in room to grow: `#[non_exhaustive]`, builders/options objects, keyword-only parameters — so the next feature is additive too.
- Every public item documented at introduction, with examples that compile (doctests where the language has them).
- Deprecate before removing: mark it, point at the replacement, remove at the next major.
- No bare `bool` parameters on public functions — call sites become unreadable; use an enum or options type.

## Verification before release

- Claiming additive/patch → existing tests are untouched AND passing; run the ecosystem's API-diff tool (see references/).
- Behavior claims verified against the documented contract, not the implementation.

## Red flags

- A version bump chosen by feel ("small change = patch").
- An existing test edited to make an "additive" change pass.
- A public item shipped undocumented ("we'll document later").
- Deleting or renaming anything public outside a major version.

## Tooling

See `references/<language>.md` for API-diff and semver-check tools.
