#!/usr/bin/env python3
"""PreToolUse(Bash) hook: detect package-install commands and inject a vetting reminder.

Empirical basis: requester-NAMED packages get installed blind (tokio-retry: dormant since
2021, zero vetting). Non-blocking — allows the call but injects dependency-vetting context.
Fails open: any error -> no output, exit 0.
"""
import json
import os
import re
import sys

# (verb regex, needs a non-flag package argument, extra-exclusion regex)
MANAGERS = [
    (r"\bcargo\s+add\b", True, None),
    (r"\bnpm\s+(?:install|i|add)\b", True, None),
    (r"\bpnpm\s+(?:add|install|i)\b", True, None),
    (r"\byarn\s+add\b", True, None),
    (r"\bbun\s+(?:add|install|i)\b", True, None),
    (r"\bpip3?\s+install\b", True, r"(?:^|\s)(?:-r|--requirement)\b"),
    (r"\buv\s+add\b", True, None),
    (r"\buv\s+pip\s+install\b", True, r"(?:^|\s)(?:-r|--requirement)\b"),
    (r"\bpoetry\s+add\b", True, None),
    (r"\bgo\s+get\b", True, None),
    (r"\bgem\s+install\b", True, None),
    (r"\bcomposer\s+require\b", True, None),
]

CONTEXT = (
    "[hook: dependency install detected]\n"
    "Vet before adding (see ~/.claude/skills/dependency-vetting/SKILL.md): last release date, "
    "maintenance signals, download trend, security advisories, and whether std/existing deps "
    "already cover the need. A requester-NAMED package (\"I think there's a crate for this\") "
    "is a lead to vet, not a decision already made. If this exact package was already vetted "
    "this session, proceed."
)


def has_package_arg(cmd, verb_match):
    tail = cmd[verb_match.end():]
    tail = re.split(r"[|;&]", tail)[0]
    for tok in tail.split():
        if tok.startswith("-"):
            continue
        if tok in (".",) or tok.startswith("./") or tok.startswith("/"):
            continue
        if tok.endswith(".txt"):
            continue
        return True
    return False


def log_fire(note):
    try:
        from datetime import datetime
        with open(os.path.expanduser("~/.claude/hooks/fire.log"), "a") as f:
            f.write(f"{datetime.now().isoformat(timespec='seconds')} PreToolUse dep-install {note}\n")
    except Exception:
        pass


def main():
    data = json.load(sys.stdin)
    if data.get("tool_name") != "Bash":
        return
    cmd = (data.get("tool_input") or {}).get("command", "")
    for verb, needs_arg, exclude in MANAGERS:
        m = re.search(verb, cmd)
        if not m:
            continue
        if exclude and re.search(exclude, cmd):
            continue
        if needs_arg and not has_package_arg(cmd, m):
            continue
        log_fire(repr(cmd[:120]))
        print(json.dumps({
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "allow",
                "permissionDecisionReason": "Install allowed; vetting reminder injected.",
                "additionalContext": CONTEXT,
            }
        }))
        return


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
