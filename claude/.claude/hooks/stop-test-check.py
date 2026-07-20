#!/usr/bin/env python3
"""Stop hook: block turn-end once if source files changed but no test additions are detectable.

Empirical basis: the single most-skipped step across all 27 skill baselines is the
regression/feature test around a code change. Heuristic: uncommitted changes vs HEAD.
Test evidence = a changed test-path file, or an added line containing a test marker
(covers Rust in-file #[test] modules). Blocks at most once per stop (stop_hook_active
guard). Fails open on any error.
"""
import json
import os
import re
import subprocess
import sys

SRC_EXTS = {".rs", ".py", ".go", ".ts", ".tsx", ".js", ".jsx", ".mjs", ".c", ".h",
            ".cc", ".cpp", ".hpp", ".java", ".rb", ".swift", ".kt", ".zig", ".cs",
            ".ex", ".exs"}

TEST_PATH = re.compile(
    r"(^|/)(tests?|spec|specs|__tests__)(/|$)|(_test|\.test|\.spec|_spec)\.|(^|/)test_|conftest\.py",
    re.IGNORECASE,
)

TEST_MARKERS = re.compile(
    r"#\[(?:tokio::)?test\]|#\[cfg\(test\)\]|#\[test_case|proptest!"
    r"|\bdef\s+test_|\bfn\s+test_|\bfunc\s+Test[A-Z]"
    r"|\b(?:it|test|describe)\s*\(|@Test\b|\bunittest\b|\bpytest\b"
)

REASON = (
    "Turn-end check: source files changed ({files}) but no test additions were detected in the "
    "diff. If this turn included a feature or bugfix, the test is required (advanced-testing "
    "HARD-GATE): write it, see it fail where applicable, run it. If tests are genuinely "
    "inapplicable to this change (docs/config-only, pure refactor already covered — then run the "
    "existing suite), state that explicitly to the user and finish. This check will not block again."
)


def git(cwd, *args):
    return subprocess.run(["git", *args], cwd=cwd, capture_output=True, text=True, timeout=10)


def main():
    data = json.load(sys.stdin)
    if data.get("stop_hook_active"):
        return
    cwd = data.get("cwd") or os.getcwd()
    if git(cwd, "rev-parse", "--is-inside-work-tree").returncode != 0:
        return

    status = git(cwd, "status", "--porcelain")
    if status.returncode != 0:
        return
    changed, untracked = [], []
    for line in status.stdout.splitlines():
        if len(line) < 4:
            continue
        code, path = line[:2], line[3:]
        if " -> " in path:
            path = path.split(" -> ", 1)[1]
        path = path.strip().strip('"')
        (untracked if code == "??" else changed).append(path)

    all_paths = changed + untracked
    def is_src(p):
        return os.path.splitext(p)[1].lower() in SRC_EXTS
    src_changed = [p for p in all_paths if is_src(p) and not TEST_PATH.search(p)]
    test_changed = [p for p in all_paths if is_src(p) and TEST_PATH.search(p)]
    if not src_changed:
        return
    if test_changed:
        return

    # No test-named files changed; look for in-file test additions (e.g. Rust #[test] modules).
    added = []
    if git(cwd, "rev-parse", "HEAD").returncode == 0:
        diff = git(cwd, "diff", "HEAD", "-U0", "--no-color", "--", *[p for p in changed if is_src(p)])
        if diff.returncode == 0:
            added = [l[1:] for l in diff.stdout.splitlines()
                     if l.startswith("+") and not l.startswith("+++")]
    for p in untracked:
        if not is_src(p):
            continue
        try:
            with open(os.path.join(cwd, p), "r", errors="ignore") as f:
                added.extend(f.read(200_000).splitlines())
        except OSError:
            pass
    if any(TEST_MARKERS.search(l) for l in added):
        return

    try:
        from datetime import datetime
        with open(os.path.expanduser("~/.claude/hooks/fire.log"), "a") as f:
            f.write(f"{datetime.now().isoformat(timespec='seconds')} Stop test-check BLOCKED {src_changed[:5]}\n")
    except Exception:
        pass
    shown = ", ".join(src_changed[:5]) + (", …" if len(src_changed) > 5 else "")
    print(json.dumps({"decision": "block", "reason": REASON.format(files=shown)}))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
