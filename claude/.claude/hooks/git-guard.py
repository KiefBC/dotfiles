#!/usr/bin/env python3
"""PreToolUse(Bash) hook: deny destructive git operations unless a recent backup exists.

Empirical basis: the git-recovery baseline showed the technique is fine but the safety
step (backup ref before surgery) gets skipped. "Recent backup" = a branch/tag with
'backup' in its name, or a stash entry, created within the last 2 hours.
Fails open on script errors; fails CLOSED (deny) only on a confirmed dangerous match
with no backup.
"""
import json
import os
import re
import subprocess
import sys
import time

DANGEROUS = [
    (r"\bgit\s+[^|;&]*\breset\s+[^|;&]*(?:--hard|--merge)\b", "reset --hard/--merge"),
    (r"\bgit\s+[^|;&]*\bpush\s+[^|;&]*(?:--force(?!-with-lease)|\s-f\b)", "push --force"),
    (r"\bgit\s+rebase\b(?!\s+(?:--continue|--abort|--skip|--quit))", "rebase"),
    (r"\bgit\s+[^|;&]*\bclean\s+[^|;&]*-[a-zA-Z]*f", "clean -f"),
    (r"\bgit\s+checkout\s+[^|;&]*\s--(?:\s|$)", "checkout -- (discard)"),
    (r"\bgit\s+restore\b(?![^|;&]*--staged)", "restore (discard working changes)"),
    (r"\bgit\s+branch\s+[^|;&]*(?:-D\b|--delete\s+--force)", "branch -D"),
    (r"\bgit\s+stash\s+(?:drop|clear)\b", "stash drop/clear"),
    (r"\bgit\s+filter-(?:branch|repo)\b", "history rewrite"),
    (r"\bgit\s+reflog\s+expire\b", "reflog expire"),
    (r"\bgit\s+update-ref\s+-d\b", "update-ref -d"),
]

BACKUP_WINDOW_SECS = 2 * 3600

REASON = (
    "Destructive git operation blocked ({label}): no recent backup found (no branch/tag named "
    "*backup* and no stash entry created within the last 2 hours). Create one first, then re-run:\n"
    "  git branch backup/pre-op          # snapshots committed state\n"
    "  git stash push -u -m backup && git stash apply   # if uncommitted work must survive\n"
    "Recovery is easy WITH a ref and painful without (git-recovery safety gate)."
)


def git(cwd, *args):
    return subprocess.run(
        ["git", *args], cwd=cwd, capture_output=True, text=True, timeout=8
    )


def recent_backup_exists(cwd):
    now = time.time()
    r = git(cwd, "for-each-ref", "--format=%(creatordate:unix) %(refname:short)",
            "refs/heads", "refs/tags")
    if r.returncode == 0:
        for line in r.stdout.splitlines():
            parts = line.split(None, 1)
            if len(parts) == 2 and "backup" in parts[1].lower():
                try:
                    if now - int(parts[0]) < BACKUP_WINDOW_SECS:
                        return True
                except ValueError:
                    pass
    r = git(cwd, "stash", "list", "--format=%ct")
    if r.returncode == 0:
        for line in r.stdout.splitlines():
            try:
                if now - int(line.strip()) < BACKUP_WINDOW_SECS:
                    return True
            except ValueError:
                pass
    return False


def log_fire(note):
    try:
        from datetime import datetime
        with open(os.path.expanduser("~/.claude/hooks/fire.log"), "a") as f:
            f.write(f"{datetime.now().isoformat(timespec='seconds')} PreToolUse git-guard {note}\n")
    except Exception:
        pass


def main():
    data = json.load(sys.stdin)
    if data.get("tool_name") != "Bash":
        return
    cmd = (data.get("tool_input") or {}).get("command", "")
    label = None
    for pat, lbl in DANGEROUS:
        if re.search(pat, cmd):
            label = lbl
            break
    if label is None:
        return
    cwd = data.get("cwd") or os.getcwd()
    inside = git(cwd, "rev-parse", "--is-inside-work-tree")
    if inside.returncode != 0:
        return  # not a repo; let git produce its own error
    if recent_backup_exists(cwd):
        log_fire(f"allowed ({label}, backup present)")
        return
    log_fire(f"DENIED ({label}) {cmd[:120]!r}")
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": REASON.format(label=label),
        }
    }))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
