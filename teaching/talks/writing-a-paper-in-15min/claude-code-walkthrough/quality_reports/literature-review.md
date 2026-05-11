# Literature Review: Idiosyncratic Volatility Puzzle (1990-2024 Update)

**Project:** Revisiting Ang, Hodrick, Xing, Zhang (2006) in the modern US equity universe.
**Window:** 1990-2024. **Method:** CAPM-based daily-residual idiovol, quintile sorts, Fama-MacBeth.

This bibliography organizes the literature into four buckets: (i) Does the puzzle exist? (ii) Why does the puzzle exist? — including a sub-bucket of benchmark factor models used to compute alphas — (iii) Does the puzzle still exist? and (iv) Methods literature for the Fama-MacBeth specification. Entries within each bucket appear in approximate chronological order. Each annotation closes with a proximity label: `foundational`, `direct precedent`, `methods`, or `context`. The closing sections present a frontier map and a gap statement.

---

## Bucket (i) — Does the Puzzle Exist? Original, Replications, Measurement

### ang2006cross

Ang, A., Hodrick, R. J., Xing, Y., and Zhang, X. 2006. "The Cross-Section of Volatility and Expected Returns." *Journal of Finance* 61(1): 259-299.

The seminal paper. Sorts NYSE/AMEX/Nasdaq stocks 1963-2000 into quintiles by lagged-month idiosyncratic volatility (FF3 daily residuals) and finds the highest-idiovol quintile underperforms the lowest by about -1.06% per month, with an FF3 alpha of -1.31%. The pattern is robust to size, book-to-market, leverage, liquidity, volume, turnover, bid-ask spread, momentum, and dispersion in analyst forecasts. *Our paper:* directly replicates and extends this design to 1990-2024 using CAPM residuals. `foundational`

### ang2009high

Ang, A., Hodrick, R. J., Xing, Y., and Zhang, X. 2009. "High Idiosyncratic Volatility and Low Returns: International and Further U.S. Evidence." *Journal of Financial Economics* 91(1): 1-23.

Extends the puzzle to 23 developed markets and finds the negative idiovol-return relation is pervasive internationally, with co-movement across countries suggesting a common source rather than a US-specific anomaly. Re-confirms US results with stricter controls and demonstrates the pattern is not driven by small stocks or short windows. *Our paper:* establishes that the puzzle is not a fluke; sets up the question of whether it survives in the post-2000 US sample. `direct precedent`

### bali2008idiosyncratic

Bali, T. G., and Cakici, N. 2008. "Idiosyncratic Risk and the Cross Section of Expected Stock Returns." *Journal of Financial and Quantitative Analysis* 43(1): 29-58.

Argues the AHXZ result is sensitive to portfolio weighting, breakpoint choice (NYSE vs all), data frequency (daily vs monthly), and screen for low-priced/illiquid stocks. Shows that under value-weighting with NYSE breakpoints and exclusion of small stocks the alpha differential weakens or disappears. *Our paper:* motivates our robustness specification with both equal- and value-weighted portfolios and explicit price/liquidity screens. `direct precedent`

### campbell2001have

Campbell, J. Y., Lettau, M., Malkiel, B. G., and Xu, Y. 2001. "Have Individual Stocks Become More Volatile? An Empirical Exploration of Idiosyncratic Risk." *Journal of Finance* 56(1): 1-43.

Documents a secular rise in firm-level idiosyncratic volatility 1962-1997 without a corresponding rise in market or industry volatility. Provides the time-series backdrop against which any idiovol-pricing study must be read, and shows idiovol is large enough to matter for portfolio diversification. *Our paper:* the 1990-2024 sample begins at the peak of this trend, so understanding the trend in the sample period is essential. `context`

### goyal2003idiosyncratic

Goyal, A., and Santa-Clara, P. 2003. "Idiosyncratic Risk Matters!" *Journal of Finance* 58(3): 975-1007.

Argues average stock variance (mostly idiosyncratic) forecasts the market return — a positive aggregate idiovol-return relation in time series. Predates AHXZ and frames idiovol as priced under-diversification at the market level. *Our paper:* useful contrast — the aggregate positive relation coexists with a cross-sectional negative one, a tension our paper inherits. `context`

---

## Bucket (ii) — Why Does the Puzzle Exist? Explanations

### fu2009idiosyncratic

Fu, F. 2009. "Idiosyncratic Risk and the Cross-Section of Expected Stock Returns." *Journal of Financial Economics* 91(1): 24-37.

Argues that *expected* (not lagged realized) idiovol matters, and estimates it via an EGARCH model on monthly returns. Finds a *positive* idiovol-return relation under this conditional measure — claiming the AHXZ puzzle reflects mean reversion in the lagged measure, not a true mispricing. Subsequent work (Guo, Kassa, Ferguson 2014, JFQA) shows this result is partly an artifact of look-ahead bias in the EGARCH fit. *Our paper:* clarifies that we follow AHXZ in using lagged realized idiovol and discuss Fu's expected-volatility critique. `direct precedent`

### boyer2010expected

Boyer, B., Mitton, T., and Vorkink, K. 2010. "Expected Idiosyncratic Skewness." *Review of Financial Studies* 23(1): 169-202.

Builds a cross-sectional model of expected idiosyncratic skewness and shows it negatively predicts returns — lottery-like stocks earn lower average returns. Because high-idiovol stocks tend to be high-skewness, this offers a partial explanation for the AHXZ result rooted in preference for skewness. *Our paper:* skewness is one of the leading explanations we discuss but do not test directly. `context`

### bali2011maxing

Bali, T. G., Cakici, N., and Whitelaw, R. F. 2011. "Maxing Out: Stocks as Lotteries and the Cross-Section of Expected Returns." *Journal of Financial Economics* 99(2): 427-446.

Introduces MAX — the average of the five highest daily returns in the prior month — as a direct proxy for lottery demand. MAX largely subsumes idiovol in cross-sectional regressions, suggesting the AHXZ puzzle is at heart a lottery-preference phenomenon. *Our paper:* MAX is the leading competing characteristic; we will report idiovol sorts both unconditional and conditional on MAX. `direct precedent`

### han2011investor

Han, B., and Lesmond, D. A. 2011. "Investor Sentiment and Liquidity-Biased Idiosyncratic Volatility." *Review of Financial Studies* 24(5): 1590-1629.

Shows that bid-ask bounce and zero-return days contaminate daily-residual idiovol estimates, particularly for small/illiquid stocks. After correcting for microstructure noise, the idiovol-return relation attenuates substantially. *Our paper:* motivates our minimum-price and minimum-volume screens and the use of NYSE breakpoints in robustness. `direct precedent`

### huang2010return

Huang, W., Liu, Q., Rhee, S. G., and Zhang, L. 2010. "Return Reversals, Idiosyncratic Risk, and Expected Returns." *Review of Financial Studies* 23(1): 147-168.

Argues that the negative idiovol-return relation is largely driven by short-term return reversal — high-idiovol stocks just experienced positive returns, and the next month they reverse. Controlling for last month's return dramatically weakens the puzzle. *Our paper:* return-reversal control is part of our robustness battery. `direct precedent`

### stambaugh2015arbitrage

Stambaugh, R. F., Yu, J., and Yuan, Y. 2015. "Arbitrage Asymmetry and the Idiosyncratic Volatility Puzzle." *Journal of Finance* 70(5): 1903-1948.

Explains the puzzle via the interaction of mispricing and arbitrage asymmetry: idiovol deters arbitrage of overpriced stocks more than of underpriced ones because short-selling is costlier. Thus high-idiovol overpriced stocks remain overpriced (low returns) and high-idiovol underpriced stocks correct slowly (high returns); the average effect is negative. *Our paper:* perhaps the most cited modern explanation; we summarize it in the literature section and note we do not test it. `direct precedent`

### hou2016have

Hou, K., and Loh, R. K. 2016. "Have We Solved the Idiosyncratic Volatility Puzzle?" *Journal of Financial Economics* 121(1): 167-194.

Conducts a horse race among more than a dozen proposed explanations using a standardized decomposition method. Finds that lottery-preference proxies (MAX, expected skewness) and one-month return reversal jointly explain roughly 60-80% of the puzzle, while other channels (illiquidity, dispersion, short-sale constraints) explain little incrementally. *Our paper:* the benchmark survey we cite when describing the state of explanations; positions our update against this 2016 stocktake. `direct precedent`

### chen2012does

Chen, Z., and Petkova, R. 2012. "Does Idiosyncratic Volatility Proxy for Risk Exposure?" *Review of Financial Studies* 25(9): 2745-2787.

Decomposes the FF3-residual idiovol into innovations to aggregate idiosyncratic volatility and idiosyncratic shocks. The aggregate component carries a negative risk premium, accounting for part of the AHXZ alpha. *Our paper:* an alternative framing — idiovol is partly a systematic risk factor in disguise. We cite as a competing interpretation. `context`

### liu2018absolving

Liu, J., Stambaugh, R. F., and Yuan, Y. 2018. "Absolving Beta of Volatility's Effects." *Journal of Financial Economics* 128(1): 1-15.

Shows the beta anomaly is driven by the positive correlation between beta and idiovol combined with the negative idiovol-alpha relation among overpriced stocks. Excluding overpriced high-idiovol stocks renders the beta anomaly insignificant. Tightly connects the idiovol puzzle to the beta anomaly through the mispricing/arbitrage-asymmetry channel of Stambaugh, Yu, and Yuan (2015). *Our paper:* reinforces that the idiovol puzzle does not stand alone — its survival is informative about a family of related low-risk anomalies. `direct precedent`

### asness2020betting

Asness, C. S., Frazzini, A., Gormsen, N. J., and Pedersen, L. H. 2020. "Betting Against Correlation: Testing Theories of the Low-Risk Effect." *Journal of Financial Economics* 135(3): 629-652.

Decomposes the low-risk effect into a leverage-constraints channel (priced via beta and correlation) and a behavioral lottery-demand channel (priced via idiosyncratic risk and SMAX). Both channels operate; idiovol-based factors load on sentiment while correlation-based factors load on margin debt. *Our paper:* the most recent JFE statement of the lottery/leverage taxonomy; clarifies that an updated idiovol estimate also speaks to the lottery side of this decomposition. `direct precedent`

### Sub-bucket: Benchmark Factor Models

These papers are *not* explanations of the idiovol puzzle. They define the factor-model benchmarks used to compute the alphas reported in the AHXZ literature, including ours.

### fama1993common

Fama, E. F., and French, K. R. 1993. "Common Risk Factors in the Returns on Stocks and Bonds." *Journal of Financial Economics* 33(1): 3-56.

The FF3 factor model — MKT, SMB, HML — that AHXZ use to extract idiosyncratic residuals. Establishes that size and value capture systematic variation absent from the CAPM. *Our paper:* we use CAPM residuals (one-factor) as the headline definition of idiovol but report FF3 residuals as robustness, following AHXZ. `methods`

### carhart1997persistence

Carhart, M. M. 1997. "On Persistence in Mutual Fund Performance." *Journal of Finance* 52(1): 57-82.

Introduces the momentum factor (UMD/WML). The four-factor model (FF3+MOM) is the standard benchmark for alpha decompositions in the idiovol literature. *Our paper:* used in alpha decomposition of the long-short idiovol portfolio. `methods`

---

## Bucket (iii) — Does the Puzzle Still Exist? Recent Updates and Robustness

### chu2020idiosyncratic

Chu, Y., Hirshleifer, D., and Ma, L. 2020. "The Causal Effect of Limits to Arbitrage on Asset Pricing Anomalies." *Journal of Finance* 75(5): 2631-2672.

Uses Regulation SHO's randomized pilot to show that relaxing short-sale constraints attenuates the idiovol puzzle (along with other anomalies). Provides causal evidence consistent with Stambaugh-Yu-Yuan's arbitrage-asymmetry mechanism. *Our paper:* confirms that the puzzle is sensitive to the short-sale environment — and the post-2007 universal SHO regime is part of our sample. `direct precedent`

### mclean2016does

McLean, R. D., and Pontiff, J. 2016. "Does Academic Research Destroy Stock Return Predictability?" *Journal of Finance* 71(1): 5-32.

Documents that, on average, anomalies decay by about 26% after in-sample publication and 58% after publication, consistent with arbitrageur learning. Lists idiovol among the affected anomalies. *Our paper:* directly motivates the question — has the post-AHXZ decay continued through 2024? `direct precedent`

### hou2020replicating

Hou, K., Xue, C., and Zhang, L. 2020. "Replicating Anomalies." *Review of Financial Studies* 33(5): 2019-2133.

Replicates 452 published anomalies with NYSE breakpoints and value-weighting and finds about half fail at the 5% level. Idiovol survives under value-weighting in their q-factor framework but with a smaller magnitude than the equal-weighted result. *Our paper:* the methodological touchstone for our robustness section — we report both VW and EW alphas with NYSE breakpoints. `direct precedent`

### bali2017lottery

Bali, T. G., Brown, S. J., Murray, S., and Tang, Y. 2017. "A Lottery-Demand-Based Explanation of the Beta Anomaly." *Journal of Financial and Quantitative Analysis* 52(6): 2369-2397.

Generalizes the lottery-demand interpretation to the beta anomaly and reinforces evidence that demand for lottery-like payoffs is the unifying channel behind several volatility/beta puzzles. *Our paper:* situates the AHXZ puzzle inside a broader family of "lottery anomalies." `context`

### barillas2018comparing

Barillas, F., and Shanken, J. 2018. "Comparing Asset Pricing Models." *Journal of Finance* 73(2): 715-754.

Bayesian model-comparison framework for ranking factor models. Relevant for the choice of alpha benchmark (CAPM vs FF3 vs FF5 vs q-factor) in the long-short idiovol portfolio. *Our paper:* cited when justifying our use of multiple benchmark models for alpha computation. `methods`

---

## Bucket (iv) — Methods Literature for the Fama-MacBeth Specification

### famamacbeth1973

Fama, E. F., and MacBeth, J. D. 1973. "Risk, Return, and Equilibrium: Empirical Tests." *Journal of Political Economy* 81(3): 607-636.

The two-pass procedure: estimate factor loadings in a first-pass time-series regression, then run cross-sectional regressions of returns on loadings each period and take the time-series mean of the slopes with Newey-West-style standard errors of the period-by-period coefficients. The estimator of choice for nearly every paper in this bibliography that reports cross-sectional risk premia. *Our paper:* the FM regression of monthly excess returns on lagged idiovol plus controls is one of our two headline specifications, alongside quintile sorts. `methods`

### shanken1992estimation

Shanken, J. 1992. "On the Estimation of Beta-Pricing Models." *Review of Financial Studies* 5(1): 1-33.

Derives the errors-in-variables correction to FM standard errors when first-pass betas are estimated rather than known, and integrates ML and two-pass approaches. Shows the uncorrected FM procedure overstates the precision of price-of-risk estimates. *Our paper:* the canonical reference when reporting Shanken-corrected standard errors alongside the unadjusted FM standard errors. `methods`

### petersen2009estimating

Petersen, M. A. 2009. "Estimating Standard Errors in Finance Panel Data Sets: Comparing Approaches." *Review of Financial Studies* 22(1): 435-480.

Compares OLS, White, clustered, Fama-MacBeth, and Rogers standard errors in finance panel data sets. Shows that when residuals exhibit a firm-effect, clustering by firm is essential; when residuals exhibit a time-effect, FM or clustering by time is essential; double clustering is appropriate when both are present. *Our paper:* governs our standard-error choice in the FM regressions — we cluster by month, with Newey-West adjustment for the time-series of FM coefficients. `methods`

### jegadeesh2019empirical

Jegadeesh, N., Noh, J., Pukthuanthong, K., Roll, R., and Wang, J. 2019. "Empirical Tests of Asset Pricing Models with Individual Assets: Resolving the Errors-in-Variables Bias in Risk Premium Estimation." *Journal of Financial Economics* 133(2): 273-298.

Proposes an instrumental-variables approach that allows individual stocks (rather than portfolios) as test assets while delivering consistent ex-post risk-premium estimates. Demonstrates that under the corrected procedure, market and factor risk premia become insignificant once asset characteristics are controlled — sharpening the case for characteristic-based interpretations. *Our paper:* methods reference for the FM specification at the individual-stock level; we note the EIV concern when discussing the magnitude (not just the sign) of the idiovol slope. `methods`

---

## Frontier Map

| Bucket | Papers |
|---|---|
| (i) Does the puzzle exist? | ang2006cross, ang2009high, bali2008idiosyncratic, campbell2001have, goyal2003idiosyncratic |
| (ii) Why does the puzzle exist? — explanations | fu2009idiosyncratic, boyer2010expected, bali2011maxing, han2011investor, huang2010return, stambaugh2015arbitrage, hou2016have, chen2012does, liu2018absolving, asness2020betting |
| (ii) Benchmark factor models (sub-bucket) | fama1993common, carhart1997persistence |
| (iii) Does the puzzle still exist? | chu2020idiosyncratic, mclean2016does, hou2020replicating, bali2017lottery, barillas2018comparing |
| (iv) Methods | famamacbeth1973, shanken1992estimation, petersen2009estimating, jegadeesh2019empirical |

The literature is mature on bucket (i) for the original sample window (1963-2000) and well-developed on bucket (ii) through 2020. Bucket (iii) is unsettled. McLean and Pontiff (2016) predicts attenuation, Hou, Xue, and Zhang (2020) finds survival under VW with q-factor benchmarks, and the post-Reg-SHO era plus the rise of indexing and high-frequency arbitrage capital create new reasons to expect decay. The benchmark factor models (FF3, FF4) and methods literature (FM, Shanken, Petersen, JNPRW) are settled tools.

**Empty cells the literature has not addressed:**

1. **No transparent decade-by-decade AHXZ replication on the 1990-2024 sample.** Hou, Xue, and Zhang (2020) cover idiovol within a 452-anomaly survey; no paper takes the AHXZ design end-to-end on this window.
2. **No update on whether the post-publication anomaly decay documented by McLean and Pontiff (2016) has continued through 2024**, specifically for idiovol — i.e., whether the spread is now indistinguishable from zero in the most recent decade.
3. **No clean comparison of CAPM-residual vs FF3-residual idiovol in the modern sample**, with both equal-weighted and value-weighted portfolios and NYSE breakpoints, holding the rest of the design fixed. Most papers either swap one design lever at a time or test one specification.
4. **No sample-period sensitivity analysis** of how the puzzle behaves across the regime shifts within 1990-2024 — pre/post Reg SHO 2007, pre/post the 2003 decimalization, and the indexing/passive-flows era (2010+).

Our paper fills cell 1 directly and provides material relevant to cells 2 and 4 as part of the same exercise. Cell 3 is partially addressed by our robustness battery (CAPM headline, FF3 robustness; EW headline, VW robustness; NYSE breakpoints robustness).

---

## Gap Statement

The literature contains a foundational result (Ang, Hodrick, Xing, Zhang 2006), a body of competing explanations through 2020, and a methodological literature on replication (Hou, Xue, Zhang 2020) — but no recent paper takes the original AHXZ research design and runs it on the 1990-2024 US universe with the explicit goal of measuring whether the negative idiovol-return relation has survived. We fill this gap by replicating the exact AHXZ exercise — CAPM-based daily-residual idiosyncratic volatility, equal-weighted quintile sorts, and Fama-MacBeth cross-sectional regressions — on common stocks (CRSP shrcd 10/11) ex-financials and ex-utilities over 1990-2024. Our contribution is descriptive and methodological: a transparent update that shows what the AHXZ-style estimate looks like today, decade-by-decade, with NYSE-breakpoint and value-weighted robustness in the spirit of Hou, Xue, and Zhang (2020). We make no causal claim and do not adjudicate among the explanations in bucket (ii); rather, we provide the updated stylized fact against which future explanations must be tested.
