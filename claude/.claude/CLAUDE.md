# Project documentation → Obsidian Context Vault

All documentation produced for projects and plans — implementation plans, design docs/specs, ADRs, changelogs, research, code reviews — is saved to the **Context Vault**, the Obsidian vault at `~/Documents/Obsidian/context-management`, via the Obsidian MCP (`mcp__obsidian__*` tools). Do not leave this material as loose markdown in project repos.

- Each project has its own directory in the vault (under `Personal Projects/` or `Work Projects/`), with subdirectories per note type: `Plans/`, `Decisions/` (ADRs), `Research/`, `Specs/`, `Guides/`, `Code Reviews/`, etc.
- The vault root has its own `CLAUDE.md` that governs style: directory convention, templates, frontmatter, tagging, and the note-creation flow. Read it (`mcp__obsidian__read_note` with path `CLAUDE.md`) before writing to the vault.
- Plan-mode output is saved as-is to the project's `Plans/` subdirectory with minimal frontmatter.

# Shell environment quirks

- **`curl` is aliased to `curlie`** — including in Claude's shell. Curlie prints response headers and colorizes/pretty-prints bodies by default, which corrupts piped or parsed output and makes scripts behave unexpectedly. When you need plain curl behavior (piping to `jq`, saving bodies, exact output), bypass the alias with `command curl` or `\curl`.

# Exploration via sub-agents

- **Delegate broad exploration to sub-agents.** When a task or skill requires exploring a codebase beyond a targeted lookup — multi-file sweeps, tracing behavior across a repo, surveying conventions — use Explore/general-purpose sub-agents (Opus-tier is sufficient) and keep only the conclusions in the main context. Direct reads are fine for single known files or symbols.

# Standing policy (Kiefer)

- **Work in a fresh git worktree** for any task that modifies files in a git repository: use EnterWorktree at the start of the task, before editing. Editing tracked files in a main checkout triggers a permission gate.
- **Commit completed, verified work in the task worktree** unless I explicitly ask you not to. Commit only task-scoped changes. Run `git commit` directly from the linked worktree, or use `git -C <absolute-worktree> commit`; never commit from the repository's main checkout. (Enforced by a hook.)
- **Always include a copyable merge command in the final response for worktree tasks**, together with the committed branch name and SHA. Use `git -C <absolute-main-checkout> merge <branch>` for a named branch, or `git -C <absolute-main-checkout> merge <commit-sha>` for a detached worktree.
- **Never delete broadly.** No `rm -rf` on `/`, system dirs, home, top-level project dirs, bare `*`, or unexpanded `$VARS` (enforced by a hook). Delete specific, explicit paths only.
