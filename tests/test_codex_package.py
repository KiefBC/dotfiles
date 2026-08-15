import re
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
SETUP = REPO_ROOT / "setup.sh"
CODEX_PACKAGE = REPO_ROOT / "codex" / ".codex"
MANAGED_CODEX_PATHS = (
    Path("AGENTS.md"),
    Path("hooks.json"),
    Path("hooks/codex_hook.py"),
    Path("hooks/test_codex_hooks.py"),
)


class CodexDotfilesPackageTests(unittest.TestCase):
    def test_codex_package_contains_every_managed_file(self):
        missing = [path for path in MANAGED_CODEX_PATHS if not (CODEX_PACKAGE / path).is_file()]

        self.assertEqual(missing, [])

    def test_setup_deploys_and_backs_up_codex_home(self):
        setup = SETUP.read_text(encoding="utf-8")
        packages = re.search(r"STOW_PACKAGES=\(([^)]*)\)", setup)

        self.assertIsNotNone(packages)
        self.assertIn("codex", packages.group(1).split())
        self.assertRegex(setup, r'"claude"\s+\|\s+"codex"')


if __name__ == "__main__":
    unittest.main()
