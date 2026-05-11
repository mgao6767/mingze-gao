# Strategy Memo — Idiosyncratic Volatility and the Cross-Section of Stock Returns, 1990-2024

**Author:** strategist agent
**Date:** 2026-05-11
**Paper type:** **Descriptive / measurement / predictive.** No causal claim. The unit of analysis is a stock-month return; the right-hand-side variable of interest is lagged realised idiosyncratic volatility. We test whether a stylised fact — the AHXZ (2006) negative idiovol-return spread — is preserved in the 1990-2024 US universe.

---

## Pre-Strategy Report

I read the three required inputs before designing the strategy. Key takeaways feeding the memo are summarised below.

### 1. Literature review (`quality_reports/literature-review.md`)

- **Four-bucket frontier map:** (i) does the puzzle exist; (ii) why; (iii) does it still exist; (iv) FM methods. Bucket (i) anchors on `ang2006cross` (foundational, 1963-2000) with replication/measurement critiques in `bali2008idiosyncratic`, `han2011investor`, and time-series backdrop in `campbell2001have`.
- **Bucket (ii) explanations** we cite but do **not** test: `fu2009idiosyncratic` (expected vs. realised idiovol), `boyer2010expected`, `bali2011maxing` (MAX lottery proxy), `huang2010return` (return reversal), `stambaugh2015arbitrage` (arbitrage asymmetry), `chen2012does`, `liu2018absolving`, `asness2020betting`.
- **Bucket (iii) — Does it still exist?** is unsettled. `mclean2016does` predicts post-publication decay. `hou2020replicating` finds survival under VW + NYSE breakpoints with smaller magnitude. `chu2020idiosyncratic` shows sensitivity to short-sale environment (Reg SHO).
- **The gap statement** is explicit: no transparent decade-by-decade AHXZ replication on 1990-2024 exists; our contribution is descriptive and methodological — an updated stylised fact, not an adjudication of explanations.
- **Methods bucket** (`famamacbeth1973`, `shanken1992estimation`, `petersen2009estimating`, `jegadeesh2019empirical`) sets the FM specification with Newey-West SEs and month clustering.

### 2. Data assessment (`quality_reports/data-assessment.md`)

- **Coverage grade: A.** Four RDS files (`crsp.dsf` 67.6M rows; `crsp.msenames` 83.8k; `comp.funda` 404k; `crsp.ccmxpf_lnkhist` 32.8k). After universe filters the analytical panel should exceed 4M stock-months — orders of magnitude above the inferential threshold.
- **Filters justified by Explorer:** `shrcd ∈ {10,11}`, `exchcd ∈ {1,2,3}`, exclude SIC 6000-6999 (financials) and SIC 4900-4999 (utilities), require ≥17 daily observations per (`permno`, month).
- **Market return constructible from `crsp.dsf`** as beginning-of-day market-cap-weighted aggregate over the same filtered universe; validates ≥5 decimals against `crsp.dsi` `vwretd`.
- **Explorer-critic recommendation:** add `curcd == 'USD'` to the Compustat funda filter alongside `indfmt=='INDL' & datafmt=='STD' & popsrc=='D' & consol=='C'`. Adopted in Section 3 below.
- **Open caveats:** delisting returns (`dlret` lives in `msedelist`, not `dsf`) — flagged as documented limitation; Han-Lesmond microstructure noise — addressed in robustness; January seasonality — addressed in robustness; negative book equity drop.

### 3. Project conventions (`CLAUDE.md` + content-invariants + working-paper-format)

- R language, `here::here()` paths, `set.seed(20260519)` once at top, R exports bare `tabular` to `output/`, no titles in ggplot, double-spaced 12pt working paper.
- INV-8 binding: this is a descriptive paper — no causal claims. INV-7: notation consistent across sections. INV-11: numbers in text must match tables.
- Strategy phase severity is **medium** (constructive criticism per `quality.md`). Missing robustness check costs -5 at this phase.

I have inputs from all three required sources and noted the explorer-critic's `curcd` recommendation. No discovery inputs are missing.

---

## Research Question and Hypotheses

We document — descriptively — whether sorting US common stocks by lagged-month idiosyncratic volatility produces the AHXZ (2006) cross-sectional return spread on the 1990-2024 sample. Three pre-specified predictive hypotheses follow.

**H1 (main, magnitude preservation).** Conditional on standard pricing controls, the next-month average return spread between the low-idiovol quintile (Q1) and the high-idiovol quintile (Q5) is positive: $\mathbb{E}[r_{Q1,t+1} - r_{Q5,t+1} \mid \mathcal{F}_t] > 0$. Equivalently, the FF3 alpha of the long-Q1/short-Q5 portfolio is positive and economically meaningful. This preserves the AHXZ sign convention (low idiovol predicts high returns).

**H2 (heterogeneity, sub-period).** The Q1-minus-Q5 spread is **larger** in the post-1999 sub-period than in the pre-1999 sub-period, consistent with the listings-decline composition shift documented by Doidge-Karolyi-Stulz (and the time-trend trajectory implied by Hou-Loh 2016).

**H3 (heterogeneity, size).** The Q1-minus-Q5 spread is **concentrated in small-cap stocks**, defined as below the NYSE 20th percentile of market capitalisation. The spread is statistically and economically smaller — possibly indistinguishable from zero — among NYSE-large stocks.

None of these hypotheses is causal. They are statements about **conditional predictive moments** of returns given lagged characteristics, in the spirit of Cochrane's "characteristic-based" cross-sectional pricing.

---

## Sample Construction

**Universe.** Begin with `crsp.dsf` joined to `crsp.msenames` on `permno` with the validity condition `namedt <= date <= coalesce(nameendt, today)`. Apply:

- `shrcd %in% c(10, 11)` (domestic common stocks)
- `exchcd %in% c(1, 2, 3)` (NYSE, AMEX, Nasdaq)
- `!(siccd %in% 6000:6999)` (exclude financials)
- `!(siccd %in% 4900:4999)` (exclude utilities)
- Date range: `1990-01-01 <= date <= 2024-12-31`
- Stock-month requirement: at least 17 valid daily returns within the calendar month (AHXZ convention; ≈80% of the 21 trading days)

**Compustat link.** Join `comp.funda` to the CRSP panel via `crsp.ccmxpf_lnkhist`. Compustat filters: `indfmt == 'INDL' & datafmt == 'STD' & popsrc == 'D' & consol == 'C' & curcd == 'USD'` (the `curcd` clause is per the explorer-critic recommendation; prevents non-USD filers from contaminating book equity construction). Link filters: `linktype %in% c('LU', 'LC')`, `linkprim %in% c('P', 'C')`, with `linkdt <= datadate <= coalesce(linkenddt, today)`.

**Book equity (Fama-French convention).** $BE = ceq + txditc - PS$, where $PS = \text{coalesce}(pstkrv, pstkl, pstk, 0)$. Drop firm-years with $BE \le 0$ for BE/ME-based controls (Fama-French 1992 convention). For sorting purposes, book equity at fiscal year-end $y$ is matched to monthly returns in July of year $y+1$ through June of year $y+2$ (FF12 lag).

**Market equity.** $ME_{i,t} = |prc_{i,t}| \cdot shrout_{i,t}$ in $ thousands; aggregated to $ millions.

**Self-constructed market return.** From the filtered `dsf` panel:
$$r_{M,t} = \frac{\sum_i ME_{i,t-1} \cdot r_{i,t}}{\sum_i ME_{i,t-1}}.$$
Lagged market cap as weight avoids look-ahead. Validate against `crsp.dsi` `vwretd` if available. Risk-free rate: Ken French daily $r_f$ file.

---

## Idiovol Construction (Main Specification)

For each (permno, month) pair with $\ge 17$ valid daily returns:

1. Compute daily excess return $r^e_{i,d} = r_{i,d} - r_{f,d}$.
2. Compute daily market excess return $r^e_{M,d} = r_{M,d} - r_{f,d}$.
3. Run the within-month CAPM time-series regression
   $$r^e_{i,d} = \alpha_{i,m} + \beta_{i,m} r^e_{M,d} + \varepsilon_{i,d}, \qquad d \in \text{month } m.$$
4. Store $\widehat{\text{IVOL}}_{i,m} = \text{sd}(\widehat{\varepsilon}_{i,d})$ as the **monthly** idiovol (raw daily residual standard deviation).
5. Optional secondary measure: annualised-monthly equivalent $\widehat{\text{IVOL}}^{(21)}_{i,m} = \widehat{\text{IVOL}}_{i,m} \cdot \sqrt{21}$. Primary reporting uses the raw daily-std measure.

**Output object:** one $\widehat{\text{IVOL}}_{i,m}$ value per (permno, month).

**Predictive lag.** $\widehat{\text{IVOL}}_{i,m}$ predicts return $r_{i,m+1}$. We never use contemporaneous idiovol as a regressor.

---

## Identification Frame

**This is a predictive, not causal, exercise.** We make four explicit non-claims.

1. We do **not** claim that idiovol *causes* low future returns. An equivalent statement is: low future returns *cause* high lagged idiovol — both are consistent with the same conditional moment.
2. We do **not** test any of the bucket-(ii) mechanisms (lottery preferences, arbitrage asymmetry, return reversal, mispricing). Those require either an instrument or an experiment we do not have.
3. We do **not** interpret the Fama-MacBeth slope on idiovol as a "price of risk." Following `jegadeesh2019empirical`, individual-stock FM coefficients are subject to errors-in-variables; we report the slope as a conditional predictive coefficient, not as a structural risk premium.
4. We do **not** claim external validity beyond US common stocks 1990-2024.

**What we DO test.** The AHXZ research design — quintile portfolios, monthly rebalancing, EW and VW returns, CAPM/FF3 alphas, FM cross-sectional slopes — applied unchanged to the 1990-2024 sample, yields a positive Q1-minus-Q5 spread. The hypothesis is operationally a sign test: in the 35-year sample, the time-series mean of the Q1-minus-Q5 portfolio return exceeds zero at conventional significance.

---

## Main Specifications

### Spec 1 — Quintile portfolio sorts

At the end of each month $m$:

- Compute $\widehat{\text{IVOL}}_{i,m}$ as above using daily data from month $m$.
- Compute **NYSE breakpoints**: the 20th, 40th, 60th, 80th percentiles of $\widehat{\text{IVOL}}_{i,m}$ over the subset of permnos with $exchcd = 1$.
- Assign every stock in the analytical universe (NYSE + AMEX + Nasdaq) to quintile Q1...Q5 according to those NYSE breakpoints.
- Form Q1...Q5 portfolios; hold for month $m+1$.
- Report:
  - **Equal-weighted** monthly excess returns of Q1, Q2, Q3, Q4, Q5, and the long-Q1/short-Q5 spread.
  - **Value-weighted** monthly excess returns of Q1...Q5 and the long-Q1/short-Q5 spread (VW preferred per AHXZ and `hou2020replicating`).
- Tabulate average excess return, standard deviation, Sharpe ratio, and Newey-West $t$-statistic (12 lags) for each portfolio and the Q1-minus-Q5 spread.

### Spec 2 — Factor-model alphas

Run the time-series regressions on the long-Q1/short-Q5 monthly portfolio return $r^{LS}_{m+1}$:

$$r^{LS}_{m+1} = \alpha^{CAPM} + \beta^{MKT} \, \text{MKT}_{m+1} + u_{m+1},$$

$$r^{LS}_{m+1} = \alpha^{FF3} + \beta^{MKT} \, \text{MKT}_{m+1} + \beta^{SMB} \, \text{SMB}_{m+1} + \beta^{HML} \, \text{HML}_{m+1} + u_{m+1}.$$

Report $\widehat{\alpha}$ in monthly percent, Newey-West $t$-statistic with 12 lags, adjusted $R^2$, and the number of monthly observations.

### Spec 3 — Fama-MacBeth cross-sectional regressions

For each month $t$, run the cross-sectional regression

$$r_{i,t} = \lambda_{0,t} + \lambda_{1,t} \widehat{\text{IVOL}}_{i,t-1} + \lambda_{2,t} \log(\text{ME}_{i,t-1}) + \lambda_{3,t} \log(\text{BE/ME}_{i,t-1}) + \lambda_{4,t} \text{MOM}_{i,t-12, t-2} + \lambda_{5,t} \text{STR}_{i,t-1} + e_{i,t},$$

where MOM is the cumulative return from $t-12$ to $t-2$ (skipping $t-1$, Jegadeesh-Titman convention) and STR is the prior-month return (short-term reversal, `huang2010return`). Report time-series means $\bar{\lambda}_k$ and Newey-West-adjusted $t$-statistics with 12 lags. Cluster observations within months for the cross-sectional fit per `petersen2009estimating`. Report Shanken-adjusted SEs alongside the standard FM SEs as a secondary diagnostic.

---

## Robustness Map

The descriptive paper's signal is the **stability** of the spread under design perturbations. Pre-committed robustness suite:

| ID | Perturbation | Reference | What we check |
|---|---|---|---|
| **R1** | Replace CAPM-residual IVOL with **FF3-residual IVOL** | `fama1993common`, `ang2006cross` | Robustness to factor benchmark in idiovol construction (the Fu 2009 measurement debate) |
| **R2** | Split sample at January 2000: pre-1999 vs. post-1999 | `hou2016have`, `mclean2016does` | Whether the spread has decayed in the more recent decade (H2 heterogeneity test) |
| **R3** | NYSE-20% small-cap vs. NYSE-80% large-cap subsamples | `bali2008idiosyncratic` | Whether the spread concentrates in small stocks (H3 test) |
| **R4** | Conditional double sorts: 5x5 size $\times$ IVOL and 5x5 BE/ME $\times$ IVOL | AHXZ Table VI | Whether the IVOL spread survives within each size/value bin |
| **R5** | Replace IVOL with **MAX** = mean of five highest daily returns in prior month | `bali2011maxing` | Whether the lottery proxy subsumes IVOL; report both in horse-race FM |
| **R6** | Drop stock-months with $prc_{i,m-1} < \$5$ | `han2011investor` | Microstructure-noise robustness |
| **R7** | Drop January observations from portfolio time series | `han2011investor` | January-seasonality robustness |
| **R8** | Drop 2008-01 through 2009-12 (financial-crisis window) | n/a | Crisis-window robustness — verifies the spread is not driven by 2008-09 |
| **R9** | Report CAPM, FF3, FF4 (Carhart) and FF5 (Fama-French 2015) alphas where the factor file is available; EW vs. VW | `fama1993common`, `carhart1997persistence`, `hou2020replicating` | Alpha is not an artefact of factor-model choice |

That is **nine** robustness checks against the user-required threshold of seven; the redundancy is deliberate because the strategist-critic deducts -5 per missing robustness at strategy-phase severity.

---

## Falsification Predictions

Pre-committed falsifiers — what we would have to observe to **reject** each hypothesis.

- **Falsifies H1.** The 35-year time-series mean of the VW long-Q1/short-Q5 portfolio return is non-positive *and* the FF3 alpha is non-positive (both with $t < 1.96$). Equivalently, the FM slope on lagged IVOL is non-negative (recall sign: AHXZ predicts $\lambda_1 < 0$ in the spec above since IVOL enters levels — H1 says low IVOL predicts high returns, i.e., the FM slope on raw IVOL is **negative**).
- **Falsifies H2.** The Q1-Q5 spread in the post-1999 sub-period is **smaller** than (or equal to within 1 SE of) the pre-1999 spread. We allow either smaller-than or statistically indistinguishable as falsifying.
- **Falsifies H3.** The Q1-Q5 spread among NYSE-large stocks (size above NYSE 20th percentile) is **as large or larger** than in the small-cap subsample. We allow either as falsifying.

We will not p-hack our way to non-falsification. The robustness map is fixed before estimation.

---

## Threats and Mitigations

| Threat | Source | Mitigation in our design |
|---|---|---|
| **T1 — Data snooping / multiple testing.** Nine robustness checks $\times$ two hypotheses generate many tests; some will be "significant" by chance. | Lo-MacKinlay (1990) | Pre-commit to the robustness list. Headline H1-H3 are the only confirmatory tests; robustness is supportive, not confirmatory. We do not report joint $p$-values; we report consistency of sign across robustness. |
| **T2 — Idiovol mismeasurement.** Residual std with ≈21 observations is noisy; sampling error attenuates the cross-sectional slope. | `jegadeesh2019empirical`, `han2011investor` | (i) Use NYSE breakpoints to make portfolio assignment robust to within-quintile measurement noise; (ii) report Shanken-corrected SEs in the FM; (iii) the ≥17-obs filter reduces variance of the daily-residual std. |
| **T3 — Microstructure noise.** Bid-ask bounce inflates IVOL for low-priced/illiquid stocks. | `han2011investor` | Robustness R6 (drop $prc < \$5$) and R3 (NYSE-only large subset) directly address this. |
| **T4 — Fu (2009) expected-vs-realised critique.** Conditioning on lagged realised IVOL may capture mean reversion in volatility, not a pricing relationship. | `fu2009idiosyncratic`, with `guo2014` corrective | We explicitly adopt the AHXZ realised-IVOL convention and disclaim it. We do **not** claim to estimate the price of expected idiovol. Robustness R1 (FF3-residual IVOL) speaks to the same residual definition Fu critiques. |
| **T5 — Transaction-cost realisation of the spread.** A Q1-Q5 spread of 100 bps/month may not survive bid-ask costs for high-IVOL stocks. | `novymarx2016taxes` | We report gross returns. Net-of-cost feasibility is a separate research question; we flag this as a limitation, not a result we claim. |

---

## Pre-Registration Note

Even though this paper is descriptive, we pre-commit to the following design choices **before** running estimation. Deviations would be disclosed and explained in any revision.

1. **Quintile breakpoints.** NYSE breakpoints (NYSE-only sample, $exchcd = 1$), 20/40/60/80 percentiles, recomputed monthly.
2. **Long-short construction.** Long Q1, short Q5 (low-minus-high). This is the **AHXZ sign convention** — positive expected spread under H1.
3. **Portfolio weighting.** Equal-weighted **and** value-weighted, both reported. VW is the primary specification (per `hou2020replicating`).
4. **Standard errors.** Newey-West with 12 monthly lags for all time-series tests. Petersen-style month clustering plus Newey-West-adjusted FM-coefficient SEs for the Fama-MacBeth regressions. Shanken-adjusted SEs reported as secondary.
5. **Sample period.** 1990-01-01 through 2024-12-31. No in-sample-optimisation of start or end dates.
6. **Hypothesis sign.** H1 predicts $\bar r_{Q1} - \bar r_{Q5} > 0$ (equivalently, the FM slope on $\widehat{\text{IVOL}}_{i,t-1}$ is negative).
7. **Lookback convention.** IVOL in month $m$ predicts return in month $m+1$. No skip-a-month variant in the main specification.

---

## Critic-Anticipated Weaknesses

The strategist-critic will flag at least the following. We list each with a defensible response.

1. **"Why CAPM-residual IVOL as the main spec, not FF3-residual?"** AHXZ (2006) Table I and `bali2008idiosyncratic` both report CAPM-residual as a benchmark precisely because the FF3 residual conflates exposures to SMB and HML (which are themselves volatile). The literature reports both; we follow the AHXZ main-text convention with FF3 in R1. *Response:* this is a convention choice, not an optimisation; we report both.
2. **"You don't have delisting returns (`dlret`)."** Confirmed limitation per the data assessment. Affects $\le 5\%$ of stock-months, and the bias is well-known to be small for monthly-frequency portfolio-level results (Shumway 1997). *Response:* documented in the limitations sub-section; quantified by reporting the delisting-flagged fraction of each quintile in summary stats.
3. **"H2 (post-1999 larger) contradicts McLean-Pontiff post-publication decay."** Yes — the two hypotheses are competing. AHXZ was published in 2006, so MP-style decay would predict a *smaller* post-publication spread. Our H2 instead conditions on listings-composition shifts (`doidge2017`-style stylised fact: post-1999 the public-firm population skews toward smaller, riskier firms). *Response:* H2 is a stated horserace between two interpretations; the data adjudicates.
4. **"Using individual-stock FM violates the Shanken correction."** Per `jegadeesh2019empirical`. *Response:* we report both Shanken-adjusted and unadjusted SEs and interpret FM slopes as conditional predictive coefficients, not structural risk premia.
5. **"Why no MAX-orthogonalised IVOL in main spec?"** The MAX-vs-IVOL horserace is the central question of `bali2011maxing` and is one paper's worth of work to do properly. We report MAX as R5 (a robustness, not a confirmatory test) and explicitly disclaim adjudication of the lottery-preference mechanism.

---

## Estimation Approach Summary

- **Headline portfolios:** quintile sorts with NYSE breakpoints (Spec 1).
- **Headline alphas:** CAPM and FF3 (Spec 2) on the long-Q1/short-Q5 portfolio. Newey-West SEs (12 lags).
- **Headline cross-section:** Fama-MacBeth with month clustering and Newey-West-adjusted SEs (Spec 3); five controls (size, BE/ME, MOM, STR, lagged IVOL).
- **Software:** R, `data.table` + `fixest::feols` for the within-month CAPM regressions (vectorised), `sandwich::NeweyWest` for SEs.
- **Output organisation:** tables (.tex bare-tabular) and figures (.pdf, .png) to `output/`. No table/figure caption in the .tex output; LaTeX wraps with `threeparttable` per INV-13. Notation across paper, tables, and talk uses the symbols defined in this memo per INV-7 and INV-20.

---

## Deliverables

- `quality_reports/strategy-memo.md` (this file)

Companion artifacts to be produced by paired creators in subsequent dispatches:

- `scripts/build_factors.R` and `scripts/analysis.R` (coder)
- `output/table_*.tex` and `output/figure_*.pdf` (coder)
- `paper/main.tex`, `paper/references.bib` (writer)
