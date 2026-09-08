#!/usr/bin/env python3
"""PreToolUse(Bash) hook: deny recursive rm aimed at anything that could take out a
system, a home directory, or a whole project.

Policy (deny if ANY recursive-rm target hits a rule):
  - `/`, `--no-preserve-root`, or any system prefix (/bin /sbin /usr /etc /var /opt
    /System /Library /Applications /private /Volumes /cores /Network) at any depth
  - unexpanded `$VAR`, `$(...)`, or backticks in a target (empty-var catastrophe)
  - bare `*` / `./*` outside tmp (cwd-dependent blast radius — use explicit paths)
  - `~`, `$HOME`, or any path shallower than 4 components (/, /home, /home/<user>,
    /home/<user>/<top-level>; likewise /Users/... on macOS) — deleting a whole
    project dir requires the user
  - `xargs rm -r` (targets unknowable from the command text)
Tmp locations (/tmp, /private/tmp, /var/folders, $TMPDIR) are always allowed.
Non-recursive rm is never touched. Fails open on script errors.
"""
import json
import os
import re
import shlex
import sys
import tempfile

SEG_SPLIT = re.compile(r"(?:\|\|?|&&?|;)")
WRAPPERS = {"sudo", "env", "command", "nohup", "time", "builtin"}
SYSTEM_PREFIXES = ["/bin", "/sbin", "/usr", "/etc", "/var", "/opt", "/System",
                   "/Library", "/Applications", "/private", "/Volumes", "/cores",
                   "/Network", "/dev"]

REASON = (
    "Recursive rm blocked ({why}: {target!r}). User policy: no broad recursive deletion — "
    "no /, system dirs, home, top-level project dirs, bare *, or unexpanded variables. "
    "Delete a specific, explicit, deeper path instead (e.g. rm -rf <project>/target/debug), "
    "or ask the user to delete it themselves."
)


def safe_prefixes():
    prefixes = ["/tmp", "/private/tmp", "/var/folders", "/private/var/folders"]
    try:
        t = os.path.realpath(tempfile.gettempdir())
        prefixes.append(t)
    except Exception:
        pass
    return prefixes


def under(path, prefix):
    return path == prefix or path.startswith(prefix.rstrip("/") + "/")


def check_target(raw, cwd):
    """Return a deny-reason string, or None if this target is fine."""
    if "$" in raw or "`" in raw:
        return "unexpanded variable or substitution"
    t = os.path.expanduser(raw)
    if not os.path.isabs(t):
        t = os.path.join(cwd, t)
    t = os.path.normpath(t)
    globby = any(c in os.path.basename(t) for c in "*?[")
    base = os.path.dirname(t) if globby else t

    if any(under(base, s) for s in safe_prefixes()):
        return None
    if base == "/":
        return "filesystem root"
    if raw.rstrip("/") in ("*", "./*"):
        return "bare glob (cwd-dependent)"
    if any(under(base, s) for s in SYSTEM_PREFIXES):
        return "system directory"
    if len([p for p in base.split("/") if p]) < 4:
        return "too broad (home / top-level dir)"
    return None


def rm_hits(cmd, cwd):
    hits = []
    for seg in SEG_SPLIT.split(cmd):
        seg = seg.strip()
        if not seg:
            continue
        try:
            toks = shlex.split(seg)
        except ValueError:
            toks = seg.split()
        if not toks:
            continue
        i = 0
        while i < len(toks) and (toks[i] in WRAPPERS or re.match(r"^\w+=", toks[i])):
            i += 1
        if i >= len(toks):
            continue
        head, args = toks[i], toks[i + 1:]
        if head == "xargs" and "rm" in args:
            tail = args[args.index("rm") + 1:]
            if any(re.fullmatch(r"-[a-zA-Z]*[rR][a-zA-Z]*", a) or a == "--recursive" for a in tail):
                hits.append(("targets unknowable via xargs", "xargs rm -r"))
            continue
        if head != "rm":
            continue
        if "--no-preserve-root" in args:
            hits.append(("--no-preserve-root", "/"))
            continue
        recursive = any(
            (a.startswith("-") and not a.startswith("--") and re.search(r"[rR]", a))
            or a in ("--recursive", "-R")
            for a in args if a != "--"
        )
        if not recursive:
            continue
        if "--" in args:
            targets = args[args.index("--") + 1:]
        else:
            targets = [a for a in args if not a.startswith("-")]
        for raw in targets:
            why = check_target(raw, cwd)
            if why:
                hits.append((why, raw))
    return hits


def main():
    data = json.load(sys.stdin)
    if data.get("tool_name") != "Bash":
        return
    cmd = (data.get("tool_input") or {}).get("command", "")
    if "rm" not in cmd:
        return
    cwd = data.get("cwd") or os.getcwd()
    hits = rm_hits(cmd, cwd)
    if not hits:
        return
    why, target = hits[0]
    try:
        from datetime import datetime
        with open(os.path.expanduser("~/.claude/hooks/fire.log"), "a") as f:
            f.write(f"{datetime.now().isoformat(timespec='seconds')} PreToolUse rm-guard DENIED ({why}) {cmd[:120]!r}\n")
    except Exception:
        pass
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": REASON.format(why=why, target=target),
        }
    }))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
