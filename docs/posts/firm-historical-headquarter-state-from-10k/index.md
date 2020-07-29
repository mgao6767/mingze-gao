# Firm Historical Headquarter State from SEC 10K/Q Filings

In the Compustat database, a firm's headquarter state (and other identification) is in fact the *current* record stored in `comp.company`. This means once a firm relocates (or updates its incorporate state, address, etc.), all historical observations will be updated and not recording historical state information anymore.

!!! note
    You can verify this by the following simple SQL query:
    ```sas
    proc sql;
    select count(distinct gvkey)
    from comp.company 
    group by gvkey having count(state) > 1;
    quit;
    ```

To resolve this issue, an effective way is to use the firm's historical SEC filings. You can follow my previous post [Textual Analysis on SEC filings](https://mingze-gao.com/posts/textual-analysis-on-sec-filings/) to extract the header information, which includes a wide range of meta data. Alternatively, the Unversity of Notre Dame's Software Repository for Accounting and Finance provides an [augmented 10-X header dataset](https://sraf.nd.edu/data/augmented-10-x-header-data/).

I'll skip the parsing procedure for now. The most important point is that using the historical SEC filings, you can ensure that you truly are using the historical headquarter state in your empirical estimation.

Based on the [augmented 10-X header dataset](https://sraf.nd.edu/data/augmented-10-x-header-data/), I find that around 2-3% of Compustat firms changed their headquarter state (as indicated by their business address) each year.

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

!!! warning
    Note that there're some apparent mistakes in the headquarter state identified from the 10K/Q filings. You may want to use Compustat/CRSP if needed.