---
name: resume-builder
description: Use when the user wants to write, update, or tailor a resume/CV against a job posting — "tailor my resume", "help me apply to this job", "update my resume for this role", "does my resume match this JD", "build me a resume" — covering the intake interview, requirement-by-requirement gap analysis, and ATS-safe LaTeX/PDF output. Not for cover letters, LinkedIn profiles, or general career advice.
---

# Resume Builder

## Overview

**Tailoring means selection and emphasis from verified experience — never invention.** ATS compatibility comes from clean structure and genuine terminology alignment, not keyword density; real ATS scoring is opaque, so no score is ever claimed. A resume that wins the interview by lying gets the user rejected in round two. A gap surfaced honestly is a decision that belongs to the user.

<HARD-GATE>
Before any line of resume content is written:
1. Every skill, employer, title, date, and metric traces to the inventory or the user's own words this session. No exceptions.
2. Never fabricate: no invented or estimated metrics, no rounded-up titles, no JD keywords the user hasn't demonstrated, no stretched dates.
3. A JD requirement the inventory can't support goes in the gap report as Missing and is put to the user. You never fill a gap yourself.
4. Unsure whether the user actually did something? Ask. A job title is not evidence of an accomplishment.
</HARD-GATE>

## Step 0 — Load the inventory

Search the Context Vault (`/Users/kiefer/Documents/Obsidian/context-management`, via `mcp__obsidian__search_notes`) for the master **Experience Inventory** note — expected home: `Personal Projects/Resume/` — before anything else. Do not ask the user a single intake question before this vault check has run.

- **Found** → do NOT re-interview. Confirm currency ("anything new since <last-updated>?") and ask only for the JD. Skip to Step 2.
- **Absent** → Step 1 builds it.

## Step 1 — Intake interview

The first message contains exactly:
1. Request the existing resume: paste, file path, or "none — start fresh".
2. Request the target JD: paste or URL. If a URL won't fetch, ask for a paste — never reconstruct a JD from the URL or the job title.
3. Nothing else. No fifteen-question wall.

Then:
- **Batched, one turn:** mechanical facts — contact info, education, employers/titles/dates. If a resume was provided, parse it into a draft inventory and confirm everything parsed in a single "here's what I extracted — corrections?" turn.
- **One question per turn:** accomplishment mining, per role — this is where quality collapses; each answer shapes the next probe. Probes: "What changed because you did that?" / "Is there a real number — revenue, latency, users, headcount? 'No number' is a fine answer." / "Who used or depended on it?" / "What would have happened if you hadn't?"
- A skill enters the inventory only with one concrete instance of use attached. No instance → it appears nowhere.

## Step 2 — Decompose the JD

Extract requirements into a flat numbered list. Tag each **Must** (JD says "required", "must", years minimums) or **Nice** ("preferred", "bonus", "a plus"). Preserve the JD's exact wording per row — the gap report and terminology alignment key off it. Skip boilerplate (EEO, benefits, culture fluff); collapse duplicates. Typical yield: 8–15.

## Step 3 — Gap report, shown BEFORE any drafting

For each requirement, search the inventory and assign a verdict:

| # | Requirement (JD wording) | Must/Nice | Verdict | Evidence from inventory |
|---|---|---|---|---|

- **Have** — direct demonstrated experience; cite the specific inventory entry.
- **Partial** — adjacent, older, or smaller-scale; say exactly how it falls short.
- **Missing** — nothing in the inventory supports it.

**No numeric score, ever.** Real ATS scoring is opaque; a made-up "82/100" is a fabricated metric about the resume itself. After showing the full table, ask about each Missing/Partial row: real gap, or evidence the user hasn't mentioned? New evidence → add to inventory, upgrade the verdict. Real gaps are the user's call to handle — not yours to paper over.

## Step 4 — Draft

- Select content by relevance to Have/Partial rows; cut, don't pad. One page unless >10 years of relevant experience. Reverse-chronological, standard headings.
- **Accomplishment over duty:** action verb + what + outcome. "Responsible for X" is flagged phrasing.
- **Metrics only from the user.** No number given → no number in the bullet; use concrete scope instead ("for three internal teams"), never an estimated percentage.
- **Terminology alignment, not inflation:** renaming the same thing to the JD's term is fine (user's "Postgres" → JD's "PostgreSQL"); relabeling lesser work with a JD phrase is fabrication ("wrote SQL queries" → "database architecture").
- **Titles verbatim as held.** A parenthetical clarifier only if the user confirms it's accurate.
- Read `references/latex.md` before emitting any LaTeX. Compile, run its mandatory extraction checks, deliver both `.tex` and `.pdf`.

## Step 5 — Persist to the vault

Read the vault's own `CLAUDE.md` first — its conventions win over this skill's defaults. Patch the inventory, don't overwrite it. Each new verified accomplishment from this session gets an entry: statement, metric-or-"none", skills demonstrated, date verified. The inventory is the superset across all jobs — never write a tailored resume into it; save tailored output only where the user asks. Creating fresh: note titled "Experience Inventory" in `Personal Projects/Resume/` (tags: `reference`, `resume`).

## Rationalization table

| Excuse | Reality |
|---|---|
| "Adding this JD keyword will get past the ATS" | A keyword without evidence is a lie the interviewer finds in five minutes. Ask the user; if they lack it, it's a Missing row, not a bullet. |
| "The bullet is stronger with a number — 30% sounds about right" | An invented metric is fabrication, full stop. No number from the user means no number; use concrete scope instead. |
| "'Senior Engineer' reads better than 'Engineer II' and it's basically the same" | Titles get verified in background checks. Print the title as held. |
| "They obviously did X if they did Y — I can infer it" | You can infer a question, not an accomplishment. Ask. |
| "The user is busy — I'll skip the interview and work from the old resume" | The old resume is one prior tailoring, not the inventory. Unmined accomplishments cost interviews; the interview is the product. |
| "All these Missing rows will discourage them — I'll soften the gap report" | The gap report is the user's decision input. Softening it moves the decision from them to you. Show it whole, before drafting. |

## Red flags — each one means STOP

- A metric, percentage, or team size in a draft bullet the user never stated.
- A skills-section entry with no supporting instance in the inventory.
- You're pasting JD phrases into bullets instead of mapping inventory evidence to JD terms.
- A title in the draft that differs from the title the user held.
- A resume drafted before the gap report was shown — or any numeric match score anywhere.
- You asked intake questions before checking the vault, or never asked for an existing resume.
- The session surfaced a new accomplishment and the vault inventory wasn't updated.
- LaTeX with columns, layout tables, or icons — you didn't read `references/latex.md`.

## Reference

`references/latex.md` — ATS-safe LaTeX constraints, package allowlist, verified compilable skeleton, compile command, mandatory post-compile extraction checks. Read it before emitting any LaTeX.
