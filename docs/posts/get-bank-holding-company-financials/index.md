# Bank Holing Company Financials from FR Y-9C

## Extract BHC balance sheet data

This is the SAS macro I write to consolidate and extract BHC's balance sheet
data from WRDS Bank Regulatory database. It creates a `bhcf` dataset in the work
directory.

```sas linenums="1"
%macro bhc_financials(loopdatestart,loopdateend);
    /* Specify the variables to extract */
    %let vars=rssd9999 rssd9001 rssd9007 rssd9008 bhck2170 bhck3210;
    %let loopdatestart=%sysfunc(inputn(&loopdatestart,anydtdte9.));
    %let loopdateend=%sysfunc(inputn(&loopdateend,anydtdte9.));
    %let dif=%sysfunc(intck(month,&loopdatestart,&loopdateend));
    %let dats=;
    %do i=0 %to &dif;
        %let date=%sysfunc(intnx(month,&loopdatestart,&i,e));
        %let month=%sysfunc(month(&date),z2.);
        %let year=%sysfunc(year(&date));
        %if &month=3 or &month=6 or &month=9 or &month=12 %then %do;
        %let dats=&dats bank.bhcf&year&month;
        %end;
    %end;
    %put &dats;
    data bhcf(keep=&vars); set &dats; 
        rssd9999 = input(put(rssd9999, 8.), yymmdd10.);/* reporting date */
        rssd9007 = input(put(rssd9007, 8.), yymmdd10.);/* date start */
        rssd9008 = input(put(rssd9008, 8.), yymmdd10.);/* date end */
        format rssd9999 date9.;
        format rssd9007 date9.;
        format rssd9008 date9.;
        where rssd9999 between rssd9007 and rssd9008;
    run;
%mend bhc_financials;

%bhc_financials(01jan1990,01dec2000);
```

!!! warning 
    RSSD dates are not always available, in which case lines 18-24 should be
    removed.


## Merge with Compustat/CRSP

The firm identifier in the Y-9C data is `RSSD9001`. To merge the BHC's balance
sheet data with Compustat/CRSP, I use the `PERMCO-RSSD` link table by the
Federal Reserve Bank of New York.[^1] I saved the most recent copy in my server,
and formatted it so that it can used directly. It is available at
https://mingze-gao.com/data/download/crsp_20181231.csv.

[^1]: https://www.newyorkfed.org/research/banking_research/datasets.html

```sas linenums="1"
%let beg_yr = 1986;
%let end_yr = 2018;

proc sql;
create table lnk as
select *
from crsp.ccmxpf_lnkhist
where
    linktype in ("LU", "LC") and
    (&end_yr+1 >= year(linkdt) or linkdt = .B) and 
    (&beg_yr-1 <= year(linkenddt) or linkenddt = .E)
order by 
    gvkey, linkdt;
quit;


/* PERMCO-RSSD link table by New York FED */
filename csv url "https://mingze-gao.com/data/download/crsp_20181231.csv";
proc import datafile=csv out=work.crsp_20181231 dbms=csv replace; run;
proc sql;
create table gvkey_permno_permco_rssd as 
    select *
from lnk join crsp_20181231 as fed
on lnk.lpermco=fed.permco;
quit;
```

!!! note 
    Please run these programs on the WRDS cloud. You'll need to modify them
    in order to run locally with SAS/Connect.