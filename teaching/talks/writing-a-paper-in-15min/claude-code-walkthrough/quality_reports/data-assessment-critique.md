# Data Assessment — Critique

**Reviewer:** explorer-critic
**Target:** `quality_reports/data-assessment.md`
**Phase:** Discovery (encouraging severity)
**Date:** 2026-05-11

## Score

**88/100** — PASS at the 80 threshold.

## Verdict

**PASS.** Technically sound; measurement validity and identification compatibility are well-handled. Main weakness is the unverified column inventory (tooling constraint, not analytic flaw) and underspecified treatment of measurement error in the headline idiovol construction.

## Issues

### Minor — Tooling: unverified column inventory (-2)
Explorer transparently flagged that it could not execute Rscript. Column inventories match canonical WRDS schemas; no fabricated fields. Routed to data-engineer for confirmation.

### Minor — Measurement error treatment of idiovol underspecified (-4)
Microstructure noise, bid-ask bounce, low-price filter all covered. Underspecified: estimation noise in residual variance at 17–22 daily obs; beta estimation error in 21-day window; Stein-shrinkage variants. Highest-impact omission.

### Minor — External validity / regime-break discussion thin (-2)
1990 start is "modern Nasdaq era," but post-decimalisation cut is 2001. Subsample motivations could be stronger (decimalisation, Reg-NMS 2007, post-2010 ETF growth).

### Minor — Delisting-return magnitude unsupported (-2)
Limitation correctly identified; Shumway (1997) named. Asserts "unlikely to overturn the headline result" without magnitudes (Shumway-Warther: 30-55%; Beaver et al. 2007 shows portfolio impact for small/penny stocks dominating the high-idiovol quintile).

### Minor — AMEX/ARCA treatment standard but not discussed (-2)
AHXZ-lineage convention. AMEX inclusion consequential for high-idiovol quintile (small, volatile firms). No robustness on dropping AMEX. ARCA migration handling unclear.

### Minor — Five-month-ahead horizon end-of-sample not discussed (-2)
AHXZ L/M/N notation: end-of-sample truncation effects matter.

### Minor — Runtime estimates optimistic (-1)
4-8 min for OLS regressions plausible with data.table + lm.fit(); doubles for FF3; 67M-row read is 30-60s; 6-8 GB peak memory on 16 GB laptop is tight.

### Minor — Compustat currency rule not pinned down (-1)
Should be explicit: `curcd == 'USD'`.

## Summary

Competent Grade-A data assessment for an AHXZ-style replication on a 1990-2024 US equity panel. Measurement validity is sound; sample selection filters are AHXZ-lineage convention; identification compatibility for predictive sorts and Fama-MacBeth is clearly supported. Main weaknesses: underspecified measurement-error treatment and a tooling constraint that prevented direct column-name verification, both explicitly acknowledged and routed downstream. Comfortably clears 80.

## Recommendations (not required; for data-engineer hand-off)

1. Verify column inventory with `str(readRDS(...))` on first load.
2. Pre-specify shrinkage or noise treatment for residual-variance estimator.
3. Pin down currency filter as `comp.funda$curcd == 'USD'`.
4. Quantify delisting-return sensitivity when splicing `msedelist`/`dlst`.
5. Document regime-break robustness pre-specification.
6. Confirm runtime on actual hardware.
