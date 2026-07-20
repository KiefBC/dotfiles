---
name: ci-cd
description: Use when creating or editing a GitHub Actions workflow, setting up build/test/release automation, adding caching or secrets to CI, handling a flaky test in CI, or investigating why CI is red, slow, or flaky.
---

# CI/CD

## Overview

Flaky-test discipline is usually sound (quarantine, not retry-to-green). The reliable gaps are security defaults left off and CI drifting from local commands. Every workflow ships with a broad default token, and models emit action versions that no longer exist.

<HARD-GATE>
1. **Least-privilege token.** Every workflow has a top-level `permissions:` block. Default to `contents: read`; elevate a single job only where it genuinely needs to (e.g. `packages: write` to publish). Never rely on the default `GITHUB_TOKEN` scope.
2. **CI runs the same commands as local dev.** One source of truth — a `make ci` / `justfile` / npm script that both the workflow and a developer invoke — so they can't silently diverge.
3. **No green-by-retry.** A failing test is fixed or quarantined, never wrapped in a retry until it passes. `continue-on-error` is only for a segregated, visible, non-gating job — never to mask the main gate.
</HARD-GATE>

## Flaky-test policy: quarantine, don't hide

When a test fails intermittently and you can't fix it now:
1. **Diagnose first** — reproduce it (rerun on the fixed commit 20–50×). A test that fails under load is a real assertion bug, not noise.
2. **Quarantine** — move it out of the gating suite (`#[ignore]`, `test.skip`, a tag) with a comment saying why and how to re-enable.
3. **Keep it visible** — a separate non-gating job still runs it and surfaces a warning, so it can't rot silently.
4. **Track + fix** — quarantine is a debt marker, not a grave. Never delete-and-forget, never retry-until-green.

The required check stays deterministic; the flaky signal stays visible; merges never block on it.

## Action versions (models emit dead ones)

Old majors HARD-FAIL now, they don't warn:
- `upload-artifact@v3` / `download-artifact@v3` — removed; use **v4** (immutable, matrix names must be unique).
- `actions/cache@v1/v2` — legacy service shut off; use **v4**.
- `checkout`/`setup-*` — on **v4/v5** (Node 24 runners; Node 20 removed from runners in 2026).
- Prefer a setup-action's built-in cache or the ecosystem tool (`Swatinem/rust-cache`) over hand-rolled `actions/cache` of `~/.cargo` + `target`.

## Security & speed

- **SHA-pin third-party actions** (comment the version), not tags — the tj-actions/changed-files compromise (CVE-2025-30066) rewrote tags to leak secrets. Automate bumps with Dependabot; lint with `zizmor` + `actionlint`.
- **OIDC over stored cloud keys** — short-lived tokens, no long-lived secrets in CI.
- **Speed**: cache hit/miss is the top "CI slow" cause; add a `concurrency:` group to cancel superseded runs; use path filters and matrix builds; fail fast (fmt/lint before the slow build).

## Red flags

| Flag | Fix |
|---|---|
| No `permissions:` block | Add least-privilege `contents: read` |
| `continue-on-error: true` on a real job to get green | That's hiding failure — quarantine the specific flaky test instead |
| `upload-artifact@v3`, `cache@v2` | Dead versions — bump to v4 |
| Third-party action pinned to a tag | SHA-pin it |
| Copy-pasted workflow from another repo | Re-derive from the local commands; strip unused jobs |
| Retrying a test to make CI pass | Diagnose + quarantine; never retry-to-green |

Action-version specifics, cache configs per language, OIDC setup, runner facts: see [references/ecosystem.md](references/ecosystem.md).
