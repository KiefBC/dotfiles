#!/usr/bin/env python3
"""SessionStart(matcher: compact) hook: after compaction, remind the model to re-read
active skills.

Empirical basis: compaction keeps conclusions but drops SKILL.md text and HARD-GATEs —
discipline decays exactly in long, late-session work. stdout on exit 0 is added to
context. Implemented as SessionStart:compact (verified injection path) rather than
PostCompact (context-injection support unconfirmed).
"""
import os
import sys

REMINDER = (
    "[hook: post-compaction reminder]\n"
    "Context was just compacted. Summaries keep conclusions but drop skill content and "
    "HARD-GATEs. If any skill from ~/.claude/skills/ applies to the ongoing task, Read its "
    "SKILL.md again before continuing — gates apply at full strength even if the summary "
    "implies they were already satisfied. Treat the summary's claims (\"tests pass\", "
    "\"verified\") as unverified until re-run if you are about to build on them."
)


def main():
    sys.stdin.read()
    try:
        from datetime import datetime
        with open(os.path.expanduser("~/.claude/hooks/fire.log"), "a") as f:
            f.write(f"{datetime.now().isoformat(timespec='seconds')} SessionStart compact-reminder\n")
    except Exception:
        pass
    print(REMINDER)


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
