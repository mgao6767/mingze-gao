# Variance Ratio Test - Lo and MacKinlay (1988) 

A simple test for the random walk hypothesis of prices and efficient market.

## Definition

Let's assume:

- a price series $\{p_t\}=\{p_0,p_1,p_2,...,p_T\}$ and
- a log return series $\{x_t\}=\{x_1, x_2, ..., x_T\}$ where $x_t=\ln \frac{p_t}{p_{t-1}}$

### Variance Ratio (VR)

The **variance ratio** of $k$-period return is defined as:

$$\textit{V}(k)=\frac{\textit{Var}(x_t+x_{t-1}+...+x_{t-k+1})/k}{\textit{Var}(x_t)}$$

The estimator of $\textit{V}(k)$ proposed in Lo and MacKinlay (1988) is

$$\textit{VR}(k)=\frac{\hat\sigma^2(k)}{\hat\sigma^2(1)}$$

where $\hat\sigma^2(1)$ is the unbiased estimator of the one-period return variance, using the one-period returns $\{x_t\}$, and is defined as

$$\hat\sigma^2(1)=\frac{1}{T-1} \sum_{t-1}^T (x_t - \hat\mu)^2$$

and $\hat\sigma^2(k)$ is the estimator of $k$-period return variance using $k$-period returns. Lo and MacKinlay (1988) defined it, due to limited sample size and the desire to improve the power of the test, as

$$\hat\sigma^2(k)=\frac{1}{m} \sum_{t-1}^T \left(\ln\frac{P_t}{P_{t-k}} - k\hat\mu \right)^2$$

where $m=k(T-k+1)(1-k/T)$ is chosen such that $\hat\sigma^2(k)$ is an unbiased estimator of the $k$-period return variance when $\sigma^2_t$ is constant over time.

### Variance Ratio Test Statistics

Lo and MacKinlay (1988) proposed that under the null hypothesis of $V(k)=1$, the test statistic is given by

$$Z(k)=\frac{\textit{VR}(k)-1}{\sqrt{\phi(k)}}$$

which follows the standard normal distribution asymptotically.

#### Homoscedasticity

Under the assumption of homoscedasticity, the asymptotic variance $\phi$ is given by 

$$\phi(k)=\frac{2(2k-1)(k-1)}{3kT}$$

#### Heteroscedasticity

Under the assumption of heteroscedasticity, the asymptotic variance $\phi$ is given by 

$$\phi(k)=\sum_{j=1}^{k-1} \left[\frac{2(k-j)}{k} \right]^2\delta(j)$$

$$\delta(j)=\frac{\sum_{t=j+1}^T (x_t - \hat\mu)^2(x_{t-j} - \hat\mu)^2}{\left[\sum_{t=1}^T (x_t - \hat\mu)^2\right]^2}$$


## Source Code 

<a href="https://opensource.org/licenses/MIT"><img style="width:82px;height:20px" src="https://img.shields.io/badge/License-MIT-green.svg" alt="MIT"></a> <a href="https://www.python.org/"><img style="width:116px;height:20px" src="https://img.shields.io/badge/Made%20with-Python-1f425f.svg" alt="MIT"></a>

This example Python code has been optimized for speed but serves only demonstration purpose. It may contain errors.

```Python linenums="1"
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
    # Var(1)
    # Didn't use np.var(rets, ddof=1) because
    # sqr_demeaned_x is calculated already and will be used many times.
    var_1 = np.sum(sqr_demeaned_x) / (T-1)
    # Var(k)
    # Variance of log returns where x(i) = ln[p(i)/p(i-k)]
    # Before np.roll() - array([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
    # After np.roll(,shift=2) - array([8, 9, 0, 1, 2, 3, 4, 5, 6, 7])
    # Discard the first k elements.
    rets_k = (log_prices - np.roll(log_prices, k))[k:]
    m = k * (T - k + 1) * (1 - k / T)
    var_k = 1/m * np.sum(np.square(rets_k - k * mu))

    # Variance Ratio
    vr = var_1 / var_k

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
                             np.roll(sqr_demeaned_x, j))[j+1:])

    delta_arr = b_arr / np.square(np.sum(sqr_demeaned_x))

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
        const_arr = np.arange(k-1, 0, step=-1, dtype=np.int)
        vr, stat1, stat2 = _estimate(np.log(prices), k, const_arr)
        result.append({
            f'Variance Ratio (k={k})': vr,
            f'Variance Ratio Test Statistic (k={k}) Homoscedasticity Assumption': stat1,
            f'Variance Ratio Test Statistic (k={k}) Heteroscedasticity Assumption': stat2
        })
    return result
```

As an example, let's create 1 million prices from random walk and estimate the variance ratio and two test statistics at various lags.

```Python linenums="1"
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

```Python linenums="1"
[{'Variance Ratio (k=2)': 0.9996707217170898,
  'Variance Ratio Test Statistic (k=2) Heteroscedasticity Assumption': -0.328937992579064,
  'Variance Ratio Test Statistic (k=2) Homoscedasticity Assumption': -0.3292781182710011},
 {'Variance Ratio (k=4)': 0.9992021890048969,
  'Variance Ratio Test Statistic (k=4) Heteroscedasticity Assumption': -0.42561351112955187,
  'Variance Ratio Test Statistic (k=4) Homoscedasticity Assumption': -0.4264477015012838},
 {'Variance Ratio (k=6)': 1.0000869872685827,
  'Variance Ratio Test Statistic (k=6) Heteroscedasticity Assumption': 0.035120623095718215,
  'Variance Ratio Test Statistic (k=6) Homoscedasticity Assumption': 0.03518806511465767},
 {'Variance Ratio (k=8)': 0.9998906108328671,
  'Variance Ratio Test Statistic (k=8) Heteroscedasticity Assumption': -0.03691864919449057,
  'Variance Ratio Test Statistic (k=8) Homoscedasticity Assumption': -0.036980269519275764},
 {'Variance Ratio (k=10)': 0.9992980829037514,
  'Variance Ratio Test Statistic (k=10) Heteroscedasticity Assumption': -0.20758162376493566,
  'Variance Ratio Test Statistic (k=10) Homoscedasticity Assumption': -0.2078897981764009},
 {'Variance Ratio (k=15)': 0.9977875916405622,
  'Variance Ratio Test Statistic (k=15) Heteroscedasticity Assumption': -0.5201534404047162,
  'Variance Ratio Test Statistic (k=15) Homoscedasticity Assumption': -0.5208267908862809},
 {'Variance Ratio (k=20)': 0.9962095559617874,
  'Variance Ratio Test Statistic (k=20) Heteroscedasticity Assumption': -0.7617411898316379,
  'Variance Ratio Test Statistic (k=20) Homoscedasticity Assumption': -0.7626783096578061},
 {'Variance Ratio (k=30)': 0.9945847374445285,
  'Variance Ratio Test Statistic (k=30) Heteroscedasticity Assumption': -0.8771491506760526,
  'Variance Ratio Test Statistic (k=30) Homoscedasticity Assumption': -0.8782143980043277},
 {'Variance Ratio (k=40)': 0.9926710842680101,
  'Variance Ratio Test Statistic (k=40) Heteroscedasticity Assumption': -1.0214797200547472,
  'Variance Ratio Test Statistic (k=40) Homoscedasticity Assumption': -1.0227495264425346},
 {'Variance Ratio (k=50)': 0.9914239418062346,
  'Variance Ratio Test Statistic (k=50) Heteroscedasticity Assumption': -1.064971483937724,
  'Variance Ratio Test Statistic (k=50) Homoscedasticity Assumption': -1.0663566866143532},
 {'Variance Ratio (k=100)': 0.9848372582876977,
  'Variance Ratio Test Statistic (k=100) Heteroscedasticity Assumption': -1.3211709479464242,
  'Variance Ratio Test Statistic (k=100) Homoscedasticity Assumption': -1.3230583986186821},
 {'Variance Ratio (k=200)': 0.9845381685980656,
  'Variance Ratio Test Statistic (k=200) Heteroscedasticity Assumption': -0.9490193421402398,
  'Variance Ratio Test Statistic (k=200) Homoscedasticity Assumption': -0.9504042233078055},
 {'Variance Ratio (k=500)': 0.9821092875569704,
  'Variance Ratio Test Statistic (k=500) Heteroscedasticity Assumption': -0.6929450052777816,
  'Variance Ratio Test Statistic (k=500) Homoscedasticity Assumption': -0.6939449713145617},
 {'Variance Ratio (k=1000)': 0.9815640440999632,
  'Variance Ratio Test Statistic (k=1000) Heteroscedasticity Assumption': -0.5045925125167533,
  'Variance Ratio Test Statistic (k=1000) Homoscedasticity Assumption': -0.5052681602579187}]
```

It's easy to see that at all lags tested, we cannot reject the null hypothesis that this price series follows a random walk.

For comparison purpose, below is an implementation in pure Python. It is more readable but is significantly slower.

```Python linenums="1"
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
    vr = var_1 / var_k
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
