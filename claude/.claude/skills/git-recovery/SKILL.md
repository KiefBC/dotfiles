---
name: git-recovery
description: Use when commits, branches, or stashes seem lost — after a botched reset, rebase, merge, force-push, or checkout, in detached HEAD, or any "git ate my work / git is broken" panic, before running any recovery or destructive git command.
---

# Git Recovery

## Overview

Recovery technique is usually sound (reflog reflex, non-destructive choices). The failure is operating without a safety net: running a recovery command directly on the live branch so that a wrong guess makes it unrecoverable. Recovery is exactly when you're stressed and one command from real loss.

<HARD-GATE>
Before ANY recovery or history-changing command:
1. **Snapshot first.** Capture the current position so you can always get back: `git branch backup/<desc>` at HEAD, and note the target SHA (`git reflog` → copy the line). This costs one command and makes every subsequent step reversible.
2. **Before any destructive command** (`reset --hard`, `push --force`, `clean -fd`, `checkout -- .`), state out loud exactly what will be lost. If you can't name what it discards, don't run it.
</HARD-GATE>

## Recovery has a clock

Lost commits live in the object store until gc prunes them — but the window is shorter than "forever":
- Reflog entries for *unreachable* commits (what `reset --hard`/rebase strand) expire at **30 days** (reachable: 90). Loose unreachable objects prune at **~2 weeks**.
- `git maintenance start` does NOT prune (safe). The instant killers are manual: `git gc --prune=now`, `git reflog expire --expire=all`. Never run those while recovering.

Act promptly, and snapshot before anything else touches the repo.

## The recovery map

| Situation | Move |
|---|---|
| `reset --hard` dropped commits | `git reflog` → find the tip SHA → `git branch backup/x <sha>`, then fast-forward or `reset --hard <sha>` (clean tree) |
| Botched interactive rebase | `git reset --hard ORIG_HEAD` (rebase sets it) — after snapshotting |
| Bad merge, NOT pushed | `git reset --hard ORIG_HEAD` |
| Bad merge, ALREADY pushed/shared | `git revert -m 1 <merge-sha>` (never rewrite shared history). Warn: reverting a merge poisons future re-merges of that branch |
| Force-push clobbered remote | Your local `git reflog`, a collaborator's `origin/<b>` reflog, or the server's copy (GitHub Events API `before` SHA) — create a ref to pin it before gc |
| Detached HEAD with work | `git branch save-work` right now, before moving |
| Lost stash | `git fsck --no-reflogs --unreachable \| grep commit`, inspect for the stash commit |
| Deleted branch | `git reflog` for its last tip → `git branch <name> <sha>` |

`git fsck --lost-found` surfaces dangling commits/blobs when the reflog doesn't have it.

## Rationalization table

| Excuse | Reality |
|---|---|
| "The recovery is obviously right, no need to back up" | If it's obvious it costs nothing to snapshot; if it's wrong the snapshot is the only undo. |
| "reset --hard will fix it" | reset --hard is destructive. Snapshot, then say what it discards. |
| "I'll just run the command Stack Overflow gave me" | Blind destructive commands on a panicking repo make it worse. Snapshot first, understand what it does. |
| "Force-push, nobody else has it" | Check: collaborator reflogs, the fork network, the server's Events API often still have it. Prevent with `--force-with-lease` + `push.useForceIfIncludes`. |

Version-sensitive mechanics (reflog expiry knobs, reftable in Git 3.0, switch/restore, server-side recovery): see [references/ecosystem.md](references/ecosystem.md).
