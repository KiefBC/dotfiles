#!/usr/bin/env python3
import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

HOOK = os.path.join(os.path.dirname(__file__), "codex_hook.py")


def run_hook(event, payload, mode):
    env = os.environ.copy()
    env["CODEX_HOOK_MODE"] = mode
    result = subprocess.run(
        [sys.executable, HOOK],
        input=json.dumps({"hook_event_name": event, **payload}),
        text=True,
        capture_output=True,
        env=env,
        check=False,
    )
    return result.returncode, result.stdout, result.stderr


class CodexHookAdapterTests(unittest.TestCase):
    def setUp(self):
        self.tempdir = tempfile.TemporaryDirectory()
        self.addCleanup(self.tempdir.cleanup)
        root = Path(self.tempdir.name)
        self.main = root / "main"
        self.linked = root / "linked"
        self.main.mkdir()
        subprocess.run(["git", "init", "-q"], cwd=self.main, check=True)
        subprocess.run(
            [
                "git",
                "-c",
                "user.name=Hook Tests",
                "-c",
                "user.email=hook-tests@example.invalid",
                "commit",
                "-q",
                "--allow-empty",
                "--no-gpg-sign",
                "-m",
                "initial",
            ],
            cwd=self.main,
            check=True,
        )
        subprocess.run(
            ["git", "worktree", "add", "-q", "--detach", self.linked],
            cwd=self.main,
            check=True,
        )

    def test_commit_is_denied_in_main_checkout(self):
        code, out, _ = run_hook(
            "PreToolUse",
            {
                "tool_name": "Bash",
                "cwd": os.fspath(self.main),
                "tool_input": {"command": "git commit -m x"},
            },
            "pretool",
        )
        self.assertEqual(code, 0)
        decision = json.loads(out)["hookSpecificOutput"]
        self.assertEqual(decision["permissionDecision"], "deny")

    def test_commit_is_allowed_in_linked_worktree(self):
        code, out, err = run_hook(
            "PreToolUse",
            {
                "tool_name": "Bash",
                "cwd": os.fspath(self.linked),
                "tool_input": {"command": "git commit -m x"},
            },
            "pretool",
        )

        self.assertEqual((code, out, err), (0, "", ""))

    def test_indirect_commit_is_denied_from_linked_worktree(self):
        _, out, _ = run_hook(
            "PreToolUse",
            {
                "tool_name": "Bash",
                "cwd": os.fspath(self.linked),
                "tool_input": {"command": f"git -C {self.main} commit -m x"},
            },
            "pretool",
        )

        decision = json.loads(out)["hookSpecificOutput"]
        self.assertEqual(decision["permissionDecision"], "deny")

    def test_absolute_git_c_commit_is_allowed_for_linked_worktree(self):
        command = f"git -C {self.linked} commit -m x"

        code, out, err = run_hook(
            "PreToolUse",
            {
                "tool_name": "Bash",
                "cwd": os.fspath(self.main),
                "tool_input": {"command": command},
            },
            "pretool",
        )

        self.assertEqual((code, out, err), (0, "", ""))

    def test_commit_with_missing_working_directory_is_denied(self):
        missing = Path(self.tempdir.name) / "missing"

        _, out, _ = run_hook(
            "PreToolUse",
            {
                "tool_name": "Bash",
                "cwd": os.fspath(missing),
                "tool_input": {"command": "git commit -m x"},
            },
            "pretool",
        )

        decision = json.loads(out)["hookSpecificOutput"]
        self.assertEqual(decision["permissionDecision"], "deny")

    def test_dependency_install_adds_context(self):
        _, out, _ = run_hook(
            "PreToolUse",
            {"tool_name": "Bash", "tool_input": {"command": "npm install lodash"}},
            "pretool",
        )
        decision = json.loads(out)["hookSpecificOutput"]
        self.assertIn("dependency install detected", decision["additionalContext"])

    def test_softener_prompt_adds_context(self):
        _, out, _ = run_hook(
            "UserPromptSubmit", {"prompt": "just get it working"}, "prompt"
        )
        self.assertIn("scope-softener detected", out)

    def test_stop_test_check_uses_codex_stop_shape(self):
        with tempfile.TemporaryDirectory() as cwd:
            subprocess.run(["git", "init", "-q"], cwd=cwd, check=True)
            with open(os.path.join(cwd, "app.py"), "w") as f:
                f.write("print('changed')\n")
            _, out, _ = run_hook("Stop", {"cwd": cwd}, "stop")
            self.assertEqual(json.loads(out)["continue"], False)


if __name__ == "__main__":
    unittest.main()
