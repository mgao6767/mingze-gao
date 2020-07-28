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
