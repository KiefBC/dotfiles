# Project documentation → Obsidian Context Vault

All documentation produced for projects and plans—implementation plans, design docs/specs,
ADRs, changelogs, research, code reviews, and similar artifacts—must be saved to the Context
Vault at `/Users/kiefer/Documents/Obsidian/context-management` through the Obsidian MCP.
Do not leave this material as loose Markdown in project repositories.

- Each project has its own directory in the vault under `Personal Projects/` or `Work Projects/`,
  with subdirectories for note types such as `Plans/`, `Decisions/`, `Research/`, `Specs/`,
  `Guides/`, and `Code Reviews/`.
- Before writing to the vault, read its `CLAUDE.md` note through the Obsidian MCP using path
  `CLAUDE.md`. It defines the directory convention, templates, frontmatter, tagging, and note-
  creation flow.
- Save plan-mode output as-is in the project's `Plans/` directory with minimal frontmatter.

# Shell environment quirks

- `curl` is aliased to `curlie`, including in Codex's shell. Curlie prints response headers and
  colorizes/pretty-prints bodies by default, which can corrupt piped or parsed output. When plain
  curl behavior is needed, use `command curl` or `\curl`.

# Exploration via sub-agents

- Delegate broad exploration to sub-agents. When a task requires exploring a codebase beyond a
  targeted lookup—multi-file sweeps, behavior tracing, or convention surveys—use an Explore or
  general-purpose sub-agent and keep only the conclusions in the main context. Direct reads are
  fine for a single known file or symbol.

# Standing policy (Kiefer)

- Work in a fresh git worktree for tasks that modify files in a git repository. Create or enter
  the worktree before editing. The Codex worktree hook blocks edits to tracked files in a main
  checkout.
- Unless Kiefer explicitly asks you not to, commit completed and verified work from the linked
  task worktree. Commit only task-scoped changes. Run `git commit` directly from that worktree or
  use `git -C <absolute-worktree> commit`; never commit from the repository's main checkout. This
  is enforced by a Codex hook.
- Always include a copyable merge command in the final response for worktree tasks, together with
  the committed branch name and SHA. Use `git -C <absolute-main-checkout> merge <branch>` for a
  named branch, or `git -C <absolute-main-checkout> merge <commit-sha>` for a detached worktree.
- Never delete broadly. Do not use `rm -rf` on `/`, system directories, the home directory,
  top-level project directories, bare `*`, or unexpanded `$VARS`. Delete only specific, explicit
  paths.

# Documentation and library references

When a task asks about a library, framework, SDK, API, CLI tool, or cloud service, use Context7
to fetch current documentation before answering or implementing. Start with `resolve-library-id`,
select the best `/org/project` match, then use `query-docs` with the full question scoped to one
concept. Use separate queries for separate concepts unless the question is specifically about
their interaction.

Do not use Context7 for refactoring, writing scripts from scratch, debugging business logic,
code review, or general programming concepts.
