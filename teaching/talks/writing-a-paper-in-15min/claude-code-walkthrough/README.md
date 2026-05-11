# Claude Code Walkthrough — Idiovol Update 1990–2024

A self-contained demonstration of the Claude Code skills workflow.
This project produces a complete empirical asset-pricing paper end-to-end
using four skills: `/discover`, `/strategize`, `/analyze`, `/write`.

## What's inside

- `CLAUDE.md` — project instructions for the next Claude session
- `.claude/` — 4 skills, 13 agents, 7 rules, 4 reference profiles
- `data/` — 4 RDS files from WRDS (not committed; fetch separately)
- `scripts/` — R analysis pipeline produced by `/analyze`
- `paper/` — LaTeX source and compiled PDF produced by `/write`
- `output/` — tables and figures produced by `/analyze`
- `quality_reports/` — literature review, strategy memo, audit trail

## Prerequisites

- R 4.4+ with packages: `tidyverse`, `fixest`, `modelsummary`, `tinytable`,
  `labelled`, `sandwich`, `lmtest`, `lubridate`, `here`
- LaTeX with `latexmk`, `biber`, `biblatex`, `booktabs`, `tabularray`,
  `threeparttable`, `cleveref`, `hyperref`
- Claude Code with this folder open as the project root
- The four RDS files placed in `data/` (see below)

## Data files

Place the following in `data/`:
- `comp.funda.rds` — Compustat North America Annual
- `crsp.dsf.rds` — CRSP Daily Stock File
- `crsp.ccmxpf_lnkhist.rds` — CRSP-Compustat link history
- `crsp.msenames.rds` — CRSP names file

These are queried from WRDS. Sample SQL is at the bottom of this file.

## Reproduce the analysis

```bash
Rscript scripts/build_factors.R
Rscript scripts/analysis.R
cd paper && latexmk main.tex
```

## Reproduce the workflow

In Claude Code, with this folder as the project root:

```
/discover  the Ang-Hodrick-Xing-Zhang (2006) idiovol puzzle, updated 1990-2024
/strategize  using literature review and data assessment
/analyze  using strategy memo
/write  full paper
```

## WRDS sample SQL (for the curious)

```sql
-- Compustat fundamentals
SELECT * FROM comp.funda
WHERE fyear BETWEEN 1990 AND 2024
  AND indfmt = 'INDL' AND datafmt = 'STD' AND popsrc = 'D' AND consol = 'C';

-- CRSP daily
SELECT permno, date, ret, prc, shrout, vol FROM crsp.dsf
WHERE date BETWEEN '1990-01-01' AND '2024-12-31';

-- CRSP-Compustat link history
SELECT * FROM crsp.ccmxpf_lnkhist
WHERE linktype IN ('LC','LU') AND linkprim IN ('P','C');

-- CRSP msenames
SELECT permno, namedt, nameendt, hsiccd, shrcd, exchcd FROM crsp.msenames;
```

## License and attribution

This walkthrough is produced by Mingze Gao for a Macquarie University seminar
("Writing a Paper in 15 minutes", 2026). The skills framework follows the
public clo-author scaffolding pattern (https://github.com/hugosantanna/clo-author).
