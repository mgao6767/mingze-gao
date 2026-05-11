# Project: Idiovol Update 1990–2024

A reduced-form asset-pricing paper revisiting the idiosyncratic-volatility puzzle
of Ang, Hodrick, Xing, and Zhang (2006, *JF*) in the modern US equity universe.
Demonstration project for the Claude Code skills workflow.

## Topic and scope

- **Question:** Does the negative idiovol-return relation survive 1990–2024?
- **Data:** CRSP daily, CRSP msenames, Compustat funda, CRSP-Compustat link.
  Optional Ken French factor library.
- **Sample:** Common stock (shrcd 10, 11) on NYSE/AMEX/Nasdaq, ex-financials
  (SIC 60–69), ex-utilities (SIC 49), ≥17 daily obs per stock-month.
- **Identification:** Descriptive predictive sorts and Fama-MacBeth regressions.
  No causal claims.

## Conventions

- **Language:** R (see `.claude/references/coding-standards-r.md`).
- **Paper format:** Working-paper standard (`.claude/rules/working-paper-format.md`).
  12pt, double-spaced, biblatex+biber, booktabs tables.
- **Tables:** R exports bare `tabular` to `output/`; LaTeX wraps with
  `threeparttable` in `paper/main.tex`.
- **Figures:** PDF + PNG to `output/`. Captions live in LaTeX, never inside ggplot.
- **Seed:** `set.seed(20260519)` at top of any script with stochastic ops.
- **Paths:** All paths via `here::here()`. No `setwd()`.

## Output organisation

```
scripts/   analysis.R, build_factors.R
output/    tables (.tex), figures (.pdf, .png), slide_bundle.rds
paper/     main.tex, references.bib, main.pdf
quality_reports/
           literature-review.md, data-assessment.md, strategy-memo.md,
           research_journal.md
```

## The 4 skills shipped here

| Skill | Use |
|---|---|
| `/discover` | Literature review + data assessment for the idiovol topic |
| `/strategize` | Strategy memo with identification, hypotheses, robustness map |
| `/analyze` | Full R pipeline → tables, figures, slide bundle |
| `/write` | Paper manuscript (intro, lit, data, results, conclusion) |

Skills dispatch agents in `.claude/agents/`. Critics enforce the rules in
`.claude/rules/`. The six creator agents are: `librarian`, `explorer`,
`strategist`, `coder`, `data-engineer`, `writer`. Their paired critics
review each artifact.

## Quality gates

- Each creator artifact reviewed by its paired critic; minimum score 80.
- `verifier` runs at the end: LaTeX compiles, no missing references,
  content invariants satisfied.
