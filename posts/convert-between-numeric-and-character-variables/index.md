---
date: 2020-05-22
tags:
    - SAS
    - Stata
    - Code
categories:
  - Programming
---

# Convert Between Numeric and Character Variables

Converting between numeric and character variables is one of the most frequently
encountered issues when processing datasets. This article explains how to do
this conversion correctly and efficiently.

<!-- more -->

## Numeric to Character

Assume there's an imported dataset named `filings`, where `cik` is stored as a
numeric variable as shown below:

| cik     | file_type | date       |
| ------- | --------- | ---------- |
| 1000229 | 8-K       | 2011-09-30 |
| 100591  | 8-K       | 2006-05-11 |
| 100826  | 8-K       | 2009-06-30 |
| 93542   | 8-K       | 2007-01-25 |

Because `cik` is of different digits, to convert the numeric `cik` into a
character variable, the natural procedure is to pad it with leading zeros. For
example, `cik` (Central Index Key) itself is a 10-digit number used by SEC.

In SAS, convert numeric variable to string with leading zeros (assuming 10-digit
fixed length) is done via `PUT()` function:

```sas
data filings(drop=cik); set filings;
    cik_char = put(cik, z10.); 
run;
```

!!! tip
    `PUT()` function also works in `PROC SQL`.

The generated `cik_char` variable is of format and informat `$10.`, and the
dataset becomes:

| cik_char   | file_type | date       |
| ---------- | --------- | ---------- |
| 0001000229 | 8-K       | 2011-09-30 |
| 0000100591 | 8-K       | 2006-05-11 |
| 0000100826 | 8-K       | 2009-06-30 |
| 0000093542 | 8-K       | 2007-01-25 |

In STATA, convert numeric variable to string with leading zeros (assuming
6-digit fixed length) can be achieved via the `string()` function.

```stata
gen char_var = string(num_var,"%06.0f")
```

## Character to Numeric

In SAS, converting a character variable to a numeric one uses the `INPUT()`
function:

```sas
var_numeric = input(var_char, best12.);
```

In STATA, this conversion be can be done via either `real()` function or
`destring` command.

```stata
gen num_var = real(char_var);
```

The `real()` function works on a single variable. `destring` command can convert
all character variables into numeric in one go.

```stata
destring, repalce
```

!!! warning
    If a character variable has non-numeric characters in it, then it will not be
    converted. In such a case, you may choose to use the `encode` command,
    although it in fact is generating categories.
    
A more detailed explanation with examples is available at
[stats.idre.ucla.edu](https://stats.idre.ucla.edu/stata/faq/how-can-i-quickly-convert-many-string-variables-to-numericvariables/)
