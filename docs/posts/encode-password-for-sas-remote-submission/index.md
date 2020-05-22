# Encode Password for SAS Remote Submission 

The [Wharton Research Data Services (WRDS)](https://wrds-www.wharton.upenn.edu/)
allows one to submit and execute SAS programs to the cloud. WRDS has an
[instruction on accessing WRDS data from SAS on our own
PCs](https://wrds-www.wharton.upenn.edu/pages/support/programming-wrds/programming-sas/sas-from-your-computer/).
Generally, you should use:

```sas
%let wrds=wrds-cloud.wharton.upenn.edu 4016;
options comamid=TCP remote=WRDS;
signon username=_prompt_;

rsubmit;

/* Code for remote execution goes here. */

endrsubmit;
signoff;
```

However, if you want to save the effort of entering username and password every
time, you'll need to [encode your
password](https://wrds-www.wharton.upenn.edu/pages/support/programming-wrds/programming-sas/encoding-your-wrds-password/).
Concluding the two articles, basically you just need to follow the steps below.

## Simple Steps

First, open your SAS program locally on your PC, run the following command
and replace `1234567890` with your WRDS password:

```sas
proc pwencode in="1234567890"; run;
```

The output `{SAS002}23AA9C2811439227077603C8365060A44800CA1F` is the encoded
password (which is `1234567890` in this example).

!!! warning "Do NOT share your SAS program with encoded password!"
    Encoded password functions the same as your plain-text password. You should
    never make public your password in any way.


Next, put the following statements at the beginning of your SAS program and
replace `my_username` with your WRDS username:

```sas
%let wrds=wrds-cloud.wharton.upenn.edu 4016;
options comamid=TCP remote=WRDS;
signon username=my_username password="{SAS002}23AA9C2811439227077603C8365060A44800CA1F";
```

After these statements, you'll be able to submit your SAS program remotely to
and execute on the WRDS server by enclosing your statements with `rsubmit` and
`endrsubmit`. An example would be:

```sas
rsubmit;
proc download data=comp.funda out=funda; run;
endrsubmit;
```

As you can guess, this statement actually downloads the whole Compustat
Fundamentals Annual to the local work directory, with the downloaded dataset
also named `funda`.

Lastly, after everything, you should run `signoff` to close the connection with
WRDS.

Full code is as below.

```sas
%let wrds=wrds-cloud.wharton.upenn.edu 4016;
options comamid=TCP remote=WRDS;
signon username=my_username password="{SAS002}23AA9C2811439227077603C8365060A44800CA1F";

rsubmit;
proc download data=comp.funda out=funda; run;
endrsubmit;
signoff;
```

Replace `my_username` and the encoded password with your actual WRDS username
and encoded password, paste it in the SAS program editor and press `F3`. You'll
be downloading `comp.funda` in a few seconds!

## Video Instruction

I made a short video introduction as well, available on my YouTube channel.

<iframe width="560" height="315" src="https://www.youtube.com/embed/XB3kd1LNJbI"
frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope;
picture-in-picture" allowfullscreen></iframe>

