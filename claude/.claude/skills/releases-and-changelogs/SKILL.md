---
name: releases-and-changelogs
description: Use when cutting a release, bumping a version, tagging, publishing a package, writing release notes, or deciding what version number a set of changes deserves — including when the requester suggests the version number.
---

# Releases & Changelogs

## Overview

Version classification instinct is reliable; the changelog artifact is what gets skipped. Release notes that exist only inside an annotated tag are invisible to everyone browsing the repo, diffing versions, or reading a registry page.

<HARD-GATE>
A release IS these four artifacts — all of them, none optional:
1. **Version bump classified against the actual diff** since the last tag (`git diff <last-tag>..HEAD` on the public surface). Commit messages lie — a "cleanup:" commit can rename a public function. Classify from the surface change, per the api-design skill's table. Highest bucket wins: any breaking change → major, else any feature → minor, else patch.
2. **CHANGELOG.md entry** — Keep-a-Changelog shape; CREATE the file if it doesn't exist. The tag message is NOT the changelog.
3. **Verification run at the new version** — the test suite, quoted.
4. **Annotated tag** (`git tag -a vX.Y.Z`), notes matching the changelog entry.
</HARD-GATE>

## Changelog discipline

```markdown
## [Unreleased]
### Added / Changed / Deprecated / Removed / Fixed / Security

## [2.0.0] - 2026-07-06
### Changed
- **Breaking:** `Config::load` renamed to `Config::from_path` (now takes `impl AsRef<Path>`).
```

- Write entries at CHANGE time under `[Unreleased]`; releasing is then a rename + date, not commit archaeology.
- Entries describe the change for a USER of the package (what breaks, what they must do), not the commit ("tidied API" is a commit message, not a changelog entry).
- Breaking entries state the migration step.

## Version decisions

- Requester-suggested version ("this is 1.4.1, right?") = a lead to verify against the diff, not a decision. Say what the diff actually classifies as and why.
- Breaking change you'd rather not ship as major? The alternative is to make it non-breaking (deprecated alias forwarding to the new name → minor; removal lands in the next major) — not to mislabel it.
- SemVer for libraries (things with dependents resolving ranges); CalVer is legitimate for apps/services — don't force one onto the other.

## Yank / hotfix

Never delete a published version. Yank/deprecate + fix forward with a new release. Registry semantics differ (cargo yank keeps the tarball; npm unpublish is blocked after 72h — use deprecate; PyPI yank still installs on exact pins) — check [references/ecosystem.md](references/ecosystem.md) before promising what yanking achieves.

## Rationalization table

| Excuse | Reality |
|---|---|
| "The tag message covers it" | Tags are invisible in the repo view and on registries. CHANGELOG.md or it didn't happen. |
| "No changelog file exists, so skip it" | Absence of the file IS the finding. Create it, backfill this release only. |
| "The commits say fix/cleanup, so patch" | Commit labels are claims. The diff is the evidence. |
| "It's internal, nobody reads changelogs" | Internal dependents on `^1.4` auto-pull your mislabeled breaking patch. They read it after the outage. |

Tooling and registry facts (Keep a Changelog 2.0, trusted publishing, release-plz/changesets): see [references/ecosystem.md](references/ecosystem.md).
