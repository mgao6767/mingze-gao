---
date: 2020-05-22
# date: May 22, 2020
tags:
  - SAS
  - Code
  - WRDS
categories:
  - Research Notes
---

# Use SAS Macros on WRDS

The [Wharton Research Data Services (WRDS)](https://wrds-www.wharton.upenn.edu/) provides quite a handful of SAS macros that can be used directly. This article explains how to use those handy macros on WRDS when you use remote submission to run your code on the WRDS cloud. Lastly, it explains how to load and use third-party SAS macros from a URL.

<!-- more -->

## Prerequisite

Before everything, just make sure that this `autoexec.sas` is located in the home folder on your WRDS cloud.

```sas
*  The library name definitions below are used by SAS;
*  Assign default libref for WRDS (Wharton Research Data Services);
%include '/wrds/lib/utility/wrdslib.sas';
options sasautos=('/wrds/wrdsmacros/', SASAUTOS) MAUTOSOURCE;
```

This code runs automatically when you've connected to the WRDS cloud. The first line assigns the default library references for you to use, e.g. `comp` for Compustat. The second line makes available the macros. A list of these handy macros is available at the [WRDS documentation](https://wrds-www.wharton.upenn.edu/pages/support/research-wrds/macros/).

If you don't have this SAS code in the home folder, simply create one there or you can choose to include these two lines of code in your remotely submitted code.

## Simple usage

Let's say we want to winsorize a dataset by using the macro provided by WRDS ([full code](https://wrds-www.wharton.upenn.edu/pages/support/research-wrds/macros/wrds-macros-winsorize/)). Below is an example of winsorizing Total Assets `AT` of Compustat sample by fiscal year from 1980 to 2018.

```sas linenums="1"
%let wrds=wrds-cloud.wharton.upenn.edu 4016;
options comamid=TCP remote=WRDS;
signon username=_prompt_;

rsubmit;

/* Create a dataset in the work directory */
data work.funda(keep=gvkey fyear at);
    set comp.funda;
    if 1980 <= fyear <= 2018;
    /* Generic filter */
    if indfmt='INDL' and datafmt='STD' and popsrc='D' and consol='C';
run;

/* Invoke the macro */
/* The documentation is available at:
   https://wrds-www.wharton.upenn.edu/pages/support/research-wrds/macros/wrds-macros-winsorize/ */
%WINSORIZE(INSET=funda,OUTSET=funda_w,SORTVAR=fyear,VARS=at,PERC1=1,TRIM=0);

/* Before the winsorization */
proc means data=work.funda; by fyear; var at; 
output out=funda_before_win min= mean= max= / autoname; run;
/* After the winsorization */
proc means data=work.funda_w; by fyear; var at;
output out=funda_after_win min= mean= max= / autoname; run;

proc print data=funda_before_win;
proc print data=funda_after_win; run;

endrsubmit;
signoff;
```

Invoking the macro is as simple as a single line (line 18 above):

```sas
%WINSORIZE(INSET=funda,OUTSET=funda_w,SORTVAR=fyear,VARS=at,PERC1=1,TRIM=0);
```

However, one thing to note about this particular winsorization macro by WRDS is that a variable named `a` is used in line 57 and 59. So if the `INSET` has a variable named `a` as well, there’ll be possible data integrity issue. Hence, I prefer to use another version described in my other post [Winsorization in SAS](https://mingze-gao.com/posts/winsorization-in-sas/).

## Load SAS macros from URL

I tend to collect and store all useful macros on my personal server, hence I don't need to worry about a loss of or changes to the macros. To use these macros, simply include them before invoking.

```sas
filename winsor url "https://mingze-gao.com/utils/winsor.sas";
%include winsor;
```

Then, I can simply call `winsor` as below.

```sas
%let winsVars = tac inv_at_l drev drevadj ppe roa;
%winsor(dsetin=work.funda, dsetout=work.funda_wins, byvar=fyear, vars=&winsVars, type=winsor, pctl=1 99);
```
