# ATS-safe LaTeX for resumes

ATS parsers run plain text extraction over the PDF and match terms against the job description. Structure survives extraction; decoration doesn't. Anything that breaks `pdftotext` reading order — columns, layout tables, text drawn as graphics — breaks parsing, and the resume dies before a human sees it. Optimize for extraction, verify with extraction.

## Structural constraints

- **Single column.** Forbidden: `multicol`, `paracol`, `minipage` side-by-side layouts, `tabular` used for page layout.
- **No graphics.** Forbidden: `tikz`, images, photos, skill bars, icon fonts (`fontawesome*` — icons extract as garbage codepoints or nothing).
- **No text in headers/footers** (`\pagestyle{empty}`) — many parsers drop or mangle marginal text.
- Contact info as plain body text with `\href`; never in a header, never as icons.
- Name as `\textbf{\LARGE ...}` — not `\maketitle` (its layout varies and can reorder).
- Dates right-aligned with `\hfill` on the same line as the role — no tabular date columns.
  - **Verified gotcha:** `\hfill` works for Experience role lines, but a lone right-aligned token on a short line (e.g. an Education year) can float out of extraction order. Inline short trailing facts instead: `\textbf{B.S. ...}, State University, 2018`.

## Standard section headings

Use these exact strings — parsers key on them: `Summary`, `Experience`, `Education`, `Skills`, `Projects` (Projects only if used). No clever renames ("Where I've Been" is invisible to a parser).

## Package allowlist

Nothing outside this list without a reason you can state:

| Package | Why |
|---|---|
| `geometry` | margins 0.5–1in |
| `[T1]{fontenc}` + `lmodern` | T1 encoding so ligatures (ffi, fl) extract as real characters, not glyph soup |
| `enumitem` | tight bullet spacing |
| `titlesec` | compact section headings |
| `hyperref` with `hidelinks` | clickable email/URLs without colored boxes |

No `moderncv`, no `altacv`, no résumé document classes — they are multi-column/icon-heavy by default.

## Verified skeleton

Compiled and extraction-checked July 2026 (tectonic 0.16.9, poppler pdftotext). Extend it; don't reinvent it.

```latex
\documentclass[11pt]{article}
\usepackage[margin=0.75in]{geometry}
\usepackage[T1]{fontenc}
\usepackage{lmodern}
\usepackage{enumitem}
\usepackage{titlesec}
\usepackage[hidelinks]{hyperref}

\pagestyle{empty}
\setlist[itemize]{leftmargin=1.2em, itemsep=2pt, parsep=0pt, topsep=3pt}
\titleformat{\section}{\large\bfseries}{}{0em}{}[\titlerule]
\titlespacing{\section}{0pt}{10pt}{6pt}
\setlength{\parindent}{0pt}

\begin{document}

\textbf{\LARGE Jane Doe}

\vspace{2pt}
Portland, OR \textbar{} \href{mailto:jane@example.com}{jane@example.com} \textbar{} 555-010-0100 \textbar{} \href{https://github.com/janedoe}{github.com/janedoe}

\section*{Summary}
Backend engineer with 6 years building distributed data pipelines in Rust and Python, focused on reliability and operational simplicity.

\section*{Experience}

\textbf{Software Engineer II}, Acme Corp \hfill Mar 2021 -- Present
\begin{itemize}
  \item Rebuilt the ingestion pipeline in Rust, cutting p99 latency from 4s to 300ms for three internal analytics teams.
  \item Led the PostgreSQL 12-to-16 migration across 14 services with zero unplanned downtime.
\end{itemize}

\textbf{Software Engineer}, Beta Labs \hfill Jun 2018 -- Mar 2021
\begin{itemize}
  \item Built and operated the metrics aggregation service consumed by every product dashboard.
\end{itemize}

\section*{Education}

\textbf{B.S. Computer Science}, State University, 2018

\section*{Skills}

Rust, Python, PostgreSQL, Kafka, Kubernetes, GitHub Actions

\end{document}
```

## Compile

```sh
tectonic resume.tex            # preferred: single pass, fetches packages itself
# or:
pdflatex -interaction=nonstopmode resume.tex && pdflatex -interaction=nonstopmode resume.tex
```

If no engine is installed, suggest `brew install tectonic` (small) or BasicTeX — **ask the user before installing anything.**

## Post-compile checks — mandatory, every compile

```sh
pdftotext resume.pdf -         # read ALL of it, not head
pdfinfo resume.pdf | grep Pages
```

Pass criteria — all of:
1. Name, contact line, and every section heading appear in the extracted text.
2. Extraction order matches visual reading order — no dates or fragments floated to the end.
3. No garbage codepoints (broken ligatures, icon glyphs).
4. `Pages:` matches the agreed length (1 unless agreed otherwise).

Any failure → fix the `.tex` and re-run the checks. Deliver both `.tex` and `.pdf` only after all four pass.
