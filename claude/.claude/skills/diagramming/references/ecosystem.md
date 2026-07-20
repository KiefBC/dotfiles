# Diagramming Ecosystem Reference (verified July 2026)

Version-sensitive facts backing SKILL.md. The skill's timeless calls (when a diagram beats prose, one-concern-per-diagram, live-next-to-code) stand on their own; this file pins the **rendering-surface and stability** facts, which is exactly what training data gets wrong. Version numbers move fast — the skill deliberately hard-codes no version.

## Mermaid — the default (and why)

Mermaid is the settled default for **diagrams that must render with zero setup on a Markdown surface**. Nothing else renders natively on GitHub — that single fact dominates tool choice for repo docs.

- Current release line **v11.16.0** (docs site); **v11.13.0** was the notable "most polished" mid-2026 drop. Do not hard-code a version.
- ~30 diagram types. **Stable, safe-everywhere core:** flowchart, sequence, class, state, entity-relationship, user-journey, gantt, pie, gitGraph, mindmap, timeline, quadrant, requirement.
- **Newer (stable in Mermaid, may not render on lagging hosts):** sankey, xychart, block, packet, kanban, **architecture** (cloud/infra icons), radar, treemap, event-modeling.
- **Beta/experimental — syntax can change under you:** **C4** (official docs say experimental, "syntax and properties can change"), plus opt-in `-beta` types: `venn-beta`, `wardley-beta`, `treeView-beta`, cynefin. Stick to stable core for anything long-lived; treat beta as throwaway.

### GitHub rendering traps (the #1 correction)
- **"Mermaid supports X" ≠ "GitHub renders X."** GitHub pins an older Mermaid and **lags upstream** — a type that works in the Mermaid Live Editor can render as an error block on GitHub. **Verify new/beta types on GitHub before committing.**
- GitHub renders Mermaid in Markdown files, Issues, PRs, Discussions, wikis — but **GitHub Pages does NOT render Mermaid by default** (Jekyll doesn't process it; needs a plugin / build-time render action). "Renders in my README" ≠ "renders on my Pages site."
- Gist editor preview doesn't render until published; the GitHub iOS app historically shows raw code.
- **GitLab** added Mermaid before GitHub, more mature (incl. self-hosted), but may be on a different version — no cross-host feature parity.
- **Obsidian**: native, plus first-class `Mermaid View` plugin. **VS Code**: not native to core; via official Mermaid Chart extension.

### The v11 Markdown-labels breaking change (training data likely misses)
Mermaid v11 changed flowchart plain-text labels to be **treated as Markdown by default**, silently breaking `\n` line breaks and v10 diagrams. **v11.13.0 reverted plain-text labels to plain text.** If line breaks look wrong, this is why — **use `<br>` for hard breaks**, don't rely on `\n`.

### Size limits (encode these)
- **`maxTextSize` default 50,000 chars**; over it, rendering is refused. Raisable via `%%{init}%%` — but **hosted renderers (GitHub) use the default and you can't override their cap**, so a huge diagram just won't render there.
- Practical ceiling is well below the char cap: ~50+ nodes get slow/unreadable. If approaching this, it's violating one-concern-per-diagram — **split, don't raise the limit**.

### Dark mode (real footgun)
- **Do NOT set an explicit `theme` in `%%{init}%%` for GitHub-committed diagrams.** GitHub auto-detects `prefers-color-scheme` and picks readable light/dark colors; hard-coding a theme (or fixed `themeVariables`) overrides that and typically yields **dark-text-on-dark-background** in the mode you didn't test.
- Residual bug: GitHub's mindmap rendering has had dark-mode contrast problems even without a custom theme; Mermaid doesn't always re-render on a live system-theme switch. Only touch `themeVariables` after verifying both modes.

## Other tools — pick by rendering surface + artifact lifetime

| Tool | Native on GitHub/Markdown? | Choose when |
|---|---|---|
| **Mermaid** | **Yes** (only one) | Must render in the README with zero setup — the default |
| **D2** | **No** — needs CLI build → SVG/PNG or Kroki | Layout quality on a nontrivial architecture diagram matters AND you have a build/publish step |
| **PlantUML** | No — needs Kroki/proxy or rendered image | Full UML fidelity is the actual requirement |
| **Graphviz / DOT** | No | Large **machine-generated** graphs (dependency/call/IR), hundreds of nodes, hand-layout hopeless |
| **Structurizr (DSL)** | No (renderable via Kroki) | A real, **maintained C4 model** |
| **Excalidraw** | n/a (`.excalidraw` JSON, weakly diffable) | Sketches, whiteboards, workshop/planning artifacts |
| **tldraw** | n/a | *Building* a canvas feature (SDK), not drawing a diagram |
| **Kroki** | unified HTTP render API | Docs pipeline wanting D2/PlantUML/Structurizr quality but needs committed/served images; self-host to avoid leaking internal diagrams |

### D2 — strong challenger, one disqualifying limit
Modern Go language (open-sourced by Terrastruct Nov 2022), widely regarded as **better-looking/better-laid-out than Mermaid**; layout engines `dagre` (default), `ELK`, **TALA** (proprietary, paid). **Disqualifying limit for repo docs: does not render natively on GitHub/GitLab/most Markdown surfaces** — always needs a build step or Kroki. That, not quality, is its real limitation. **Health signal (training data won't know):** D2's creator **joined OpenAI**; project moving to **non-profit stewardship via Hack Club** to stay OSS after slowing-activity concern — not abandoned, but single-maintainer momentum questions are real.

### PlantUML — Java objection is weaker now
Actively maintained on the monthly-ish `1.2026.x` scheme (bus-factor: largely Arnaud Roques + community). Most complete UML coverage. **New in 2026:** `@plantuml/core` on npm runs the engine **in-browser via TeaVM (no Java)**; `@plantuml/mcp-js` is a pure-Node MCP server; recent versions **bundle a minimal `dot`** so a separate Graphviz install is usually unnecessary. Still not native on GitHub. Choose only when full UML fidelity is the requirement; for lightweight sequence/class, Mermaid is lower-friction.

## C4 model tooling (settled recommendation)

C4 is a modeling *approach* (Context / Container / Component / Code — nested zoom), the canonical "one concern per diagram" at architecture scale.

- **Structurizr (DSL)** for **long-lived, maintained C4**: key property is **separating the model from the views** — define elements/relationships once, render many views, add a view years later without redrawing. Renderable via Kroki.
- **Mermaid C4 is experimental** (official docs say so) with the **weakest layout** of the C4-capable options — use only for a throwaway sketch that must render on GitHub *today*; never build a maintained C4 model on it.
- PlantUML (C4-PlantUML macros) is a good-fidelity middle option with non-native rendering.

## GUI vs code-first — segments by artifact lifetime, not either/or (2026)

Code-first (Mermaid/D2) for diagrams that must stay in sync with code and live in the repo. Excalidraw for ephemeral sketches/whiteboards (deliberately hand-drawn look). Don't put a whiteboard sketch where a maintained diagram belongs, or force brainstorming into Mermaid. **Biggest 2026 shift:** MCP servers fronting Excalidraw, tldraw, and Mermaid so an agent can edit the canvas directly — the movement is hybrid (agent-editable canvases), not a winner between code-first and GUI.

## Notable deltas vs stale assumptions

1. **"Mermaid supports X" ≠ "GitHub renders X"** — GitHub pins/lags; verify before committing. Most important single correction.
2. **Mermaid C4 is experimental**, not production-stable; Structurizr is the maintained-C4 answer.
3. **GitHub Pages does not render Mermaid by default** (Jekyll) — separate from README rendering.
4. **No explicit Mermaid `theme` for GitHub-committed diagrams** — breaks automatic dark-mode adaptation.
5. **D2 renders natively nowhere GitHub-like** — always needs build/Kroki; that's the limit, not quality.
6. **PlantUML no longer requires Java** for many workflows (2026 `@plantuml/core`, bundled `dot`).
7. **D2 maintainer joined OpenAI; project → Hack Club stewardship** — health signal, not abandonment.
8. **Mermaid v11 briefly treated labels as Markdown** (broke `\n`); reverted in v11.13.0.
9. **`maxTextSize` default 50,000 chars**, can't raise a hosted cap — oversized diagrams just fail; fix is splitting.

## Key sources (all verified July 2026)

- mermaid.js.org + /intro/ (v11.16.0, type list, experimental markers); /syntax/c4.html (experimental notice)
- mermaid v11.13.0 release notes (plain-text-label fix); github.com/mermaid-js/mermaid/releases
- maxTextSize 50,000: mermaid-js/mermaid#7778
- github.blog + docs.github.com Mermaid rendering (surfaces, version lag); community#13761 (Pages/Jekyll); community#12116 / #189152 (dark mode)
- github.com/terrastruct/d2 + discussions/2720 (OpenAI/Hack Club); github.com/terrastruct/TALA
- plantuml.github.io + plantuml.com/faq + /graphviz-dot (1.2026.x, @plantuml/core, bundled dot)
- Structurizr vs Mermaid C4: hidekazu-konishi.com C4 selection guide; databasesystems.info Structurizr (Jan 2026)
- kroki.io + github.com/yuzutech/kroki (unified renderer)
- Excalidraw vs tldraw + MCP trend: openalternative.co; nimbalyst.com (2026)
