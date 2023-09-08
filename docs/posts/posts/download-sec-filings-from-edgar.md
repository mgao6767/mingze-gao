---
date: 2023-09-08 
categories:
  - Research Notes
  - Programming
tags:
  - SEC
  - EDGAR
  - Textual Analysis
  - Python
  - Code
links:
  - Textual Analysis on SEC filings: /posts/textual-analysis-on-sec-filings/
---

# Download SEC Filings from EDGAR

This post documents how to download SEC filings from EDGAR using [`edgar-analyzer`](https://github.com/mgao6767/edgar-analyzer), a Python program I wrote. It features:

- [x] 3 commands only to download any type of filings for any period of time
- [x] auto throttling of download speed to adhere to the SEC policy of fair use

<!-- more -->

## Install `edgar-analyzer`

```python
pip install edgar-analyzer
```

!!! warning
    EDGAR has [limitations on the download speed](https://www.sec.gov/os/accessing-edgar-data). While the program tries its best to adhere to the requirements, it may accidentally go above the limit, resulting a temporary or even permanent ban. Please use at your own risk.

## Download index files

EDGAR started in 1994/1995. EDGAR provides quarterly index files since 1993Q1 (1) which contain the firm CIK, name, filing date, type, and URL of the filing.
{ .annotate }

1. The number of filings in 1993 is close to zero so we can start from 1994.

We will use these index files to build a database so that we can more efficiently download the filings of our choice.

Further, EDGAR now requires download requests to supply identity info. We need to specify our name/institution and contact email in user agent. Otherwise, none of requests will work.

Then, run the following command. Notice that we specify the beginning year as 2010 and output directory as "index" in the current working directory.

```bash
edgar-analyzer download_index --user_agent "MyCompany name@mycompany.com" --output "./index" -b 2010
```

After the index files are downloaded, we build a database of the index files for more efficient queries.

```bash
edgar-analyzer build_database --inputdir "./index" --database "edgar-idx.sqlite3"
```

As at September 2023, the database's size is about 3GB.

## Download filings

Now we get to the actual filings download using the following command. Note that here we have specified to download 10-K filings using 4 threads.

```bash
edgar-analyzer download_filings --user_agent "MyCompany name@mycompany.com" --output "./output" --database "edgar-idx.sqlite3" --file_type "10-K" -t 4
```

Some extra notes:

- Only filings not downloaded yet will be downloaded. This ensures that we do not repeatedly download the same filings multiple times if we restart the program.
- Download speed will be auto throttled as per SEC's fair use policy, irrespective of the number of threads specified. Multithreading beyond certain number will not increase download speed any further.

!!! tip
    You can always use `edgar-analyzer [subcommand] --help` to check the docs.

## Extras

The program additionally has some subcommands to perform certain textual analyses.

Just a simple example of the job `find_event_date`. Based on the 1,491,368 8K filings (2004-2022), the table below shows the reporting lags (date of filing minus date of event). 

We can find that _most_ filings are filed on the same day as the event reported, and that over 99.99% of filings are filed within 4 calendar days (SEC requires 4 business days).

| Filing lag   (calendar days) | Frequency | Percentage | Cumulative |
| ---------------------------- | --------- | ---------- | ---------- |
| 0                            | 1470089   | 98.57%     | 98.57%     |
| 1                            | 20761     | 1.39%      | 99.97%     |
| 2                            | 285       | 0.02%      | 99.98%     |
| 3                            | 89        | 0.01%      | 99.99%     |
| 4                            | 47        | 0.00%      | 99.99%     |
| 5                            | 26        | 0.00%      | 100.00%    |
| 6                            | 14        | 0.00%      | 100.00%    |
| 7                            | 6         | 0.00%      | 100.00%    |
| 8                            | 4         | 0.00%      | 100.00%    |
| 9                            | 3         | 0.00%      | 100.00%    |
| 10 or more                   | 44        | 0.00%      | 100.00%    |

!!! note
    This tool is a work in progress and breaking changes may be expected.
