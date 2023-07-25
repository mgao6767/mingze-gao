---
authors:
    - mgao
date: 2020-05-26
categories:
    - Programming
tags:
    - SAS
    - Code
    - WRDS
---

# Winsorization in SAS

These are two versions of winsorization in SAS, of which I recommend the first one.

<!-- more -->

## Version 1 (Unknown Author)

```SAS linenums="1"
/*****************************************
Author unknown - that is a pity because this macro is the best since sliced bread! 
Trim or winsorize macro
* byvar = none for no byvar;
* type  = delete/winsor (delete will trim, winsor will winsorize;
*dsetin = dataset to winsorize/trim;
*dsetout = dataset to output with winsorized/trimmed values;
*byvar = subsetting variables to winsorize/trim on;
Sample usage:
%winsor(dsetin=work.myDsetIn, byvar=fyear, 
        dsetout=work.myDsOut, vars=btm roa roe, type=winsor, pctl=1 99);
****************************************/
 
%macro winsor(dsetin=, dsetout=, byvar=none, vars=, type=winsor, pctl=1 99);
 
%if &dsetout = %then %let dsetout = &dsetin;
    
%let varL=;
%let varH=;
%let xn=1;
 
%do %until ( %scan(&vars,&xn)= );
    %let token = %scan(&vars,&xn);
    %let varL = &varL &token.L;
    %let varH = &varH &token.H;
    %let xn=%EVAL(&xn + 1);
%end;
 
%let xn=%eval(&xn-1);
 
data xtemp;
    set &dsetin;
    run;
 
%if &byvar = none %then %do;
 
    data xtemp;
        set xtemp;
        xbyvar = 1;
        run;
 
    %let byvar = xbyvar;
 
%end;
 
proc sort data = xtemp;
    by &byvar;
    run;
 
proc univariate data = xtemp noprint;
    by &byvar;
    var &vars;
    output out = xtemp_pctl PCTLPTS = &pctl PCTLPRE = &vars PCTLNAME = L H;
    run;
 
data &dsetout;
    merge xtemp xtemp_pctl;
    by &byvar;
    array trimvars{&xn} &vars;
    array trimvarl{&xn} &varL;
    array trimvarh{&xn} &varH;
 
    do xi = 1 to dim(trimvars);
 
        %if &type = winsor %then %do;
            if not missing(trimvars{xi}) then do;
              if (trimvars{xi} < trimvarl{xi}) then trimvars{xi} = trimvarl{xi};
              if (trimvars{xi} > trimvarh{xi}) then trimvars{xi} = trimvarh{xi};
            end;
        %end;
 
        %else %do;
            if not missing(trimvars{xi}) then do;
              if (trimvars{xi} < trimvarl{xi}) then delete;
              if (trimvars{xi} > trimvarh{xi}) then delete;
            end;
        %end;
 
    end;
    drop &varL &varH xbyvar xi;
    run;
 
%mend winsor;
```

## Version 2 (WRDS)

A potential problem with this WRDS macro is that a variable named `a` is used in line 57 and 59 (highlighted below). So if the `INSET` has a variable named `a` as well, there’ll be possible data integrity issue.

??? example "`WINSORIZE` macro"
    ```SAS linenums="1" hl_lines="57 59"
    /* ********************************************************************************* */
    /* ******************** W R D S   R E S E A R C H   M A C R O S ******************** */
    /* ********************************************************************************* */
    /* WRDS Macro: WINSORIZE                                                             */
    /* Summary   : Winsorizes or Trims Outliers                                          */
    /* Date      : April 14, 2009                                                        */
    /* Author    : Rabih Moussawi, WRDS                                                  */
    /* Variables : - INSET and OUTSET are input and output datasets                      */
    /*             - SORTVAR: sort variable used in ranking                              */
    /*             - VARS: variables to trim and winsorize                               */
    /*             - PERC1: trimming and winsorization percent, each tail (default=1%)   */
    /*             - TRIM: trimming=1/winsorization=0, default=0                         */
    /* ********************************************************************************* */
    
    %MACRO WINSORIZE (INSET=,OUTSET=,SORTVAR=,VARS=,PERC1=1,TRIM=0);
    
    /* List of all variables */
    %let vars = %sysfunc(compbl(&vars));
    %let nvars = %nwords(&vars);
    
    /* Display Output */
    %put ### START.;
    
    /* Trimming / Winsorization Options */
    %if &trim=0 %then %put ### Winsorization; %else %put ### Trimming;
    %put ### Number of Variables:  &nvars;
    %put ### List   of Variables:  &vars;
    options nonotes;
    
    /* Ranking within &sortvar levels */
    %put ### Sorting... ;
    proc sort data=&inset; by &sortvar; run;
    
    /* 2-tail winsorization/trimming */
    %let perc2 = %eval(100-&perc1);
    
    %let var2 = %sysfunc(tranwrd(&vars,%str( ),%str(__ )))__;
    %let var_p1 = %sysfunc(tranwrd(&vars,%str( ),%str(__&perc1 )))__&perc1 ;
    %let var_p2 = %sysfunc(tranwrd(&vars,%str( ),%str(__&perc2 )))__&perc2 ;
    
    /* Calculate upper and lower percentiles */
    proc univariate data=&inset noprint;
    by &sortvar;
    var &vars;
    output out=_perc pctlpts=&perc1 &perc2 pctlpre=&var2;
    run;
    
    %if &trim=1 %then
    %let condition = %str(if myvars(i)>=perct2(i) or myvars(i)<=perct1(i) then myvars(i)=. );
    %else %let condition = %str(myvars(i)=min(perct2(i),max(perct1(i),myvars(i))) );
    
    %if &trim=0 %then %put ### Winsorizing at &perc1.%... ;
    %else %put ### Trimming at &perc1.%... ;
    
    /* Save output with trimmed/winsorized variables */
    data &outset;
    merge &inset (in=a) _perc;
    by &sortvar;
    if a;
    array myvars {&nvars} &vars;
    array perct1 {&nvars} &var_p1;
    array perct2 {&nvars} &var_p2;
    do i = 1 to &nvars;
        if not missing(myvars(i)) then
        do;
        &condition;
        end;
    end;
    drop i &var_p1 &var_p2;
    run;
    
    /* House Cleaning */
    proc sql; drop table _perc; quit;
    options notes;
    
    %put ### DONE . ; %put ;
    
    %MEND WINSORIZE;
    
    /* ********************************************************************************* */
    /* *************  Material Copyright Wharton Research Data Services  *************** */
    /* ****************************** All Rights Reserved ****************************** */
    /* ********************************************************************************* */
    ```