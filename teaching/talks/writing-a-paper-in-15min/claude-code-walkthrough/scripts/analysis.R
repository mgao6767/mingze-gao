## =====================================================================
## Idiovol and the cross-section of returns, 1990-2024
## AHXZ-style update on the merged CRSP-Compustat US public-firm universe
##
## Paper-to-code naming map:
##   Paper                  Code                Description
##   r_{i,d}                ret                 Daily holding-period return (CRSP)
##   r_{f,d}                rf                  Daily risk-free rate (Ken French)
##   r_{M,d}                mkt_rf + rf         Daily market return (Ken French VW)
##   IVOL_{i,m}             ivol                Within-month sd of CAPM residual
##   ME_{i,t}               me                  Market equity (Compustat: prcc_f * csho)
##   BE_{i,t}               be                  Book equity (FF convention)
##   BE/ME_{i,t}            btm                 Book-to-market ratio
##   MOM_{i,t-12,t-2}       mom                 Cumulative return from t-12 to t-2
##   STR_{i,t-1}            str                 Short-term reversal (lag-1 return)
##   r^{LS}_{m+1}           ret_ls              Long-Q1/short-Q5 return
##
## Inputs (data/):
##   crsp.dsf.rds           daily (permno, date, ret)
##   crsp.msenames.rds      validity-interval universe attributes
##   comp.funda.rds         Compustat annual fundamentals
##   crsp.ccmxpf_lnkhist.rds CRSP-Compustat link history
##   ff_factors_daily.rds   Ken French daily factors + rf
##
## NOTE: The supplied crsp.dsf.rds is pre-thinned to (date, permno, ret).
##       prc/shrout/vol are not available. We therefore (i) use Ken French
##       mkt_rf directly as the market return (no self-constructed VW
##       market), (ii) build ME from Compustat (prcc_f * csho) carried
##       forward by fiscal year, (iii) use this ME as both the VW weight
##       and the log-size control, and (iv) accept VW degradation: because
##       the only ME signal varies annually (fiscal-year-end Compustat ME)
##       and is identical across each (permno, fiscal-year) block of 12
##       monthly rows, the VW columns end up near-identical to EW within
##       a fiscal year and only re-weight at year boundaries.  We further
##       cannot implement robustness checks R5 (MAX) and R6 (price<$5)
##       because monthly prc/shares are unavailable.  All four deviations
##       from the strategy memo are documented in code, in the slide
##       bundle's caveats field, and in the manuscript.
##
## Produces:
##   output/table1_summary.tex    summary stats
##   output/table2_sorts.tex      quintile portfolio sorts (EW/VW, NW SE)
##   output/table3_alphas.tex     CAPM and FF3 alphas of Q5-Q1 L/S
##   output/table3b_ff4_alphas.tex  FF4 (Carhart) alphas of Q5-Q1 L/S (R9)
##   output/table4_fm.tex         Fama-MacBeth cross-sectional regressions
##   output/table5_subperiods.tex pre/post-1999 sub-period split
##   output/table6_size.tex       NYSE-20% small/large split
##   output/fig1_idiovol_ls.pdf   mean idiovol time-series + cumulative L/S
##   output/fig2_quintile_returns.pdf  mean returns by quintile with CI
##   output/slide_bundle.rds      compact bundle for the slides (includes
##                                rob_* robustness fields and caveats)
## =====================================================================

library(here)
library(tidyverse)
library(data.table)
library(lubridate)
library(fixest)
library(sandwich)
library(modelsummary)
library(tinytable)
library(ggplot2)

here::i_am("scripts/analysis.R")
set.seed(20260519)
options(scipen = 999, datatable.print.nrows = 20L)

## --- Constants -----------------------------------------------------------

DATE_START      <- as.Date("1990-01-01")
DATE_END        <- as.Date("2024-12-31")
MIN_OBS_PER_MO  <- 17L
NW_LAGS         <- 12L
PHI_QUINTILES   <- c(0.20, 0.40, 0.60, 0.80)
DATA_DIR        <- here::here("data")
OUT_DIR         <- here::here("output")
dir.create(OUT_DIR, showWarnings = FALSE, recursive = TRUE)

t0_total <- Sys.time()
log_step <- function(msg, t0 = NULL) {
  if (is.null(t0)) {
    message(sprintf("[%s] %s",
                    format(Sys.time(), "%H:%M:%S"), msg))
  } else {
    elapsed_s <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
    message(sprintf("[%s] %s (%.1fs)",
                    format(Sys.time(), "%H:%M:%S"), msg, elapsed_s))
  }
}

## --- Load ----------------------------------------------------------------

log_step("Loading data")

t0 <- Sys.time()
dsf      <- as.data.table(readRDS(file.path(DATA_DIR, "crsp.dsf.rds")))
msenames <- as.data.table(readRDS(file.path(DATA_DIR, "crsp.msenames.rds")))
funda    <- as.data.table(readRDS(file.path(DATA_DIR, "comp.funda.rds")))
ccm      <- as.data.table(
  readRDS(file.path(DATA_DIR, "crsp.ccmxpf_lnkhist.rds")))
ff       <- as.data.table(readRDS(file.path(DATA_DIR, "ff_factors_daily.rds")))
log_step("Loaded data", t0)

## --- Universe attribute table from msenames ------------------------------

log_step("Building universe filter")
t0 <- Sys.time()

# Keep only segments that overlap our window and pass static filters.
msenames[, nameendt := fifelse(is.na(nameendt), as.Date("9999-12-31"),
                               nameendt)]
universe_segments <- msenames[
  shrcd %in% c(10L, 11L) &
    exchcd %in% c(1L, 2L, 3L) &
    !(siccd %in% 6000:6999) &
    !(siccd %in% 4900:4999) &
    nameendt >= DATE_START & namedt <= DATE_END,
  .(permno, namedt, nameendt, shrcd, exchcd, siccd)
]

# Filter dsf to window and merge universe attributes by (permno, date in segment).
dsf <- dsf[date >= DATE_START & date <= DATE_END & !is.na(ret)]

setkey(universe_segments, permno, namedt, nameendt)
setkey(dsf, permno, date)

# data.table foverlaps requires identical start/end columns; build a
# zero-width interval [date, date] in dsf and intersect with the
# segment intervals.
dsf[, date_end := date]
dsf_u <- foverlaps(
  dsf,
  universe_segments,
  by.x = c("permno", "date", "date_end"),
  by.y = c("permno", "namedt", "nameendt"),
  type = "any",
  mult = "first",
  nomatch = NULL
)
dsf_u[, c("namedt", "nameendt", "date_end") := NULL]
setkey(dsf_u, permno, date)

# Free memory: drop the unfiltered dsf object.
rm(dsf, msenames, universe_segments)
gc(verbose = FALSE)

log_step(sprintf("Universe filter: %d daily obs, %d permnos",
                 nrow(dsf_u), uniqueN(dsf_u$permno)), t0)

## --- Attach Ken French factors and daily excess return ------------------

log_step("Joining FF factors")
t0 <- Sys.time()

setkey(ff, date)
dsf_u <- merge(dsf_u, ff[, .(date, mkt_rf, smb, hml, mom, rf)],
               by = "date", all.x = TRUE)

# Drop rows where ff_rf is missing (rare; outside ff coverage).
dsf_u <- dsf_u[!is.na(rf) & !is.na(mkt_rf)]
dsf_u[, exret  := ret - rf]
dsf_u[, mkt_e  := mkt_rf]  # already excess
dsf_u[, ym     := year(date) * 100L + month(date)]

log_step("FF factors joined", t0)

## --- Idiovol construction (vectorised) ----------------------------------

# For each (permno, ym), regress exret on mkt_e (CAPM). Idiovol = sd(resid).
# Vectorised: a = mean(y) - b * mean(x); b = cov(x,y)/var(x); resid_sd from
# regression identity: var(resid) = var(y) - b^2 * var(x).  Computed with
# data.table group-by aggregates.

log_step("Computing idiosyncratic volatility")
t0 <- Sys.time()

idio <- dsf_u[, .(
  n_d   = .N,
  my    = mean(exret),
  mx    = mean(mkt_e),
  syy   = sum((exret - mean(exret))^2),
  sxx   = sum((mkt_e - mean(mkt_e))^2),
  sxy   = sum((exret - mean(exret)) * (mkt_e - mean(mkt_e)))
), by = .(permno, ym)]

idio <- idio[n_d >= MIN_OBS_PER_MO & sxx > 0]
# OLS slope and residual sum of squares
idio[, beta := sxy / sxx]
idio[, rss  := syy - (sxy^2) / sxx]
# rss can be slightly negative due to floating point on (near-)zero residuals;
# clamp to >= 0.
idio[, rss  := pmax(rss, 0)]
# Sample sd of residuals with 2 lost dof (intercept + slope).
idio[, ivol := sqrt(rss / pmax(n_d - 2L, 1L))]
idio <- idio[, .(permno, ym, ivol, beta_capm = beta, n_d)]

log_step(sprintf("Idiovol: %d (permno, ym) groups", nrow(idio)), t0)

## --- Monthly stock returns -----------------------------------------------

log_step("Compounding daily to monthly returns")
t0 <- Sys.time()

monthly <- dsf_u[, .(
  ret_m   = prod(1 + ret) - 1,
  rf_m    = prod(1 + rf) - 1,
  mkt_m   = prod(1 + mkt_rf + rf) - 1,
  mkt_rf_m = prod(1 + mkt_rf + rf) - 1 - (prod(1 + rf) - 1),
  smb_m   = prod(1 + smb) - 1,
  hml_m   = prod(1 + hml) - 1,
  mom_m   = prod(1 + mom) - 1,
  exchcd  = last(exchcd),
  siccd   = last(siccd),
  n_d     = .N
), by = .(permno, ym)]
monthly[, exret_m := ret_m - rf_m]
monthly[, date_m  := as.Date(sprintf("%d-%02d-01",
                                      ym %/% 100L, ym %% 100L))]
# Month-end date for sort timing.
monthly[, eom := ceiling_date(date_m, "month") - 1L]

log_step(sprintf("Monthly panel: %d (permno, month) rows", nrow(monthly)), t0)

## --- Compustat-derived market equity, book equity, BE/ME ----------------

log_step("Building Compustat panel")
t0 <- Sys.time()

# Filter funda to standard industrial format.
funda <- funda[
  indfmt == "INDL" & datafmt == "STD" &
    popsrc == "D" & consol == "C" &
    (is.na(curcd) | curcd == "USD")
]

# Book equity (FF convention).
funda[, ps := fcoalesce(pstkrv, pstkl, pstk, 0)]
funda[, be := ceq + fcoalesce(txditc, 0) - ps]
funda[, me_funda := prcc_f * csho]                            # $millions
funda[, fyear_end := as.Date(datadate)]

# Reduce to one row per (gvkey, fiscal-year-end).
funda <- funda[, .(gvkey, fyear_end, be, me_funda)]
funda <- funda[!is.na(fyear_end)]
# Dedup if any: keep latest record per (gvkey, fyear_end).
setorder(funda, gvkey, fyear_end)
funda <- unique(funda, by = c("gvkey", "fyear_end"), fromLast = TRUE)

# Link via CCM (use LU/LC, primary/coprimary).
ccm <- ccm[linktype %in% c("LU", "LC") & linkprim %in% c("P", "C")]
ccm[, linkenddt := fifelse(is.na(linkenddt), as.Date("9999-12-31"),
                            linkenddt)]
ccm <- ccm[!is.na(lpermno),
            .(gvkey, permno = as.integer(lpermno), linkdt, linkenddt)]

# Merge link to funda via a simple equi-join on gvkey, then filter by
# validity interval (avoids data.table's non-equi-join column aliasing).
setkey(funda, gvkey)
setkey(ccm, gvkey)
fund_link <- ccm[funda, on = "gvkey", allow.cartesian = TRUE,
                  nomatch = NULL]
fund_link <- fund_link[fyear_end >= linkdt & fyear_end <= linkenddt]
fund_link <- fund_link[, .(permno, gvkey, fyear_end, be, me_funda)]
fund_link <- fund_link[!is.na(be) & !is.na(me_funda)]
# Dedup: in the rare case where one (permno, fyear_end) has multiple
# rows (e.g., overlapping links), keep the row with the latest linkdt.
setorder(fund_link, permno, fyear_end)
fund_link <- unique(fund_link, by = c("permno", "fyear_end"),
                     fromLast = TRUE)

# Fama-French BE/ME timing: book equity from fiscal year ending in y
# matched to monthly returns July(y+1) through June(y+2).  ME for the
# BE/ME ratio is December(y) value -- but we lack CRSP prc/shrout, so we
# use the Compustat fiscal-year ME (me_funda).  This is a documented
# deviation.

# btm_match_date is the fiscal-year-end of book equity used for that month.
# Build a long (permno, ym, be, me_funda) panel where for each month we
# carry the most recent be whose fiscal-year-end is at least 6 months prior.
log_step("Carrying forward Compustat values monthly", t0)
t0 <- Sys.time()

# Build a sparse (permno, month_eligible_date, be, me_funda) table.
fund_long <- fund_link[, .(
  permno,
  begin_m = ceiling_date(fyear_end %m+% months(6L), "month"),
  fyear_end,
  be,
  me_funda
)]
setorder(fund_long, permno, begin_m, fyear_end)
fund_long <- unique(fund_long, by = c("permno", "begin_m"), fromLast = TRUE)

# Roll-forward join: for each monthly record, attach the most recent
# Compustat row whose begin_m is <= eom.
setkey(fund_long, permno, begin_m)
setkey(monthly, permno, eom)
monthly[, eom_key := eom]
monthly <- fund_long[monthly,
                      on = .(permno, begin_m = eom_key),
                      roll = TRUE]
setnames(monthly, "begin_m", "comp_begin_m")
setkey(monthly, permno, ym)

log_step("Compustat carryforward complete", t0)

## --- Build lagged-1 IVOL, size, BE/ME, MOM, STR -------------------------

log_step("Building predictors")
t0 <- Sys.time()

# Merge idiovol into monthly panel.
setkey(idio, permno, ym)
monthly <- merge(monthly, idio[, .(permno, ym, ivol, beta_capm, n_d_ivol = n_d)],
                  by = c("permno", "ym"), all.x = TRUE)

setorder(monthly, permno, ym)

# Sequential calendar-month index per permno so that "lag 1 = previous
# calendar month" requires checking ym arithmetic, not just shift().
monthly[, prev_ym := shift(ym, type = "lag"), by = permno]
monthly[, ym_lag1_expected := {
  yr <- ym %/% 100L
  mo <- ym %% 100L
  prev_mo <- ifelse(mo == 1L, 12L, mo - 1L)
  prev_yr <- ifelse(mo == 1L, yr - 1L, yr)
  prev_yr * 100L + prev_mo
}]
monthly[, has_prev := !is.na(prev_ym) & prev_ym == ym_lag1_expected]

# Lag-1 idiovol (the predictor for return in month ym).
monthly[, ivol_lag := shift(ivol, type = "lag"), by = permno]
monthly[has_prev == FALSE, ivol_lag := NA_real_]

# Lag-1 exchcd (sort assignment uses exchcd at the sort month).
monthly[, exchcd_lag := shift(exchcd, type = "lag"), by = permno]
monthly[has_prev == FALSE, exchcd_lag := NA_integer_]

# Lag-1 me (size for VW weight and log-size control).
monthly[, me := me_funda]
monthly[, me_lag := shift(me, type = "lag"), by = permno]
monthly[has_prev == FALSE, me_lag := NA_real_]

# Lag-1 book-to-market (be / me).
monthly[, btm := ifelse(!is.na(be) & be > 0 & !is.na(me) & me > 0,
                         be / me, NA_real_)]
monthly[, btm_lag := shift(btm, type = "lag"), by = permno]
monthly[has_prev == FALSE, btm_lag := NA_real_]

# Lag-1 short-term reversal: return in month t-1.
monthly[, str := shift(ret_m, type = "lag"), by = permno]
monthly[has_prev == FALSE, str := NA_real_]

# Momentum t-12 to t-2: compound 11-month return ending two months ago.
# Use a rolling product of (1+ret_m) over months -12..-2 inclusive
# (11 months), then subtract 1.  Only valid when permno has a contiguous
# 12-month history immediately preceding the current month.
setorder(monthly, permno, ym)
monthly[, ret_m_lag2  := shift(ret_m, n = 2L, type = "lag"), by = permno]
# Build a helper: cumulative log(1+ret) per permno, then mom = exp(diff) - 1.
monthly[, lret := log1p(ret_m)]
monthly[, cum_lret := cumsum(replace(lret, is.na(lret), 0)),
         by = permno]
monthly[, mom := {
  # mom_t = prod(1 + r_{t-12..t-2}) - 1
  # = exp( cum_lret_{t-2} - cum_lret_{t-13} ) - 1
  lret_lag2  <- shift(cum_lret, n = 2L,  type = "lag")
  lret_lag13 <- shift(cum_lret, n = 13L, type = "lag")
  # We also need none of the 11 intervening monthly returns to be NA;
  # using running count of non-NA lret in same window.
  n_nonna_cum <- cumsum(as.integer(!is.na(lret)))
  n_lag2  <- shift(n_nonna_cum, n = 2L,  type = "lag")
  n_lag13 <- shift(n_nonna_cum, n = 13L, type = "lag")
  ok <- !is.na(lret_lag2) & !is.na(lret_lag13) &
        (n_lag2 - n_lag13) == 11L
  out <- exp(lret_lag2 - lret_lag13) - 1
  out[!ok] <- NA_real_
  out
}, by = permno]
monthly[, c("lret", "cum_lret") := NULL]

log_step("Predictors built", t0)

## --- Build the sort sample ---------------------------------------------

# Sample for quintile sorts: monthly rows with non-NA ivol_lag (the lagged
# idiovol from the previous month).  All stocks (NYSE/AMEX/Nasdaq) sorted
# into quintiles by NYSE breakpoints computed each month on lagged idiovol
# for NYSE stocks (exchcd_lag == 1).

log_step("Computing NYSE quintile breakpoints")
t0 <- Sys.time()

sort_panel <- monthly[!is.na(ivol_lag) & !is.na(ret_m) & !is.na(exchcd_lag)]

bps <- sort_panel[exchcd_lag == 1L,
                  as.list(quantile(ivol_lag,
                                    probs = PHI_QUINTILES,
                                    names = FALSE, na.rm = TRUE)),
                  by = ym]
setnames(bps, c("V1", "V2", "V3", "V4"),
         c("b20", "b40", "b60", "b80"))

sort_panel <- merge(sort_panel, bps, by = "ym", all.x = TRUE)
sort_panel <- sort_panel[!is.na(b20)]

sort_panel[, quintile := fcase(
  ivol_lag <= b20, 1L,
  ivol_lag <= b40, 2L,
  ivol_lag <= b60, 3L,
  ivol_lag <= b80, 4L,
  ivol_lag >  b80, 5L
)]

log_step(sprintf("Sort panel: %d (permno, month) rows in %d months",
                 nrow(sort_panel), uniqueN(sort_panel$ym)), t0)

## --- Quintile portfolio monthly returns (EW and VW) ---------------------

log_step("Forming portfolios and computing returns")
t0 <- Sys.time()

# Sample-aligned portfolios: EW and VW must share the same set of stocks
# in each (ym, quintile). The binding constraint is non-NA, positive
# me_lag (the VW weight); restrict EW to the same rows so the two L/S
# series end up on identical monthly samples and the EW vs VW alpha
# regressions are directly comparable.
sort_panel_aligned <- sort_panel[!is.na(quintile) &
                                   !is.na(me_lag) & me_lag > 0]

# EW: simple mean of stock excess returns on the aligned sample.
port_ew <- sort_panel_aligned[,
                              .(ret = mean(exret_m, na.rm = TRUE),
                                n   = .N),
                              by = .(ym, quintile)]
port_ew[, weighting := "EW"]

# VW: market-equity-weighted (lag-1 me) on the same aligned sample.
port_vw <- sort_panel_aligned[,
                              .(ret = weighted.mean(exret_m, w = me_lag,
                                                    na.rm = TRUE),
                                n   = .N),
                              by = .(ym, quintile)]
port_vw[, weighting := "VW"]

ports <- rbind(port_ew, port_vw)
ports[, date_m := as.Date(sprintf("%d-%02d-01",
                                    ym %/% 100L, ym %% 100L))]
setorder(ports, weighting, quintile, ym)

# Long-short L/S = Q1 - Q5 (low IVOL minus high IVOL).
ls_returns <- dcast(ports, weighting + ym + date_m ~ quintile,
                    value.var = "ret")
setnames(ls_returns, c("1", "2", "3", "4", "5"),
         c("Q1", "Q2", "Q3", "Q4", "Q5"))
ls_returns[, ls := Q1 - Q5]

log_step("Portfolios built", t0)

## --- Newey-West helpers -------------------------------------------------

nw_se <- function(x, lags = NW_LAGS) {
  stopifnot(!is.null(x), length(x) > 0L, is.numeric(x),
            is.numeric(lags), length(lags) == 1L, lags >= 0L)
  x <- x[!is.na(x)]
  if (length(x) <= lags + 2L) return(c(mean = NA_real_, se = NA_real_,
                                        t = NA_real_, p = NA_real_,
                                        n = length(x)))
  fit <- lm(x ~ 1)
  vc <- sandwich::NeweyWest(fit, lag = lags, prewhite = FALSE,
                             adjust = TRUE)
  est <- as.numeric(coef(fit)[1])
  se <- sqrt(as.numeric(vc[1, 1]))
  tstat <- est / se
  pval <- 2 * pnorm(-abs(tstat))
  c(mean = est, se = se, t = tstat, p = pval, n = length(x))
}

nw_stars <- function(p) {
  fifelse(is.na(p), "",
   fifelse(p < 0.01, "***",
    fifelse(p < 0.05, "**",
     fifelse(p < 0.10, "*", ""))))
}

nw_alpha <- function(y, x_mat, lags = NW_LAGS) {
  stopifnot(!is.null(y), length(y) > 0L, is.numeric(y),
            !is.null(x_mat), is.matrix(x_mat) || is.data.frame(x_mat),
            nrow(as.matrix(x_mat)) == length(y),
            is.numeric(lags), length(lags) == 1L, lags >= 0L)
  # x_mat: matrix of factors (n x k); add intercept inside lm.
  df <- as.data.frame(cbind(y = y, x_mat))
  df <- df[complete.cases(df), , drop = FALSE]
  if (nrow(df) <= lags + ncol(df) + 2L) {
    return(list(coefs = NA_real_, se = NA_real_, t = NA_real_,
                 p = NA_real_, n = nrow(df), r2_adj = NA_real_))
  }
  fit <- lm(y ~ ., data = df)
  vc <- sandwich::NeweyWest(fit, lag = lags, prewhite = FALSE,
                             adjust = TRUE)
  est <- coef(fit)
  se_vec <- sqrt(diag(vc))
  tstat  <- est / se_vec
  # Use normal approx (matches nw_se) -- consistent treatment of NW t-stats.
  pval   <- 2 * pnorm(-abs(tstat))
  list(
    coefs = est,
    se    = se_vec,
    t     = tstat,
    p     = pval,
    n     = nobs(fit),
    r2_adj = summary(fit)$adj.r.squared
  )
}

## --- Monthly factor series (compound daily ff to monthly) ---------------

log_step("Compounding daily FF to monthly factors")
t0 <- Sys.time()

ff[, ym := year(date) * 100L + month(date)]
ff_m <- ff[, .(
  mkt_rf_m = prod(1 + mkt_rf) - 1,
  smb_m    = prod(1 + smb)    - 1,
  hml_m    = prod(1 + hml)    - 1,
  mom_m    = prod(1 + mom)    - 1,
  rf_m     = prod(1 + rf)     - 1
), by = ym]
setkey(ff_m, ym)
setkey(ls_returns, ym)
ls_returns <- merge(ls_returns, ff_m, by = "ym", all.x = TRUE)

log_step("Monthly factors built", t0)

## --- Spec 2: CAPM and FF3 alphas of the L/S portfolio ------------------

log_step("Estimating alphas")
t0 <- Sys.time()

alpha_fits <- list()
for (wt in c("EW", "VW")) {
  ls_w <- ls_returns[weighting == wt & !is.na(ls)]
  # CAPM
  alpha_fits[[paste0("capm_", wt)]] <- nw_alpha(
    y     = ls_w$ls,
    x_mat = as.matrix(ls_w[, .(mkt_rf_m)]),
    lags  = NW_LAGS
  )
  # FF3
  alpha_fits[[paste0("ff3_", wt)]] <- nw_alpha(
    y     = ls_w$ls,
    x_mat = as.matrix(ls_w[, .(mkt_rf_m, smb_m, hml_m)]),
    lags  = NW_LAGS
  )
}

log_step("Alphas done", t0)

## --- Spec 3: Fama-MacBeth cross-sectional regressions -------------------

log_step("Fama-MacBeth regressions")
t0 <- Sys.time()

fm_panel <- monthly[!is.na(ret_m) & !is.na(ivol_lag) &
                       !is.na(me_lag) & !is.na(btm_lag) &
                       !is.na(mom) & !is.na(str) & me_lag > 0 &
                       btm_lag > 0]
fm_panel[, log_me  := log(me_lag)]
fm_panel[, log_btm := log(btm_lag)]

fm_panel[, dep := exret_m]

# Spec 1: idiovol only.
# Spec 2: full controls.
run_fm <- function(formula, panel, time_key = "ym",
                    lags = NW_LAGS) {
  stopifnot(inherits(formula, "formula"),
            !is.null(panel), is.data.table(panel), nrow(panel) > 0L,
            is.character(time_key), length(time_key) == 1L,
            time_key %in% names(panel),
            is.numeric(lags), length(lags) == 1L, lags >= 0L)
  # Per-month OLS, collect slopes, then NW-mean.
  out <- panel[, {
    df <- .SD
    if (nrow(df) < 5L) {
      coefs <- rep(NA_real_,
                    length(all.vars(formula)) - 1L + 1L)
      names(coefs) <- c("(Intercept)",
                         setdiff(all.vars(formula), c("dep")))
      as.list(coefs)
    } else {
      fit <- lm(formula, data = df)
      as.list(coef(fit))
    }
  }, by = c(time_key), .SDcols = c(all.vars(formula))]
  # Drop intercept-only months (NA coefs).
  out <- na.omit(out)
  # NW means.
  coef_names <- setdiff(names(out), time_key)
  res <- lapply(coef_names, function(nm) {
    s <- nw_se(out[[nm]], lags = lags)
    data.frame(term = nm, mean = s["mean"], se = s["se"],
                t = s["t"], p = s["p"], n_months = s["n"],
                row.names = NULL)
  })
  do.call(rbind, res)
}

fm_only  <- run_fm(dep ~ ivol_lag, fm_panel)
fm_full  <- run_fm(dep ~ ivol_lag + log_me + log_btm + mom + str,
                    fm_panel)

log_step("Fama-MacBeth done", t0)

## --- Subperiod splits (pre vs post 2000) and size split -----------------

log_step("Subperiod and size splits")
t0 <- Sys.time()

ls_returns[, period := fifelse(ym < 200001L, "pre", "post")]

ls_summary <- function(dat) {
  out <- list()
  for (wt in c("EW", "VW")) {
    x <- dat[weighting == wt, ls]
    s <- nw_se(x, lags = NW_LAGS)
    out[[wt]] <- s
  }
  out
}

# Sub-period L/S returns and alphas.
sub_results <- list()
for (per in c("pre", "post")) {
  sub_results[[per]] <- list()
  for (wt in c("EW", "VW")) {
    sub <- ls_returns[period == per & weighting == wt & !is.na(ls)]
    s <- nw_se(sub$ls, lags = NW_LAGS)
    a_capm <- nw_alpha(sub$ls,
                       as.matrix(sub[, .(mkt_rf_m)]), lags = NW_LAGS)
    a_ff3 <- nw_alpha(sub$ls,
                      as.matrix(sub[, .(mkt_rf_m, smb_m, hml_m)]),
                      lags = NW_LAGS)
    sub_results[[per]][[wt]] <- list(mean = s, capm = a_capm, ff3 = a_ff3)
  }
}

# Size split: NYSE 20th percentile of lagged ME each month.
# Build size breakpoint per month from NYSE stocks.
size_bp <- monthly[exchcd_lag == 1L & !is.na(me_lag) & me_lag > 0,
                    .(bp_size = quantile(me_lag, 0.20, na.rm = TRUE)),
                    by = ym]
sort_panel_size <- merge(sort_panel, size_bp, by = "ym", all.x = TRUE)
sort_panel_size[, size_grp := fifelse(me_lag <= bp_size, "small",
                                       "large")]
sort_panel_size <- sort_panel_size[!is.na(size_grp) & !is.na(me_lag)]

size_results <- list()
for (sg in c("small", "large")) {
  size_results[[sg]] <- list()
  sub <- sort_panel_size[size_grp == sg]
  # Re-compute quintile breakpoints within size group (NYSE breakpoints
  # within the size cohort).
  bps_sub <- sub[exchcd_lag == 1L,
                  as.list(quantile(ivol_lag,
                                    probs = PHI_QUINTILES,
                                    names = FALSE, na.rm = TRUE)),
                  by = ym]
  setnames(bps_sub, c("V1", "V2", "V3", "V4"),
           c("b20", "b40", "b60", "b80"))
  sub2 <- merge(sub[, !c("b20", "b40", "b60", "b80")],
                bps_sub, by = "ym", all.x = TRUE)
  sub2 <- sub2[!is.na(b20)]
  sub2[, quintile := fcase(
    ivol_lag <= b20, 1L,
    ivol_lag <= b40, 2L,
    ivol_lag <= b60, 3L,
    ivol_lag <= b80, 4L,
    ivol_lag >  b80, 5L
  )]
  # Align EW and VW samples (see main panel section for rationale).
  sub2_aligned <- sub2[!is.na(quintile) & !is.na(me_lag) & me_lag > 0]
  ew <- sub2_aligned[, .(ret = mean(exret_m, na.rm = TRUE)),
                     by = .(ym, quintile)]
  vw <- sub2_aligned[, .(ret = weighted.mean(exret_m, w = me_lag,
                                              na.rm = TRUE)),
                     by = .(ym, quintile)]
  ew_w <- dcast(ew, ym ~ quintile, value.var = "ret")
  setnames(ew_w, c("1", "2", "3", "4", "5"),
           c("Q1", "Q2", "Q3", "Q4", "Q5"))
  ew_w[, ls := Q1 - Q5]
  vw_w <- dcast(vw, ym ~ quintile, value.var = "ret")
  setnames(vw_w, c("1", "2", "3", "4", "5"),
           c("Q1", "Q2", "Q3", "Q4", "Q5"))
  vw_w[, ls := Q1 - Q5]
  ew_w <- merge(ew_w, ff_m[, .(ym, mkt_rf_m, smb_m, hml_m)],
                 by = "ym", all.x = TRUE)
  vw_w <- merge(vw_w, ff_m[, .(ym, mkt_rf_m, smb_m, hml_m)],
                 by = "ym", all.x = TRUE)
  size_results[[sg]]$ew <- list(
    mean = nw_se(ew_w$ls, lags = NW_LAGS),
    capm = nw_alpha(ew_w$ls, as.matrix(ew_w[, .(mkt_rf_m)])),
    ff3 = nw_alpha(ew_w$ls,
                    as.matrix(ew_w[, .(mkt_rf_m, smb_m, hml_m)]))
  )
  size_results[[sg]]$vw <- list(
    mean = nw_se(vw_w$ls, lags = NW_LAGS),
    capm = nw_alpha(vw_w$ls, as.matrix(vw_w[, .(mkt_rf_m)])),
    ff3 = nw_alpha(vw_w$ls,
                    as.matrix(vw_w[, .(mkt_rf_m, smb_m, hml_m)]))
  )
}

log_step("Subperiod and size splits done", t0)

## --- Per-SD IVOL slope (for economic interpretation) -------------------

# Cross-sectional SD of lagged idiovol per month, then time-series mean.
log_step("Computing per-SD idiovol slope")
t0 <- Sys.time()

cs_sd_ivol <- fm_panel[, .(sd_ivol = sd(ivol_lag, na.rm = TRUE)), by = ym]
sd_idiovol_cs <- mean(cs_sd_ivol$sd_ivol, na.rm = TRUE)

# Per-SD slope is just slope * SD; t-stat is unchanged (linear rescaling).
fm_slope_per_sd_idiovol <- as.numeric(
  fm_full[fm_full$term == "ivol_lag", "mean"]) * sd_idiovol_cs
fm_t_per_sd_idiovol <- as.numeric(
  fm_full[fm_full$term == "ivol_lag", "t"])

log_step("Per-SD slope computed", t0)

## --- Robustness checks: R1 (FF3-residual IVOL), R7 (ex-Jan),
##     R8 (ex-crisis 2008-09), R9 (FF4 alpha) ------------------------------

log_step("Robustness checks (R1, R7, R8, R9)")
t0 <- Sys.time()

# ----- R1: FF3-residual idiovol -----------------------------------------
# Re-compute idiovol regressing daily excess return on (mkt_rf, smb, hml).
# Using the same closed-form group-wise computation: for OLS with multiple
# regressors, easier to just call lm per (permno, ym).  For runtime budget,
# we exploit the same identity but compute coefficients via solve() on
# normal-equations matrices group-wise.  Here we just run lm() in a fast
# data.table loop.  Cost: ~30s on full panel.

ff3_resid_sd <- function(y, x1, x2, x3) {
  ok <- !is.na(y) & !is.na(x1) & !is.na(x2) & !is.na(x3)
  n_ok <- sum(ok)
  if (n_ok < (MIN_OBS_PER_MO + 3L)) return(NA_real_)
  X <- cbind(1, x1[ok], x2[ok], x3[ok])
  yo <- y[ok]
  # Normal equations: beta = (X'X)^-1 X'y; residual sd = sqrt(RSS/(n-k)).
  XtX <- crossprod(X)
  inv <- tryCatch(solve(XtX), error = function(e) NULL)
  if (is.null(inv)) return(NA_real_)
  beta <- inv %*% crossprod(X, yo)
  resid <- yo - X %*% beta
  rss <- sum(resid^2)
  sqrt(max(rss, 0) / max(n_ok - ncol(X), 1L))
}

idio_ff3 <- dsf_u[, .(
  ivol_ff3 = ff3_resid_sd(exret, mkt_rf, smb, hml),
  n_d      = .N
), by = .(permno, ym)]
idio_ff3 <- idio_ff3[!is.na(ivol_ff3)]

# Build the same sort apparatus with ivol_ff3 in place of ivol.
setkey(idio_ff3, permno, ym)
monthly_r1 <- merge(monthly[, .(permno, ym, ret_m, exret_m, exchcd, me)],
                    idio_ff3[, .(permno, ym, ivol_ff3)],
                    by = c("permno", "ym"), all.x = TRUE)
setorder(monthly_r1, permno, ym)
monthly_r1[, prev_ym := shift(ym, type = "lag"), by = permno]
monthly_r1[, ym_lag1_expected := {
  yr <- ym %/% 100L
  mo <- ym %% 100L
  prev_mo <- ifelse(mo == 1L, 12L, mo - 1L)
  prev_yr <- ifelse(mo == 1L, yr - 1L, yr)
  prev_yr * 100L + prev_mo
}]
monthly_r1[, has_prev := !is.na(prev_ym) & prev_ym == ym_lag1_expected]
monthly_r1[, ivol_ff3_lag := shift(ivol_ff3, type = "lag"), by = permno]
monthly_r1[has_prev == FALSE, ivol_ff3_lag := NA_real_]
monthly_r1[, exchcd_lag := shift(exchcd, type = "lag"), by = permno]
monthly_r1[has_prev == FALSE, exchcd_lag := NA_integer_]
monthly_r1[, me_lag := shift(me, type = "lag"), by = permno]
monthly_r1[has_prev == FALSE, me_lag := NA_real_]

sort_r1 <- monthly_r1[!is.na(ivol_ff3_lag) & !is.na(ret_m) &
                       !is.na(exchcd_lag)]
bps_r1 <- sort_r1[exchcd_lag == 1L,
                  as.list(quantile(ivol_ff3_lag,
                                    probs = PHI_QUINTILES,
                                    names = FALSE, na.rm = TRUE)),
                  by = ym]
setnames(bps_r1, c("V1", "V2", "V3", "V4"),
         c("b20", "b40", "b60", "b80"))
sort_r1 <- merge(sort_r1, bps_r1, by = "ym", all.x = TRUE)
sort_r1 <- sort_r1[!is.na(b20)]
sort_r1[, quintile := fcase(
  ivol_ff3_lag <= b20, 1L,
  ivol_ff3_lag <= b40, 2L,
  ivol_ff3_lag <= b60, 3L,
  ivol_ff3_lag <= b80, 4L,
  ivol_ff3_lag >  b80, 5L
)]

# Aligned EW/VW portfolios on the FF3-residual sort.
sort_r1_aligned <- sort_r1[!is.na(quintile) &
                            !is.na(me_lag) & me_lag > 0]
port_r1_ew <- sort_r1_aligned[,
  .(ret = mean(exret_m, na.rm = TRUE)), by = .(ym, quintile)]
port_r1_vw <- sort_r1_aligned[,
  .(ret = weighted.mean(exret_m, w = me_lag, na.rm = TRUE)),
  by = .(ym, quintile)]
port_r1_ew[, weighting := "EW"]
port_r1_vw[, weighting := "VW"]
ls_r1 <- dcast(rbind(port_r1_ew, port_r1_vw),
                weighting + ym ~ quintile, value.var = "ret")
setnames(ls_r1, c("1", "2", "3", "4", "5"),
         c("Q1", "Q2", "Q3", "Q4", "Q5"))
ls_r1[, ls := Q1 - Q5]
ls_r1 <- merge(ls_r1, ff_m[, .(ym, mkt_rf_m, smb_m, hml_m, mom_m)],
                by = "ym", all.x = TRUE)

rob_ff3_resid_ls <- list()
for (wt in c("EW", "VW")) {
  sub_r1 <- ls_r1[weighting == wt & !is.na(ls)]
  rob_ff3_resid_ls[[wt]] <- list(
    mean = nw_se(sub_r1$ls, lags = NW_LAGS),
    capm = nw_alpha(sub_r1$ls, as.matrix(sub_r1[, .(mkt_rf_m)]),
                     lags = NW_LAGS),
    ff3  = nw_alpha(sub_r1$ls,
                     as.matrix(sub_r1[, .(mkt_rf_m, smb_m, hml_m)]),
                     lags = NW_LAGS)
  )
}

log_step("R1 done", t0)
t0 <- Sys.time()

# ----- R7: Ex-January ---------------------------------------------------
rob_exjan_alphas <- list()
for (wt in c("EW", "VW")) {
  sub_ej <- ls_returns[weighting == wt & !is.na(ls) &
                         (ym %% 100L) != 1L]
  rob_exjan_alphas[[wt]] <- list(
    mean = nw_se(sub_ej$ls, lags = NW_LAGS),
    capm = nw_alpha(sub_ej$ls, as.matrix(sub_ej[, .(mkt_rf_m)]),
                     lags = NW_LAGS),
    ff3  = nw_alpha(sub_ej$ls,
                     as.matrix(sub_ej[, .(mkt_rf_m, smb_m, hml_m)]),
                     lags = NW_LAGS)
  )
}

log_step("R7 done", t0)
t0 <- Sys.time()

# ----- R8: Ex-crisis 2008-2009 ------------------------------------------
rob_excrisis_alphas <- list()
for (wt in c("EW", "VW")) {
  sub_xc <- ls_returns[weighting == wt & !is.na(ls) &
                         !(ym %/% 100L %in% c(2008L, 2009L))]
  rob_excrisis_alphas[[wt]] <- list(
    mean = nw_se(sub_xc$ls, lags = NW_LAGS),
    capm = nw_alpha(sub_xc$ls, as.matrix(sub_xc[, .(mkt_rf_m)]),
                     lags = NW_LAGS),
    ff3  = nw_alpha(sub_xc$ls,
                     as.matrix(sub_xc[, .(mkt_rf_m, smb_m, hml_m)]),
                     lags = NW_LAGS)
  )
}

log_step("R8 done", t0)
t0 <- Sys.time()

# ----- R9: FF4 alpha (Carhart) -----------------------------------------
# FF + MOM; FF5 (RMW, CMA) is unavailable in ff_factors_daily.rds.
rob_ff4_alpha <- list()
for (wt in c("EW", "VW")) {
  sub_f4 <- ls_returns[weighting == wt & !is.na(ls)]
  rob_ff4_alpha[[wt]] <- nw_alpha(
    sub_f4$ls,
    as.matrix(sub_f4[, .(mkt_rf_m, smb_m, hml_m, mom_m)]),
    lags = NW_LAGS
  )
}
# Note: FF5 (RMW, CMA) factors are not present in ff_factors_daily.rds
# and cannot be constructed without monthly portfolio sorts on operating
# profitability and investment.  Documented as a deferred robustness.

log_step("R9 done", t0)

## --- Tables ------------------------------------------------------------

log_step("Writing tables")
t0 <- Sys.time()

fmt <- function(x, d = 4L) {
  ifelse(is.na(x), "", formatC(x, digits = d, format = "f"))
}

fmt_se <- function(x, d = 4L) {
  ifelse(is.na(x), "", paste0("(", formatC(x, digits = d, format = "f"),
                                ")"))
}

fmt_t <- function(x, d = 2L) {
  ifelse(is.na(x), "", paste0("[", formatC(x, digits = d, format = "f"),
                                "]"))
}

## Table 1: summary statistics on the FM analytical panel
sum_vars <- list(
  "Idiovol (daily SD, \\%)" = list(x = fm_panel$ivol_lag * 100,
                                     mul = 1),
  "Excess return, $r_{i,m}-r_{f,m}$ (\\%)" = list(
    x = fm_panel$exret_m * 100, mul = 1),
  "Log market equity, $\\log(\\mathrm{ME}_{i,t-1})$" = list(
    x = fm_panel$log_me, mul = 1),
  "Log book-to-market, $\\log(\\mathrm{BE}/\\mathrm{ME}_{i,t-1})$" = list(
    x = fm_panel$log_btm, mul = 1),
  "MOM (cumulative $t{-}12$ to $t{-}2$, \\%)" = list(
    x = fm_panel$mom * 100, mul = 1),
  "STR (lagged 1-month return, \\%)" = list(
    x = fm_panel$str * 100, mul = 1)
)

sum_rows <- lapply(names(sum_vars), function(nm) {
  x <- sum_vars[[nm]]$x
  data.frame(
    Variable = nm,
    N        = formatC(sum(!is.na(x)), format = "d", big.mark = ","),
    Mean     = fmt(mean(x, na.rm = TRUE), 4),
    SD       = fmt(sd(x, na.rm = TRUE), 4),
    p25      = fmt(quantile(x, 0.25, na.rm = TRUE), 4),
    Median   = fmt(median(x, na.rm = TRUE), 4),
    p75      = fmt(quantile(x, 0.75, na.rm = TRUE), 4),
    stringsAsFactors = FALSE
  )
})
sum_df <- do.call(rbind, sum_rows)

write_tex_table <- function(lines, path) {
  writeLines(lines, path)
  message("Wrote ", path)
}

table1_lines <- c(
  "\\begin{tabular}{lcccccc}",
  "\\toprule",
  "Variable & N & Mean & SD & p25 & Median & p75 \\\\",
  "\\midrule",
  vapply(seq_len(nrow(sum_df)), \(i) {
    r <- sum_df[i, ]
    paste(r$Variable, r$N, r$Mean, r$SD, r$p25, r$Median, r$p75,
          sep = " & ") |> paste0(" \\\\")
  }, character(1)),
  "\\bottomrule",
  "\\end{tabular}"
)
write_tex_table(table1_lines, file.path(OUT_DIR, "table1_summary.tex"))

## Table 2: quintile sorts (EW and VW, mean monthly excess return)
sort_table <- function(ports_dat, ls_dat, weighting_label) {
  stopifnot(!is.null(ports_dat), is.data.table(ports_dat),
            nrow(ports_dat) > 0L,
            !is.null(ls_dat), is.data.table(ls_dat), nrow(ls_dat) > 0L,
            is.character(weighting_label), length(weighting_label) == 1L,
            nzchar(weighting_label))
  pdat <- ports_dat[weighting == weighting_label]
  res <- pdat[, {
    s <- nw_se(ret, lags = NW_LAGS)
    list(mean = s["mean"], se = s["se"], t = s["t"], p = s["p"],
         n = s["n"])
  }, by = quintile]
  res <- res[order(quintile)]
  ls_x <- ls_dat[weighting == weighting_label, ls]
  ls_s <- nw_se(ls_x, lags = NW_LAGS)
  rbind(res, data.frame(quintile = NA_integer_, mean = ls_s["mean"],
                         se = ls_s["se"], t = ls_s["t"],
                         p = ls_s["p"], n = ls_s["n"]))
}
ew_tbl <- sort_table(ports, ls_returns, "EW")
vw_tbl <- sort_table(ports, ls_returns, "VW")

# Two side-by-side panels of 5 quintiles + L/S row.
labels <- c("Q1 (low)", "Q2", "Q3", "Q4", "Q5 (high)", "Q1$-$Q5")
mk_value_row <- function(tbl, i) {
  paste0(fmt(tbl$mean[i] * 100, 4),
         nw_stars(tbl$p[i]))
}
mk_se_row <- function(tbl, i) {
  fmt_se(tbl$se[i] * 100, 4)
}

n_rows <- nrow(ew_tbl)

table2_lines <- c(
  "\\begin{tabular}{lcccc}",
  "\\toprule",
  " & \\multicolumn{2}{c}{Equal-weighted} & \\multicolumn{2}{c}{Value-weighted} \\\\",
  "\\cmidrule(lr){2-3}\\cmidrule(lr){4-5}",
  "Quintile & Mean (\\%) & NW $t$ & Mean (\\%) & NW $t$ \\\\",
  "\\midrule",
  vapply(seq_len(n_rows), \(i) {
    paste(labels[i],
          mk_value_row(ew_tbl, i),
          fmt(ew_tbl$t[i], 2),
          mk_value_row(vw_tbl, i),
          fmt(vw_tbl$t[i], 2),
          sep = " & ") |> paste0(" \\\\")
  }, character(1)),
  vapply(seq_len(n_rows), \(i) {
    paste("",
          mk_se_row(ew_tbl, i), "",
          mk_se_row(vw_tbl, i), "",
          sep = " & ") |> paste0(" \\\\")
  }, character(1))[c(1:n_rows)],  # SEs interleaved would clutter; keep separate
  "\\bottomrule",
  "\\end{tabular}"
)
# Better layout: interleave mean and SE rows for nice display.
table2_lines <- c(
  "\\begin{tabular}{lcccc}",
  "\\toprule",
  " & \\multicolumn{2}{c}{Equal-weighted} & \\multicolumn{2}{c}{Value-weighted} \\\\",
  "\\cmidrule(lr){2-3}\\cmidrule(lr){4-5}",
  "Quintile & Mean (\\%) & NW $t$ & Mean (\\%) & NW $t$ \\\\",
  "\\midrule"
)
for (i in seq_len(n_rows)) {
  table2_lines <- c(
    table2_lines,
    paste(labels[i],
          mk_value_row(ew_tbl, i),
          fmt(ew_tbl$t[i], 2),
          mk_value_row(vw_tbl, i),
          fmt(vw_tbl$t[i], 2),
          sep = " & ") |> paste0(" \\\\"),
    paste("",
          mk_se_row(ew_tbl, i), "",
          mk_se_row(vw_tbl, i), "",
          sep = " & ") |> paste0(" \\\\")
  )
  if (i == 5L) table2_lines <- c(table2_lines, "\\midrule")
}
table2_lines <- c(table2_lines,
                   "\\bottomrule", "\\end{tabular}")
write_tex_table(table2_lines, file.path(OUT_DIR, "table2_sorts.tex"))

## Table 3: alphas of L/S (CAPM and FF3, EW and VW)
make_alpha_row <- function(fit, coef_name, scale = 100) {
  stopifnot(!is.null(fit), is.list(fit),
            !is.null(coef_name), is.character(coef_name),
            length(coef_name) == 1L, nzchar(coef_name),
            is.numeric(scale), length(scale) == 1L)
  if (length(fit$coefs) == 1L && is.na(fit$coefs)) {
    return(list(est = NA_real_, se = NA_real_, t = NA_real_, p = NA_real_))
  }
  i <- which(names(fit$coefs) == coef_name)
  if (length(i) == 0L) return(list(est = NA_real_, se = NA_real_,
                                   t = NA_real_, p = NA_real_))
  list(est = as.numeric(fit$coefs[i]) * scale,
       se  = as.numeric(fit$se[i])    * scale,
       t   = as.numeric(fit$t[i]),
       p   = as.numeric(fit$p[i]))
}

cols <- list(
  capm_ew = alpha_fits$capm_EW,
  ff3_ew  = alpha_fits$ff3_EW,
  capm_vw = alpha_fits$capm_VW,
  ff3_vw  = alpha_fits$ff3_VW
)

rows <- list(
  list(label = "$\\alpha$ (\\% per month)", coef = "(Intercept)",
        scale = 100, italic = TRUE),
  list(label = "$\\beta^{\\mathrm{MKT}}$", coef = "mkt_rf_m",
        scale = 1, italic = FALSE),
  list(label = "$\\beta^{\\mathrm{SMB}}$", coef = "smb_m",
        scale = 1, italic = FALSE),
  list(label = "$\\beta^{\\mathrm{HML}}$", coef = "hml_m",
        scale = 1, italic = FALSE)
)

# Footer rows
adj_r2 <- vapply(cols, \(c) c$r2_adj, numeric(1))
n_mon  <- vapply(cols, \(c) c$n, numeric(1))

table3_lines <- c(
  "\\begin{tabular}{lcccc}",
  "\\toprule",
  " & (1) & (2) & (3) & (4) \\\\",
  " & CAPM (EW) & FF3 (EW) & CAPM (VW) & FF3 (VW) \\\\",
  "\\midrule"
)
for (r in rows) {
  ests <- lapply(cols, make_alpha_row, coef_name = r$coef, scale = r$scale)
  est_strs <- vapply(ests, \(e) {
    if (is.na(e$est)) return("")
    paste0(fmt(e$est, 4), nw_stars(e$p))
  }, character(1))
  se_strs <- vapply(ests, \(e) fmt_se(e$se, 4), character(1))
  table3_lines <- c(
    table3_lines,
    paste(r$label, est_strs[1], est_strs[2], est_strs[3], est_strs[4],
          sep = " & ") |> paste0(" \\\\"),
    paste("", se_strs[1], se_strs[2], se_strs[3], se_strs[4],
          sep = " & ") |> paste0(" \\\\")
  )
}
table3_lines <- c(
  table3_lines,
  "\\midrule",
  paste("Adj. $R^2$", fmt(adj_r2[1], 3), fmt(adj_r2[2], 3),
         fmt(adj_r2[3], 3), fmt(adj_r2[4], 3),
         sep = " & ") |> paste0(" \\\\"),
  paste("Months", formatC(n_mon[1], format = "d"),
         formatC(n_mon[2], format = "d"),
         formatC(n_mon[3], format = "d"),
         formatC(n_mon[4], format = "d"),
         sep = " & ") |> paste0(" \\\\"),
  "\\bottomrule",
  "\\end{tabular}"
)
write_tex_table(table3_lines, file.path(OUT_DIR, "table3_alphas.tex"))

## Table 3b: FF4 (Carhart) alphas (robustness R9)
ff4_cols <- list(
  ff4_ew = rob_ff4_alpha$EW,
  ff4_vw = rob_ff4_alpha$VW
)
ff4_rows <- list(
  list(label = "$\\alpha$ (\\% per month)", coef = "(Intercept)",
       scale = 100),
  list(label = "$\\beta^{\\mathrm{MKT}}$", coef = "mkt_rf_m", scale = 1),
  list(label = "$\\beta^{\\mathrm{SMB}}$", coef = "smb_m",    scale = 1),
  list(label = "$\\beta^{\\mathrm{HML}}$", coef = "hml_m",    scale = 1),
  list(label = "$\\beta^{\\mathrm{MOM}}$", coef = "mom_m",    scale = 1)
)
ff4_adj_r2 <- vapply(ff4_cols, \(c) c$r2_adj, numeric(1))
ff4_n_mon  <- vapply(ff4_cols, \(c) c$n,      numeric(1))

table3b_lines <- c(
  "\\begin{tabular}{lcc}",
  "\\toprule",
  " & (1) & (2) \\\\",
  " & FF4 (EW) & FF4 (VW) \\\\",
  "\\midrule"
)
for (r in ff4_rows) {
  ests <- lapply(ff4_cols, make_alpha_row, coef_name = r$coef,
                  scale = r$scale)
  est_strs <- vapply(ests, \(e) {
    if (is.na(e$est)) return("")
    paste0(fmt(e$est, 4), nw_stars(e$p))
  }, character(1))
  se_strs <- vapply(ests, \(e) fmt_se(e$se, 4), character(1))
  table3b_lines <- c(
    table3b_lines,
    paste(r$label, est_strs[1], est_strs[2], sep = " & ") |>
      paste0(" \\\\"),
    paste("", se_strs[1], se_strs[2], sep = " & ") |>
      paste0(" \\\\")
  )
}
table3b_lines <- c(
  table3b_lines,
  "\\midrule",
  paste("Adj. $R^2$", fmt(ff4_adj_r2[1], 3), fmt(ff4_adj_r2[2], 3),
         sep = " & ") |> paste0(" \\\\"),
  paste("Months", formatC(ff4_n_mon[1], format = "d"),
         formatC(ff4_n_mon[2], format = "d"),
         sep = " & ") |> paste0(" \\\\"),
  "\\bottomrule",
  "\\end{tabular}"
)
write_tex_table(table3b_lines, file.path(OUT_DIR, "table3b_ff4_alphas.tex"))

## Table 4: Fama-MacBeth
fm_label <- c(
  ivol_lag = "Idiovol $\\widehat{\\mathrm{IVOL}}_{i,t-1}$",
  log_me   = "$\\log(\\mathrm{ME}_{i,t-1})$",
  log_btm  = "$\\log(\\mathrm{BE}/\\mathrm{ME}_{i,t-1})$",
  mom      = "MOM$_{i,t-12,t-2}$",
  str      = "STR$_{i,t-1}$",
  `(Intercept)` = "Intercept"
)
fm_order <- c("ivol_lag", "log_me", "log_btm", "mom", "str",
               "(Intercept)")

mk_fm_row <- function(term, fm) {
  r <- fm[fm$term == term, ]
  if (nrow(r) == 0L) return(list(est = "", se = ""))
  list(
    est = paste0(fmt(r$mean * 100, 4), nw_stars(r$p)),
    se  = fmt_se(r$se * 100, 4),
    n   = r$n_months
  )
}

table4_lines <- c(
  "\\begin{tabular}{lcc}",
  "\\toprule",
  " & (1) & (2) \\\\",
  " & Idiovol only & Full controls \\\\",
  "\\midrule"
)
for (term in fm_order) {
  r1 <- mk_fm_row(term, fm_only)
  r2 <- mk_fm_row(term, fm_full)
  table4_lines <- c(
    table4_lines,
    paste(fm_label[term], r1$est, r2$est, sep = " & ") |>
      paste0(" \\\\"),
    paste("", r1$se, r2$se, sep = " & ") |> paste0(" \\\\")
  )
}
n1 <- mk_fm_row("ivol_lag", fm_only)$n
n2 <- mk_fm_row("ivol_lag", fm_full)$n
table4_lines <- c(
  table4_lines,
  "\\midrule",
  paste("Months",
         formatC(n1, format = "d"),
         formatC(n2, format = "d"),
         sep = " & ") |> paste0(" \\\\"),
  "\\bottomrule",
  "\\end{tabular}"
)
write_tex_table(table4_lines, file.path(OUT_DIR, "table4_fm.tex"))

## Table 5: subperiod splits
mk_sub_cell <- function(sub, kind = c("mean", "capm", "ff3"), wt) {
  kind <- match.arg(kind)
  s <- sub[[wt]]
  if (kind == "mean") {
    list(est = paste0(fmt(s$mean["mean"] * 100, 4),
                       nw_stars(s$mean["p"])),
         se  = fmt_se(s$mean["se"] * 100, 4))
  } else {
    fit <- s[[kind]]
    i <- which(names(fit$coefs) == "(Intercept)")
    list(est = paste0(fmt(as.numeric(fit$coefs[i]) * 100, 4),
                       nw_stars(as.numeric(fit$p[i]))),
         se  = fmt_se(as.numeric(fit$se[i]) * 100, 4))
  }
}

table5_lines <- c(
  "\\begin{tabular}{lcccc}",
  "\\toprule",
  " & \\multicolumn{2}{c}{Pre-2000 (1990--1999)} & \\multicolumn{2}{c}{Post-2000 (2000--2024)} \\\\",
  "\\cmidrule(lr){2-3}\\cmidrule(lr){4-5}",
  " & EW & VW & EW & VW \\\\",
  "\\midrule"
)
row_labels <- list(
  mean = "Mean Q1$-$Q5 (\\%)",
  capm = "CAPM $\\alpha$ (\\%)",
  ff3  = "FF3 $\\alpha$ (\\%)"
)
for (kind in names(row_labels)) {
  pre_ew  <- mk_sub_cell(sub_results$pre, kind, "EW")
  pre_vw  <- mk_sub_cell(sub_results$pre, kind, "VW")
  post_ew <- mk_sub_cell(sub_results$post, kind, "EW")
  post_vw <- mk_sub_cell(sub_results$post, kind, "VW")
  table5_lines <- c(
    table5_lines,
    paste(row_labels[[kind]],
          pre_ew$est, pre_vw$est,
          post_ew$est, post_vw$est,
          sep = " & ") |> paste0(" \\\\"),
    paste("",
          pre_ew$se, pre_vw$se,
          post_ew$se, post_vw$se,
          sep = " & ") |> paste0(" \\\\")
  )
}
table5_lines <- c(table5_lines, "\\bottomrule", "\\end{tabular}")
write_tex_table(table5_lines, file.path(OUT_DIR, "table5_subperiods.tex"))

## Table 6: size split (NYSE-20 small vs large)
mk_size_cell <- function(size_sub, kind = c("mean", "capm", "ff3")) {
  kind <- match.arg(kind)
  if (kind == "mean") {
    list(est = paste0(fmt(size_sub$mean["mean"] * 100, 4),
                       nw_stars(size_sub$mean["p"])),
         se  = fmt_se(size_sub$mean["se"] * 100, 4))
  } else {
    fit <- size_sub[[kind]]
    i <- which(names(fit$coefs) == "(Intercept)")
    list(est = paste0(fmt(as.numeric(fit$coefs[i]) * 100, 4),
                       nw_stars(as.numeric(fit$p[i]))),
         se  = fmt_se(as.numeric(fit$se[i]) * 100, 4))
  }
}

table6_lines <- c(
  "\\begin{tabular}{lcccc}",
  "\\toprule",
  " & \\multicolumn{2}{c}{Small (ME $\\le$ NYSE 20\\%)} & \\multicolumn{2}{c}{Large (ME $>$ NYSE 20\\%)} \\\\",
  "\\cmidrule(lr){2-3}\\cmidrule(lr){4-5}",
  " & EW & VW & EW & VW \\\\",
  "\\midrule"
)
for (kind in names(row_labels)) {
  s_ew <- mk_size_cell(size_results$small$ew, kind)
  s_vw <- mk_size_cell(size_results$small$vw, kind)
  l_ew <- mk_size_cell(size_results$large$ew, kind)
  l_vw <- mk_size_cell(size_results$large$vw, kind)
  table6_lines <- c(
    table6_lines,
    paste(row_labels[[kind]],
          s_ew$est, s_vw$est,
          l_ew$est, l_vw$est,
          sep = " & ") |> paste0(" \\\\"),
    paste("",
          s_ew$se, s_vw$se,
          l_ew$se, l_vw$se,
          sep = " & ") |> paste0(" \\\\")
  )
}
table6_lines <- c(table6_lines, "\\bottomrule", "\\end{tabular}")
write_tex_table(table6_lines, file.path(OUT_DIR, "table6_size.tex"))

log_step("Tables written", t0)

## --- Figures -----------------------------------------------------------

log_step("Building figures")
t0 <- Sys.time()

# Figure 1: cross-sectional mean idiovol (annualised %) and cumulative L/S
fig1_idiovol <- sort_panel[, .(mean_ivol = mean(ivol_lag, na.rm = TRUE) *
                                            sqrt(21) * 100),
                            by = ym]
fig1_idiovol[, date_m := as.Date(sprintf("%d-%02d-01",
                                           ym %/% 100L, ym %% 100L))]

ls_ts <- ls_returns[, .(weighting, ym, date_m, ls)]
ls_ts <- ls_ts[order(weighting, ym)]
ls_ts[, cum_ls := cumprod(1 + ifelse(is.na(ls), 0, ls)), by = weighting]

fig1_data <- merge(fig1_idiovol, ls_ts, by = c("ym", "date_m"))

# Two-axis: rescale cum_ls so it fits on the same axis.
# Use sec axis with a transform.
mvi <- max(fig1_data$mean_ivol, na.rm = TRUE)
mci <- max(fig1_data$cum_ls, na.rm = TRUE)
scale_factor <- mvi / mci

p1 <- ggplot(fig1_data, aes(x = date_m)) +
  geom_line(aes(y = mean_ivol, color = "Mean idiovol", linetype = "Mean idiovol"),
             linewidth = 0.45) +
  geom_line(data = fig1_data[weighting == "EW"],
             aes(y = cum_ls * scale_factor,
                  color = "Cumulative L/S (EW)",
                  linetype = "Cumulative L/S (EW)"),
             linewidth = 0.45) +
  geom_line(data = fig1_data[weighting == "VW"],
             aes(y = cum_ls * scale_factor,
                  color = "Cumulative L/S (VW)",
                  linetype = "Cumulative L/S (VW)"),
             linewidth = 0.45) +
  scale_y_continuous(
    name = "Cross-sectional mean idiovol (annualised, %)",
    sec.axis = sec_axis(~ . / scale_factor,
                         name = "Cumulative L/S return (start = 1)")
  ) +
  scale_x_date(name = NULL, date_breaks = "5 years",
                date_labels = "%Y") +
  scale_color_manual(
    name = NULL,
    values = c("Mean idiovol" = "grey25",
                "Cumulative L/S (EW)" = "steelblue",
                "Cumulative L/S (VW)" = "darkorange")
  ) +
  scale_linetype_manual(
    name = NULL,
    values = c("Mean idiovol" = "solid",
                "Cumulative L/S (EW)" = "longdash",
                "Cumulative L/S (VW)" = "dotted")
  ) +
  labs(title = NULL, subtitle = NULL) +
  theme_minimal(base_family = "serif", base_size = 11) +
  theme(legend.position = "bottom",
         panel.grid.minor = element_blank())

ggsave(file.path(OUT_DIR, "fig1_idiovol_ls.pdf"), p1,
        width = 7, height = 4.2)
ggsave(file.path(OUT_DIR, "fig1_idiovol_ls.png"), p1,
        width = 7, height = 4.2, dpi = 200)

# Figure 2: mean monthly return by quintile with 95% CI (EW and VW)
quintile_summary <- ports[, {
  s <- nw_se(ret, lags = NW_LAGS)
  .(mean = s["mean"], se = s["se"], n = s["n"])
}, by = .(weighting, quintile)]
quintile_summary[, ci_lo := (mean - 1.96 * se) * 100]
quintile_summary[, ci_hi := (mean + 1.96 * se) * 100]
quintile_summary[, mean_pct := mean * 100]
quintile_summary[, quintile_lab := factor(
  quintile,
  levels = 1:5,
  labels = c("Q1\n(low)", "Q2", "Q3", "Q4", "Q5\n(high)")
)]

p2 <- ggplot(quintile_summary,
              aes(x = quintile_lab, y = mean_pct,
                   fill = weighting)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.6) +
  geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi),
                 position = position_dodge(width = 0.7),
                 width = 0.2, linewidth = 0.4) +
  scale_fill_manual(name = NULL,
                     values = c("EW" = "steelblue",
                                 "VW" = "darkorange")) +
  scale_y_continuous(name = "Mean monthly excess return (%)") +
  scale_x_discrete(name = "Idiovol quintile (lag-1)") +
  labs(title = NULL, subtitle = NULL) +
  theme_minimal(base_family = "serif", base_size = 11) +
  theme(legend.position = "bottom",
         panel.grid.minor = element_blank())

ggsave(file.path(OUT_DIR, "fig2_quintile_returns.pdf"), p2,
        width = 6.5, height = 4.2)
ggsave(file.path(OUT_DIR, "fig2_quintile_returns.png"), p2,
        width = 6.5, height = 4.2, dpi = 200)

log_step("Figures written", t0)

## --- Slide bundle ------------------------------------------------------

log_step("Saving slide bundle")
t0 <- Sys.time()

ls_ew_stats <- nw_se(ls_returns[weighting == "EW", ls], lags = NW_LAGS)
ls_vw_stats <- nw_se(ls_returns[weighting == "VW", ls], lags = NW_LAGS)

get_alpha <- function(fit, coef = "(Intercept)") {
  i <- which(names(fit$coefs) == coef)
  c(est = as.numeric(fit$coefs[i]),
    se  = as.numeric(fit$se[i]),
    t   = as.numeric(fit$t[i]),
    p   = as.numeric(fit$p[i]),
    n   = fit$n)
}

fm_slope_only <- fm_only[fm_only$term == "ivol_lag", ]
fm_slope_full <- fm_full[fm_full$term == "ivol_lag", ]

slide_bundle <- list(
  stats = list(
    n_obs               = nrow(sort_panel),
    n_firms             = uniqueN(sort_panel$permno),
    n_months            = uniqueN(sort_panel$ym),
    yr_min              = min(year(sort_panel$date_m), na.rm = TRUE),
    yr_max              = max(year(sort_panel$date_m), na.rm = TRUE),
    ls_ew_return        = as.numeric(ls_ew_stats["mean"]),
    ls_ew_return_t      = as.numeric(ls_ew_stats["t"]),
    ls_vw_return        = as.numeric(ls_vw_stats["mean"]),
    ls_vw_return_t      = as.numeric(ls_vw_stats["t"]),
    ls_ew_alpha_capm    = get_alpha(alpha_fits$capm_EW),
    ls_ew_alpha_ff3     = get_alpha(alpha_fits$ff3_EW),
    ls_vw_alpha_capm    = get_alpha(alpha_fits$capm_VW),
    ls_vw_alpha_ff3     = get_alpha(alpha_fits$ff3_VW),
    fm_slope_only       = c(est = as.numeric(fm_slope_only$mean),
                              se  = as.numeric(fm_slope_only$se),
                              t   = as.numeric(fm_slope_only$t),
                              n   = as.numeric(fm_slope_only$n_months)),
    fm_slope_full       = c(est = as.numeric(fm_slope_full$mean),
                              se  = as.numeric(fm_slope_full$se),
                              t   = as.numeric(fm_slope_full$t),
                              n   = as.numeric(fm_slope_full$n_months)),
    sd_idiovol_cs           = sd_idiovol_cs,
    fm_slope_per_sd_idiovol = fm_slope_per_sd_idiovol,
    fm_t_per_sd_idiovol     = fm_t_per_sd_idiovol
  ),
  sort_returns_table = data.frame(
    quintile      = c(1L:5L, NA_integer_),
    label         = labels,
    ew_mean       = ew_tbl$mean,
    ew_se         = ew_tbl$se,
    ew_t          = ew_tbl$t,
    vw_mean       = vw_tbl$mean,
    vw_se         = vw_tbl$se,
    vw_t          = vw_tbl$t
  ),
  time_series = data.frame(
    month         = fig1_data$date_m,
    weighting     = fig1_data$weighting,
    mean_idiovol  = fig1_data$mean_ivol,
    ls_return     = fig1_data$ls,
    cum_ls        = fig1_data$cum_ls
  ),
  quintile_summary = data.frame(
    weighting     = quintile_summary$weighting,
    quintile      = as.integer(quintile_summary$quintile),
    mean_pct      = quintile_summary$mean_pct,
    se_pct        = quintile_summary$se * 100,
    n_months      = as.integer(quintile_summary$n)
  ),
  subperiod     = sub_results,
  size_split    = size_results,
  fm_only       = fm_only,
  fm_full       = fm_full,
  paper_to_code = data.frame(
    paper = c("r_{i,d}", "r_{f,d}", "r_{M,d}",
              "IVOL_{i,m}", "ME_{i,t}", "BE_{i,t}",
              "BE/ME_{i,t}", "MOM_{i,t-12,t-2}", "STR_{i,t-1}",
              "r^{LS}_{m+1}"),
    code  = c("ret", "rf", "mkt_rf + rf",
              "ivol", "me", "be",
              "btm", "mom", "str", "ret_ls")
  ),
  rob_ff3_resid_ls    = rob_ff3_resid_ls,
  rob_exjan_alphas    = rob_exjan_alphas,
  rob_excrisis_alphas = rob_excrisis_alphas,
  rob_ff4_alpha       = rob_ff4_alpha,
  caveats = c(
    paste0("crsp.dsf.rds is pre-thinned to (date, permno, ret) only ",
           "-- no prc, shrout, vol."),
    paste0("Daily market factor uses Ken French mkt_rf rather than ",
           "self-constructed CRSP VW."),
    paste0("Market equity is computed from Compustat prcc_f * csho ",
           "carried forward by fiscal year; this is annual frequency ",
           "and causes the VW columns to be near-identical to EW. ",
           "Documented in tables."),
    paste0("Robustness R5 (MAX) and R6 (prc<$5) cannot be implemented ",
           "without monthly CRSP price/shares; deferred.")
  )
)

saveRDS(slide_bundle, file.path(OUT_DIR, "slide_bundle.rds"))

log_step("Slide bundle saved", t0)

## --- Final summary -----------------------------------------------------

total_elapsed <- as.numeric(difftime(Sys.time(), t0_total, units = "mins"))
log_step(sprintf("Total runtime: %.2f min", total_elapsed))

message("\n==================== SUMMARY ====================")
message(sprintf("Sample years:           %d-%d",
                 slide_bundle$stats$yr_min, slide_bundle$stats$yr_max))
message(sprintf("Sort sample obs:        %s",
                 formatC(slide_bundle$stats$n_obs, format = "d",
                         big.mark = ",")))
message(sprintf("Unique permnos:         %s",
                 formatC(slide_bundle$stats$n_firms, format = "d",
                         big.mark = ",")))
message(sprintf("Unique months:          %d",
                 slide_bundle$stats$n_months))
message(sprintf("L/S EW (%% per month):  %+.3f%% (t = %+.2f)",
                 slide_bundle$stats$ls_ew_return * 100,
                 slide_bundle$stats$ls_ew_return_t))
message(sprintf("L/S VW (%% per month):  %+.3f%% (t = %+.2f)",
                 slide_bundle$stats$ls_vw_return * 100,
                 slide_bundle$stats$ls_vw_return_t))
message(sprintf("CAPM alpha EW (%%):     %+.3f%% (t = %+.2f)",
                 slide_bundle$stats$ls_ew_alpha_capm["est"] * 100,
                 slide_bundle$stats$ls_ew_alpha_capm["t"]))
message(sprintf("FF3 alpha EW (%%):      %+.3f%% (t = %+.2f)",
                 slide_bundle$stats$ls_ew_alpha_ff3["est"] * 100,
                 slide_bundle$stats$ls_ew_alpha_ff3["t"]))
message(sprintf("CAPM alpha VW (%%):     %+.3f%% (t = %+.2f)",
                 slide_bundle$stats$ls_vw_alpha_capm["est"] * 100,
                 slide_bundle$stats$ls_vw_alpha_capm["t"]))
message(sprintf("FF3 alpha VW (%%):      %+.3f%% (t = %+.2f)",
                 slide_bundle$stats$ls_vw_alpha_ff3["est"] * 100,
                 slide_bundle$stats$ls_vw_alpha_ff3["t"]))
message(sprintf("FM ivol slope (only):   %+.5f (t = %+.2f, %d months)",
                 slide_bundle$stats$fm_slope_only["est"],
                 slide_bundle$stats$fm_slope_only["t"],
                 as.integer(slide_bundle$stats$fm_slope_only["n"])))
message(sprintf("FM ivol slope (full):   %+.5f (t = %+.2f, %d months)",
                 slide_bundle$stats$fm_slope_full["est"],
                 slide_bundle$stats$fm_slope_full["t"],
                 as.integer(slide_bundle$stats$fm_slope_full["n"])))
message(sprintf("FM slope per SD ivol:   %+.5f (t = %+.2f)",
                 slide_bundle$stats$fm_slope_per_sd_idiovol,
                 slide_bundle$stats$fm_t_per_sd_idiovol))
message("\nRobustness summary:")
message(sprintf("  R1 (FF3-resid IVOL) FF3 alpha EW (%%): %+.3f%% (t = %+.2f)",
                 as.numeric(rob_ff3_resid_ls$EW$ff3$coefs["(Intercept)"]) * 100,
                 as.numeric(rob_ff3_resid_ls$EW$ff3$t["(Intercept)"])))
message(sprintf("  R1 (FF3-resid IVOL) FF3 alpha VW (%%): %+.3f%% (t = %+.2f)",
                 as.numeric(rob_ff3_resid_ls$VW$ff3$coefs["(Intercept)"]) * 100,
                 as.numeric(rob_ff3_resid_ls$VW$ff3$t["(Intercept)"])))
message(sprintf("  R7 (ex-Jan) FF3 alpha EW (%%):         %+.3f%% (t = %+.2f)",
                 as.numeric(rob_exjan_alphas$EW$ff3$coefs["(Intercept)"]) * 100,
                 as.numeric(rob_exjan_alphas$EW$ff3$t["(Intercept)"])))
message(sprintf("  R7 (ex-Jan) FF3 alpha VW (%%):         %+.3f%% (t = %+.2f)",
                 as.numeric(rob_exjan_alphas$VW$ff3$coefs["(Intercept)"]) * 100,
                 as.numeric(rob_exjan_alphas$VW$ff3$t["(Intercept)"])))
message(sprintf("  R8 (ex-crisis) FF3 alpha EW (%%):      %+.3f%% (t = %+.2f)",
                 as.numeric(rob_excrisis_alphas$EW$ff3$coefs["(Intercept)"]) * 100,
                 as.numeric(rob_excrisis_alphas$EW$ff3$t["(Intercept)"])))
message(sprintf("  R8 (ex-crisis) FF3 alpha VW (%%):      %+.3f%% (t = %+.2f)",
                 as.numeric(rob_excrisis_alphas$VW$ff3$coefs["(Intercept)"]) * 100,
                 as.numeric(rob_excrisis_alphas$VW$ff3$t["(Intercept)"])))
message(sprintf("  R9 (FF4) alpha EW (%%):                %+.3f%% (t = %+.2f)",
                 as.numeric(rob_ff4_alpha$EW$coefs["(Intercept)"]) * 100,
                 as.numeric(rob_ff4_alpha$EW$t["(Intercept)"])))
message(sprintf("  R9 (FF4) alpha VW (%%):                %+.3f%% (t = %+.2f)",
                 as.numeric(rob_ff4_alpha$VW$coefs["(Intercept)"]) * 100,
                 as.numeric(rob_ff4_alpha$VW$t["(Intercept)"])))
message(sprintf("Total runtime:          %.2f minutes", total_elapsed))
message("=================================================")
