#!/usr/bin/env python3
"""UserPromptSubmit hook: detect scope-softening language and inject a discipline reminder.

Empirical basis (skill-suite baselines, 2026-07): phrases like "just get it working"
delete verification/tests/structure in the model's output. This hook fires the counter
at exactly the moment no skill may be loaded. stdout on exit 0 is added to context.
Fails open: any error -> no output, exit 0.
"""
import json
import os
import re
import sys

PATTERNS = [
    r"just get (?:it|this|that|something) working",
    r"just make it work",
    r"quick[- ]?(?:and|n)[- ]?dirty",
    r"nothing fancy",
    r"keep it simple",
    r"don'?t overthink",
    r"quick fix",
    r"real quick",
    r"doesn'?t (?:need|have) to be (?:perfect|pretty|fancy|thorough|robust)",
    r"no need (?:for|to be|to write) (?:tests|thorough|fancy|careful)",
    r"just hack",
    r"good enough for now",
    r"(?:we|you) can clean (?:it |this )?up later",
    r"skip the (?:tests|ceremony|process|formalities)",
    r"bang (?:it|this|one) out",
    r"don'?t worry about (?:tests|edge cases|error handling)",
]

REMINDER = (
    '[hook: scope-softener detected — "{phrase}"]\n'
    "Softening language scopes the FEATURE, not the discipline. Empirically, this phrasing "
    "is where output quality collapses: verification gets skipped, tests get dropped, structure "
    "dissolves. Requirements unchanged: verify before claiming done (run the code, run the tests), "
    "features and bugfixes still get tests first, error handling and structure still apply at full "
    "strength. Check ~/.claude/skills/ for an applicable skill (e.g. advanced-testing, code-quality) "
    "and Read its SKILL.md before starting."
)


def log_fire(note):
    try:
        from datetime import datetime
        with open(os.path.expanduser("~/.claude/hooks/fire.log"), "a") as f:
            f.write(f"{datetime.now().isoformat(timespec='seconds')} UserPromptSubmit softener {note}\n")
    except Exception:
        pass


def main():
    data = json.load(sys.stdin)
    prompt = data.get("prompt") or data.get("user_prompt") or ""
    for pat in PATTERNS:
        m = re.search(pat, prompt, re.IGNORECASE)
        if m:
            log_fire(repr(m.group(0)))
            print(REMINDER.format(phrase=m.group(0)))
            return


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
