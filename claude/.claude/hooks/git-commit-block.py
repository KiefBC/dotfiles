#!/usr/bin/env python3
"""PreToolUse(Bash) hook: allow commits only in linked Git worktrees.

A direct ``git commit`` or ``git -C /absolute/worktree commit`` may pass. Other commands that
change shell or Git context are denied so the hook always verifies the repository actually used.
"""

import json
import os
import re
import shlex
import subprocess
import sys

GIT_COMMIT = re.compile(r"\bgit(?:\s+(?:-[cC]\s+\S+|--?[\w.=/-]+))*\s+commit\b")
SHELL_PUNCTUATION = frozenset(";&|()<>")

MAIN_CHECKOUT_REASON = (
    "User policy: commits are allowed only in a linked task worktree, never in a repository's "
    "main checkout or outside a verified linked worktree. Enter a fresh worktree and run the "
    "commit there."
)
INDIRECT_COMMAND_REASON = (
    "User policy: run `git commit` directly from the linked task worktree, or use "
    "`git -C /absolute/linked/worktree commit`. Relative `git -C` paths and other commands that "
    "change shell or Git context are denied because their actual target cannot be verified safely."
)


def git(cwd: str, *args: str) -> subprocess.CompletedProcess[str]:
    command = ["git", *args]
    try:
        return subprocess.run(
            command, cwd=cwd, capture_output=True, text=True, timeout=8, check=False
        )
    except (OSError, subprocess.SubprocessError) as error:
        return subprocess.CompletedProcess(command, 1, "", str(error))


def shell_tokens(command: str) -> list[str] | None:
    lexer = shlex.shlex(
        command, posix=True, punctuation_chars="".join(SHELL_PUNCTUATION)
    )
    lexer.whitespace_split = True
    lexer.commenters = ""
    try:
        return list(lexer)
    except ValueError:
        return None


def contains_commit(tokens: list[str] | None, command: str) -> bool:
    if tokens is None:
        return bool(GIT_COMMIT.search(command))
    return any(
        token == "git" and "commit" in tokens[index + 1 :]
        for index, token in enumerate(tokens)
    )


def commit_target(tokens: list[str] | None, command: str, cwd: str) -> str | None:
    if tokens is None or "\n" in command or "\r" in command:
        return None
    if any(token and set(token) <= SHELL_PUNCTUATION for token in tokens):
        return None
    if len(tokens) >= 2 and tokens[:2] == ["git", "commit"]:
        return cwd
    if (
        len(tokens) >= 4
        and tokens[:2] == ["git", "-C"]
        and tokens[3] == "commit"
        and os.path.isabs(tokens[2])
    ):
        return tokens[2]
    return None


def is_linked_worktree(cwd: str) -> bool:
    inside = git(cwd, "rev-parse", "--is-inside-work-tree")
    if inside.returncode != 0 or inside.stdout.strip() != "true":
        return False
    git_dir = git(cwd, "rev-parse", "--absolute-git-dir")
    common_dir = git(cwd, "rev-parse", "--git-common-dir")
    if git_dir.returncode != 0 or common_dir.returncode != 0:
        return False
    common = common_dir.stdout.strip()
    if not os.path.isabs(common):
        common = os.path.normpath(os.path.join(cwd, common))
    return os.path.realpath(git_dir.stdout.strip()) != os.path.realpath(common)


def deny(reason: str) -> None:
    print(
        json.dumps(
            {
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": "deny",
                    "permissionDecisionReason": reason,
                }
            }
        )
    )


def log_fire(note: str) -> None:
    try:
        from datetime import datetime, timezone

        with open(os.path.expanduser("~/.claude/hooks/fire.log"), "a") as f:
            f.write(
                f"{datetime.now(timezone.utc).isoformat(timespec='seconds')} "
                f"PreToolUse commit-worktree-gate {note}\n"
            )
    except OSError:
        return


def main():
    data = json.load(sys.stdin)
    if data.get("tool_name") != "Bash":
        return
    tool_input = data.get("tool_input") or {}
    command = tool_input.get("command", "")
    # Trust boundary: command and cwd come from the hook payload; accept only a direct command
    # whose current repository Git itself proves is a linked worktree.
    tokens = shell_tokens(command)
    if not contains_commit(tokens, command):
        return
    cwd = tool_input.get("workdir") or data.get("cwd") or os.getcwd()
    target = commit_target(tokens, command, cwd)
    if target is None:
        log_fire(f"DENIED indirect {command[:120]!r}")
        deny(INDIRECT_COMMAND_REASON)
        return
    if not is_linked_worktree(target):
        log_fire(f"DENIED main-or-unverified cwd={target!r} {command[:120]!r}")
        deny(MAIN_CHECKOUT_REASON)
        return
    log_fire(f"allowed linked-worktree cwd={target!r}")


if __name__ == "__main__":
    try:
        main()
    except Exception:  # noqa: BLE001 - a policy-hook failure must deny, not cancel the hook
        deny(MAIN_CHECKOUT_REASON)
    sys.exit(0)
