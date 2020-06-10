# Compute Jackknife Coefficient Estimates in SAS

In certain scenarios, we want to estimate a model's parameters on the sample for
each observation with itself excluded. This can be achieved by estimating the
model repeatedly on the leave-one-out samples but is very inefficient. If we
estimate the model on the full sample, however, the coefficient estimates will
certainly be biased. Thankfully, we have the Jackknife method to correct for the
bias, which produces the ***Jackknifed*** coefficient estimates for each
observation.

## Variable Definition

Let's start with some variable definitions to help with the explanation.

| Variable                                                    | Definition                                                                                                     |
|-------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------|
| $b(i)$                                                      | the parameter estimates after deleting the $i$th observation                                                   |
| $s^2(i)$                                                    | the variance estimate after deleting the $i$th observation                                                     |
| $X(i)$                                                      | the $X$ matrix without the $i$th observation                                                                   |
| $\hat{y}(i)$                                                | the $i$th value predicted without using the $i$th observation                                                  |
| $r_i = y_i - \hat{y}_i$                                     | the $i$th residual                                                                                             |
| $h_i = x_i(X'X)^{-1}x_i'$                                   | the $i$th diagonal of the projection matrix for the predictor space, also called the hat matrix                |
| $RStudent =\frac{r_i}{s(i) \sqrt{1-h_i}}$                   | studentized residual                                                                                           |
| $(X'X)_{jj}$                                                | the $(j,j)$th element of $(X'X)^{-1}$                                                                          |
| $DFBeta_j = \frac{b_{j} - b_{(i)j}}{s(i)\sqrt{(X'X)_{jj}}}$ | the scaled measures of the change in the $j$th parameter estimate calculated by deleting the $i$th observation |

## Objective

Compute the coefficient estiamtes with the $i$th observation excluded from the
sample, i.e. $b(i)$, or the Jackknifed coefficient estimate.

## Formula

From the table above, we can get that the $j$th Jackknifed coefficient estimate
$b_{(i)j}$ without using the $i$th observation is:

$$b_{(i)j} = b_j - DFBeta_j \times s(i) \sqrt{(X'X)_{jj}} $$

Hence,

$$b_{(i)j} = b_j - DFBeta_j \times \frac{r_i}{RStudent\times \sqrt{1-h_i}} \sqrt{(X'X)_{jj}}$$

The good thing is that `PROC REG` produces the coefficient estimate $b_j$ for
$j=1,2,...K$, where $K$ is the number of coefficients, and the `INFLUENCE` and
`I` options produce the remaining statistics just enough to compute $b(i)$:

| Variable     | Option in `PROC REG` or `MODEL` statement                        | Name in the output dataset |
|--------------|------------------------------------------------------------------|----------------------------|
| $b_j$        | `Outest=` option in `PROC REG`                                   | `<jthVariable>`            |
| $r_i$        | `OutputStatistics=` from `INFLUENCE` option in `MODEL` statement | `Residual`                 |
| $RStudent$   | `OutputStatistics=` from `INFLUENCE` option in `MODEL` statement | `RStudent`                 |
| $h_i$        | `OutputStatistics=` from `INFLUENCE` option in `MODEL` statement | `HatDiagnol`               |
| $DFBeta_j$   | `OutputStatistics=` from `INFLUENCE` option in `MODEL` statement | `DFB_<jthVariable>`        |
| $(X'X)_{jj}$ | `InvXPX=` from `I` option in `MODEL` statement                   | `<jthVariable>`            |

## Example

### Discretionary accruals
Suppose we want to calculate the firm-level [discretionary
accruals](/documentation/discretionary-accruals/) for each year using the Jones
(1991) model and Kothari et al (2005) model. For a firm $i$, we need to first
estimate the model for the industry-year excluding firm $i$, then use the
coefficient estimates to generate predicted accruals for firm $i$. The firm's
discretionary accruals is the actual accruals minus the predicted accruals.

Below is an example `PROC REG` that produces three datasets named `work.params`,
`work.outstats` and `work.xpxinv`, which contain sufficient statistics to
compute the Jackknifed estimates and thus the predicted accruals.

```sas linenums="1"
ods listing close; 
proc reg data=work.funda edf outest=work.params;
  /* industry-year regression */
  by fyear sic2;
  /* id is necessary for later matching Jackknifed coefficients to firm-year */
  id key;
  /* Jones Model */
  Jones: model tac = inv_at_l drev ppe / noint influence i;
  /* Kothari Model with ROA */
  Kothari: model tac = inv_at_l drevadj ppe roa / noint influence i;
  ods output OutputStatistics=work.outstats InvXPX=work.xpxinv;
run;
ods listing;
```

Full SAS program for estimating 5 different measures of discretionary accruals:

??? Example "SAS code for computing discretionary accruals"
    ```SAS linenums="1"
    /* Use Jackknife method to compute discretionary accruals */
    /* see https://mingze-gao.com/posts/compute-jackknife-coefficient-estimates-in-sas/ */

    /* UseHribarCollinsTotalAccruals:
      - true:  use Hribar-Collins Cashflow Total Accruals 
      - false: use normal method */
    %let UseHribarCollinsTotalAccruals = false;

    /* Include %array and %do_over */
    filename do_over url "https://mingze-gao.com/utils/do_over.sas";
    filename array url "https://mingze-gao.com/utils/array.sas";
    %include do_over array;

    /* Winsorize macro */
    filename winsor url "https://mingze-gao.com/utils/winsor.sas";
    %include winsor;

    /*
      Earnings management models
      
      Author: Mingze (Adrian) Gao, Feb 2019
      Modified based on the work by Joost Impink, March 2016

      Models estimated (Note that the intercept a0 is removed in the modified code below):
      - Jones model, 	tac = a0 + a1 1/TAt-1 + a2chSales + a3PPE + a4ROA + error.
        - variable names DA_Jones  
      - Modified Jones model, as Jones model, but using chSales - chREC to compute fitted values.
        - variable names DA_mJones  
      - Kothari 2005, controlling for ROA, tac = a0 + a1 1/TAt-1 + a2(chSales - chREC) + a3PPE + a4ROA + error.
        - variable names DA_Kothari   
      - Kothari 2005, performance matched, Jones model, difference in discretionary accruals between firm and closest firm in terms of (contemporaneous) roa
        - variable names DA_pmKothari_Jones
      - Kothari 2005, performance matched, modified Jones model, difference in discretionary accruals between firm and closest firm in terms of (contemporaneous) roa
        - variable names DA_pmKothari_mJones

      tac:		Total accruals, computed as net profit after tax before extraordinary items less cash flows from operations	
      1/TAt-1:	Inverse of beginning of year total assets
      chSales:	Change in net sales revenue
      chREC: 		Change in net receivables
      PPE:		Gross property, plant, and equipment
      ROA:		Return on assets. 
      Variables used Compustat Funda
      AT:		Total assets
      IB: 	Income Before Extraordinary Items
      IBC: 	Income Before Extraordinary Items (Cash Flow) (used if IB is missing)
      OANCF: 	Operating Activities - Net Cash Flow
      PPEGT:	Property, Plant and Equipment - Total (Gross)
      RECT: 	Receivables - Total
      SALE:	Sales
      INVT:	Inventories - Total
      LCO:	Current Liabilities Other Total
      DP:		Depreciation and Amortization
      ACO:	Current Assets Other Total
      AP:		Accounts Payable - Trade
    */

    /* Get Funda variables */
    %let fundaVars = at ib ibc oancf ppegt rect sale xidoc lco dp aco invt ap;

    data work.a_funda(keep=key gvkey fyear datadate sich &fundaVars);
      set comp.funda;
      if 1980 <= fyear <= 2018;
      /* Generic filter */
      if indfmt='INDL' and datafmt='STD' and popsrc='D' and consol='C';
      /* Firm-year identifier */
      key = gvkey || fyear;
      /* Keep if sale > 0, at > 0 */
      if sale > 0 and at > 0;
      /* Use Income Before Extraordinary Items (Cash Flow) if ib is missing */
      if ib =. then ib=ibc;
    run;

    /* Lagged values for: at sale rect invt aco ap lco */
    %let lagVars = at sale rect invt aco ap lco;

    /* Self join to get lagged values at_l, sale_l, rect_l */
    proc sql;
      create table work.b_funda as select a.*, %do_over(values=&lagVars, between=comma, phrase=b.? as ?_l)
      from work.a_funda a, work.a_funda b
      where a.gvkey = b.gvkey and a.fyear-1 = b.fyear;
    quit;

    /* Construct additional variables */
    data work.b_funda(compress=yes);
      set work.b_funda;
      /* 2-digit SIC  */
      sic2 = int(sich/100);
      /* variables */
      if "&UseHribarCollinsTotalAccruals." eq "false" then
        tac	  	= ((rect-rect_l)+(invt-invt_l)+(aco-aco_l)-(ap-ap_l)-(lco-lco_l)-dp)/at_l; /* Accruals ratio */
      else
        tac     = (ibc - oancf + xidoc)/at_l;  /* Hribar Collins total cash flow accruals */
      inv_at_l  	= 1 / at_l;
      drev      	= (sale - sale_l) / at_l;
      drevadj   	= (sale - sale_l)/at_l - (rect - rect_l)/at_l;
      ppe       	= ppegt / at_l;
      roa 	  	= ib / at_l;
      /* these variables may not be missing (cmiss counts missing variables)*/
      *if cmiss  (of tac inv_at_l drevadj ppe roa) eq 0;
    run;

    /* Optional winsorization before industry-year regression */
    %let winsVars = tac inv_at_l drev drevadj ppe roa  ; 
    %winsor(dsetin=work.b_funda, dsetout=work.b_funda_wins, byvar=fyear, vars=&winsVars, type=winsor, pctl=1 99);

    /* Regression by industry-year 
    edf(error degrees of freedom) + #params will equal the number of obs (no need for proc univariate to count) */
    proc sort data=work.b_funda_wins; by fyear sic2; run;
    /* regressors */
    %array(vars, values=inv_at_l drev ppe drevadj roa);
    ods listing close;
    proc reg data=work.b_funda_wins edf outest=work.c_parms;
      by fyear sic2;
      id key;
      /* Jones Model */
      Jones: 		model tac = inv_at_l drev ppe / noint influence i;	
      /* Kothari with ROA in model */ 
      Kothari:	model tac = inv_at_l drevadj ppe roa / noint influence i;
      ods output OutputStatistics=work.outstats InvXPX=work.xpxinv;
    run;
    ods listing;

    /* Compute discretionary accrual measures */
    proc sql;
      /* Compute firm-year Jackknifed coefficient estimates */
      create table work.xpxinv2 as
      /* Extract the diagnol elements of the symmetric inv(X'X) for each firm-year */
        select fyear, sic2, model,
          %do_over(vars, phrase=sum(case when variable="?" then xpxinv else . end) as ?, between=comma)
        from (select fyear, sic2, model, variable,
            case %do_over(vars, phrase=when variable="?" then ?) else . end as xpxinv
          from work.xpxinv where variable ~= 'tac')
        group by fyear, sic2, model
        order by fyear, sic2, model;
      /* The difference between original coefficient estimates and the Jackknifed estimates */
      create table work.bias as
        select a.fyear, a.sic2, a.model, a.key,
          %do_over(vars, phrase=a.DFB_?*(a.Residual/(a.RStudent*sqrt(1-a.HatDiagonal)))*sqrt(b.?) as bias_?, between=comma)
        from work.outstats as a left join work.xpxinv2 as b
        on a.fyear=b.fyear and a.sic2=b.sic2 and a.model=b.model
        order by a.fyear, a.sic2, a.model, a.key;
      /* Compute Jackknifed coefficient estimates by subtracting the bias from the original estimates */
      create table work.Jackknifed_params as
        select a.fyear, a.sic2, a.model, a.key, %do_over(vars, phrase=b.? - a.bias_? as ?, between=comma), b._EDF_
        from work.bias as a left join work.c_parms as b
        on a.fyear=b.fyear and a.sic2=b.sic2 and a.model=b._MODEL_
        order by a.fyear, a.sic2, a.model, a.key;
      /* Compute discretionary accruals */
      create table work.tmp as
        select distinct a.fyear, a.sic2, a.gvkey, a.key,
          /* Jones model at a minimum 8 obs (5 degrees of freedom + 3 params) */
          sum(case when b.model eq 'Jones' and b._EDF_ ge 5 then
            a.tac - (%do_over(values=inv_at_l drev ppe, between=%str(+), phrase=a.? * b.?)) else . end) as DA_Jones,
          /* Modified Jones model: drev is used in first model, but drevadj is used to compute fitted value */
          sum(case when b.model eq 'Jones' and b._EDF_ ge 5 then
            a.tac - (a.drevadj * b.drev + %do_over(values=inv_at_l ppe, between=%str(+), phrase=a.? * b.?)) else . end) as DA_mJones,
          /* Kothari model (with ROA in regression) at a minimum 8 obs (4 degrees of freedom + 4 params) */
          sum(case when b.model eq 'Kothari' and b._EDF_ ge 4 then
            a.tac - (%do_over(values=inv_at_l drevadj ppe roa, between=%str(+), phrase=a.? * b.?)) else . end) as DA_Kothari
        from work.b_funda_wins as a left join work.Jackknifed_params as b
        on a.key=b.key
        group by a.key
        order by a.gvkey, a.fyear;
      /* Kothari performance matching: get DA_Jones (DA_mJones) accruals for the matched firm closest in ROA */
      create table work.da_roa as select a.*, b.roa from work.tmp as a left join work.b_funda_wins as b on a.key=b.key;
      create table work.da_all as
        select a.*,
          /* gvkey of matched firm */
          b.gvkey as gvkey_m, 
          /* difference in ROA */
          abs(a.roa - b.roa) as Difference, 
          /* difference in DA_Jones */
          a.DA_Jones - b.DA_Jones as DA_pmKothari_Jones,
          a.DA_mJones - b.DA_mJones as DA_pmKothari_mJones
        from work.da_roa as a left join  work.da_roa as b
        on a.fyear = b.fyear and a.sic2 = b.sic2 /* same 2-digit SIC industry-year */		
        and a.key ne b.key /* not the same firm */
        group by a.gvkey, a.fyear
        having Difference = min(Difference) /* keep best match for size difference */
        order by gvkey, fyear;
    quit;

    /* drop possible multiple matches (with the same difference) in previous step */
    proc sort data=work.da_all nodupkey; by key; run;

    %let DAVars = DA_Jones DA_mJones DA_Kothari DA_pmKothari_Jones DA_pmKothari_mJones;

    /* Winsorize discretionary accrual variables (Optional) */
    %winsor(dsetin=work.da_all, dsetout=work.accruals_HribarCollins_&UseHribarCollinsTotalAccruals., byvar=fyear, vars=&DAVars, type=winsor, pctl=1 99);

    /* Means, medians for key variables */
    proc means data=work.accruals_HribarCollins_&UseHribarCollinsTotalAccruals. n mean min median max; var &DAVars; run; 
    ```