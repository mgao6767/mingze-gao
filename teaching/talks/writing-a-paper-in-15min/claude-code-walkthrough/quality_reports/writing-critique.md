# Manuscript — Critique

**Reviewer:** writer-critic
**Targets:** `paper/main.tex`, `paper/references.bib`, `paper/main.pdf`
**Paper type:** Descriptive predictive (asset-pricing update)
**Phase:** Execution (strict severity)
**Date:** 2026-05-11

## Round 1 — PASS at threshold (87/100)

Manuscript well-structured. 35 pages. All numbers traced to source tables (19+ checked).

### Issues found in R1
- **Major:** Overfull hboxes (74.9pt FM equation; 24pt summary stats); awkward SMB-loading phrasing; "driven by" causal verb
- **Moderate:** Orphan bib entry (`barillas2018comparing`); STR t-stat -6.07 should be -6.06; "ambiguous" should be "statistically indistinguishable"
- **Minor:** vbox warnings; cleveref output for Table 4 omission; capitalisation drift between `\cref` and `\Cref`; second "drive" usage; appendix table layout

## Round 2 — PASS (~95/100 estimated)

All 7 high-priority fixes applied:

1. FM equation rewritten as `\begin{multline}` — 74.9pt overflow resolved
2. Summary-stats table reformatted with `\footnotesize` — 24pt overflow resolved
3. STR t-stat corrected: `-6.07` → `-6.06`
4. Two causal verbs scrubbed: "driven by" → "and they track"; "does not drive" → "leaves… unchanged"
5. `barillas2018comparing` cited in §2.4 Methodology
6. SMB-loading sentence rewritten for clarity
7. "ambiguous" → "statistically indistinguishable from zero" (terminology consistency)

Page count: 35. No LaTeX errors. No new overfull hboxes >10pt.

## Numeric verification (R1, 19+ claims checked)

| Claim location | Number in prose | Source table | Match |
|---|---|---|---|
| Abstract, §1 | VW spread +0.16% (t=0.41) | table2_sorts | yes |
| Abstract, §1, §8 | VW CAPM α +0.90% (t=2.86) | table3_alphas | yes |
| Abstract, §1, §8 | VW FF3 α +0.76% (t=2.96) | table3_alphas | yes |
| Abstract, §1, §6.4 | VW FF4 α +0.12% (t=0.61) | table3b_ff4 | yes |
| §1, §5.2 | SMB β -1.02 (t=-6.10) on VW LS | table3_alphas | yes |
| §6.4 | β^MOM +0.74 (t=7.93) VW | table3b | yes |
| §6.4 | β^MOM +0.41 (t=4.12) EW | table3b | yes |
| §5.3 | FM IVOL slope -5.32, -4.27 | table4_fm | yes |
| §5.3 | STR coef -3.10 t=-6.07 → -6.06 | table4_fm | FIXED R2 |
| §5.4 | VW Pre-2000 FF3 α +0.62% (t=2.65) | table5 | yes |
| §5.4 | VW Post-2000 FF3 α +0.66% (t=2.14) | table5 | yes |
| §5.5 | VW Small FF3 α +0.80% (t=3.00) | table6 | yes |
| §5.5 | VW Large FF3 α +0.71% (t=2.96) | table6 | yes |
| §3.1 | 1,609,652 stock-months, 15,030 firms, 411 months | Consistent | yes |

## Verdict

**PASS at Round 2.** Pair converged. Paper-type coherence strong (descriptive predictive throughout); INV-1 through INV-13 satisfied; VW-degradation limitation disclosed in §3.2, §5 table notes, §8, and Appendix B. Ready for verifier pass.
