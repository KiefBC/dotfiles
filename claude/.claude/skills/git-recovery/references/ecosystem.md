# Git Recovery Ecosystem Reference (verified July 2026)

Version-sensitive mechanics backing SKILL.md. Current Git: **2.55.x** (2.55.0 released 2026-06-29; 2.55.0.2 point release 2026-07-03). **Git 3.0 in progress** (~end of 2026): SHA-256 default object format, Rust build requirement, and the **reftable** ref backend. None of this changes recovery *concepts* — but reftable changes how you must read refs (below). The governing fact: recovery is a **race against gc**, and the timers are shorter than "forever."

## The reflog expiry clock

| Config | Default | What it governs |
|---|---|---|
| `gc.reflogExpire` | **90 days** | reflog entries for **reachable** commits |
| `gc.reflogExpireUnreachable` | **30 days** | reflog entries for commits no longer reachable from the ref tip — **this is the one that bites**: a commit you `reset --hard` away from is unreachable, on the 30-day clock, not 90 |
| `gc.pruneExpire` | **2 weeks** | loose unreachable objects (+ cruft-pack expiration) — the raw object often survives ~2 weeks *after* its reflog entry expires |
| `gc.auto` | 6700 loose objects | auto-gc threshold (packs: `gc.autoPackLimit` = 50) |

Practical window for "I did this an hour/day/week ago" is essentially always open — **if you stop making things worse.** But **never tell the user "git keeps everything forever"** — it doesn't.

## What prunes vs what is safe

| Command | Effect |
|---|---|
| `git gc --prune=now` | **Instant, irreversible** — collapses the window to zero. Destructive. |
| `git reflog expire --expire-unreachable=all` (or `--expire=all`) | **Instant, irreversible.** Destructive. |
| `git maintenance start` | **SAFE** — default incremental strategy schedules `prefetch`, `commit-graph`, `loose-objects`, `incremental-repack`, `pack-refs` but **NOT the `gc` task**. `loose-objects` packs loose objects; it does **not** prune unreachable ones on the expiry clock. Correct the "maintenance ran, so it's gone" assumption. |
| Auto-gc (on `commit`/`merge`/`rebase` when loose > 6700) | Honors the 2-week/30-day/90-day expiry → prunes *old* unreachable data, not what you lost 5 minutes ago. |
| `git gc --aggressive` | Heavier; Git docs recommend against it; does **not** change the pruning expiry math. |

**Move when the clock might be short** (old loss, or a shared/CI machine that runs gc): immediately `git config gc.pruneExpire never` and `git config gc.reflogExpireUnreachable never`, recover, then revert the config.

## What has NO reflog / is unrecoverable
- **Uncommitted tracked changes** discarded by `reset --hard`, `checkout -- <path>`, `restore` → **gone, no reflog.** Only hope: editor/IDE local-history or filesystem backup. State this plainly.
- **Untracked files** removed by `clean -fd` → **gone, not in git at all.**
- **Reflog is not universal:** requires `core.logAllRefUpdates`, **off by default in bare repos** (servers); a fresh `git clone` starts with an empty reflog. Don't assume a reflog exists everywhere.

## Modern command surface

- **`git switch` / `git restore`** (stable since 2.23, 2019) are the **preferred** spellings and reduce recovery risk:
  - `git switch -c <name> [<SHA>]` — create-and-move, the correct way to rescue a detached HEAD or dangling commit. `git switch -` returns to previous; `git switch --detach <SHA>` for deliberate inspection.
  - `git restore --source=<SHA> -- <path>` — recover one file's old content without touching HEAD. `git restore --staged` to unstage.
  - **`git checkout` is NOT deprecated and is not being removed** — correct the common overstatement. Prefer switch/restore for new instructions; still read checkout in existing scripts.
- **`git reset --hard ORIG_HEAD`** — fast undo for a just-completed `reset`/`merge`/`rebase` (they write ORIG_HEAD to the pre-op tip). **Gotcha: ORIG_HEAD is a single slot** — one operation back; every subsequent merge/reset/rebase overwrites it. Two risky ops → it points at the wrong one; fall back to reflog.
- **`git reflog`** — primary recovery instrument. `HEAD@{2}`, `main@{1}`, `<branch>@{yesterday}`. `--date=iso` to disambiguate. **`git reflog --all`** (or `show --all`) walks *every* ref's reflog at once — fastest way to find a lost commit when you don't know which ref it hung off.

## reftable / Git 3.0 warning — do NOT read `.git/` directly
The **reftable** backend stores refs *and reflogs* in a binary format instead of loose files under `.git/refs` and plaintext under `.git/logs`. As it rolls out (experimental in recent releases, prominent in the Git 3.0 line), **recovery scripts that `cat .git/logs/HEAD` or `cat .git/refs/heads/<branch>` will break.** Always use plumbing/porcelain — `git reflog`, `git rev-parse`, `git for-each-ref`, `git update-ref` — so the same instructions work on both ref backends. The concepts (reflog, ORIG_HEAD, fsck, the expiry clock) are unchanged by reftable.

## Disaster-specific mechanics

| Disaster | Recovery |
|---|---|
| Hard reset (committed state) | `git reset --hard ORIG_HEAD` (if immediate), else reflog → `git reset --hard <SHA>` after snapshot |
| Rebase **in progress** | `git rebase --abort` — clean escape to exact pre-rebase state; reach for it before anything manual |
| Rebase **finished + wrong** | `git reset --hard ORIG_HEAD`, or reflog: reset to the commit just *before* the `rebase (start)` entry |
| **Corrupted rebase state** (`.git/rebase-merge` left, "rebase in progress" won't abort) | Try `git rebase --abort`; if it fails, **read `orig-head` from `.git/rebase-merge/` first** (it's the pre-rebase tip — a recovery SHA), then `rm -rf .git/rebase-merge` (or `.git/rebase-apply`), then reflog back |
| Bad merge, **not pushed** | `git reset --hard ORIG_HEAD` (or `HEAD@{1}`) — removes the merge cleanly |
| Bad merge, **already pushed/shared** | `git revert -m 1 <merge-SHA>` — never rewrite shared history. `-m 1` keeps first parent (usually `main`), `-m 2` the feature branch; wrong number reverts the wrong side |
| Lost stash | `git fsck --no-reflogs --unreachable \| grep commit`, inspect (`WIP on <branch>` message), reapply via `git stash apply <SHA>` |
| Deleted branch | Tip SHA is printed on delete (check scrollback) → `git branch <name> <SHA>`; else `git reflog --all` / `git fsck --lost-found` |
| Detached HEAD with commits | `git switch -c rescue/<name>` **right now**; if already left, reflog → `git switch -c rescue/<name> <SHA>` |

**The revert-a-merge trap (must warn):** after `git revert -m 1` of a feature merge, that feature branch **will not merge cleanly again** — git thinks those changes are already present. To re-land you must revert the revert, or rebase the feature. (MIT "How to revert a faulty merge.") Single most common follow-on failure.

## Force-push recovery (server-side / GitHub)

- **Your own machine:** local `git reflog` still has the pre-force SHA → `git reset --hard <SHA>`, re-push with lease. Easiest case.
- **A collaborator has it:** anyone who fetched before the force-push has the old commits in *their* `refs/remotes/origin/...` reflog. `git reflog show origin/<branch>` on their clone finds it; have them push it back.
- **GitHub, nobody has a local copy** — orphaned commits stay reachable server-side for a window:
  - **Events API**: `GET https://api.github.com/repos/{owner}/{repo}/events` returns recent `PushEvent`s with `before`/`head` SHAs — the **`before` SHA of the offending push is your lost tip**. Then create a ref to rescue it. (Limited: ~300 events / ~90 days.)
  - **Dangling-commit trick**: browse/compare the SHA on github.com (`/compare/<sha>`) and create a branch/tag via `POST /repos/{owner}/{repo}/git/refs` **before it's gc'd** — making it reachable preserves it.
  - **Forks/network**: if the repo has forks, the commit may still be reachable through the fork network.
  - GitHub Support as last resort (rarely restores; GitHub does not expose a git reflog to users).
- **Prevention:** `push --force-with-lease` (fails if remote moved unexpectedly) over `push --force`, plus `push.useForceIfIncludes` and branch protection.
- **Server reflog** only helps if *you* control the server (self-hosted, bare repo with `core.logAllRefUpdates` enabled — off by default for bare repos).

## `git fsck` — recovery of last resort
When reflog doesn't have it (expired, disabled, fresh clone, or the ref never touched HEAD):
- `git fsck --full --no-reflogs --unreachable` lists all unreachable objects. **`--no-reflogs` is key** — a bare `git fsck` hides objects still pinned by reflog and won't surface what you expect.
- `git fsck --lost-found` writes dangling **commits** to `.git/lost-found/commit/<SHA>` and dangling **blobs** (raw file contents — useful for a lost uncommitted file that was once staged) to `.git/lost-found/other/<SHA>`.
- Triage: `git show <SHA>` / `git log --oneline <SHA>`; for lost file content `git cat-file -p <blob-SHA>`. Rescue by creating a ref. A `git gc` that already ran swept truly-expired unreachable objects — fsck only finds what still exists.

## Key sources
- git-scm.com/docs/git-reflog (90/30-day expiry, `@{}` syntax, `--all`)
- git-scm.com/docs/git-gc (`gc.pruneExpire` 2 weeks, `gc.auto` 6700, `--prune=now`)
- git-scm.com/docs/git-maintenance (incremental strategy — gc task NOT scheduled)
- git-scm.com/docs/git-fsck (`--lost-found`, `--no-reflogs`, lost-found layout)
- git-scm.com/docs/git-rebase (ORIG_HEAD, `--abort`, `.git/rebase-merge` contents)
- git-scm.com/book/en/v2/Git-Internals-Maintenance-and-Data-Recovery
- web.mit.edu/git/www/howto/revert-a-faulty-merge.html (revert -m re-merge trap)
- Current Git + Git 3.0 direction (SHA-256, Rust, reftable): github.com/git/git/releases ; github.blog/open-source/git/
- GitHub force-push recovery (Events API `before` SHA): github.com/orgs/community/discussions/146637
