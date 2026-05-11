# Strategy Memo — Critique

**Reviewer:** strategist-critic
**Target:** `quality_reports/strategy-memo.md`
**Paper type:** Descriptive predictive (asset-pricing replication)
**Phase:** Strategy (constructive severity)
**Date:** 2026-05-11

## Score

**91/100** — PASS (round 1).

## Verdict

**PASS.** Memo clears the 80 threshold by a wide margin. All 11 required sections present, descriptive framing impeccable (no causal language anywhere), 9-check robustness suite addresses real literature concerns, inference machinery (NW 12 lags, Petersen month clustering, Shanken secondary) correctly assembled.

## Issues (all Minor; -1 to -2 each)

| ID | Issue | Deduction |
|---|---|---|
| M1 | Citation form drift: plain-text "Doidge-Karolyi-Stulz" inline vs `doidge2017` bibkey elsewhere | -2 |
| M2 | Sample boundary for first monthly observation (Dec-1989 vs Jan-1990) not stated | -1 |
| M3 | CRSP return field (`ret` vs `retx`) not stated | -1 |
| M4 | "FF12 lag" without `fama1992cross` bibkey | -1 |
| M5 | R1 (FF3-residual IVOL) doesn't say daily FF3 from Ken French | -1 |
| M6 | "Month" not explicitly defined as calendar month | -1 |
| M7 | Skip-a-month robustness omission | -2 |

## Strengths

- Descriptive framing impeccable (INV-8 fully satisfied); no causal verbs.
- Falsification criteria explicit and quantitative for H1, H2, H3.
- Pre-registration discipline: 7 concrete commitments with numeric specificity.
- Anti-data-snooping: confirmatory (H1-H3) separated from supportive (R1-R9).
- Inference correct (NW 12, Petersen clustering, Shanken).
- 9 robustness checks (≥ 7 required), each tied to real literature concern.
- Honest self-critique pre-acknowledges five referee challenges.
- Lagged-ME weights for self-constructed market return; validation against `crsp.dsi.vwretd`.

## Summary

A strong, submission-ready Strategy-phase artifact. Strengths outweigh the minor specificity gaps. The remaining deductions are polish-level and tractable; none threaten the design. No round 2 required for gate purposes.

## Recommendations (advisory)

1. Add explicit statement: "We use CRSP `ret` throughout. A 'month' is the calendar month."
2. State sample boundaries: "First predictive observation Feb 1990 (IVOL from Jan 1990 daily returns); last Dec 2024."
3. Standardize citations to bibkey form throughout memo body.
4. Add to R1: "Daily FF3 factors from Ken French Data Library, US Research Factors, daily."
5. Optional R10 — Skip-a-month variant — to absorb bid-ask reversal concern at month boundary (≈30 lines of code).
