---
date: 2020-05-27
authors:
    - mgao
updatedDate: Feb 24, 2023
tags:
    - Textual Analysis
    - SEC
    - Python
    - Code
categories:
  - Research Notes
links:
  - Download SEC filings from EDGAR: https://mingze-gao.com/posts/download-sec-filings-from-edgar/
---

# Textual Analysis on SEC Filings

Nowadays top journals favour more granular studies. Sometimes it's useful to dig into the raw SEC filings and perform textual analysis. This note documents how I download all historical SEC filings via EDGAR and conduct some textual analyses.

<!-- more -->

!!! tip 
    If you don't require a very customized textual analysis, you should try
    for example [SeekEdgar.com](https://www.seekedgar.com/).

!!! tip "Ready-to-use program"
    (2023 update) I've made [a program specifically for downloading SEC filings from EDGAR](/posts/download-sec-filings-from-edgar/). So you can now skip the steps 1 and 2 below.

## 1. Build a master index of SEC filings

I use the [`python-edgar`](https://github.com/edouardswiac/python-edgar/) to
download quarterly zipped index files to `./edgar-idx`.

```bash
$ mkdir ~/edgar && cd ~/edgar
$ git clone https://github.com/edouardswiac/python-edgar.git
$ python ./python-edgar/run.py -d ./edgar-idx
```

Then merge the downloaded tsv files into a master file using `cat`.

```bash
$ cat ./edgar-idx/*.tsv > ./edgar-idx/master.tsv
$ du -h ./edgar-idx/master.tsv
```

The resulting `master.tsv` is about 2.6G as at Feb 2020. I then use the
following python script to build a SQLite database for more efficient query.

```python
# Load index files in `edgar-idx` to a sqlite database.

import sqlite3

EDGAR_BASE = "https://www.sec.gov/Archives/"

def parse(line):
    # each line: "cik|firm_name|file_type|date|url_txt|url_html"
    # an example:
    # "99780|TRINITY INDUSTRIES INC|8-K|2020-01-15|edgar/data/99780/0000099780-\
    # 20-000008.txt|edgar/data/99780/0000099780-20-000008-index.html"
    line = tuple(line.split('|')[:5])
    l = list(line)
    l[-1] = EDGAR_BASE + l[-1]
    return tuple(l)

if __name__ == '__main__':
    conn = sqlite3.connect(r"edgar-idx.sqlite3")
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS edgar_idx 
        (cik TEXT, firm_name TEXT, file_type TEXT, date DATE, url TEXT,
        PRIMARY KEY(cik, file_type, date));''')

    filename = './edgar-idx/master.tsv'
    with open(filename, 'r') as f:
        lines = f.readlines()

    data = [parse(line) for line in lines]
    c.executemany('INSERT OR IGNORE INTO edgar_idx \
        (cik, firm_name, file_type, date, url) VALUES (?,?,?,?,?)', data)

    conn.commit()
    conn.close()
```

## 2. Download filings from EDGAR

I write the following script to download filings from EDGAR. Note that this
script is only a skeleton. The full implementation has proper logging, speed
control and detailed error handling. For example, you'll need to keep track of
failures and re-download them later. 

!!! warning 
    As per SEC's policy, you should limit concurrent requests to below
    10 per second. Hence, there is no need to use a proxy pool, such as
    [`Scylla`](https://github.com/imWildCat/scylla). 

    This example script download all 8-K files to `./data/{cik}/{file_type}/{date}.txt.gz`.
    
    Compression is highly recommended unless you've TBs of free disk space!

```python
# Download all 8-K filings.

import os
import sqlite3
import requests
import concurrent.futures
import gzip
import tqdm

def download(job):
    cik, _, file_type, date, url = job
    try:
        res = requests.get(url)
        filename = f'./data/{cik}/{file_type}/{date}.txt.gz'
        if res.status_code == 200:
            with gzip.open(filename, 'wb') as f:
                f.write(res.content)
    except Exception:
        pass

if __name__ == "__main__":
    # select what to download
    conn = sqlite3.connect(r"edgar-idx.sqlite3")
    c = conn.cursor()
    c.execute('SELECT * FROM edgar_idx WHERE file_type="8-K";')
    jobs = c.fetchall()
    conn.close()
    # start downloading
    progress = tqdm.tqdm(total=len(jobs))
    futures = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=16) as exe:
        for job in jobs:
            cik, _, file_type, date, url = job
            filename = f'./data/{cik}/{file_type}/{date}.txt.gz'
            os.makedirs(os.path.dirname(filename), exist_ok=True)
            if os.path.exists(filename):
                progress.update()
            else:
                f = exe.submit(download, job)
                f.add_done_callback(progress.update)
                futures.append(f)
    for f in concurrent.futures.as_completed(futures):
        pass
```

## 3. Example textual analyses

The downloaded txt files are the text version of filings htmls, which generally
are well structured. Specifically, each filing is structured as:

```html
<SEC-DOCUMENT>
  <SEC-HEADER></SEC-HEADER>
  <DOCUMENT>
    <TYPE>
      <SEQUENCE>
        <FILENAME>
          <DESCRIPTION>
            <TEXT>
            </TEXT>
          </DESCRIPTION>
        </FILENAME>
      </SEQUENCE>
    </TYPE>
  </DOCUMENT>
  <DOCUMENT></DOCUMENT>
  <DOCUMENT></DOCUMENT>
  ...
</SEC-DOCUMENT>
```

??? example 
    ```html
    <SEC-DOCUMENT>
        <SEC-HEADER></SEC-HEADER>
        <DOCUMENT>
            <TYPE>8-K
                <SEQUENCE>1
                    <FILENAME>f13478e8vk.htm
                        <DESCRIPTION>FORM 8-K
                            <TEXT>
                            ...
                            </TEXT>
                        </DESCRIPTION>
                    </FILENAME>
                </SEQUENCE>
            </TYPE>
        </DOCUMENT>
        <DOCUMENT>
            <TYPE>EX-99.1
                <SEQUENCE>2
                    <FILENAME>f13478exv99w1.htm
                        <DESCRIPTION>EXHIBIT 99.1
                            <TEXT>
                            ...
                            </TEXT>
                        </DESCRIPTION>
                    </FILENAME>
                </SEQUENCE>
            </TYPE>
        </DOCUMENT>
        <DOCUMENT></DOCUMENT>
        ...
    </SEC-DOCUMENT>
    ```

### 3.1 Extract all items reported in 8-K filings since 2004

Since 2004, SEC requires companies to file 8-K within 4 business days of many
types of events. For a short description, see [SEC's fast answer to Form
8-K](https://www.sec.gov/fast-answers/answersform8khtm.html). The detailed
instruction (PDF) is available at
[here](https://www.sec.gov/about/forms/form8-k.pdf).

To extract all items reported in each filing since 2004, there are several ways.
First, I can use a regular expression to extract all `"Item X.XX"` from the 8-K
`<DOCUMENT>`. Or, I can take advantage of the information in `<SEC-HEADER>`.
Below is an example `<SEC-HEADER>`[^1], of which the lines of `ITEM INFORMATION`
actually describe the items reported in the filing. 

[^1]: The original file is at
https://www.sec.gov/Archives/edgar/data/0000008192/0000079732-02-000036.txt

```html
<SEC-HEADER>0000079732-02-000036.hdr.sgml : 20020802
<ACCEPTANCE-DATETIME>20020802082752
ACCESSION NUMBER:		0000079732-02-000036
CONFORMED SUBMISSION TYPE:	8-K
PUBLIC DOCUMENT COUNT:		4
CONFORMED PERIOD OF REPORT:	20020801
ITEM INFORMATION:		Changes in control of registrant
ITEM INFORMATION:		Financial statements and exhibits
FILED AS OF DATE:		20020802

FILER:

	COMPANY DATA:	
		COMPANY CONFORMED NAME:			ATLANTIC CITY ELECTRIC CO
		CENTRAL INDEX KEY:			0000008192
		STANDARD INDUSTRIAL CLASSIFICATION:	ELECTRIC SERVICES [4911]
		IRS NUMBER:				210398280
		STATE OF INCORPORATION:			NJ
		FISCAL YEAR END:			1231

	FILING VALUES:
		FORM TYPE:		8-K
		SEC ACT:		1934 Act
		SEC FILE NUMBER:	001-03559
		FILM NUMBER:		02717802

	BUSINESS ADDRESS:	
		STREET 1:		800 KING STREET
		STREET 2:		PO BOX 231
		CITY:			WILMINGTON
		STATE:			DE
		ZIP:			19899
		BUSINESS PHONE:		6096454100

	MAIL ADDRESS:	
		STREET 1:		800 KING STREET
		STREET 2:		PO BOX 231
		CITY:			WILMINGTON
		STATE:			DE
		ZIP:			19899
</SEC-HEADER>
```

Following this strategy, I write the code below to extract all items reported in
8-K filings since 2004. I didn't use regex for this task because the text
portion of the filing is actually dirty. For instance, you'll need to remove all
html tags, and be careful about the "non-breaking space", `&nbsp;`, etc. My
experience is that using `<SEC-HEADER>` for this task is the best.

```python
# Extract all items reported in 8-K filings since 2004.
import os
import gzip
import tqdm
import sqlite3
import concurrent.futures


BASE_DIR = './data'
FILE_TYPE = '8-K'
DB = "result.sqlite3"


def walk_dirpath(cik, file_type):
    """ Yield paths of all files for a given cik and file type """
    for root, _, files in os.walk(os.path.join(BASE_DIR, cik, file_type)):
        for filename in files:
            yield os.path.join(root, filename)


def regsearch(cik):
    matches = []
    for filepath in walk_dirpath(cik, FILE_TYPE):
        date = os.path.split(filepath)[1].strip('.txt.gz')
        if int(date.split('-')[0]) < 2004:
            continue
        with gzip.open(filepath, 'rb') as f:
            data = f.readlines()
        ls = [l for l in data if l.startswith(b'ITEM INFORMATION')]
        for l in ls:
            item = l.decode().replace('\t','').replace('ITEM INFORMATION:', '')
            if len(item.strip()):
                matches.append((cik, FILE_TYPE, date, item.strip()))
    return matches


if __name__ == "__main__":
    conn = sqlite3.connect(DB)
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS files_all_items
        (cik TEXT, file_type TEXT, date DATE, item TEXT,
        PRIMARY KEY(cik, file_type, date, item));''')
    conn.commit()

    _, ciks, _ = next(os.walk(BASE_DIR))
    progress = tqdm.tqdm(total=len(ciks))
    with concurrent.futures.ProcessPoolExecutor(max_workers=16) as exe:
        futures = [exe.submit(regsearch, cik) for cik in ciks]
        for f in concurrent.futures.as_completed(futures):
            res = f.result()
            c.executemany(
                "INSERT OR IGNORE INTO files_all_items \
                    (cik, file_type, date, item) VALUES (?,?,?,?)", res)
            conn.commit()
            progress.update()

    conn.close()
```

### 3.2 Find all 8-K filings with Item 1.01 and/or Item 2.03

To get those filings that have *either*:

* Item 1.01 Entry into a Material Definitive Agreement, or
* Item 2.03 Creation of a Direct Financial Obligation or an Obligation under an
  Off-Balance Sheet Arrangement of a Registrant

I run the following SQL query:

```SQL
-- SQLite
CREATE TABLE `files_with_items_101_or_203` AS
SELECT DISTINCT cik, file_type, date
FROM `files_all_items`
WHERE
    instr(lower(item), "creation of a direct financial obligation") > 0 OR
    instr(lower(item), "entry into a material definitive agreement") > 0
ORDER BY cik, file_type, date;
```

To get those with *both* items, use the following query:

```SQL
-- SQLite
CREATE TABLE `files_with_items_101_and_203` AS
SELECT cik, file_type, date
FROM `files_all_items`
WHERE
    instr(lower(item), "creation of a direct financial obligation") > 0 OR
    instr(lower(item), "entry into a material definitive agreement") > 0
GROUP BY cik, file_type, date
HAVING count(*) > 1
ORDER BY cik, file_type, date;
```

### 3.3 Nini, Smith and Sufi (2009)

This example code finds the appearance of any of the 10 search words used in
"Creditor control rights and firm investment policy" by Nini, Smith and Sufi
(JFE 2009), which is used to identify the loan contracts as attached in the SEC
filing.

```Python
import re
import os
import sys
import gzip
import tqdm
import sqlite3
import logging
import concurrent.futures

logging.basicConfig(stream=sys.stdout, level=logging.WARN)

BASE_DIR = './data'
FILE_TYPE = '10-Q'
DB = "result.sqlite3"

# Regex pattern used to remove html tags
cleanr = re.compile(b'<.*?>|&([a-z0-9]+|#[0-9]{1,6}|#x[0-9a-f]{1,6});')

# Regex pattern used to find the appearance of any of the 10 search words used
# in "Creditor control rights and firm investment policy"
# by Nini, Smith and Sufi (JFE 2009)
# pat_10_words = r"CREDIT FACILITY|REVOLVING CREDIT|(CREDIT|LOAN|(LOAN (AND|&) \
#    SECURITY)|(FINANCING (AND|&) SECURITY)|CREDIT (AND|&) GUARANTEE) AGREEMENT"
NSS_10_words = ['credit facility',
                'revolving credit',
                'credit agreement',
                'loan agreement',
                'loan and security agreement',
                'loan & security agreement',
                'credit and guarantee agreement',
                'credit & guarantee agreement',
                'financing and security agreement',
                'financing & security agreement']
NSS_10_words_str = '|'.join([word.upper() for word in NSS_10_words])
pat_10_words = re.compile(NSS_10_words_str.encode())

# Regex pattern used in this search
pattern = pat_10_words


def walk_dirpath(cik, file_type):
    """ Yield paths of all files for a given cik and file type """
    for root, _, files in os.walk(os.path.join(BASE_DIR, cik, file_type)):
        for filename in files:
            yield os.path.join(root, filename)


def regsearch(cik):
    matches = []
    for filepath in walk_dirpath(cik, FILE_TYPE):
        date = os.path.split(filepath)[1].strip('.txt.gz')
        try:
            with gzip.open(filepath, 'rb') as f:
                data = b' '.join(f.read().splitlines())
                data = re.sub(cleanr, b'', data)
            match = pattern.search(data)
            if match:
                matches.append((cik, FILE_TYPE, date))
                logging.info(f'{filepath}, {match.group()}')
        except Exception as e:
            logging.error(f'failed at {filepath}, {e}')
    return matches


if __name__ == "__main__":

    conn = sqlite3.connect(DB)
    c = conn.cursor()
    # create a table to store the indices
    c.execute('''CREATE TABLE IF NOT EXISTS files_with_10_words
        (cik TEXT, file_type TEXT, date DATE,
        PRIMARY KEY(cik, file_type, date));''')
    conn.commit()
    _, ciks, _ = next(os.walk(BASE_DIR))
    progress = tqdm.tqdm(total=len(ciks))
    with concurrent.futures.ProcessPoolExecutor(max_workers=16) as exe:
        futures = [exe.submit(regsearch, cik) for cik in ciks]
        for f in concurrent.futures.as_completed(futures):
            matches = f.result()
            c.executemany(
                "INSERT OR IGNORE INTO files_with_10_words \
                    (cik, file_type, date) VALUES (?,?,?)", matches)
            conn.commit()
            progress.update()
    conn.close()
    logging.info('complete')
```
