#!/usr/bin/env python3
"""PreToolUse(Edit|Write|NotebookEdit) hook: gate edits to TRACKED files in a repo's MAIN
checkout behind a permission ask — user policy: repo work happens in a fresh worktree.

Allows without asking: files outside any git repo, untracked/new files, and any file in a
linked worktree (git-dir != git-common-dir). "ask" (not deny) so the user can approve an
intentional in-place edit. Known gap: Bash-mediated writes (sed -i, echo >) bypass this;
the CLAUDE.md policy line covers intent. Fails open on script errors.
"""
import json
import os
import subprocess
import sys

REASON = (
    "User policy: changes to a git repository happen in a fresh worktree, not the main "
    "checkout. Enter one first (EnterWorktree, or `git worktree add`) and edit there — "
    "or the user can approve this in-place edit."
)


def git(cwd, *args):
    return subprocess.run(["git", *args], cwd=cwd, capture_output=True, text=True, timeout=8)


def main():
    data = json.load(sys.stdin)
    if data.get("tool_name") not in ("Edit", "Write", "NotebookEdit"):
        return
    ti = data.get("tool_input") or {}
    path = ti.get("file_path") or ti.get("notebook_path") or ""
    if not path:
        return
    d = os.path.dirname(os.path.abspath(path)) or "/"
    while not os.path.isdir(d):
        parent = os.path.dirname(d)
        if parent == d:
            return
        d = parent
    if git(d, "rev-parse", "--is-inside-work-tree").returncode != 0:
        return
    gd = git(d, "rev-parse", "--absolute-git-dir")
    gcd = git(d, "rev-parse", "--git-common-dir")
    if gd.returncode != 0 or gcd.returncode != 0:
        return
    common = gcd.stdout.strip()
    if not os.path.isabs(common):
        common = os.path.normpath(os.path.join(d, common))
    if os.path.realpath(gd.stdout.strip()) != os.path.realpath(common):
        return  # linked worktree — the sanctioned place to work
    tracked = git(d, "ls-files", "--error-unmatch", os.path.abspath(path))
    if tracked.returncode != 0:
        return  # new/untracked file
    try:
        from datetime import datetime
        with open(os.path.expanduser("~/.claude/hooks/fire.log"), "a") as f:
            f.write(f"{datetime.now().isoformat(timespec='seconds')} PreToolUse worktree-guard ASK {path[:120]!r}\n")
    except Exception:
        pass
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "ask",
            "permissionDecisionReason": REASON,
        }
    }))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
