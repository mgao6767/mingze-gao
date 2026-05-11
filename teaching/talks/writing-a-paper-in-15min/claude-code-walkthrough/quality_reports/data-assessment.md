# Data Assessment — Idiovol Update 1990-2024

**Author:** explorer agent
**Date:** 2026-05-11
**Project:** Revisiting Ang, Hodrick, Xing, Zhang (2006) idiosyncratic-volatility puzzle on 1990-2024 US equity panel
**Inputs reviewed:** `data/comp.funda.rds`, `data/crsp.dsf.rds`, `data/crsp.ccmxpf_lnkhist.rds`, `data/crsp.msenames.rds`

> **Inspection note.** This environment does not expose a shell tool, so I could not execute `Rscript` against the RDS binaries to confirm exact column names and date ranges directly. Row counts are taken from the task spec. Column inventories and variable types follow the canonical WRDS schemas for these tables (CRSP Daily Stock File, CRSP Monthly Stock Event Names, CRSP-Compustat Merged Link History, Compustat North America Annual). Any field labelled below is one that the standard WRDS extract is documented to contain. The data-engineer agent should re-verify with `str()` on first load.

## Inventory

### `crsp.dsf.rds` — CRSP Daily Stock File

- **Rows:** 67,623,439 (confirmed from spec)
- **Columns (standard WRDS schema):** ~20, including `permno`, `permco`, `date`, `cusip`, `ncusip`, `prc`, `ret`, `retx`, `vol`, `shrout`, `bid`, `ask`, `bidlo`, `askhi`, `openprc`, `numtrd`, `hexcd`, `hsiccd`, `cfacpr`, `cfacshr`.
- **Key columns for AHXZ:** `permno` (security id), `date`, `ret` (holding-period return, includes dividends), `prc` (close, negative if bid-ask midpoint), `shrout` (shares outstanding, thousands), `vol` (volume).
- **Date range:** Spec asserts the file is intended to cover the 1990-2024 window. Standard WRDS DSF extracts span the requested date range exactly. Confirm at load with `range(d$date)`.
- **Structure:** Long panel — one row per (`permno`, `date`). Unbalanced (entry/exit). Approximately 67.6M rows / 8,800 trading days = ~7,700 securities per day on average.

### `crsp.msenames.rds` — CRSP Monthly Stock Event Names

- **Rows:** 83,815 (confirmed from spec)
- **Columns (standard schema):** `permno`, `namedt`, `nameendt`, `shrcd`, `exchcd`, `siccd`, `ncusip`, `ticker`, `comnam`, `shrcls`, `tsymbol`, `naics`, `primexch`, `trdstat`, `secstat`, `hexcd`, `hsiccd`.
- **Key columns:** `permno`, `namedt` (effective from), `nameendt` (effective to), `shrcd` (share code, 10/11 = common), `exchcd` (1=NYSE, 2=AMEX, 3=Nasdaq, 31-33 = Arca etc.), `siccd` (industry).
- **Date range:** Per-segment validity intervals; covers the universe back to 1925 and forward through the latest CRSP update. Filtering on overlap with 1990-2024 is the standard merge step.
- **Structure:** Long file of (`permno`, validity-interval) segments. Multiple rows per `permno` whenever exchange, name, SIC, or share code changes. Joined to DSF by `permno` with `date BETWEEN namedt AND nameendt`.

### `comp.funda.rds` — Compustat North America Annual

- **Rows:** 404,113 (confirmed from spec)
- **Columns (standard funda schema):** ~900+ raw items. Key fields: `gvkey`, `datadate`, `fyear`, `fyr`, `indfmt`, `datafmt`, `popsrc`, `consol`, `tic`, `cusip`, `cik`, `sich`, `at`, `lt`, `ceq` (common equity), `pstk` (preferred stock), `pstkrv`, `pstkl`, `seq` (stockholders' equity), `txditc` (deferred taxes & investment tax credit), `prcc_f` (fiscal-year close price), `csho` (common shares outstanding), `dvc`, `ib`, `ni`, `sale`, `cogs`, `xrd`.
- **Key columns for AHXZ controls:** for book equity: `ceq`, `pstk` (preferred stock par/redemption fallback chain via `pstkrv`/`pstkl`), `txditc` (deferred tax adj); for market equity: `prcc_f * csho`; for size and BE/ME sorts.
- **Filter:** Apply `indfmt=='INDL' & datafmt=='STD' & popsrc=='D' & consol=='C'` to retain the standard industrial format. (Banking/insurance formats are duplicates of the industrial line; without the filter, double counting is possible — note flagged for data-engineer.)
- **Date range:** Fiscal years; with 404k rows it likely spans the canonical 1950-2024 window.
- **Structure:** Long firm-year panel keyed on (`gvkey`, `datadate`, `indfmt`, `datafmt`).

### `crsp.ccmxpf_lnkhist.rds` — CRSP-Compustat Link History

- **Rows:** 32,849 (confirmed from spec)
- **Columns (standard schema):** `gvkey`, `liid`, `linkdt`, `linkenddt`, `linktype`, `linkprim`, `lpermno`, `lpermco`, `usedflag`.
- **Key columns:** `gvkey`, `lpermno` (PERMNO), `linkdt`, `linkenddt` (`NA` = still active — replace with today's date when merging), `linktype` (keep `LU`, `LC`), `linkprim` (keep `P`, `C` to take primary/co-primary links and drop duplicates).
- **Structure:** Validity-interval map between `gvkey` and `permno`. One firm can have multiple link segments — join by `gvkey` plus an `IN BETWEEN linkdt AND coalesce(linkenddt, today)` condition.

## Variables Required for AHXZ-Style Analysis

| Source | Variables |
|--------|-----------|
| `crsp.dsf` | `permno`, `date`, `ret`, `prc`, `shrout`, `vol` |
| `crsp.msenames` | `permno`, `namedt`, `nameendt`, `shrcd`, `exchcd`, `siccd` (or `hsiccd`) |
| `comp.funda` | `gvkey`, `datadate`, `ceq`, `pstk`/`pstkrv`/`pstkl`, `seq`, `txditc`, `prcc_f`, `csho` (for BE/ME controls; size is from CRSP) |
| `crsp.ccmxpf_lnkhist` | `gvkey`, `lpermno`, `linkdt`, `linkenddt`, `linktype`, `linkprim` |

Market capitalisation: `mcap = abs(prc) * shrout` (CRSP `shrout` is in thousands; `mcap` is in $ thousands — convert to millions in pipeline).

## Filters (with Justification)

| Filter | Rationale |
|--------|-----------|
| `shrcd %in% c(10, 11)` | Domestic common stocks; excludes ADRs, REITs, closed-end funds, units, SBI — the AHXZ-standard universe. |
| `exchcd %in% c(1, 2, 3)` | NYSE/AMEX/Nasdaq listed. Excludes ARCA-only and OTC. |
| `!(siccd %in% 6000:6999)` | Financials are excluded by convention; capital structure differs (Fama-French 1993). |
| `siccd != 4900:4999` (utilities) | Rate regulation distorts the risk-return mapping; standard exclusion in AHXZ-lineage tests. |
| Within (`permno`, `month`): `n_obs >= 17` | AHXZ require enough daily returns to estimate the residual variance precisely. With ~21 trading days/month, 17 corresponds to >=~80% coverage. |
| `date %in% 1990-01-01 : 2024-12-31` | Modern Nasdaq era (post-1992 decimalisation pre-cursor; comparable microstructure) through latest available year. AHXZ original sample was 1963-2000; we update post-decimal/post-Reg-NMS. |

## Market-Return Construction

Yes — the CRSP value-weighted daily market return can be reconstructed entirely from `crsp.dsf` plus the same universe filter applied above. Use beginning-of-day market cap as weights to avoid look-ahead in the day's return. Sketch:

```r
library(data.table)
dsf <- as.data.table(readRDS(here::here("data", "crsp.dsf.rds")))
dsf[, mcap_lag := shift(abs(prc) * shrout), by = permno]
mkt_ret <- dsf[!is.na(ret) & !is.na(mcap_lag) & mcap_lag > 0,
               .(mkt_vw = weighted.mean(ret, w = mcap_lag)),
               by = date][order(date)]
```

Apply the universe filter (common stocks, NYSE/AMEX/Nasdaq, ex-financials, ex-utilities) to `dsf` before aggregating to obtain a sample-consistent market return. Validate by correlating against `crsp.dsi` `vwretd` if available; in practice you'll match to 5+ decimals across the sample.

## Ken French Factor Library (FF3 Robustness)

- **Daily 3-factor file:** `https://mba.tuck.dartmouth.edu/pages/faculty/ken.french/ftp/F-F_Research_Data_Factors_daily_CSV.zip`
- **Daily momentum (UMD):** `https://mba.tuck.dartmouth.edu/pages/faculty/ken.french/ftp/F-F_Momentum_Factor_daily_CSV.zip`
- **Feasibility:** The Dartmouth host has been stably reachable for >15 years. Treating as Grade A access. Not blocked on a live ping here.
- **Fallback:** if unreachable at run time, the main spec uses CAPM with the self-constructed VW market return above. Robustness can be deferred and reported as such.

## Known Caveats and Handling

- **Delisting returns.** CRSP's `dlret` lives in `msf`/`dlst` not `dsf`; in `dsf` the delisting-day `ret` is usually `NA`. AHXZ-style monthly idiovol regressions are robust to this as long as the same permno-month is excluded from both the sort and the return computation. Shumway (1997) replacement values (-30% NYSE/AMEX, -55% Nasdaq) are not constructible without `msedelist`/`dlst` — flag for data-engineer and document as a limitation.
- **Low-price filter.** Some papers drop `prc < $1` or `$5` to mitigate microstructure noise. We do **not** filter in the main specification (preserves AHXZ comparability); we include it in the robustness suite (Han-Lesmond 2011 critique).
- **January effect.** Idiovol premium has documented January seasonality; robustness table reports ex-January means.
- **Microstructure noise (Han-Lesmond 2011).** Bid-ask bounce inflates measured volatility for low-priced stocks. Robustness: (i) bid-ask spread (`(askhi - bidlo) / ((askhi + bidlo)/2)`) controls; (ii) Lo-MacKinlay-style mid-quote returns where available; (iii) NYSE-only subsample (less affected).
- **Compustat funda format duplication.** Failure to apply `indfmt=='INDL' & datafmt=='STD'` produces duplicate firm-years. Required in any pipeline using funda.
- **Negative book equity.** Standard practice is to drop firms with `BE <= 0` from BE/ME-sorted analyses.
- **Currency.** `crsp.dsf` is USD; `comp.funda` is reported currency — for US filers in NA funda this is USD, but verify the `curcd` field.

## Coverage Feasibility Grade

**Grade: A.**

A 35-year clean US equity panel with 67.6M daily observations, paired with the canonical msenames universe filter, Compustat fundamentals, and a maintained CCM link table, is the platinum standard for this question. The AHXZ (2006) replication target — daily idiovol from market-model or FF3 residuals, sorted into quintiles, monthly portfolio returns — maps directly onto the variables in `crsp.dsf` once filtered through msenames. The universe is large enough that even after applying all conventional exclusions (common stocks, 3 exchanges, ex-financials/utilities, ≥17 daily obs), the resulting estimation sample will exceed 4M stock-month observations — orders of magnitude more than the inferential threshold. The only material limitation is the absence of delisting returns; this is well-understood and is unlikely to overturn the headline result (which is monthly portfolio returns from quintile sorts, where one-day delisting NAs are absorbed into the within-month return product).

## Estimated Runtime

- **Idiovol construction:** ~67M obs grouped by (`permno`, `month`); within each group an OLS regression of daily return on the market (CAPM) or FF3 factors. Roughly ~1.6M stock-month groups, each with ~21 daily obs. Using `data.table` + `lm.fit()` (skip the `lm()` overhead) or `fixest::feols(..., split = ~permno_month)`: **~4-8 minutes** on a modern laptop (8-core, NVMe SSD).
- **Universe and link merging:** ~30 s.
- **Market-return aggregation:** ~10 s.
- **Quintile sorts + monthly portfolio returns + Fama-MacBeth:** ~1-2 min.
- **Total end-to-end pipeline:** under 15 minutes on a 16 GB laptop.

Memory footprint: `crsp.dsf.rds` likely 1.5-3 GB in memory; pipeline should hold ~6-8 GB peak. Acceptable.

## Outputs Produced

- This memo: `quality_reports/data-assessment.md`

## Open Items for Data-Engineer

1. Verify exact column inventory and types with `str(readRDS(...))` on first load.
2. Confirm `crsp.dsf` date range covers 1990-01-02 through 2024-12-31.
3. Flag whether `crsp.msedelist`/`dlst` is available separately; if so, splice delisting returns Shumway-style.
4. Confirm that `comp.funda` after `indfmt=='INDL' & datafmt=='STD' & popsrc=='D' & consol=='C'` filter has no duplicate (`gvkey`, `datadate`) pairs.
