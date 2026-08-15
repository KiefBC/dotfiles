#!/usr/bin/env python3
import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

HOOK = Path(__file__).with_name("git-commit-block.py")


def git(cwd, *args):
    return subprocess.run(
        ["git", *args], cwd=cwd, check=True, capture_output=True, text=True
    )


def run_hook(cwd, command):
    payload = {
        "hook_event_name": "PreToolUse",
        "tool_name": "Bash",
        "cwd": os.fspath(cwd),
        "tool_input": {"command": command},
    }
    return subprocess.run(
        [sys.executable, HOOK],
        input=json.dumps(payload),
        text=True,
        capture_output=True,
        check=True,
    ).stdout


def decision(output):
    return json.loads(output)["hookSpecificOutput"]["permissionDecision"]


class GitCommitBlockTests(unittest.TestCase):
    def setUp(self):
        self.tempdir = tempfile.TemporaryDirectory()
        self.addCleanup(self.tempdir.cleanup)
        root = Path(self.tempdir.name)
        self.main = root / "main"
        self.linked = root / "linked"
        self.main.mkdir()
        git(self.main, "init", "-q")
        git(self.main, "config", "user.name", "Hook Tests")
        git(self.main, "config", "user.email", "hook-tests@example.invalid")
        git(self.main, "config", "commit.gpgsign", "false")
        (self.main / "tracked.txt").write_text("initial\n", encoding="utf-8")
        git(self.main, "add", "tracked.txt")
        git(self.main, "commit", "-q", "-m", "initial")
        git(self.main, "worktree", "add", "-q", "--detach", self.linked)

    def test_commit_is_denied_in_main_checkout(self):
        output = run_hook(self.main, "git commit -m x")

        self.assertEqual(decision(output), "deny")
        self.assertIn("main checkout", output)

    def test_commit_is_allowed_in_linked_worktree(self):
        self.assertEqual(run_hook(self.linked, "git commit -m x"), "")

    def test_amend_is_allowed_in_linked_worktree(self):
        self.assertEqual(run_hook(self.linked, "git commit --amend --no-edit"), "")

    def test_absolute_git_c_commit_is_allowed_for_linked_worktree(self):
        command = f"git -C {self.linked} commit -m x"

        self.assertEqual(run_hook(self.main, command), "")

    def test_relative_git_c_commit_is_denied(self):
        output = run_hook(self.main, "git -C ../linked commit -m x")

        self.assertEqual(decision(output), "deny")
        self.assertIn("absolute", output)

    def test_quoted_shell_punctuation_in_message_is_allowed(self):
        command = "git commit -m 'safe && quoted; message'"

        self.assertEqual(run_hook(self.linked, command), "")

    def test_commit_outside_a_repository_is_denied(self):
        outside = Path(self.tempdir.name) / "outside"
        outside.mkdir()

        output = run_hook(outside, "git commit -m x")

        self.assertEqual(decision(output), "deny")
        self.assertIn("linked worktree", output)

    def test_commit_with_missing_working_directory_is_denied(self):
        missing = Path(self.tempdir.name) / "missing"

        output = run_hook(missing, "git commit -m x")

        self.assertEqual(decision(output), "deny")
        self.assertIn("linked worktree", output)

    def test_git_config_commit_setting_is_not_a_commit(self):
        self.assertEqual(
            run_hook(self.main, "git config commit.template template.txt"), ""
        )

    def test_generated_context_changing_commands_are_denied(self):
        git_dir = self.main / ".git"
        prefixes = [
            f"git -C {self.main} ",
            f"git --git-dir={git_dir} --work-tree={self.main} ",
            f"GIT_DIR={git_dir} GIT_WORK_TREE={self.main} git ",
            f"cd {self.main} && git ",
        ]
        commands = [
            f"{prefix}commit -m {message}"
            for prefix in prefixes
            for message in ("x", "'quoted; message'")
        ]
        commands.extend(
            [
                f"git commit -m x && git -C {self.main} commit -m y",
                f"git commit -m x\ngit -C {self.main} commit -m y",
            ]
        )

        for command in commands:
            with self.subTest(command=command):
                output = run_hook(self.linked, command)
                self.assertEqual(decision(output), "deny")


if __name__ == "__main__":
    unittest.main()
