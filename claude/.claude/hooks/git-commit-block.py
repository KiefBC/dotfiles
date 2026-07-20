#!/usr/bin/env python3
"""PreToolUse(Bash) hook: deny any `git commit` — user policy: Claude never commits.

Matches the commit subcommand position (handles `git -C path commit`, `git -c k=v commit`,
`--git-dir=... commit`, and commits embedded in && chains) without false-positives on
`git config commit.*`. Fails open on script errors.
"""
import json
import os
import re
import sys

GIT_COMMIT = re.compile(r"\bgit(?:\s+(?:-[cC]\s+\S+|--?[\w.=/-]+))*\s+commit\b")

REASON = (
    "User policy: Claude never runs `git commit` (including --amend). Stage the changes "
    "(`git add`), summarize what is ready to commit and why, and let the user commit it "
    "themselves. Do not attempt workarounds (plumbing commands, scripts, aliases)."
)


def main():
    data = json.load(sys.stdin)
    if data.get("tool_name") != "Bash":
        return
    cmd = (data.get("tool_input") or {}).get("command", "")
    if not GIT_COMMIT.search(cmd):
        return
    try:
        from datetime import datetime
        with open(os.path.expanduser("~/.claude/hooks/fire.log"), "a") as f:
            f.write(f"{datetime.now().isoformat(timespec='seconds')} PreToolUse commit-block DENIED {cmd[:120]!r}\n")
    except Exception:
        pass
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": REASON,
        }
    }))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
