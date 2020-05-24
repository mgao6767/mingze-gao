# Merge Compustat and CRSP

Using the CRSP/Compustat Merged Database (CCM) to extract data is one of the
fundamental steps in most finance studies. Here I document several SAS programs
for annual, quarterly and monthly data, inspired by and adapted from several
examples from the WRDS.[^4]

## `GVKEY-PERMNO` link table

First, we need to create a `GVKEY-PERMNO` link table.

```sas linenums="1" hl_lines="9 11"
%let beg_yr = 2000;
%let end_yr = 2003;

proc sql;
create table lnk as
select *
from crsp.ccmxpf_lnkhist
where
    /* See below for a description of the link types */
    linktype in ("LU", "LC") and
    /* Extend the period to deal with fiscal year issues */
    /* Note that the ".B" and ".E" missing value codes represent the   */
    /* earliest possible beginning date and latest possible end date   */
    /* of the Link Date range, respectively.                           */
    (&end_yr+1 >= year(linkdt) or linkdt = .B) and 
    (&beg_yr-1 <= year(linkenddt) or linkenddt = .E)
order by 
    gvkey linkdt;
quit;
```

| Link Type | Description                                                                                                                                                                            |
|-----------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| LC        | Link research complete (after extensive research by CRSP). Standard connection between databases.                                                                                      |
| LU        | Link is unresearched by CRSP. It is established by comparing the Compustat and historical CRSP CUSIPs. LU represents the most popular link type.                                       |
| LS        | Link valid for this security only.[^1]                                                                                                                                                 |
| LX        | Link to a security that trades on foreign exchange not included in CRSP data.                                                                                                          |
| LD        | Duplicate link to a security. Two GVKEYs map to a single `PERMNO` (`PERMCO`) during the same period, and this link should not be used. Almost all of these cases happened before 1990. |
| LN        | Primary link exists but Compustat does not have prices.[^2]                                                                                                                            |
| NR        | No link available; confirmed by research.                                                                                                                                              |
| NU        | No link available; not yet confirmed.                                                                                                                                                  |



According to WRDS's support page: 

* Primary link types (`LC`, `LU` and `LS`) account for 41% of the links in CCM.
* Secondary link types (`LX`, `LD` and `LN`) account for only 2%. 
* Non-matching link types (`NR` and `NU`) account for the rest 57%, which is
  expected because of the different coverage of the two databases.

Generally, using `LC` and `LU` should be sufficient.

## Compustat Annual and CRSP

Example `ccmfunda.sas`.

```sas linenums="1"
proc sql;
create table mydata as 
select *
from lnk, comp.funda (keep=gvkey fyear datadate indfmt datafmt popsrc consol sale) as cst
where indfmt= 'INDL' 
and datafmt='STD' 
and popsrc='D' 
and consol='C' 
and lnk.gvkey = cst.gvkey
and (&beg_yr <= fyear <= &end_yr) 
and (linkdt <= cst.datadate or linkdt = .B) 
and (cst.datadate <= linkenddt or linkenddt = .E);
quit;
```

## Compustat Quarterly and CRSP

Example `ccmfundq.sas`.

```sas linenums="1"
proc sql;
create table mydata as 
select *
from lnk, comp.fundq (keep=gvkey fyearq datadate indfmt datafmt popsrc consol saley saleq) as cst
where indfmt= 'INDL' 
and datafmt='STD' 
and popsrc='D' 
and consol='C' 
and lnk.gvkey = cst.gvkey
and (&beg_yr <= fyearq <= &end_yr) 
and (linkdt <= cst.datadate or linkdt = .B) 
and (cst.datadate <= linkenddt or linkenddt = .E);
quit;
```

## Compustat Monthly and CRSP

To be done.

[^4]: WRDS Overview of CRSP/COMPUSTAT Merged: <br>
      https://wrds-www.wharton.upenn.edu/pages/support/manuals-and-overviews/crsp/crspcompustat-merged-ccm/wrds-overview-crspcompustat-merged-ccm/ <br> 
      Use CRSP-Compustat Merged Table to Add Permno to Compustat Data: <br> 
      https://wrds-www.wharton.upenn.edu/pages/support/research-wrds/macros/wrds-macro-ccm/ <br>
      Merging CRSP and Compustat Data: <br>
      https://wrds-www.wharton.upenn.edu/pages/support/applications/linking-databases/linking-crsp-and-compustat/

[^1]: Other CRSP `PERMNOs` with the same `PERMCO` will link to other `GVKEYs`.
`LS` links mainly relate to ETFs where a single CRSP `PERMCO` links to multiple
Compustat `GVKEYs`. In Compustat, even though they may belong to the same
investment company (e.g. ISHARES), ETFs are presented with different `GVKEYs`
and CRSP flags this situation. 

[^2]:  Prices are used to check the accuracy of the link. For linktype LN there
is no price information available even on a quarterly or annual basis. The user
will have to decide whether or not to include these links.