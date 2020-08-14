# Measures

My (growing) collection of various measures' definitions. Please see [mingze-gao.com](https://mingze-gao.com) for how to compute all these measures in one click.

## Firm Characteristics

* [Accounting Restatements](https://mingze-gao.com/measures/accounting_restatement)
    * Number of various accounting restatements during the past (*n*) fiscal year.
    * Source: `wrds.comp.funda`, `wrds.audit.auditnonreli`. 
* [Asset Tangibility](https://mingze-gao.com/measures/asset_tangibility) 
    * Property, Plant and Equipment (Net) scaled by total assets.
    * Source: `wrds.comp.funda`.
* [Board Independence](https://mingze-gao.com/measures/board_independence)
    * Board size and independence measured as the ratio of independent board members to board size.
    * Source: `wrds.funda`, `wrds.boardex.na_wrds_company_profile`, `wrds.boardex.na_wrds_org_composition`.
* [Book Leverage](https://mingze-gao.com/measures/book_leverage)
    * Amount of debts scaled by the firm's total debts plus common equity.
    * Source: `wrds.comp.funda`.
* [Capital Expenditure](https://mingze-gao.com/measures/capital_expenditure)
    * Capital expenditures scaled by total assets.
    * Source: `wrds.comp.funda`.
* [Credit Rating](https://mingze-gao.com/measures/credit_rating)
    * S&P credit rating.
    * Source: `wrds.ciq.erating`, `wrds.ciq.gvkey`.
* [Executive Ownership](https://mingze-gao.com/measures/executive_ownership)
    * Various measures of executive stock ownership.
    * Source: `wrds.comp.funda`, `wrds.execcomp.anncomp`.
* [Firm Size](https://mingze-gao.com/measures/firm_size)
    * Natural logarithm of total assets.
    * Source: `wrds.comp.funda`.
* [Market-to-Book Ratio](https://mingze-gao.com/measures/market_to_book)
    * Market value of common equity to book value of common equity.
    * Source: `wrds.comp.funda`.
* [ROA](https://mingze-gao.com/measures/roa)
    * Income before extraordinary items scaled by total assets.
    * Source: `wrds.comp.funda`.
* [ROE](https://mingze-gao.com/measures/roe)
    * Income before extraordinary items scaled by common equity.
    * Source: `wrds.comp.funda`.
* [Stock Delisting](https://mingze-gao.com/measures/stock_delisting)
    * Stocks delisted due to financial troubles or as a result of being merged.
    * Source: `wrds.crsp.dse`.
* [Tobin's Q](https://mingze-gao.com/measures/tobin_q)
    * Tobin's Q
    * Source: `wrds.comp.funda`.
    * Reference: [Gompers, Ishii and Metrick (2003 QJE)](https://doi.org/10.1162/00335530360535162), and [Kaplan and Zingales (1997 QJE)](https://doi.org/10.1162/003355397555163).

## Bank Holding Company (BHC) Characteristics

* [BHC Size](https://mingze-gao.com/measures/bhc_size)
    * Natural logarithm of total assets.
    * Source: `frb_chicago.bhc.bhcf`.
* [BHC Loan Growth](https://mingze-gao.com/measures/bhc_loan_growth)
    * Natural logarithm of total loans in the current quarter divided by the total loans in the previous quarter.
    * Source: `frb_chicago.bhc.bhcf`.
    * Referece: [Zheng (2020 JBF)](https://doi.org/10.1016/j.jbankfin.2020.105900).
* [BHC FX Exposure](https://mingze-gao.com/measures/bhc_fx_exposure)
    * Fee and interest income from loans in foreign offices (BHCK4059) scaled by total interest income (BHCK4107).
    * Source: `frb_chicago.bhc.bhcf`.
    * Reference: [Rampini, Viswanathan and Vuillemey (2020 JF)](https://doi.org/10.1111/jofi.12868).
* [BHC NetIncome/Assets](https://mingze-gao.com/measures/bhc_netincome_to_assets)
    * Net income (BHCK4340) / total assets (BHCK2170).
    * Source: `frb_chicago.bhc.bhcf`.
    * Reference: [Rampini, Viswanathan and Vuillemey (2020 JF)](https://doi.org/10.1111/jofi.12868).
* [BHC Dividend/Assets](https://mingze-gao.com/measures/bhc_dividend_to_assets)
    * Cash dividends on common stock (BHCK4460) / total assets (BHCK2170).
    * Source: `frb_chicago.bhc.bhcf`.
    * Reference: [Rampini, Viswanathan and Vuillemey (2020 JF)](https://doi.org/10.1111/jofi.12868).
* [BHC RegulatoryCapital/Assets](https://mingze-gao.com/measures/bhc_regcap_to_assets)
    * Total qualifying capital allowable under the risk-based capital guidelines (BHCK3792) normalized by risk-weighted assets (BHCKA223).
    * Source: `frb_chicago.bhc.bhcf`.
    * Reference: [Rampini, Viswanathan and Vuillemey (2020 JF)](https://doi.org/10.1111/jofi.12868).
* [BHC Tier1Capital/Assets](https://mingze-gao.com/measures/bhc_tier1cap_to_assets)
    * Tier 1 capital allowable under the risk-based capital guidelines (BHCK8274) normalized by risk-weighted assets (BHCKA223).
    * Source: `frb_chicago.bhc.bhcf`.
    * Reference: [Rampini, Viswanathan and Vuillemey (2020 JF)](https://doi.org/10.1111/jofi.12868).
* [BHC Gross IR Hedging](https://mingze-gao.com/measures/bhc_gross_ir_hedging)
    * Total gross notional amount of interest rate derivatives held for purposes other than trading (BHCK8725) over total assets (BHCK2170); for the period 1995 to 2000, contracts not marked to market (BHCK8729) are added.
    * Source: `frb_chicago.bhc.bhcf`.
    * Reference: [Rampini, Viswanathan and Vuillemey (2020 JF)](https://doi.org/10.1111/jofi.12868).
* [BHC Gross FX Hedging](https://mingze-gao.com/measures/bhc_gross_fx_hedging)
    * Total gross notional amount of foreign exchange rate derivatives held for purposes other than trading (BHCK8726) over total assets (BHCK2170); for the period 1995 to 2000, contracts not marked to market (BHCK8730) are added.
    * Source: `frb_chicago.bhc.bhcf`.
    * Reference: [Rampini, Viswanathan and Vuillemey (2020 JF)](https://doi.org/10.1111/jofi.12868).
* [BHC Maturity Gap & Narrow Maturity Gap](https://mingze-gao.com/measures/bhc_maturity_gap)
    * Maturity gap is defined as the earning assets that are repriceable or mature within one year (BHCK3197) minus interest-bearing deposits that mature or reprice within one year (BHCK3296) minus long-term debt that reprices or matures within one year (BHCK3298 + BHCK3409) minus variable rate preferred stock (BHCK3408) minus other borrowed money with a maturity of one year or less (BHCK2332) minus commercial paper (BHCK2309) minus federal funds and repo liabilities (BHDMB993 + BHCKB995), normalized by total assets.
    * Narrow maturity gap does not subtract interest-bearing deposits that mature or reprice within one year (BHCK3296).
    * Source: `frb_chicago.bhc.bhcf`.
    * Reference: [Rampini, Viswanathan and Vuillemey (2020 JF)](https://doi.org/10.1111/jofi.12868).