---
title: Estimate Organization Capital
date: 2022-01-09
tags:
- Code
- SAS
categories:
- Research Notes
---

This post explains the estimation of organization capital [@gao_organization_2021]. As in @eisfeldt_organization_2013, we obtain firm-year accounting data from the Compustat and compute the stock of organization capital for firms using the perpetual inventory method that recursively calculates the stock of OC by accumulating the deflated value of SG&A expenses.

<!-- more -->

## Organization Capital

$$
OC_{i,t} = (1-\delta_{OC})OC_{i,t-1} + \frac{SGA_{i,t}}{CPI_t}
$$ {#eq-organization-capital}

where $SGA_{i,t}$ is firm $i$'s SG&A expenses in year $t$, $CPI_t$ is the consumer price index, and $\delta_{OC}$ is the depreciation rate of OC stock, which is set to be 15% as used by the U.S. Bureau of Economic Analysis (BEA). The initial value of OC stock is set to:

$$
OC_{i,0} = \frac{SGA_{i,1}}{g+\delta_{OC}}
$$ {#eq-organization-capital-inital-value}

where $g$ is the average real growth rate of firm-level SG&A expenses, which is 10% in @eisfeldt_organization_2013 or specific for an industry-decade in @li_organization_2018.

## Code

This code estimates the organization capital for all Compustat firm-years.

Note that it requires an external dataset of CPI. You need to name it `cpiaucsl` and store it in your WRDS home directory.

<script src="https://gist.github.com/mgao6767/3ad7c19f1dc621e4d22a49c383249d3b.js"></script>

Lastly, if you use this code above, please consider citing the following article for which it was written.

> Gao, M. Leung, H. and Qiu, B. (2021). Organization Capital and Executive Performance Incentives, *Journal of Banking & Finance*, 123, 106017.
