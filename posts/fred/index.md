---
title: FRED - Federal Reserve Economic Data
date: 2023-08-08
draft: false
tags:
    - Stata
categories:
    - Research Notes
disqus: true
slug: "fred-federal-reserve-economic-data"
---

Since Stata 15, we can search, browse and import almost a million U.S. and international economic and financial time series made available by the St. Louis Federal Reserve's [Federal Research Economic Data](https://fred.stlouisfed.org/). This post briefly explains this great feature.

<!-- more -->

## Prerequisite

Before you start, you will need an API Key from FRED. [Register one here](https://fred.stlouisfed.org/docs/api/api_key.html)

Then in Stata, you can store this key permanently so you don't need to provide again.[^1]

[^1]: Replace `_key_` with your actual API Key obtained.

```stata
set fredkey _key_, permanently
```

## GUI is always a good start

Alternatively, click on menu `File>Import>Fedearl Reserve Economic Data (FRED)` will bring up the dialog as shown below.

![Set FRED key](/images/set_fredkey.png){#fig-set-fred-key fig-align="center"}

Enter API Key and you'll be free to explore all the data series available on FRED.

![Import data from FRED database](/images/import_fred.png){#fig-import-fred fig-align="center"}

For example, let's see the CPI of Australia...

![Import Australia's CPI data](/images/import_fred_cpi_australia.png){#fig-import-au-cpi fig-align="center"}

Describe the data series, we can find many useful meta info.

![The window showing the description of Australia's CPI data](/images/import_fred_cpi_australia_desc.png){#fig-import-au-cpi-desc fig-align="center"}

::: {.callout-note title="Vintage"}
Note that "vintage" section lists a number of dates, with each vintage referring __a particular version of the data series at that point of time__.
:::

It may sound strange but an economic data series may be revised multiple times after it has been published. Potential reasons may be that later people collect more accurate information, or that there is a change of estimation method, etc.[^2]

[^2]: For example, the _CPI from 2005 to 2010_ collected by a research as at 2011 may be different from the one collected as at 2023. Without specifying the data vintage, replicating a prior work can be hard.

Another tricky part is that ignoring vintages introduces __look-ahead bias__ in analysis.[^3]

[^3]: For example, a trading strategy using the _revised_ GDP accessed today, instead of the _vintage_ GDP, implicitly uses hindsight as the GDP series may have been revised to accommodate more accurate data obtained after release.

Let's close the description, double click on the series and click on import. Another dialog will be shown to confirm some final details.

![Import data](/images/import_fred_cpi_australia_import.png){#fig-import-au-cpi-import fig-align="center"}

The outputs will be like the following:

```stata
. import fred AUSCPIALLQINMEI, daterange(2010-01-01 2023-08-08) aggregate(quarterly,avg)

Summary
--------------------------------------------------------------------------
Series ID                    Nobs    Date range                Frequency
--------------------------------------------------------------------------
AUSCPIALLQINMEI              53      2010-01-01 to 2023-01-01  Quarterly
--------------------------------------------------------------------------
# of series imported: 1
   highest frequency: Quarterly
    lowest frequency: Quarterly
```

## Programmatical is recipe to reproducibility

We don't need to go through the GUI process every time. In fact, Stata already told us what the corresponding command is:

```stata
import fred AUSCPIALLQINMEI, daterange(2010-01-01 2023-08-08) aggregate(quarterly,avg)
```

We can simply put this line of code into our program.

For example, the code below generates a time-series chart for Australia's CPI.

```stata
// Import
import fred AUSCPIALLQINMEI, daterange(2010-01-01 2023-03-31) vintage(2023-05-10) aggregate(quarterly,avg) clear
rename AUSCPIALLQINMEI_20230510 cpi_australia
// Time format
gen yrqtr = yq(year(daten),quarter(daten))
format yrqtr %tq
tsset yrqtr
// Set start of the period to 100
gen cpi_ret = cpi_australia/L.cpi_australia - 1
replace cpi_australia = 100 if _n==1
replace cpi_australia = L.cpi_australia * (1+cpi_ret) if _n>1
// Plotting
twoway (tsline cpi_australia), title("Quarterly CPI of Australia 2010Q1-2023Q1") ytitle("") ttitle("") note("Index 2010Q1=100. Source: FRED, 2023-05-10 vintage.")
```

![Timeseries plot of Australia's CPI data imported from the FRED database](/images/import_fred_cpi_australia_example.png){#fig-timeseries-au-cpi fig-align="center"}

::: {.callout-note}
The code snippet above specifies the data vintage. Therefore, even if someone runs it 30 years from now, they will still get exactly the same data and plot as I do in 2023.
:::
