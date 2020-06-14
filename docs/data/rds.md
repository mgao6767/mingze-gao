# RDS - deprecated

!!! warning 
    This research data service has been deprecated and will be merged into 
    [frds - financial research data services](https://github.com/mgao6767/frds).

A database of market microstructure measures.

***Proof-of-concept*** joint work with [Prof. Joakim
Westerholm](https://business.sydney.edu.au/staff/joakim.westerholm) and [Dr.
Henry Leung](https://business.sydney.edu.au/staff/henry.leung).

Our objective is to construct and maintain a database of market micriostructure
measures based on high-frequency tick history sourced from [Refinitiv Thomson
Reuters Tick History](http://solutions.refinitiv.com/RefinitivTickHistory).

## Example Usage

I provide an easy-to-use SQL interface for researchers to retrieve the data.
Below is an example usage in SAS.

Currently, you'll need to be inside the USYD's network to use RDS. You can
either use a PC inside the Business School or use VPN.

```SAS linenums="1"
/* Assign lib reference to connect to the server. */
libname rds mysql 
	server="asgard.econ.usyd.edu.au" database=rds 
	user=actualusername password=actualpassword;
```

If you enconter this error:

> ERROR: The SAS/ACCESS Interface to MYSQL cannot be loaded. The libmysql code
> appendage could not be loaded.

Solution is here http://support.sas.com/kb/19/250.html.

Let's now use RDS to get a collection of measures estimated.

```SAS linenums="1"
/* Some example usage. */
/* More measures and complete documentaion to come. */
proc sql;
/* Retrieve the full table of estimated measures. */
create table measures as select * from rds.measures 
	order by local_date asc, RIC asc;

/* Retrieve all Bid-Ask Spread estimates. */
create table baspread as select * from rds.bidaskspread;

/* Retrieve all Effective Spread estimates for RIC=AAL.OQ. */
create table espread as select * from rds.effectivespread 
	where RIC='AAL.OQ';

/* Retrieve all Realized Spread estimates from 2019-01-01 to 2019-01-15. */
create table rspread as select * from rds.realizedspread 
	where local_date between "01Jan2019"d and "15Jan2019"d;

/* Retrieve all LinSangerBooth1995 estimates of adverse selection. */
create table lsb1995 as select * from rds.measures
	where measure="LinSangerBooth1995";

quit;
```
Let's try plot a timeseries to prove it works.

```SAS linenums="1"
/* Simple timeseries plot */
title "Timeseries Plot of Realized Spread For USB.N and AIG.N";
proc sgplot data=measures;
	where measure="RealizedSpread" & (RIC="USB.N" | RIC="AIG.N");
	series x=local_date y=estimate /markers group=RIC;
	refline 0/axis=y;
run;
```

The output is:

![Example Timeseries Plot](https://mingze-gao.com/images/AMG-demo-timeseries-plot.png)


## Technology Stack

I wrote this system in Python and C/C++. A workstation of an 8-core 16-thread
CPU, 64GB RAM and m.2. SSDs is used.

![Example Usage](https://mingze-gao.com/images/AMG-demo.gif)

> Behind the scene, the program classifies trade directions using Lee and Ready
> (1991) algorithm on the fly, and estimates several measures for each security
> and each day.

Results are stored in a MySQL database inside the university network, but may be
stored and served at AWS in the future.

## Development Plan

We plan to continue the development of this project and:

- cover more measures, securities and extend the data period;
- provide an easy-to-use web interface apart from the SQL interface;
- provide a REST API for more efficient and professional usage.


## Disclaimer

> This project may contain errors. Users are recommended to double check the
> data quality before usage. We hold no responsibility for any damage and/or
> loss incurred as a result of using any data provided on this site. We may
> provide the source code for selected measures and encourage users to check it
> for correctness and accuracy.

> If there is any bug and/or error, please contact me at
> [mingze.gao@sydney.edu.au](mailto:mingze.gao@sydney.edu.au).


## Contact

- Mingze Gao: [mingze.gao@sydney.edu.au](mailto:mingze.gao@sydney.edu.au).
- Henry Leung: [henry.leung@sydney.edu.au](mailto:henry.leung@sydney.edu.au).
- Joakim Westerholm: [joakim.westerholm@sydney.edu.au](mailto:joakim.westerholm@sydney.edu.au).