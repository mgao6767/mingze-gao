# Firm Historical Headquarter State from SEC 10K/Q Filings

## Why the need to use SEC filings?

In the Compustat database, a firm's headquarter state (and other identification) is in fact the *current* record stored in `comp.company`. This means once a firm relocates (or updates its incorporate state, address, etc.), all historical observations will be updated and not recording historical state information anymore.

To resolve this issue, an effective way is to use the firm's historical SEC filings. You can follow my previous post [Textual Analysis on SEC filings](https://mingze-gao.com/posts/textual-analysis-on-sec-filings/) to extract the header information, which includes a wide range of meta data. Alternatively, the Unversity of Notre Dame's Software Repository for Accounting and Finance provides an [augmented 10-X header dataset](https://sraf.nd.edu/data/augmented-10-x-header-data/).

## Do I have to use SEC filings?

I'll skip the parsing procedure for now. The most important point is that using the historical SEC filings, you can ensure that you truly are using the historical headquarter state in your empirical estimation. Based on the [augmented 10-X header dataset](https://sraf.nd.edu/data/augmented-10-x-header-data/), I find that around 2-3% of Compustat firms changed their headquarter state (as indicated by their business address) each year.

| Year | Firms Changed State | Total Firms | % Firms Changed State |
| ---- | ------------------- | ----------- | --------------------- |
| 1995 | 22                  | 4205        | 0.52                  |
| 1996 | 69                  | 7939        | 0.87                  |
| 1997 | 199                 | 8101        | 2.46                  |
| 1998 | 206                 | 8126        | 2.54                  |
| 1999 | 202                 | 8199        | 2.46                  |
| 2000 | 202                 | 8252        | 2.45                  |
| 2001 | 204                 | 7802        | 2.61                  |
| 2002 | 167                 | 7421        | 2.25                  |
| 2003 | 214                 | 6930        | 3.09                  |
| 2004 | 175                 | 6742        | 2.6                   |
| 2005 | 154                 | 6478        | 2.38                  |
| 2006 | 156                 | 6267        | 2.49                  |
| 2007 | 144                 | 6091        | 2.36                  |
| 2008 | 125                 | 5797        | 2.16                  |
| 2009 | 127                 | 5523        | 2.3                   |
| 2010 | 128                 | 5479        | 2.34                  |
| 2011 | 152                 | 5445        | 2.79                  |
| 2012 | 160                 | 5494        | 2.91                  |
| 2013 | 171                 | 5491        | 3.11                  |
| 2014 | 195                 | 5455        | 3.57                  |
| 2015 | 147                 | 5322        | 2.76                  |
| 2016 | 117                 | 5092        | 2.3                   |
| 2017 | 129                 | 4914        | 2.63                  |
| 2018 | 107                 | 4847        | 2.21                  |

Moreover, 2,947 out of the 17,221 firms, or about 17% firms changed their headquarter state in the merged sample. This is by no means a small number that can be ignored. So, whenever possible, you should try to use the historical information from past SEC filings' metadata.

## How to get the actual historical firm HQ state using SEC filings?

### 1986 - 2003

I start with the firm historical HQ state provided by [Bai, Fairhurst and Serfling (2020 RFS)](https://academic.oup.com/rfs/article-abstract/33/2/644/5522377). This dataset contains the historical HQ locations from 1986 to 2003, which is based on the SEC filings post 1994 and hand-collected by the authors from the Moody’s Manuals (later Mergent Manuals) and Dun & Bradstreet’s Million Dollar Directory (later bought by Mergent).[^1]

### 1994 - 2018

To extend the dataset, I download the [augmented 10-X header dataset](https://sraf.nd.edu/data/augmented-10-x-header-data/) and use the following Python script to extract the business address (state) filed.

```python
import pandas as pd

filepath = "~/Downloads/LM_EDGAR_10X_Header_1994_2018.csv"

if __name__ == "__main__":

    df = pd.read_csv(
        filepath,
        usecols=["cik", "file_date", "ba_state"],
        dtype={"cik": str},
        parse_dates=["file_date"],
    )
    # Some `ba_stata` codes are lowercase
    df["ba_state"] = df["ba_state"].str.upper()
    # Some  `ba_state` codes are not valid US states
    df = df[df["ba_state"].str.isalpha() & ~pd.isnull(df["ba_state"])]
    df.drop_duplicates().to_stata(
        "~/Downloads/historical_state_1994_2018.dta",
        write_index=False,
        convert_dates={"file_date": "td"},
    )
```

The result is a `historical_state.dta` Stata file like this:

![historical_state.dta](/images/historical_state.png)

### 1986 - 2018 merged

Finally, to merge the two datasets together, I imported them into WRDS Cloud and run the following SAS script:

* Pre-2003, use [Bai, Fairhurst and Serfling (2020 RFS)](https://academic.oup.com/rfs/article-abstract/33/2/644/5522377).
* Post-2003, use the business address as in the header of 10K/Q filings, and the Compustat records if the business address is missing and invalid from parsing the headers.

```sas
libname hs "~/historical_state";

/* Historical HQ state (1994 to 2018) from augmented 10-X header dataset */
proc import datafile="~/historical_state/historical_state_1994_2018.dta"
	out=historical_state_1994_2018 dbms=stata replace;
/* Historical HQ state (1986 to 2003) from Bai, Fairhurst and Serfling (2020 RFS) */
proc import datafile="~/historical_state/hist_headquarters_Bai_et_al.dta"
	out=hist_headquarters_Bai_et_al dbms=stata replace;

/* Build the post-1994 dataset using SEC filings */
proc sql;
create table funda as 
select gvkey, cik, datadate, fyear from comp.funda
where indfmt= 'INDL' and datafmt='STD' and popsrc='D' and consol='C'
and year(datadate) between 1994 and 2018
/* "For firms that change fiscal year within a calendar year, 
	we take the last reported date when extracting financial data. 
	This leaves us with one set of observations for each firm (gvkey) in each year." 
	-- Pelueger, Siriwardane and Sunderam (2020 QJE) */
group by gvkey, fyear having datadate=max(datadate);

create table firm_historical_state as 
select a.*, b.ba_state as state_sec label="State from SEC filings"
from funda as a left join historical_state as b 
on a.cik=b.cik and year(a.datadate)=year(b.file_date) and b.file_date<=a.datadate
group by a.gvkey, a.datadate
/* use the SEC filing closet to and before the Compustat datadate */
having b.file_date=max(b.file_date);

create table historical_state_1994_2018 as
select a.*, b.state as state_comp label="State from Compustat"
from firm_historical_state as a left join comp.company as b 
on a.gvkey=b.gvkey
order by a.gvkey, a.datadate;
quit;

/* Sanity check: no duplicated gvkey-fyear */
proc sort data=historical_state_1994_2018 nodupkey; by gvkey datadate; run;


proc sql;
create table hist_headquarters_Bai_et_al as 
select put(gvkeyn, z6.) as gvkey, fyear, state 
from hist_headquarters_Bai_et_al;
quit;

/* Stack together the two datasets */
data states; 
set hist_headquarters_Bai_et_al 
	historical_state_1994_2018(where=(fyear>2003) keep=gvkey fyear state:);
run;

proc sql;
create table hs.corrected_hist_state_1986_2018 as 
select *, coalesce(state, state_sec, state_comp) as corrected_state
from states where not missing(calculated corrected_state)
order by gvkey, fyear;
quit;

/* Sanity check: no duplicated gvkey-fyear */
proc sort data=hs.corrected_hist_state_1986_2018 nodupkey; by gvkey fyear; run;
```

## Data available for download

You can download the data I compiled here: [corrected_hist_state_1986_2018.dta](/data/download/corrected_hist_state_1986_2018.dta).


[^1]: The authors note that "for our final sample of 115,432 firm-year observations, we find that over the 1969 to 2003 period, 9,847 (87.50%) never relocate, 1,211 (10.76%) relocate once, 178 (1.58%) relocate twice, and 18 (0.16%) relocate three times."