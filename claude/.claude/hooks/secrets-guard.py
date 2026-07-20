#!/usr/bin/env python3
"""PreToolUse(Bash) hook: deny `git commit` / `git push` when outgoing changes contain
what looks like a real credential.

Scans ADDED diff lines only. Never echoes the matched value — reports pattern name and
file. Complements secure-coding the way git-guard complements git-recovery: the skill
handles judgment, the hook handles the irreversible moment. Fails open on script errors.
"""
import json
import os
import re
import subprocess
import sys

PATTERNS = [
    ("GitHub fine-grained PAT", re.compile(r"github_pat_[A-Za-z0-9_]{22,}")),
    ("GitHub token", re.compile(r"\bgh[pousr]_[A-Za-z0-9]{36,}")),
    ("AWS access key", re.compile(r"\bAKIA[0-9A-Z]{16}\b")),
    ("Anthropic API key", re.compile(r"\bsk-ant-[A-Za-z0-9\-_]{20,}")),
    ("OpenAI API key", re.compile(r"\bsk-(?:proj-)?[A-Za-z0-9]{40,}\b")),
    ("Slack token", re.compile(r"\bxox[baprs]-[A-Za-z0-9\-]{10,}")),
    ("Google API key", re.compile(r"\bAIza[0-9A-Za-z_\-]{35}\b")),
    ("Stripe live key", re.compile(r"\b[sr]k_live_[A-Za-z0-9]{20,}")),
    ("Private key block", re.compile(r"-----BEGIN [A-Z ]*PRIVATE KEY-----")),
    ("Assigned secret", re.compile(
        r"(?i)\b(?:api[_-]?key|secret|token|passw(?:or)?d)\b\s*[:=]\s*['\"]([A-Za-z0-9_\-/+=]{20,})['\"]")),
]

PLACEHOLDER = re.compile(r"(?i)example|dummy|placeholder|changeme|your[_-]|xxxx|<|\{\{|\$\{|\$\(")

REASON = (
    "Blocked: outgoing changes contain what looks like a real credential — {hits}. "
    "Remove it from the tracked content (env var, gitignored config, secret manager), restage, "
    "and re-run. If it is a genuine false positive (e.g. a documented test fixture), the user "
    "must explicitly approve committing it."
)


def git(cwd, *args):
    return subprocess.run(["git", *args], cwd=cwd, capture_output=True, text=True, timeout=10)


def added_lines_with_files(diff_text):
    current = "?"
    for line in diff_text.splitlines():
        if line.startswith("+++ b/"):
            current = line[6:]
        elif line.startswith("+") and not line.startswith("+++"):
            yield current, line[1:]


def scan(diff_text):
    hits = []
    for fname, line in added_lines_with_files(diff_text):
        for name, pat in PATTERNS:
            m = pat.search(line)
            if not m:
                continue
            value = m.group(1) if m.groups() and m.group(1) else m.group(0)
            if name == "Assigned secret" and PLACEHOLDER.search(line):
                continue
            if PLACEHOLDER.search(value):
                continue
            hits.append(f"{name} in {fname}")
    return sorted(set(hits))


def main():
    data = json.load(sys.stdin)
    if data.get("tool_name") != "Bash":
        return
    cmd = (data.get("tool_input") or {}).get("command", "")
    is_commit = re.search(r"\bgit\b[^|;&]*\bcommit\b", cmd)
    is_push = re.search(r"\bgit\b[^|;&]*\bpush\b", cmd)
    if not (is_commit or is_push):
        return
    cwd = data.get("cwd") or os.getcwd()
    if git(cwd, "rev-parse", "--is-inside-work-tree").returncode != 0:
        return

    diff_text = ""
    if is_commit:
        r = git(cwd, "diff", "--cached", "-U0", "--no-color")
        if r.returncode == 0:
            diff_text += r.stdout
        if re.search(r"\bcommit\b[^|;&]*(?:\s-[a-zA-Z]*a[a-zA-Z]*\b|--all\b)", cmd):
            r = git(cwd, "diff", "HEAD", "-U0", "--no-color")
            if r.returncode == 0:
                diff_text += r.stdout
    if is_push:
        up = git(cwd, "rev-parse", "--abbrev-ref", "@{u}")
        if up.returncode == 0:
            r = git(cwd, "diff", up.stdout.strip() + "..HEAD", "-U0", "--no-color")
            if r.returncode == 0:
                diff_text += r.stdout

    hits = scan(diff_text)
    if not hits:
        return
    try:
        from datetime import datetime
        with open(os.path.expanduser("~/.claude/hooks/fire.log"), "a") as f:
            f.write(f"{datetime.now().isoformat(timespec='seconds')} PreToolUse secrets DENIED {hits}\n")
    except Exception:
        pass
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": REASON.format(hits="; ".join(hits)),
        }
    }))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
