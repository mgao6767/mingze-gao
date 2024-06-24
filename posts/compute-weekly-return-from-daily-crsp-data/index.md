---
title: Compute Weekly Return from Daily CRSP Data
date: 2020-05-22
tags:
  - CRSP
  - SAS
  - Code
categories:
  - Research Notes
---

Computing the weekly returns from the CRSP daily stock data is a common task but
may be tricky sometimes. Let's discuss a few different ways to get it done
incorrectly and correctly.

::: {.callout-tip title="**TL;DR** Take me to the final solution!"}
Surely -> [The solution](#group-using-aligned-dates-fast-version-with-caveat)
:::

<!-- more -->

## **INCORRECT** ways

Let me start with a few incorrect ways, which may seem perfectly okay at first
glance. This part is important because it shows you how a small mistake can lead
to hard-to-discover bugs.

### Weekly index return from daily data

::: {.panel-tabset}

# Date as the Friday of the week

Using `intnx()`, we can derive the Friday of the week given a date, as shown
below.

```sas
proc sql;
/* Compute weekly marekt return from daily data */
create table mktret_weekly as 
select distinct date, 
  year(date) as Year,
  week(date) as Week,
  case when weekday(date)=6 then date
  else intnx("week.6",date,1) end as FridayOfWeek format=date9.,
  (exp(sum(log(1+sprtrn)))-1)*100 as mktret label="Weekly SP500 Index Return (%)"
from crsp.dsi 
where 
  year(date) between &startyear. and &endyear.
group by year(date), week(date) order by date;
quit;
```

Note that `intnx("weekday.6", date, 0)` will give the **last** Friday, which is
not what we want. We want the **next** Friday of the week for a given date, so
we use `intnx("weekday.6", date, 1)`. The `case...when...` statement ensures
that if the given date is already a Friday, we don't go for the next one. Below
is a sample output of the `mktret_weekly` table generated. 

::: {.callout-note collapse=true title="Example output of `mktret_weekly`"}
| Obs | Date     | Year | Week | FridayOfWeek | mktret       |
| --- | -------- | ---- | ---- | ------------ | ------------ |
| 1   | 19860102 | 1986 | 0    | 03JAN1986    | -0.1893222   |
| 2   | 19860103 | 1986 | 0    | 03JAN1986    | -0.1893222   |
| 3   | 19860106 | 1986 | 1    | 10JAN1986    | -2.333080418 |
| 4   | 19860107 | 1986 | 1    | 10JAN1986    | -2.333080418 |
| 5   | 19860108 | 1986 | 1    | 10JAN1986    | -2.333080418 |
| 6   | 19860109 | 1986 | 1    | 10JAN1986    | -2.333080418 |
| 7   | 19860110 | 1986 | 1    | 10JAN1986    | -2.333080418 |
| 8   | 19860113 | 1986 | 2    | 17JAN1986    | 1.1992620931 |
| 9   | 19860114 | 1986 | 2    | 17JAN1986    | 1.1992620931 |
:::

We can verify that the `FridayOfWeek` indeed gives the Friday of the week.
Therefore, the final weekly dataset using Friday as the date identifier just
need to keep `FridayOfWeek` and `mktret`.

```sas
proc sql;
/* Compute weekly marekt return from daily data */
create table mktret_weekly as 
select distinct
  case when weekday(date)=6 then date else intnx("week.6",date,1) end 
    as date format=date9. label="Friday of the Week",
  (exp(sum(log(1+sprtrn)))-1)*100 
    as mktret label="Weekly SP500 Index Return (%)"
from crsp.dsi 
where 
  year(date) between &startyear. and &endyear.
group by year(date), week(date) order by date;
quit;
```

::: {.callout-note collapse=true title="Example output of `mktret_weekly`"}
| Obs | date      | mktret       |
| --- | --------- | ------------ |
| 1   | 03JAN1986 | -0.1893222   |
| 2   | 10JAN1986 | -2.333080418 |
| 3   | 17JAN1986 | 1.1992620931 |
| 4   | 24JAN1986 | -0.959555101 |
| 5   | 31JAN1986 | 2.5916781551 |
| 6   | 07FEB1986 | 1.3126828796 |
:::

# Date as the last trading day of the week

```sas
%let startyear=1986;
%let endyear=2019;

proc sql;
/* Compute weekly marekt return from daily data */
create table mktret_weekly as 
select distinct date, 
  (exp(sum(log(1+sprtrn)))-1)*100 as mktret label="Weekly SP500 Index Return (%)"
from crsp.dsi where year(date) between &startyear. and &endyear. 
group by year(date), week(date) 
having date=max(date) 
order by date;
quit;
```

Note here that it's tempting to use `having weekday(date)=6` to make sure the
dates are all Friday. However, if Friday in a week is not the last trading day,
then the weekly return will be missing. This is why here I use `date=max(date)`
to ensure non-missing weekly returns. The date is the last trading day in any
given week, consistent with the CRSP's daily stock file.

The caveat here is that since the dates are the weekly last trading days, when
merged with other weekly datasets, you should be very careful about whether the
other dataset is using Friday or the last trading day per week as its date
variable.

:::

### Weekly stock return from daily data

Following the same logic, we can calculate the weekly stock returns from daily
CRSP data, where dates are aligned to the Friday of the week.

```sas
proc sql;
/* Stocks (ordinary shares only) in the financial sector */
create table stocks as select distinct permno from crsp.stocknames
where shrcd in (10, 11) and floor(siccd/100) between 60 and 67;

create table stockrets_weekly as 
select distinct permno,
  case when weekday(date)=6 then date else intnx("week.6",date,1) end 
    as date format=date9. label="Friday of the Week",
  (exp(sum(log(1+ret)))-1)*100 as ret label="Weekly Return (%)"
from crsp.dsf 
where 
  year(date) between &startyear. and &endyear.
  and permno in (select * from stocks) 
  and prc>0 and not missing(ret)
group by year(date), week(date), permno order by permno, date;
quit;
```

### What's wrong?

The code above seems okay. We know that CRSP daily stock file contains many
observations where the daily trading volume is 0, in which case the price is
recorded as the negative bid-ask midpoint. Therefore, we restrict to only those
with positive stock prices. So what's the problem?

::: {.callout-important title="The problem is that a week can span two calendar years."}
:::

For example, check out the last week of 2019:

| Mon | Tue | Wed | Thu | Fri | Sat | Sun |
| --- | --- | --- | --- | --- | --- | --- |
| 30  | 31  | 1   | 2   | 3   | 4   | 5   |

- Dec30 and Dec31 belong to week 53 of 2019, while the code above will use these
  two days' returns to compute the weekly return and align the date to Jan03 of
  2020.
- Jan01 to Jan03 belong to week 0 of 2020, so the code above will use these
  three days' returns to compute the weekly return and align the date to Jan03
  of 2020.

Now we have a mistake. A single week is broken into two because of the use of
`week()` function in SAS. Another consequence is that when there're many years
of data, there will be a lot of duplicates.

## **CORRECT** ways

Now let's explore two ways that avoid this mistake. Although both generate the
same result (there can be a few differences, see the caveat), the second one is
much faster.

### 1. Start with a list of dates (slow version)

Now we can write some correct code to compute the weekly returns. We'll generate
a series of Fridays first, then we merge based on the past 5 calendar days. This
will ensure all trading days with non-missing data will be included in the
weekly return calculation, and correct the mistake mentioned above.

```sas
%let start_date	= 01Jan1986;
%let end_date	= 31Dec2019;

/* Generate a series of Fridays */
data fridays;
date="&start_date"d;
do while (date<="&end_date"d);
    if weekday(date)=6 then output;
    date=intnx('day', date, 1, 's');
end;
format date date9.;
run;
```
::: {.panel-tabset}

# Weekly index return from daily data (as at Friday)

```sas
proc sql;
/* Compute weekly index return from daily data */
create table mktret_weekly as 
select distinct a.date,
  (exp(sum(log(1+sprtrn)))-1)*100 
    as mktret label="Weekly SP500 Index Return (%)"
from fridays as a left join crsp.dsi as dsi
on dsi.date between intnx('day', a.date, -4) and a.date
group by a.date
order by a.date;
quit;
```

# Weekly stock return from daily data (as at Friday)

Note that this version is inefficient and takes a long time to run.

```sas
proc sql;
/* Stocks (ordinary shares) in the financial sector (2-digit SIC=60-67) */
create table stocks as select distinct permno from crsp.stocknames
where shrcd in (10, 11) and floor(siccd/100) between 60 and 67;

/* Compute weekly stock return from daily data */
create table stockrets_weekly as 
select distinct a.date, dsf.permno, dsf.hsiccd,
  (exp(sum(log(1+ret)))-1)*100 as ret label="Weekly Return (%)"
from fridays as a left join crsp.dsf as dsf
on dsf.date between intnx('day', a.date, -4) and a.date
  and dsf.permno in (select * from stocks) 
  and dsf.prc>0 and not missing(dsf.ret)
group by dsf.permno, a.date
order by dsf.permno, a.date;
quit;
```
:::

### 2. Group using aligned dates (fast version with caveat)

This version uses a similar logic from the [previous incorrect
one](#weekly-stock-return-from-daily-data), but it groups based on the aligned
dates instead of `year(date)` and `week(date)`.

```sas
proc sql;
/* Compute weekly stock return from daily data */
create table stockrets_weekly2 as 
select distinct permno, hsiccd,
  case when weekday(date)=6 then date else intnx("week.6",date,1) end 
    as date format=date9. label="Friday of the Week",
  (exp(sum(log(1+ret)))-1)*100 as ret label="Weekly Return (%)"
from crsp.dsf (keep=permno date ret prc shrout hsiccd)
where 
  date between "01Jan1986"d and "31Dec2019"d
  and permno in (select * from stocks) 
  and prc>0 and not missing(ret)
group by permno, calculated date order by permno, date;
quit;
```

::: {.callout-warning title="Caveat"}
If the beginning and ending dates, `"01Jan1986"d and "31Dec2019"d` in the 
example, are not Fridays, then the first and last weekly returns for all 
stocks will be incorrect, because they are not using all the daily data in 
those weeks.

To fix this minor issue, simply extend the beginning and ending dates beyond
your sample period by a few weeks.
:::
