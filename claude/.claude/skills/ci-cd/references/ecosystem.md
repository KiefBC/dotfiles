# CI/CD Ecosystem Reference (verified July 2026)

Version-sensitive facts backing SKILL.md. Scope: GitHub Actions. The recurring training-data hazard is emitting action versions that **hard-fail** (not warn) and shipping security defaults that 2025's supply-chain attacks made obsolete. Verify a pinned SHA at authoring time — SHAs are load-bearing here.

## Action versions: DEAD vs current

Old majors HARD-FAIL now — treat as build-breakers, not deprecation warnings.

| Action | DEAD | Current | Notes |
|---|---|---|---|
| `actions/upload-artifact` | **v3** (removed Jan 30 2025) | **v4** | v4 artifacts **immutable**; not v3-compatible. Exception: GHES still supports v3. |
| `actions/download-artifact` | **v3** (removed Jan 30 2025) | **v4** | Cannot download a v3 artifact with v4 or vice versa. |
| `actions/cache` | **v1, v2** (service off ~Apr 15 2025); v3 EOL-track | **v4** (v4.2.0+) | Legacy cache backend rewritten; `@actions/cache` npm pkg < 4.0.0 also stopped working. |
| `actions/checkout` | v3 (Node16/20-era, deprecation noise) | **v5** (v5.0.0, Aug 11 2025; Node 24) | v5 needs runner **≥ v2.327.1**. v4 still works/maintained. |
| `actions/setup-node` | v4 and older | **v5** (also v6 shipping; Node 24) | v5+ auto-caches when `packageManager` set in package.json. |
| `actions/setup-python` | v5 (ran on now-deprecated Node 20) | **v6** (Node 24) | |
| `actions/setup-go` | older | **v5** (Node 24) | Built-in module+build cache by default. |
| runner label `ubuntu-20.04` | removed (brownouts early 2025) | `ubuntu-latest` / `ubuntu-24.04` | `runs-on: ubuntu-20.04` now fails. |

### artifact v4 breaking change (the migration surprise)
- v4 artifacts are **immutable**: you cannot upload the same artifact name twice in one run (v3 merged them). Matrix legs each uploading `my-artifact` collide/fail.
- Fix: unique names per leg (`my-artifact-${{ matrix.os }}`), then `download-artifact` with `merge-multiple: true` (or the merge action).
- Upside GitHub cites: up to ~98% faster upload/download; immediate API availability.

### Why everything bumped a major: Node 20 → Node 24 runner migration (live, mid-2026)
- Node 20 deprecated on runners (announced Sept 19 2025); runners default JS actions to Node 24 ~**June 16 2026**; Node 20 **removed from runner images Sept 16 2026**.
- Any action still declaring `using: node20` throws deprecation warnings now, breaks after removal.
- If a repo shows "Node.js 20 actions are deprecated" annotations, the fix is bumping the action majors above — not touching repo code.

## Caching, per language

`actions/cache@v4` is the generic primitive, but **prefer the setup action's built-in cache** — fewer key-management bugs.

| Language | Use | Notes |
|---|---|---|
| Node | `actions/setup-node` `cache: 'npm'\|'yarn'\|'pnpm'` | Keys off lockfile; v5+ auto-caches with `packageManager` set. |
| Python | `actions/setup-python` `cache: 'pip'\|'poetry'\|'pipenv'` | Caches download/wheel cache, **not** the installed venv — add your own venv cache if install time dominates. |
| Go | `actions/setup-go@v5` (`cache: true`, default) | Keys off `go.sum`. A redundant manual `actions/cache` on top is the common mistake. |
| Rust | **`Swatinem/rust-cache`** | De-facto standard; cleans stale deps (avoids unbounded "cache rot"), handles `target/`, keys off `Cargo.lock` + rustc version. Do **not** hand-cache `~/.cargo` + `target/`. Third-party → SHA-pin it. |

"CI slow" triage order: (1) cache hit/miss — key too specific (never hits) or too loose (stale), no cache on the deps step, or wrong dir cached (installed venv vs download cache); (2) no concurrency cancellation (old runs pile up); (3) serial jobs that could be a matrix.

## Security posture (where 2026 diverges hardest from training data)

### SHA-pin third-party actions — CVE-2025-30066
- **tj-actions/changed-files (CVE-2025-30066, Mar 14 2025)**: attacker retroactively **rewrote existing version tags** (v35, v44.x, …) to point at a malicious commit that dumped CI secrets (cloud keys, PATs, npm tokens, RSA keys) into workflow logs across **20,000+ repos**. Chained through a second compromised action, **reviewdog/action-setup@v1 (CVE-2025-30154)**.
- Root cause: **Git tags and branches are mutable; GitHub has no immutable tags.** `uses: foo/bar@v1` runs whatever that tag points at *today*. Only a full 40-char commit SHA is immutable.
- **Rule**: pin third-party actions to a full commit SHA with the version in a trailing comment:
  `uses: tj-actions/changed-files@<40-char-sha> # v46.0.1`
- Automate the SHA churn with **Dependabot** (`.github/dependabot.yml`, `package-ecosystem: github-actions`) — bumps the SHA *and* the comment, so pinning doesn't mean going stale.
- **Cooldown / dependency-delay** is the newer layer: don't adopt a release the day it drops — a window lets the community catch a compromised release first. (Recommended layer, not universal practice.)
- Lint workflows with **`zizmor`** (docs.zizmor.sh) — catches unpinned `uses:`, dangerous `pull_request_target` + PR-head checkout, template-injection sinks (`${{ github.event.* }}` into `run:`), overbroad tokens. Peer: `actionlint` (syntax/expression). ~91% of repos using any third-party action have ≥1 unpinned use.

### Least-privilege GITHUB_TOKEN
Default token perms are broad. Set explicit least-privilege at the top, widen per-job only where needed:

```yaml
permissions:
  contents: read          # hardened default (or {} for none)

jobs:
  release:
    permissions:
      contents: write     # only this job needs to push tags/releases
      packages: write     # only to publish images
```

Template injection + a write-scoped token is the exploit chain; narrowing the token limits blast radius even if an action is compromised.

### OIDC over stored cloud secrets
For deploying to AWS/GCP/Azure, use **OIDC federation, not long-lived access keys.** The workflow requests a short-lived per-run JWT (`permissions: id-token: write`); the cloud IAM trust policy exchanges it for temporary credentials scoped to that repo/branch/environment. No static secret to leak or rotate; a stolen token expires in minutes. `id-token: write` only lets the job *request* a token — it grants no resource access by itself. If you see `AWS_ACCESS_KEY_ID` / long-lived keys in repo secrets for deploys, migrate to `aws-actions/configure-aws-credentials` with `role-to-assume` + OIDC. **Contested:** SHA-pinning first-party `actions/*` too — hardened/regulated shops pin everything; many teams SHA-pin only third-party and allow major-tag pins for GitHub-owned actions. Both defensible.

## Canonical Rust workflow snippet

```yaml
name: ci
on:
  push: { branches: [main] }
  pull_request:

permissions:
  contents: read

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@<sha>            # v5.0.0
      - uses: dtolnay/rust-toolchain@<sha>      # stable; SHA-pin third-party
        with: { toolchain: stable, components: clippy, rustfmt }
      - uses: Swatinem/rust-cache@<sha>         # v2.x — not hand-rolled ~/.cargo + target
      - run: make ci                            # one source of truth; same command locally
```

`make ci` (fmt --check → clippy -D warnings → test) is the single source of truth both CI and a developer invoke, so they cannot silently diverge.

## Structure & scaling levers

- **Composite action** = a packaged sequence of *steps* dropped into a job as one step ("set up my toolchain"). Nest up to 10 layers.
- **Reusable workflow** (`workflow_call`) = a whole *job/pipeline* graph. **Stale correction:** reusable workflows **CAN** nest (up to 4 levels; 10 total counting caller) and **CAN** be matrix-called — the old "they can't call each other" claim is obsolete. Permissions can only be maintained or reduced down a chain, never elevated. Heuristic: "reusable workflow when it's shaped like a pipeline; composite action when it's shaped like a step."
- **Matrix**: `strategy.matrix` for fan-out; `fail-fast: false` when you want all legs to report (default `true` cancels siblings on first failure). `max-parallel` to throttle.
- **Path filters + required checks interact badly**: a required check *skipped* by a path filter never reports, leaving a PR unmergeable — a classic "why is my PR stuck." Fix with an always-passes shim or merge-queue handling. `dorny/paths-filter` for per-job monorepo conditionals.
- **Concurrency**: caveat — a naive `group: ${{ github.workflow }}` shared between caller and called reusable workflow can cancel the caller.

## Runner landscape (2026)
- **Linux arm64 hosted runners** GA for paid/private, **free for public repos** (from Jan 2025) — native arm64 builds without QEMU. But **not all community actions ship arm64 binaries** — an arm64 job using an x64-only action fails: a real "works on x64, red on arm64" cause.
- **Larger runners** (more vCPU/RAM, GPU, static IPs) configured at org level; opt-in via `runs-on: <label>`.

## Flaky tests: quarantine + fix, never retry-to-green
- **No green-by-retry as policy.** `pytest-rerunfailures` / `jest.retryTimes` / `--retry` are acceptable only as a temporary bandage on a test you are actively fixing. Retrying the whole job to clear a red is the gate violation — it hides regressions.
- **Quarantine** = move the flaky test to a lane where it still runs and records results but a failure does not block merge (vs `skip`/`xfail`, which hides it and lets it rot). Each quarantined test needs a tracking issue + owner.
- Managed layers (Mergify Test Insights, Trunk Flaky Tests, Datadog CI Test Visibility, BuildPulse) auto-detect by confidence score and distinguish "new failure" from "known historical flake." No single winner — pick by scale.

## Key sources
- Artifact v3 removal: github.blog/changelog/2024-04-16-deprecation-notice-v3-of-the-artifact-actions/
- Node 20 deprecation on runners: github.blog/changelog/2025-09-19-deprecation-of-node-20-on-github-actions-runners/
- checkout v5: github.com/actions/checkout/releases/tag/v5.0.0
- cache + service migration: github.com/actions/cache ; github.blog/changelog/2025-03-20-notification-of-upcoming-breaking-changes-in-github-actions/
- Swatinem/rust-cache: github.com/swatinem/rust-cache
- tj-actions CVE-2025-30066 + reviewdog CVE-2025-30154: cisa.gov alert 2025/03/18 ; wiz.io/blog/github-action-tj-actions-changed-files-supply-chain-attack-cve-2025-30066 ; advisory GHSA-mrrh-fwg8-r2c3
- zizmor: docs.zizmor.sh/audits/
- OIDC + least-privilege token: docs.github.com/en/actions/concepts/security/openid-connect
- Reusable workflow nesting/matrix: docs.github.com/en/actions/sharing-automations/reusing-workflows
- arm64 runners free for public: github.blog/changelog/2025-01-16-linux-arm64-hosted-runners-now-available-for-free-in-public-repositories-public-preview/
