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