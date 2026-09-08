#!/usr/bin/env python3
"""Codex lifecycle adapter for the personal Claude hook policy."""

import importlib.util
import io
import json
import os
import re
import shlex
import subprocess
import sys

CLAUDE_HOOKS = os.path.expanduser("~/.claude/hooks")
SHELL_PUNCTUATION = frozenset(";&|()<>")


def load(name):
    path = os.path.join(CLAUDE_HOOKS, name + ".py")
    spec = importlib.util.spec_from_file_location("claude_hook_" + name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def invoke(name, data):
    module = load(name)
    old_stdin, old_stdout = sys.stdin, sys.stdout
    sys.stdin, sys.stdout = io.StringIO(json.dumps(data)), io.StringIO()
    try:
        module.main()
        return sys.stdout.getvalue()
    except Exception:  # noqa: BLE001 - isolate independent lifecycle hooks
        return sys.stdout.getvalue()
    finally:
        sys.stdin, sys.stdout = old_stdin, old_stdout


def run_git(cwd, *args):
    command = ["git", *args]
    try:
        return subprocess.run(
            command, cwd=cwd, capture_output=True, text=True, timeout=8, check=False
        )
    except (OSError, subprocess.SubprocessError) as error:
        return subprocess.CompletedProcess(command, 1, "", str(error))


def pretool(data):
    tool = data.get("tool_name")
    if tool == "Bash":
        outputs = []
        for name in (
            "dep-install-gate",
            "git-commit-block",
            "git-guard",
            "rm-guard",
            "secrets-guard",
        ):
            if name == "git-commit-block" and direct_commit_in_linked_worktree(data):
                continue
            output = invoke(name, data)
            if output:
                outputs.append(json.loads(output))
        if not outputs:
            return
        denies = [
            x
            for x in outputs
            if x.get("hookSpecificOutput", {}).get("permissionDecision") == "deny"
        ]
        if denies:
            print(json.dumps(denies[0]))
            return
        contexts = [
            x["hookSpecificOutput"]["additionalContext"]
            for x in outputs
            if x.get("hookSpecificOutput", {}).get("additionalContext")
        ]
        if contexts:
            print(
                json.dumps(
                    {
                        "hookSpecificOutput": {
                            "hookEventName": "PreToolUse",
                            "permissionDecision": "allow",
                            "additionalContext": "\n\n".join(contexts),
                        }
                    }
                )
            )
    elif tool == "apply_patch":
        command = (data.get("tool_input") or {}).get("command", "")
        for raw in re.findall(
            r"^\*\*\* (?:Update|Delete|Add) File: (.+)$", command, re.MULTILINE
        ):
            if tracked_main_checkout(raw, data.get("cwd") or os.getcwd()):
                print(
                    json.dumps(
                        {
                            "hookSpecificOutput": {
                                "hookEventName": "PreToolUse",
                                "permissionDecision": "deny",
                                "permissionDecisionReason": (
                                    "User policy: edits to tracked files in a repository's main checkout are blocked. "
                                    "Enter a fresh worktree before editing, or create/approve the edit explicitly."
                                ),
                            }
                        }
                    )
                )
                return


def direct_commit_in_linked_worktree(data):
    tool_input = data.get("tool_input") or {}
    command = tool_input.get("command", "")
    if "\n" in command or "\r" in command:
        return False
    # Trust boundary: skip the blanket hook only when Git proves that the direct command, or an
    # absolute `git -C` command, targets a linked worktree.
    lexer = shlex.shlex(
        command, posix=True, punctuation_chars="".join(SHELL_PUNCTUATION)
    )
    lexer.whitespace_split = True
    lexer.commenters = ""
    try:
        tokens = list(lexer)
    except ValueError:
        return False
    if any(token and set(token) <= SHELL_PUNCTUATION for token in tokens):
        return False
    if len(tokens) >= 2 and tokens[:2] == ["git", "commit"]:
        target = tool_input.get("workdir") or data.get("cwd") or os.getcwd()
    elif (
        len(tokens) >= 4
        and tokens[:2] == ["git", "-C"]
        and tokens[3] == "commit"
        and os.path.isabs(tokens[2])
    ):
        target = tokens[2]
    else:
        return False
    return linked_worktree(target)


def linked_worktree(cwd):
    inside = run_git(cwd, "rev-parse", "--is-inside-work-tree")
    if inside.returncode != 0 or inside.stdout.strip() != "true":
        return False
    git_dir = run_git(cwd, "rev-parse", "--absolute-git-dir")
    common_dir = run_git(cwd, "rev-parse", "--git-common-dir")
    if git_dir.returncode != 0 or common_dir.returncode != 0:
        return False
    common = common_dir.stdout.strip()
    if not os.path.isabs(common):
        common = os.path.normpath(os.path.join(cwd, common))
    return os.path.realpath(git_dir.stdout.strip()) != os.path.realpath(common)


def tracked_main_checkout(raw, cwd):
    path = raw if os.path.isabs(raw) else os.path.join(cwd, raw)
    path = os.path.abspath(path)
    directory = os.path.dirname(path)
    inside = run_git(directory, "rev-parse", "--is-inside-work-tree")
    if inside.returncode != 0:
        return False
    gd = run_git(directory, "rev-parse", "--absolute-git-dir")
    gcd = run_git(directory, "rev-parse", "--git-common-dir")
    if gd.returncode or gcd.returncode:
        return False
    common = gcd.stdout.strip()
    if not os.path.isabs(common):
        common = os.path.normpath(os.path.join(directory, common))
    if os.path.realpath(gd.stdout.strip()) != os.path.realpath(common):
        return False
    return run_git(directory, "ls-files", "--error-unmatch", path).returncode == 0


def stop(data):
    output = invoke("stop-test-check", data)
    if not output:
        return
    result = json.loads(output)
    if result.get("decision") == "block":
        print(
            json.dumps(
                {
                    "continue": False,
                    "stopReason": result.get("reason", "Test check blocked the turn."),
                }
            )
        )


def main():
    data = json.load(sys.stdin)
    mode = os.environ.get("CODEX_HOOK_MODE", "")
    if mode == "pretool":
        pretool(data)
    elif mode == "prompt":
        data["prompt"] = data.get("prompt") or data.get("user_prompt", "")
        output = invoke("softener-detector", data)
        if output:
            print(
                json.dumps(
                    {
                        "hookSpecificOutput": {
                            "hookEventName": "UserPromptSubmit",
                            "additionalContext": output.strip(),
                        }
                    }
                )
            )
    elif mode == "session":
        output = invoke("sessionstart-compact", data)
        if output:
            print(
                json.dumps(
                    {
                        "hookSpecificOutput": {
                            "hookEventName": "SessionStart",
                            "additionalContext": output.strip(),
                        }
                    }
                )
            )
    elif mode == "stop":
        stop(data)


if __name__ == "__main__":
    try:
        main()
    except Exception:  # noqa: BLE001 - lifecycle adapters must not crash the tool runner
        sys.exit(0)
