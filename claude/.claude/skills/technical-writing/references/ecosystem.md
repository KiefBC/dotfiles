# Technical-Writing Tooling & Standards Reference (verified July 2026)

Version-sensitive facts backing SKILL.md. The core (lead with the conclusion, one idea per paragraph, concrete over abstract, cut decorative hedging, reader-first structure) is durable and not controversial — it predates and outlives the tooling below. This file pins the authorities to cite, the tools that actually exist in 2026 under their current names, and the empirical backing for the anti-slop list.

## Style guides — current editions (vendor guides are living web docs, NOT books)

| Guide | Status / date | What to know |
|---|---|---|
| **Google developer docs style** | Living web guide, no edition; last substantive update **2026-04-27** | developers.google.com/style. Default for engineering prose. **Sentence case** headings, **second person**, **active voice**, **present tense**, contractions fine. Word list is the term-by-term reference. "What's new" page (renamed from "Release notes"). Recent: GCP→Google Cloud, "internet" now lowercase, new Headings/Placeholders pages |
| **Microsoft Writing Style Guide** | Free web guide; "What's new" **2026-05-29** | learn.microsoft.com/style-guide. **The print *Microsoft Manual of Style* 4th ed. (2012) was RETIRED in 2018** — do NOT cite the book as current. Warm/relaxed voice, contractions encouraged, strong bias-free/inclusive + accessibility guidance ("select" not "click"), mature bots/chat/AI guidance |
| **Apple Style Guide** | Web + PDF, current edition **June 2026** | Mainly terminology/product names. **Defers to Chicago Manual for general style and Merriam-Webster for spelling** — cite as the "fall back to Chicago + Merriam-Webster" pattern |
| **Chicago Manual of Style** | 18th ed., 2024 | The one real book edition; general-English fallback |

Recommendation: **Google** default for developer prose; **Microsoft** for product-UI + inclusive-language depth; **Chicago + Merriam-Webster** general-English fallback. Only Chicago has a fixed edition number.

## Prose linters — names, versions, the big rename

- **Vale** is the dominant configurable linter. Latest **3.15.1 (2026-06-13)**. Markup-aware (Markdown, AsciiDoc, reST, HTML, + source-code comments incl. Java via tree-sitter), runs **fully offline** (nothing sent to a server — answers the "don't paste our docs into a cloud tool" objection).
- **Org renamed `errata-ai` → `vale-cli`.** Repos: `vale-cli/vale`, `vale-cli/vale-action`, `vale-cli/Microsoft`, `vale-cli/proselint`. Old `errata-ai/*` URLs redirect; **training data will say errata-ai — flag it.**
- Ready-made style packages: **Microsoft, Google**, write-good, proselint, alex, Joblint, Readability, plus org styles (GitLab, RedHat, Grafana Writers' Toolkit, Elastic). Compose these + a house style.

| Tool | Type | Verdict |
|---|---|---|
| **Vale** | rule-based, configurable | Only serious option to enforce a house style exactly; wire into CI |
| **alex** | heuristic — insensitive/non-inclusive language | Keep for inclusivity, but tune |
| **write-good** | heuristic — passive/weasel/adverbs | **[contested]** noisy, high false-positives; nudge not gate |
| **proselint** (amperser) | heuristic — Garner/Strunk rules | **[contested]** several rules wrong for technical prose; now also a Vale package |
| **textlint** | pluggable JS engine combining rule sets | Vale's JS-world analog, smaller adoption |

**Load-bearing caveat: no linter checks whether writing is correct or useful — surface style only.** Nothing has displaced Vale as of 2026 (there's a CHI 2026 paper "Linting Style and Substance in READMEs" but no new dominant tool — don't invent one).

## Plain-language standards — the 2023 international standard is the gap in training data

- **ISO 24495-1:2023 "Plain language — Part 1: Governing principles and guidelines"** (published June 2023) — the **first international plain-language standard**, drafted by experts from ~25 countries / 19 languages; adopted as a national standard by many bodies. **Most likely training-data gap.**
  - Four governing principles: readers get (1) **what they need**, (2) can **find** it, (3) can **understand** it, (4) can **use** it — a clean "find → understand → use" reader-first checklist.
  - Deliberately language- and medium-agnostic, process-oriented (know your reader, draft, test with real readers, revise). Part 2 (readability metrics) in development. Bodies: International Plain Language Federation (iplfederation.org), PLAIN (plainlanguagenetwork.org).
- **US Plain Writing Act of 2010** — still law (agencies file annual compliance reports). **But plainlanguage.gov as a standalone maintained site is effectively deprecated** — content migrated to **digital.gov** plain-language guides + a GitHub archive. Cite the *Federal Plain Language Guidelines* / digital.gov, not plainlanguage.gov as a live destination.
- **Readability metrics (Flesch-Kincaid etc.) are a weak proxy** — smell test, not a target (Goodhart: short choppy sentences game the score without improving clarity). Say this explicitly.

## PR / issue / review conventions

- **PR description [settled anatomy]:** answer **why before what** (the diff shows what; the description supplies why + what reviewers can't see). Order: short title → summary → why/context → what changed → how to test → linked issue → screenshots for UI. Keep PRs small; link the issue, don't restate. Backing: Graphite, arXiv 2602.14611.
- **Conventional Commits** (`type(scope)!: description`, `feat/fix/docs/refactor/test/chore`) is a *commit-message* spec repurposed for PR titles because it feeds automated changelogs/semver — not a description format.
- **Issue/bug report [settled]:** title = what + where + under what condition. Four load-bearing fields: (1) numbered **steps to reproduce** from a known state, naming exact UI/values; (2) **expected vs actual** as an explicit contrast; (3) **environment** (OS, build, browser, prod/staging/local); (4) **evidence** (screenshot/log). Include **reproduction rate** ("5/5" vs "1/10") — it changes triage. Stick to facts, no guessed cause.
- **Conventional Comments** (conventionalcomments.org) — the machine-parseable review-comment standard. Format: **`<label> [decorations]: <subject> [discussion]`**.
  - Labels: **`praise`, `nitpick`, `suggestion`, `issue`, `question`, `todo`, `thought`, `chore`, `note`**.
  - Decorations: **`(blocking)`, `(non-blocking)`, `(if-minor)`**.
  - Makes intent + severity explicit/grep-able and defuses tone. Used by GitLab and many OSS projects.

## Anti-slop tells — empirically grounded (this is the most training-data-sensitive area)

Backing: **Wikipedia "Signs of AI writing"** (crowd-sourced reference) + **Kobak et al. 2024 "Delving into… excess vocabulary"** (14M PubMed abstracts, "excess word" method — measured an abrupt post-ChatGPT spike). The list is evidence-based, not vibes.

### Settled tells — flag and cut
- **Overused vocabulary (measured):** delve, underscore, crucial, pivotal, intricate, showcase, boasts, realm, landscape, tapestry, testament, vibrant, foster, garner, robust, seamless, leverage, nuanced, multifaceted, notably, additionally. Verb-inflation: "is/are" → "serves as / stands as / plays a role in." *Clustered* frequency is the signal, not any single word.
- **Puffery / significance inflation:** "plays a vital/pivotal role," "stands as a testament to," "rich tapestry of" → replace with the specific fact or delete.
- **Rule of three:** reflexive "adjective, adjective, and adjective" tripling to *look* comprehensive.
- **Negative parallelism:** "Not just X, but Y," "It's not about X — it's about Y."
- **Vague attribution:** "experts say," "studies suggest" with no citation — name the source or drop it.
- **"-ing" pseudo-synthesis:** trailing "…, highlighting the importance of…," "…, emphasizing its significance…".
- **Formulaic conclusions:** "In conclusion, X continues to evolve…," "Despite its challenges, X remains…".
- **Formatting tells:** bullet-point abuse (prose→lists), bold overuse, Title Case where sentence case is house style, inconsistent curly quotes, inline-header bullets ("• **Thing**: description") as default structure.

### Contested tells — do NOT treat as proof
- **Em-dash overuse [the loud one]:** the "ChatGPT hyphen" claim went viral Feb 2025. Counter-evidence strong — em dash is legitimate long-standing human punctuation, no hard evidence LLMs use it more than professional writers, detection is "more art than science." **Don't ban em dashes; don't treat them as a fingerprint.** Critique overuse-for-emphasis-where-a-comma-would-do, not the mark. (SKILL.md's stance already matches.)
- **AI detection generally [contested]:** automated detectors are unreliable, high false-positives (esp. non-native English). The tells are for **self-editing your own drafts**, not accusing others.

### Editorial meta-finding [settled]
Studies (incl. a top journal's 2026 measurement) find AI-drafted prose is **more verbose, more jargon-laden, harder to read, more likely rejected** — generic fluency without a point of view. The editorial fix: **restore specificity and cut length** — the same instruction as "concrete over abstract" + "cut hedging." Unifying framing: **anti-slop editing and good technical writing are the same discipline.**

## Hedging nuance (SKILL.md "delete hedges")
Cut **decorative** intensifiers ("very," "really," "quite," "actually," "basically"). **Keep calibrated epistemic hedges** that carry real uncertainty ("this likely regresses X," "untested on Windows"). Generic "cut hedging" advice misses this distinction.

## Key sources

- Google style: developers.google.com/style; word-list; whats-new
- Microsoft: learn.microsoft.com/style-guide (print MoS 4th ed. retired 2018)
- Apple Style Guide (June 2026); Chicago 18th ed. 2024
- Vale: github.com/vale-cli/vale (renamed from errata-ai); vale.sh; releases 3.15.1
- ISO 24495-1:2023: iplfederation.org/iso-standard; plainlanguagenetwork.org
- Federal Plain Language Guidelines / digital.gov (plainlanguage.gov deprecated as standalone)
- Conventional Comments: conventionalcomments.org; Conventional Commits: conventionalcommits.org
- PR practice: graphite.com/guides; arXiv 2602.14611
- Anti-slop: Wikipedia "Signs of AI writing"; Kobak et al. 2024 arXiv:2406.07016; em-dash debate (theconversation.com 259629)
