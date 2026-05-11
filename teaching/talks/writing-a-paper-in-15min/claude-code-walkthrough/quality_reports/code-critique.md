# Analysis Code — Critique

**Reviewer:** coder-critic
**Targets:** `scripts/analysis.R`, `scripts/build_factors.R`
**Phase:** Execution (strict severity)
**Date:** 2026-05-11

## Round 1 — PASS at threshold (81/100)

Code ran end-to-end in 1.57 minutes producing all 6 tables and 2 figures. Major and Moderate issues identified:

**Major (Round 1):**
- M1 VW degraded (annual Compustat ME → near-EW behaviour) — DATA LIMITATION, not code bug
- M2 Raw spread (+0.18%, t=0.46) does not support H1 in isolation; factor adjustment lifts to +0.55-0.76% alpha — narrative implication
- M3 Deviation list omitted VW degradation

**Moderate (Round 1):**
- M4 me_funda vs market equity aliasing
- M5 pt vs pnorm inconsistency in nw_alpha
- M7 IVOL scale labelling in Table 4
- Robustness incompleteness (R1, R7, R8, R9 missing)
- Function design (silent NA, no stopifnot, API drift)
- EW/VW sample size mismatch (418 vs 411)

## Round 2 — PASS with improvements (estimated 90/100)

Coder addressed all tractable items:

1. **Code style:** `cat()` → `message()` in summary; `nw_alpha()` uses `pnorm()`; `stopifnot()` added to 5 functions.
2. **EW/VW alignment:** Both series now share 411-month sample.
3. **Caveats field:** `slide_bundle$caveats` lists 4 deviations including VW degradation.
4. **Per-SD IVOL slope:** Added `fm_slope_per_sd_idiovol = -0.00134` (t = -1.08).
5. **Robustness suite extended:**
   - R1 FF3-residual IVOL: EW α +0.35% (t=1.40), VW α +0.74% (t=2.59) — VW survives
   - R7 ex-January: VW FF3 α **+1.06% (t=3.49)** — *strengthens* puzzle, rejecting Han-Lesmond January-microstructure
   - R8 ex-crisis: VW FF3 α +0.84% (t=3.19) — robust to 2008-09 exclusion
   - **R9 FF4 (Carhart momentum): EW α +0.11% (t=0.47), VW α +0.12% (t=0.61)** — momentum substantially absorbs the puzzle (β^MOM = +0.74 VW, highly significant)

## Headline finding for the paper

The unconditional Q1-Q5 spread in 1990-2024 (~0.17%/mo, t<1) is **not** statistically significant on its own — the puzzle has weakened relative to AHXZ's 1963-2000 sample. However:
- CAPM and FF3 alphas remain significant (VW +0.76%, t=2.96)
- Robust to ex-January, ex-crisis sub-periods
- Survives FF3-residual reconstruction of IVOL (VW α +0.74%, t=2.59)
- **Substantially absorbed by the Carhart momentum factor (FF4 α +0.12%, t=0.61)**

The interpretation: the "puzzle" in the modern sample is largely a momentum-related phenomenon rather than a stand-alone anomaly. This is a defensible, nuanced finding consistent with Hou-Loh (2016) and the Stambaugh-Yu-Yuan (2015) arbitrage-asymmetry literature.

## Documented limitations carried into the paper

1. CRSP DSF is pre-thinned (date, permno, ret only) → VW degraded to near-EW due to annual Compustat ME.
2. R5 (MAX) and R6 (prc<$5) deferred — require monthly CRSP price/shares not in the dataset.

## Final verdict

**PASS at Round 2.** Pair converged. Ready to advance to /write phase. Limitations documented honestly in slide_bundle$caveats and will be reflected in the paper's Data section.
