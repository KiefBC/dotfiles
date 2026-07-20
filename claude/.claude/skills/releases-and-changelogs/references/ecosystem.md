# Releases & Changelogs Ecosystem Reference (verified July 2026)

Version-sensitive facts backing SKILL.md. Single most important delta vs training data: **Keep a Changelog shipped 2.0.0 (2026-06-07)** — the first major revision ever. Tool versions and registry policies move fast; treat specifics as early-July-2026.

## Spec status at a glance

| Spec | Current | Correction |
|---|---|---|
| **Semantic Versioning** | **2.0.0** (unchanged since 2013) | **No 3.0 exists or is in development.** Cite 2.0.0 confidently. Epoch SemVer (`EPOCH.MAJOR.MINOR.PATCH`, antfu.me) is a *community proposal*, not a standard |
| **Keep a Changelog** | **2.0.0 (2026-06-07)** | Training data says 1.0.0 / 1.1.0 (1.1.0 = 2019). Backward-compatible in substance — the six types + `[YANKED]` are unchanged |
| **Conventional Commits** | **1.0.0** (unchanged since 2019/20) | No newer version. Increasingly *contested* (see below) — do not treat as mandatory |

## Keep a Changelog 2.0.0 — what changed

- **Unchanged (still load-bearing):** six change types **Added, Changed, Deprecated, Removed, Fixed, Security**; `YYYY-MM-DD` ISO dates; `[Unreleased]` section; `[YANKED]` marker; newest-first; "changelogs are for humans, not machines"; write entries at change time (don't reconstruct from git log). Existing changelogs stay valid — 2.0.0 is a *guidance/site* major (anchors moved, translations lagged), not a format break.
- **New in 2.0.0** (encode these):
  - `# Changelog` header + preamble recommended.
  - Explicit guidance on **marking breaking changes** and where upgrade/migration steps belong.
  - How to choose **Changed vs Fixed vs Security** (previously ambiguous).
  - **Lead a Security entry with its CVE identifier.**
  - **Explicitly endorses non-SemVer schemes** (CalVer etc.) — removes the old "the changelog standard assumes SemVer" objection.
  - Link each version heading to a **compare/diff URL** via reference links (`[1.2.0]: https://.../compare/v1.1.0...v1.2.0`).
- **Common Changelog** (common-changelog.org) — stricter alternative: one bullet per change, imperative mood, no Unreleased section, author/PR references required. KaC stays the default; Common Changelog is the "I want stricter rules" option.

## Conventional Commits — still 1.0.0, now contested

Format: `type(scope)!: description`; `feat`→minor, `fix`→patch, `!` or `BREAKING CHANGE:` footer→major. Strong in JS (a 2025 study: 360/381 JS projects used CC-formatted commits) and Rust/Go tooling (git-cliff, release-plz, semantic-release). Criticisms that have stuck:
- **Categorization is a guess** — `feat` vs `fix` is often ambiguous, yet the *type* silently determines the SemVer bump, so a mislabel produces a wrong version. Couples commit hygiene to release correctness.
- **Enforcement is all-or-nothing** — diverges fast without a validating parser (commitlint).
- **Breaking changes ≠ commit granularity** — a breaking change spans several commits; one footer is lossy.

Competing philosophy = **changesets / intent files**: the author writes an explicit changeset ("this is a minor, here's the human summary") at change time instead of inferring from commit type. Skill stance: **the person who wrote the change declares the bump and changelog line deliberately** — commit convention vs changeset file is a tooling choice; the deliberate human decision is non-negotiable.

## Ecosystem breaking-change rules (a bump is relative to these, not the bare spec)

| Ecosystem | Rule |
|---|---|
| npm | `^0.x` treats **minor as breaking** |
| Cargo | `^` default; doc.rust-lang.org/cargo/reference/semver.html is the best cross-language "what counts as breaking" checklist |
| Go | **major in import path** (`/v2`, `/vN`) — the tag's major must match |

Verify the bump with a detector, don't assert it: cargo-semver-checks, griffe, apidiff, api-extractor (see api-design brief). A "just a patch" that changes a signature is the canonical failure.

## Release automation tooling per ecosystem (all actively maintained mid-2026 unless noted)

Two workflow philosophies to name: **Release-PR model** (CI opens a PR bumping version + changelog; merge → publish; human gate) vs **push-to-publish** (every qualifying commit to main publishes, no gate).

| Ecosystem | Tool | Role |
|---|---|---|
| **Rust** | **release-plz** (release-plz.dev) | **Default.** Release-PR; compares local crates vs what's *published on crates.io* (not git tags); zero-config, workspace-aware; integrates crates.io Trusted Publishing + cargo-semver-checks |
| Rust | cargo-release (crate-ci) | Lower-level imperative "do the release steps"; complements release-plz |
| Rust | cargo-smart-release (GitoxideLabs, ~0.21) | Maintained but effectively **gitoxide-internal** — don't lead with it despite old lists |
| Rust | cargo-dist | Builds/uploads cross-platform *artifacts*; orthogonal to version/changelog |
| **JS/npm** | **changesets** (~3M wk downloads) | **Default for monorepos + multi-package OSS.** Intent-file model |
| JS/npm | semantic-release (~2M wk) | Fully-automated, CC-driven, no gate; best for single-package CD services. Inherits CC critique |
| JS/npm | release-please (Google) | Release-PR driven by CC; multi-language, GitHub-centric; middle ground |
| JS/npm | release-it | Imperative/interactive, max control |
| **Go** | **GoReleaser** (~v2.16) | Standard, but **artifact-engineering only** — cross-compile, archives, checksums, SBOMs, Docker, Homebrew. **Does NOT compute your version**; consumes the tag you provide. Pair with a changelog/version step |
| **Any** | git-cliff (orhun, ~v2.13) | Rust binary changelog generator; CC-aware but supports arbitrary regex parsers; go-to outside JS |
| Any | knope (knope.tech) | Broader single-binary workflow automator; changeset + CC inputs |

Skill guidance: monorepo/library → changesets; hands-off service → semantic-release/release-please; manual control → release-it.

## Trusted publishing / provenance — landed 2025–2026 (training data likely wrong)

Industry-wide pattern: **short-lived OIDC tokens replace long-lived API tokens**; provenance attestations (Sigstore, in-toto) bind artifact → source repo + commit + workflow. OpenSSF "Trusted Publishers" spec.

| Registry | Status | Detail |
|---|---|---|
| **PyPI** | mature baseline | Trusted Publishers (OIDC) GA since 2023; **provenance attestations ON by default for trusted publishers since late 2024**. Supports GitHub Actions, GitLab, Google Cloud Build, ActiveState |
| **npm** | GA, significant in 2026 | Trusted publishing from GitHub Actions/GitLab CI **generates + publishes provenance by default (no `--provenance` flag)**. Requires **npm CLI ≥ 11.5.1 and Node ≥ 22.14.0**. **2026-05-20 change:** trusted-publisher configs created after that date must explicitly select ≥1 allowed action (older configs default publish-only) |
| **crates.io** | Trusted Publishing GA since **July 2025** (RFC 3691) | OIDC, GitHub Actions first. 2026: **+GitLab CI/CD** (GitLab.com only), and crate owners can **enforce** Trusted Publishing (disables traditional API-token publishing — a leaked token can't publish). **crates.io does tokenless auth, NOT Sigstore provenance yet — don't conflate with npm/PyPI provenance** |

Modern checklist: publish from CI via trusted publishing, not a long-lived secret token; provenance on where supported (npm/PyPI automatic; crates.io = tokenless auth only); enforce where supported.

## Yank / hotfix mechanics — different per registry, widely misremembered

Governing principle everywhere: **immutability** — registries refuse deletion because it breaks the ecosystem (left-pad). Yank is the primitive; deletion is the exception.

| Registry | Primitive | Semantics |
|---|---|---|
| **crates.io** | `cargo yank` (`--undo` reverses) | Blocks **new** dependency resolution only. **Does NOT delete** — tarball stays downloadable, existing `Cargo.lock` keeps working. Therefore **yanking does NOT contain a leaked secret or remove malware** (existing lockfiles still pull it) — rotate secrets; contact crates.io team + RustSec for malware |
| **npm** | `npm deprecate <pkg>@ver "msg"` | **Unpublish is time/dependency-limited:** only within **72h** of publish, or anytime if nothing depends on it & ~no downloads. After 72h with dependents you **cannot unpublish — only deprecate.** Deprecated version stays installable but prints a warning. `deprecate … ""` un-deprecates. In practice hotfix = deprecate + publish fixed patch |
| **PyPI** | `yank` (PEP 592) | Ignored by resolvers **unless a pin/constraint selects the exact version** (`==1.2.3` still installs). File stays hosted. Reversible. Deletion possible but discouraged/being restricted |

**Universal rule: never delete/unpublish to fix a bad release — yank/deprecate the bad version, then release a corrected higher version.** Deleting breaks downstream lockfiles and enables dependency-confusion re-registration of the freed name. Never rely on yank to contain secrets/malware.

## CalVer vs SemVer — settled into "it depends"

| Scheme | Use when |
|---|---|
| **SemVer** | **libraries/packages/APIs with dependents** resolving version ranges — they need the breaking-change signal; the whole resolution machinery assumes it. Bump must be justified against the API diff |
| **CalVer** (`YYYY.MM` / `YYYY.MINOR`) | **apps, SaaS, CLIs, OS/distro products, continuously-deployed services** — "when" matters more than "what broke," no downstream `^`-resolver. Ubuntu, pip, Black-era tooling |
| **Hybrid** | common + legitimate: SemVer for the reusable library layer, CalVer for the shipped app |

Choose from **whether you have external dependents resolving version ranges.** KaC 2.0.0 now explicitly blesses non-SemVer, removing the old objection. The load-bearing discipline (changelog at change time, yank-don't-delete, publish from CI) is identical either way.

## Key sources

- semver.org (2.0.0); Epoch SemVer proposal antfu.me/posts/epoch-semver
- Keep a Changelog 2.0.0: keepachangelog.com/en/2.0.0; Common Changelog: common-changelog.org
- Conventional Commits: conventionalcommits.org/en/v1.0.0
- Cargo SemVer taxonomy: doc.rust-lang.org/cargo/reference/semver.html
- release-plz.dev; changesets (github.com/changesets/changesets); goreleaser.com; git-cliff.org; knope.tech
- crates.io Trusted Publishing: crates.io/docs/trusted-publishing; RFC 3691; min-publish-age RFC 3923 (proposal)
- npm trusted publishing: docs.npmjs.com/trusted-publishers; PyPI attestations: docs.pypi.org/attestations
- cargo yank: doc.rust-lang.org/cargo/commands/cargo-yank.html; npm unpublish policy: docs.npmjs.com/policies/unpublish; PyPI yank PEP 592
- CalVer vs SemVer by project type: sensiolabs.com/blog 2025; frontside.com/blog 2022-02-09
