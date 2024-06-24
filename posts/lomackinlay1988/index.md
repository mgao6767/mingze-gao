---
title: Variance Ratio Test - Lo and MacKinlay (1988)
date: 2020-05-26
# date-modified: 2021-03-04
date-modified: 2023-08-23
slug: lomackinlay1988
format:
  html:
    code-line-numbers: true
code-annotations: hover
tags:
    - Python
    - Code
categories:
    - Teaching Notes
---

A simple test for the random walk hypothesis of prices and efficient market.

<!-- more -->

## Definition

Let's assume:

- a price series $\{p_t\}=\{p_0,p_1,p_2,...,p_T\}$ and
- a log return series $\{x_t\}=\{x_1, x_2, ..., x_T\}$ where $x_t=\ln \frac{p_t}{p_{t-1}}$

### Variance Ratio (VR)

The **variance ratio** of $k$-period return is defined as:

$$
\begin{equation}
\textit{V}(k)=\frac{\textit{Var}(x_t+x_{t-1}+...+x_{t-k+1})/k}{\textit{Var}(x_t)}
\end{equation}
$$

The estimator of $\textit{V}(k)$ proposed in Lo and MacKinlay (1988) is

$$
\begin{equation}
\textit{VR}(k)=\frac{\hat\sigma^2(k)}{\hat\sigma^2(1)}
\end{equation}
$$

where $\hat\sigma^2(1)$ is the unbiased estimator of the one-period return variance, using the one-period returns $\{x_t\}$, and is defined as

$$
\begin{equation}
\hat\sigma^2(1)=\frac{1}{T-1} \sum_{t-1}^T (x_t - \hat\mu)^2
\end{equation}
$$

and $\hat\sigma^2(k)$ is the estimator of $k$-period return variance using $k$-period returns. Lo and MacKinlay (1988) defined it, due to limited sample size and the desire to improve the power of the test, as

$$
\begin{equation}
\hat\sigma^2(k)=\frac{1}{m} \sum_{t-1}^T \left(\ln\frac{P_t}{P_{t-k}} - k\hat\mu \right)^2
\end{equation}
$$

where $m=k(T-k+1)(1-k/T)$ is chosen such that $\hat\sigma^2(k)$ is an unbiased estimator of the $k$-period return variance when $\sigma^2_t$ is constant over time.

### Variance Ratio Test Statistics

Lo and MacKinlay (1988) proposed that under the null hypothesis of $V(k)=1$, the test statistic is given by

$$
\begin{equation}
Z(k)=\frac{\textit{VR}(k)-1}{\sqrt{\phi(k)}}
\end{equation}
$$

which follows the standard normal distribution asymptotically.

#### Homoscedasticity

Under the assumption of homoscedasticity, the asymptotic variance $\phi$ is given by

$$
\begin{equation}
\phi(k)=\frac{2(2k-1)(k-1)}{3kT}
\end{equation}
$$

#### Heteroscedasticity

Under the assumption of heteroscedasticity, the asymptotic variance $\phi$ is given by

$$
\begin{equation}
\phi(k)=\sum_{j=1}^{k-1} \left[\frac{2(k-j)}{k} \right]^2\delta(j)
\end{equation}
$$

$$
\begin{equation}
\delta(j)=\frac{\sum_{t=j+1}^T (x_t - \hat\mu)^2(x_{t-j} - \hat\mu)^2}{\left[\sum_{t=1}^T (x_t - \hat\mu)^2\right]^2}
\end{equation}
$$

::: {.callout-warning title="Erratum"}

Note that there's a missing $T$ in the numerator of $\delta(j)$ of Equation (8). It is actually missing the 1988 RFS paper and the 1998 JE'mtric paper, but has been corrected in the 1990 RFS Issue 1: [https://doi.org/10.1093/rfs/3.1.ii](https://doi.org/10.1093/rfs/3.1.ii). The corrected version reads:

$$
\begin{equation}
\delta(j)=\frac{T\sum_{t=j+1}^T (x_t - \hat\mu)^2(x_{t-j} - \hat\mu)^2}{\left[\sum_{t=1}^T (x_t - \hat\mu)^2\right]^2}
\end{equation}
$$

To correct it in the example code below, change the line 51 below to:

```python
delta_arr = T * b_arr / np.square(np.sum(sqr_demeaned_x))
```

I thank Simon Jurkatis for letting me know about the erratum.
:::

## Source Code

<img
  style="width:82px;height:20px"
  src="https://img.shields.io/badge/License-MIT-blue.svg"
  alt="MIT"
/>

This example Python code has been optimized for speed but serves only demonstration purpose. It may contain errors.

```python
# LoMacKinlay.py
import numpy as np
from numba import jit

name = 'LoMacKinlay1988'
description = 'Variance ratio and test statistics as in Lo and MacKinlay (1988)'
vars_needed = ['Price']


@jit(nopython=True, nogil=True, cache=True)
def _estimate(log_prices, k, const_arr):
    # Log returns = [x2, x3, x4, ..., xT], where x(i)=ln[p(i)/p(i-1)]
    rets = np.diff(log_prices)
    # T is the length of return series
    T = len(rets)
    # mu is the mean log return
    mu = np.mean(rets)
    # sqr_demeaned_x is the array of squared demeaned log returns
    sqr_demeaned_x = np.square(rets - mu)
    # Var_1
    # Didn't use np.var(rets, ddof=1) because
    # sqr_demeaned_x is calculated already and will be used many times.
    var_1 = np.sum(sqr_demeaned_x) / (T-1)
    # Var_k
    # Variance of log returns where x(i) = ln[p(i)/p(i-k)]
    # Before np.roll() - array([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
    # After np.roll(,shift=2) - array([8, 9, 0, 1, 2, 3, 4, 5, 6, 7])
    # Discard the first k elements.
    rets_k = (log_prices - np.roll(log_prices, k))[k:]
    m = k * (T - k + 1) * (1 - k / T)
    var_k = 1/m * np.sum(np.square(rets_k - k * mu))

    # Variance Ratio
    vr = var_k / var_1

    # a_arr is an array of { (2*(k-j)/k)^2 } for j=1,2,...,k-1, fixed for a given k:
    #   When k=5, a_arr = array([2.56, 1.44, 0.64, 0.16]).
    #   When k=8, a_arr = array([3.0625, 2.25, 1.5625, 1., 0.5625, 0.25, 0.0625])
    # Without JIT it's defined as:
    #   a_arr = np.square(np.arange(k-1, 0, step=-1, dtype=np.int) * 2 / k)
    # But np.array creation is not allowed in nopython mode.
    # So const_arr=np.arange(k-1, 0, step=-1, dtype=np.int) is created outside.
    a_arr = np.square(const_arr * 2 / k)

    # b_arr is part of the delta_arr.
    b_arr = np.empty(k-1, dtype=np.float64)
    for j in range(1, k):
        b_arr[j-1] = np.sum((sqr_demeaned_x *
                             np.roll(sqr_demeaned_x, j))[j:]) # <1>

    delta_arr = b_arr / np.square(np.sum(sqr_demeaned_x)) # <2>

    # Both arrarys are of length (k-1)
    assert len(delta_arr) == len(a_arr) == k-1

    phi1 = 2 * (2*k - 1) * (k-1) / (3*k*T)
    phi2 = np.sum(a_arr * delta_arr)

    # VR test statistics under two assumptions
    vr_stat_homoscedasticity = (vr - 1) / np.sqrt(phi1)
    vr_stat_heteroscedasticity = (vr - 1) / np.sqrt(phi2)

    return vr, vr_stat_homoscedasticity, vr_stat_heteroscedasticity


def estimate(data):
    "A fast estimation of Variance Ratio test statistics as in Lo and MacKinlay (1988)"
    # Prices array = [p1, p2, p3, p4, ..., pT]
    prices = data['Price'].to_numpy(dtype=np.float64)
    result = []
    # Estimate many lags.
    for k in [2, 4, 6, 8, 10, 15, 20, 30, 40, 50, 100, 200, 500, 1000]:
        # Compute a constant array as np.array creation is not allowed in nopython mode.
        const_arr = np.arange(k-1, 0, step=-1, dtype=np.int64) # <3>
        vr, stat1, stat2 = _estimate(np.log(prices), k, const_arr)
        result.append({
            f'Variance Ratio (k={k})': vr,
            f'Variance Ratio Test Statistic (k={k}) Homoscedasticity Assumption': stat1,
            f'Variance Ratio Test Statistic (k={k}) Heteroscedasticity Assumption': stat2
        })
    return result
```

1. Note that a correction has been made here in August 2023. The summed vector should have a length of T-j not T-j-1.
   The incorrect code before was `np.roll(sqr_demeaned_x, j))[j+1:])`.
   I thank Jakub Bujnowicz for spotting this error.
2. Check the Erratum for correction.
3. `np.int` is deprecated in NumPy 1.2. Changed to `np.int64` in August 2023.

As an example, let's create 1 million prices from random walk and estimate the variance ratio and two test statistics at various lags.

```python
if __name__ == "__main__":

    import pandas as pd
    from pprint import pprint
    np.random.seed(1)
    # Generate random steps with mean=0 and standard deviation=1
    steps = np.random.normal(0, 1, size=1000000)
    # Set first element to 0 so that the first price will be the starting stock price
    steps[0] = 0
    # Simulate stock prices, P with a large starting price
    P = 10000 + np.cumsum(steps)
    # Test
    data = pd.DataFrame(P, columns=['Price'])
    result = estimate(data)
    pprint(result)
```

In just a few seconds, the output is:

```python
[{'Variance Ratio (k=2)': 1.0003293867428107,
  'Variance Ratio Test Statistic (k=2) Heteroscedasticity Assumption': 0.32904631796994205,
  'Variance Ratio Test Statistic (k=2) Homoscedasticity Assumption': 0.3293865781172764},
 {'Variance Ratio (k=4)': 1.0007984480057008,
  'Variance Ratio Test Statistic (k=4) Heteroscedasticity Assumption': 0.42595328310183966,
  'Variance Ratio Test Statistic (k=4) Homoscedasticity Assumption': 0.4267881978179488},
 {'Variance Ratio (k=6)': 0.9999130202975436,
  'Variance Ratio Test Statistic (k=6) Heteroscedasticity Assumption': -0.03511755955165345,
  'Variance Ratio Test Statistic (k=6) Homoscedasticity Assumption': -0.03518500446740915},
 {'Variance Ratio (k=8)': 1.0001094011344323,
  'Variance Ratio Test Statistic (k=8) Heteroscedasticity Assumption': 0.036922676034485354,
  'Variance Ratio Test Statistic (k=8) Homoscedasticity Assumption': 0.03698431520284624},
 {'Variance Ratio (k=10)': 1.0007024101299271,
  'Variance Ratio Test Statistic (k=10) Heteroscedasticity Assumption': 0.2077273579781436,
  'Variance Ratio Test Statistic (k=10) Homoscedasticity Assumption': 0.20803582207648225},
 {'Variance Ratio (k=15)': 1.0022173139633859,
  'Variance Ratio Test Statistic (k=15) Heteroscedasticity Assumption': 0.521306589715623,
  'Variance Ratio Test Statistic (k=15) Homoscedasticity Assumption': 0.5219816274022102},
 {'Variance Ratio (k=20)': 1.003804866170505,
  'Variance Ratio Test Statistic (k=20) Heteroscedasticity Assumption': 0.7646392343979235,
  'Variance Ratio Test Statistic (k=20) Homoscedasticity Assumption': 0.7655801985572465},
 {'Variance Ratio (k=30)': 1.0054447472916037,
  'Variance Ratio Test Statistic (k=30) Heteroscedasticity Assumption': 0.8819247138934212,
  'Variance Ratio Test Statistic (k=30) Homoscedasticity Assumption': 0.8829960534693014},
 {'Variance Ratio (k=40)': 1.007383025302277,
  'Variance Ratio Test Statistic (k=40) Heteroscedasticity Assumption': 1.0290210221871228,
  'Variance Ratio Test Statistic (k=40) Homoscedasticity Assumption': 1.0303005120741011},
 {'Variance Ratio (k=50)': 1.0086502431826903,
  'Variance Ratio Test Statistic (k=50) Heteroscedasticity Assumption': 1.0741834484206978,
  'Variance Ratio Test Statistic (k=50) Homoscedasticity Assumption': 1.0755809312730416},
 {'Variance Ratio (k=100)': 1.0153961901671607,
  'Variance Ratio Test Statistic (k=100) Heteroscedasticity Assumption': 1.341511635554299,
  'Variance Ratio Test Statistic (k=100) Homoscedasticity Assumption': 1.3434284573260966},
 {'Variance Ratio (k=200)': 1.015704654116103,
  'Variance Ratio Test Statistic (k=200) Heteroscedasticity Assumption': 0.9639231633966341,
  'Variance Ratio Test Statistic (k=200) Homoscedasticity Assumption': 0.9653299929053236},
 {'Variance Ratio (k=500)': 1.018216620766853,
  'Variance Ratio Test Statistic (k=500) Heteroscedasticity Assumption': 0.7055679685728111,
  'Variance Ratio Test Statistic (k=500) Homoscedasticity Assumption': 0.7065863036900603},
 {'Variance Ratio (k=1000)': 1.0187822241562867,
  'Variance Ratio Test Statistic (k=1000) Heteroscedasticity Assumption': 0.5140697633208364,
  'Variance Ratio Test Statistic (k=1000) Homoscedasticity Assumption': 0.5147582201029187}]
```

It's easy to see that at all lags tested, we cannot reject the null hypothesis that this price series follows a random walk.

For comparison purpose, below is an implementation in pure Python. It is more readable but is significantly slower.

```python
def estimate_python(data, k=5):
    "A slow pure python implementation"
    prices = data['Price'].to_numpy(dtype=np.float64)
    log_prices = np.log(prices)
    rets = np.diff(log_prices)
    T = len(rets)
    mu = np.mean(rets)
    var_1 = np.var(rets, ddof=1, dtype=np.float64)
    rets_k = (log_prices - np.roll(log_prices, k))[k:]
    m = k * (T - k + 1) * (1 - k / T)
    var_k = 1/m * np.sum(np.square(rets_k - k * mu))

    # Variance Ratio
    vr = var_k / var_1
    # Phi1
    phi1 = 2 * (2*k - 1) * (k-1) / (3*k*T)
    # Phi2

    def delta(j):
        res = 0
        for t in range(j+1, T+1):
            t -= 1  # array index is t-1 for t-th element
            res += np.square((rets[t]-mu)*(rets[t-j]-mu))
        return res / ((T-1) * var_1)**2

    phi2 = 0
    for j in range(1, k):
        phi2 += (2*(k-j)/k)**2 * delta(j)

    return vr, (vr - 1) / np.sqrt(phi1), (vr - 1) / np.sqrt(phi2)
```
