---
date: 2022-01-09
authors:
- mgao
tags:
- Code
- SAS
categories:
- Research Notes
---

# Estimate Organization Capital

As in Eisfeldt and Papanikolaou (2013), we obtain firm-year accounting data from the Compustat and compute the stock of organization capital for firms using the perpetual inventory method that recursively calculates the stock of OC by accumulating the deflated value of SG&A expenses.

<!-- more -->

## Organization Capital

$$
OC_{i,t} = (1-\delta_{OC})OC_{i,t-1} + \frac{SGA_{i,t}}{CPI_t}
$$

where $SGA_{i,t}$ is firm $i$'s SG&A expenses in year $t$, $CPI_t$ is the consumer price index, and $\delta_{OC}$ is the depreciation rate of OC stock, which is set to be 15% as used by the U.S. Bureau of Economic Analysis (BEA). The initial value of OC stock is set to:

$$
OC_{i,0} = \frac{SGA_{i,1}}{g+\delta_{OC}}
$$

where $g$ is the average real growth rate of firm-level SG&A expenses, which is 10% in Eisfeldt and Papanikolaou (2013) or specific for an industry-decade in Li, Qiu and Shen (2018).

## Code

This code estimates the organization capital for all Compustat firm-years.

Note that it requires an external dataset of CPI. You need to name it `cpiaucsl` and store it in your WRDS home directory.

```SAS linenums="1"
%let wrds=wrds-cloud.wharton.upenn.edu 4016;
options comamid=TCP remote=WRDS;
signon username=_prompt_;
 
rsubmit;

/* ==============================================================================================
 * This SAS program calcualtes the firm-year Organization Capital, measured by the capitalized 
 * 		SG&A expenses using perpetual inventory method.
 * See e.g. Eisfeldt and Papanikolaou (2013), Li, Qiu and Shen (2018), Gao, Leung and Qiu (2021).
 *
 * Input: Compustat from WRDS.
 * Output:
 *  sgastock: capitalized SG&A expenses
 *  oc: capitalized SG&A expenses scaled by CPI-adjusted total assets
 *  indadj_oc: industry median adjusted oc
 *  rank_oc: annual decile rank of oc
 *  rank_indadj_oc: annual decile rank of indadj_oc
 *
 * Note:
 *  This program requires an external dataset of CPI named `cpiaucsl` in your home directory.
 *	I use the Consumer Price Index for All Urban Consumers: All Items (CPIAUCSL)
 *	sourced from Federal Reserve Bank of St.Louis,
 *	available at https://fred.stlouisfed.org/series/CPIAUCSL/
 *	Also, the industry-adjustment is based on sich from compustat only.
 *  This code may contain error. Please check before use.
 *
 * Author: Mingze (Adrian) Gao
 *
 * Last Modifed: 24 Feb 2019
 * ============================================================================================== */

libname home "~/";

data funda(keep=gvkey cusip cik fyear datadate at xsga xrd xad sic2);
	/*  Variables from Compustat:
	*	AT: 	Assets Total;
	*	XSGA:	Selling, General and Administrative Expense;
	*	XRD:	Research and Development Expense;
	*	XAD:	Advertising Expense; */
	set comp.funda;
    if cmiss(of fyear datadate)=0;
	if indfmt = 'INDL' and datafmt='STD' and popsrc='D' and consol='C';
	sic2 = int(sich/100);
run;

proc sql;
	/* Keep only obs from the first year with non-missing XSGA */
	create table funda_nonmissing_xsga as
		select distinct a.*
		from funda as a left join 
			/* This subquery selects the first year of appearance 
				with non-missing XSGA */
			(select gvkey, fyear as firstfyear from funda 
			 where xsga is not missing 
			 group by gvkey having fyear = min(fyear)) as b
		on a.gvkey=b.gvkey
		where a.fyear>=b.firstfyear; 
	
	/* CPIAUCSL: Consumer Price Index for All Urban Consumers: All Items
		Source: https://fred.stlouisfed.org/series/CPIAUCSL/ */
	create table funda_cpi as
		select distinct a.*, b.cpiaucsl as cpi
		from funda_nonmissing_xsga as a left join home.cpiaucsl as b
		on year(a.datadate) = year(b.date) and month(a.datadate) = month(b.date)
		order by gvkey, fyear;
quit;

/* Sanity Check -- No Duplicates */
proc sort nodupkey data=funda_cpi; 
	by gvkey fyear;
run;

data funda_adj;
	set funda_cpi;
	by gvkey fyear;
	/* Replace missing XSGA, XRD and XAD with 0 */
	if xsga=. then xsga=0;
	if xrd=. then xrd=0;
	if xad=. then xad=0;
	/* Total assets adjusted for CPI */
	adjat = at / cpi;
	/* Two alternative SG&A measures */
	adjxsga1 = xsga / cpi;
	adjxsga2 = sum(xsga, -xrd, -xad) / cpi;
run;

data sgastock(drop=cnt adjxsga1 adjxsga2 lag:);
	set funda_adj(keep=gvkey cik cusip datadate fyear sic2 adj:);
	by gvkey;
	if first.gvkey then call missing(of cnt lag:);
	cnt+1;
	array adjxsga adjxsga1-adjxsga2;
	array sgastock sgastock1-sgastock2;
	array sgastock_r sgastock_r1-sgastock_r2;
	array lag_sgastock lag_sgastock1-lag_sgastock2;
	select (cnt);
		when (1) do;
			/* Under Perpetual Inventory Method, 
			* the initial value of capitalized SG&A at time 0, O(0), is:
			*	O(0)=O(1)/(g+delta)
			* where g is average SGA growth rate (10%) and delta is depreciation rate (15%).
			* So that,
			*	O(0)=SGA(1)/(0.15+0.1)=SGA(1)/0.25=SGA(1)*4
			* This is why `adjxsga*4` is used below, specifically,
			* 	O(1)=O(0)*0.85+SGA(1)
			*		=SGA(0)*4*0.85+SGA(1) */
			do over sgastock;
				sgastock = (adjxsga * 4)* 0.85 + adjxsga; end;
		end;
		otherwise do;
			/* When t>1,
			* the capitalized SG&A at time t, O(t), is:
			*	O(t)=O(t-1)*(1-delta)+SGA(t)
			* where g is average SGA growth rate (10%) and delta is depreciation rate (15%).
			* Note that here SG&A is adjusted for CPI. */
			do over sgastock;
				sgastock = lag_sgastock * 0.85 + adjxsga; end;
		end;
	end;
	do over sgastock;
		lag_sgastock = sgastock;
		/* `sgastock_r` is sgastock scaled by adjusted total assets. */
		sgastock_r = sgastock / adjat;
		if adjat=. then sgastock_r=0;
	end;
	output;
	retain lag:;
run;

/* industry-adjusted OC and rank-based OC measures */
proc sql;
	create table tmp as
		select gvkey, cik, cusip, datadate, fyear, sic2,
			sgastock_r1 as oc1,
			sgastock_r2 as oc2,
			sgastock_r1 - median(sgastock_r1) as indadj_oc1,
			sgastock_r2 - median(sgastock_r2) as indadj_oc2
		from sgastock
		group by fyear, sic2
		order by gvkey, fyear;
quit;
proc sort data=tmp; by fyear; run;
proc rank data=tmp out=result groups=10;
	by fyear;
	var oc1 oc2 indadj_oc1 indadj_oc2;
	ranks rank_oc1 rank_oc2 rank_indadj_oc1 rank_indadj_oc2;
run;

data download(compress=yes); set work.result; run;
proc download data=work.download out=sgastock; run;
 
endrsubmit;
signoff;
```

Lastly, if you use this code above, please consider citing the following article for which it was written.

> Gao, M. Leung, H. and Qiu, B. (2021). Organization Capital and Executive Performance Incentives, *Journal of Banking & Finance*, 123, 106017.
