# Docs Tooling Reference (verified July 2026)

Version-sensitive facts backing SKILL.md. The four-slot README gate, "document every public item," and "examples must run" are the durable core; below is the per-language tooling that *enforces* them and the version facts training data gets wrong.

## "Every public item documented" — enforcement per language

| Language | Mechanical gate | Notes |
|---|---|---|
| Rust | `#![warn(missing_docs)]` / `deny` in CI; `RUSTDOCFLAGS="-D warnings"` | Built into rustc. `rustdoc::broken_intra_doc_links` catches dead `[Type]` links |
| Go | revive `exported` rule; golangci-lint (bundles revive + `godot`) | No stdlib linter. Norm: every exported (capitalized) name; comment starts with the item's name. `godot` enforces trailing period |
| Python | Ruff `D` rules (`select = ["D"]`, convention `google`/`numpy`/`pep257`); interrogate `--fail-under` | Ruff absorbed pydocstyle/flake8-docstrings — it's the modern host, not standalone pydocstyle |
| TypeScript | TypeDoc `--validation.notDocumented` + `--validation.invalidLink`; eslint-plugin-jsdoc `require-jsdoc` | API Extractor `.api.md` reports double as a documented-surface check |
| C++ | Doxygen `WARN_IF_UNDOCUMENTED = YES` + `WARN_AS_ERROR` | Fails build on undocumented entities |

## "Examples must run" — native support ranked

| Language | Native runner | Status |
|---|---|---|
| Rust | rustdoc doctests — fenced ` ```rust ` in `///`, compiled+run by `cargo test` | **First-class.** Supports `#`-hidden setup, `no_run`, `compile_fail`, `should_panic`, `ignore` |
| Go | Testable examples: `Example`/`ExampleFoo` in `_test.go` with trailing `// Output:` | **First-class** — but `// Output:` (or `// Unordered output:`) is REQUIRED; without it the example compiles but is never checked |
| Python | stdlib `doctest`; `pytest --doctest-modules` / `--doctest-glob='*.md'`; Sybil, mktestdocs for prose/README blocks | Good. Use `--doctest-glob` or Sybil so README snippets can't rot |
| TypeScript | **None** — `@example` in TSDoc is NOT executed | **Must wire manually**: extract fenced TS blocks + typecheck/run (ts-node extraction, eslint-plugin-markdown to lint). TypeDoc alone does not satisfy the gate |
| C++ | **None** | Keep compiled example programs in CI, pull into docs via Doxygen `\include`/`\snippet` from real compilable files. (The C++ *doctest* testing framework is unrelated — not a doc-example runner) |

### Rust merged doctests (Edition 2024) — precise scope
- From the **2024 edition**, rustdoc compiles compatible doctests into a *single binary* instead of one-per-test (large speedup; Gomez PR #126245). **Edition-2024-only** — don't claim all crates get it.
- Not merged: tests using `compile_fail`, a per-test `edition` tag, or global attributes (`#[global_allocator]`); `standalone_crate` forces a test to stay separate (needed when line numbers / `type_name` / `Location` matter).
- Stable-channel bug (issue #138418) silently ignored merged doctests in edition 2024; fixed/backported 2025.
- `#[doc = include_str!("../README.md")]` makes the README double as crate-level docs AND get doctested — recommend it.

## Doc generators — version facts (training data likely stale)

| Tool | Version (Jul 2026) | Correction |
|---|---|---|
| TypeDoc | **0.28.x (0.28.20, 2026-07)** | Still **pre-1.0** — no 1.0 exists. Supports **TS up to 6.0** (as of 0.28.18); **no TS 7.0 / tsgo "Corsa" support** (needs the native-Go compiler's stable API, a TS 7.1 item). Keep type-analysis tooling on the TS 6.0 line |
| Doxygen | **v1.17.0 (2026-04-30)** | Actively maintained. Complaint is dated default HTML → use Doxygen-as-parser + m.css, Poxy (wraps Doxygen+m.css), or Breathe/Exhale→Sphinx. dox++/Standardese (libclang, emit Markdown) are niche |
| griffe (Python API) | **2.1.0 (2026-06)** | Engine behind mkdocstrings |

- **Comment grammars:** Go = pkg.go.dev's Go Doc Comments (go.dev/doc/comment); gofmt canonicalizes doc comments since Go 1.19; links are `[pkg.Symbol]` / `[Symbol]`. TS = TSDoc (`@microsoft/tsdoc`) is the *grammar*, TypeDoc the *renderer*.

## Python docs site: Sphinx vs MkDocs-Material — a real fork, not a default

| Pick | When |
|---|---|
| **Sphinx** | autodoc + cross-referenced API reference is the point; 100+ modules, deep type hierarchies, intersphinx, Read the Docs. reST is the cost; MyST-Markdown softens it |
| **MkDocs + Material for MkDocs** | apps, CLIs, internal handbooks, dev products; Markdown speed + good default theme over autodoc depth; styling is YAML |

Consensus phrasing: "new project/app → MkDocs-Material; big API-reference effort → Sphinx." API extraction on MkDocs side = **mkdocstrings** (engine: griffe); "plenty" for small-mid libraries. **Do not assert one universally.**

## README conventions — the four-slot gate maps to consensus section order

| Slot | Maps to | Note |
|---|---|---|
| **What** | title + one-line, zero-context description | plain language, no jargon |
| **Why** | "why this exists / vs alternatives" | **most-omitted section, biggest quality differentiator** |
| **Quickstart** | copy-paste-runnable install + minimal usage | dominant failure mode everywhere: examples that don't run / missing install step |
| **Status** | shields.io badges (build/version/coverage/license) and/or explicit "alpha/beta/stable/maintenance/archived" line | badges are the convention; an explicit status sentence is the more honest version |

- **Reference points:** Make a README (makeareadme.com) — approachable, most-cited; standard-readme (RichardLitt/standard-readme) — stricter spec with a linter + `standard-readme-compliant` badge.
- Length norm ~**500–1500 words**; headers/bullets; GIF/asciinema for anything with visible output. Don't over-engineer a small project's README into a docs site.

## Prose linter — Vale (repo moved; training data stale)

- **Canonical repo is now `github.com/vale-cli/vale`** (moved from `errata-ai/vale`). Old URLs redirect; a source citing errata-ai is pre-move. Latest **v3.x (~3.15)**, MIT, fully offline.
- Markup-aware (ignores Markdown/rST/AsciiDoc/HTML/code). Ships styles: Microsoft, Google, write-good, proselint, alex. Recent: **Views** (v3.12 — lint inside YAML/JSON/TOML/source), multi-word vocab (v3.15).
- Complementary/lighter: markdownlint (structural), proselint, alex, write-good — Vale can run these as styles, so it's the umbrella recommendation.

## Diátaxis — use as a lens, not a folder tree

- Four modes unchanged since 2020: **tutorial** (learning), **how-to** (task), **reference** (lookup), **explanation** (understanding). Canonical: **diataxis.fr** (Daniele Procida). Adopted by Python docs, Canonical/Ubuntu, Django, Gatsby.
- 2026 relevance is driven by **AI/RAG chunking** (four cleanly-separated modes retrieve better) — not a change to the framework.
- Real weaknesses to name: (1) **content drift** — quadrants blur under maintenance; (2) **over-application** — a single library/CLI does not need four doc trees. Load-bearing takeaway: **don't blend reference/task/explanation in one blob**; reserve the full tree for large docs sites.

## Docs-as-code — settled default; the caveat is writer friction

- Docs in-repo, Markdown/rST, PR-reviewed, CI-built, versioned with code — mainstream. Canonical: Write the Docs (writethedocs.org/guide/docs-as-code).
- Contested edge (name honestly): Tom Johnson's "broken promise" critique (git/CI friction burdens non-engineer writers). **But** State of Docs 2026: essentially no one migrates back to vendor CCMS — the response is professionalizing IA/tooling, not abandonment.

## llms.txt — an unratified proposal, NOT a standard (do not present as settled)

- Jeremy Howard's format: `/llms.txt` (curated Markdown links/summaries), optionally `/llms-full.txt`. **No IETF/W3C standardization** as of 2026.
- Adoption grew ~**8.8×** YoY to ~**36k** sites (May 2026), but **~97% of files received zero AI requests** (Ahrefs, 137k domains). **Google (May 2026) explicitly says it is NOT needed** for AI Overviews/AI Mode; platforms point to robots.txt for crawler control.
- Only demonstrated use: **IDE/coding agents** (Cursor, Windsurf, Claude Code, Copilot, Cline, Aider) fetch it when pointed at docs. So: practical for *developer-tool* docs, largely inert for general web/SEO. Skill red-flags adding it unprompted — matches this.
- Low-regret "docs for AI" techniques (help humans too, safe): serve clean Markdown, stable heading anchors, self-contained chunks, language-tagged code fences, Diátaxis separation. Avoid asserting: agent-only hidden content, a separate AI-only corpus, llms.txt as must-have.

## Key sources

- Rust doctests: doc.rust-lang.org/rustdoc/write-documentation/documentation-tests.html; edition-guide/rust-2024/rustdoc-doctests.html; PR #126245; issue #138418
- Go doc comments: go.dev/doc/comment; testable examples on pkg.go.dev
- TypeDoc: typedoc.org; npmjs.com/package/typedoc (0.28.20); TSDoc tsdoc.org
- Doxygen: doxygen.nl (v1.17.0); m.css; github.com/marzer/poxy
- Sphinx/MkDocs: squidfunk.github.io/mkdocs-material; mkdocstrings/griffe
- README: makeareadme.com; github.com/RichardLitt/standard-readme
- Vale: github.com/vale-cli/vale; vale.sh
- Diátaxis: diataxis.fr
- Docs-as-code: writethedocs.org/guide/docs-as-code; stateofdocs.com/2026
- llms.txt: caseyrb.com/blog/state-of-llms-txt-adoption; ppc.land (8.8× / 97% zero-fetch)
