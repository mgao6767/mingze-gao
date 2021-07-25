---
redirect: https://frds.io/measures/kyle_lambda/
disqus: ""
---

# Kyle's Lambda

A measure of market impact cost from Kyle (1985), which can be interpreted as
the cost of demanding a certain amount of liquidity over a given time period.

## Definition

Following Hasbrouck (2009) and Goyenko, Holden, Trzcinka (2009), Kyle's Lambda
for a given stock $i$ and day $t$, is calculated as the slope coefficient
$\lambda_{i,t}$ in the regression:

$$
ret_{i,t,n}= \delta_{i,t} + \lambda_{i,t} S_{i,t,n}+\epsilon_{i,t,n}
$$

where for the $n$th five-minute period on date $t$ and stock $i$, $ret_{i,t,n}$
is the stock return and $S_{i,t,n}$ is the sum of the signed square-root dollar
volume, that is,

$$
S_{i,t,n}=\sum_k{sign}(dvol_{i,t,n,k}) \sqrt{dvol_{i,t,n,k}}
$$


## Source Code 

<a href="https://opensource.org/licenses/MIT"><img style="width:82px;height:20px" src="https://img.shields.io/badge/License-MIT-green.svg" alt="MIT"></a> <a href="https://www.python.org/"><img style="width:116px;height:20px" src="https://img.shields.io/badge/Made%20with-Python-1f425f.svg" alt="MIT"></a>

This example Python code is not optimized for speed and serves only demonstration purpose. It may contain errors.

It returns $\lambda \times 10^6$

```Python linenums="1"
# KylesLambda.py
import numpy as np

name = 'KylesLambda'
description = """
A measure of market impact cost from Kyle (1985), 
which can be interpreted as the cost of demanding a certain amount of liquidity over a given time period.
Result is Lambda*1E6.
"""
vars_needed = ['Price', 'Volume', 'Direction']


def estimate(data):
    price = data['Price'].to_numpy()
    volume = data['Volume'].to_numpy()
    direction = data['Direction'].to_numpy()
    sqrt_dollar_volume = np.sqrt(np.multiply(price, volume))
    signed_sqrt_dollar_volume = np.abs(
        np.multiply(direction, sqrt_dollar_volume))
    # Find the total signed sqrt dollar volume and return per 5 min.
    timestamps = np.array(data.index, dtype='datetime64')
    last_ts, last_price = timestamps[0], price[0]
    bracket_ssdv = 0
    bracket = last_ts + np.timedelta64(5, 'm')
    rets, ssdvs, = [], []
    for idx, ts in enumerate(timestamps):
        if ts <= bracket:
            bracket_ssdv += signed_sqrt_dollar_volume[idx]
        else:
            ret = np.log(price[idx-1]/last_price)
            if not np.isnan(ret) and not np.isnan(bracket_ssdv):
                rets.append(ret)
                ssdvs.append(bracket_ssdv)
            # Reset bracket
            bracket = ts + np.timedelta64(5, 'm')
            last_price = price[idx]
            bracket_ssdv = signed_sqrt_dollar_volume[idx]
    # Perform regression.
    x = np.vstack([np.ones(len(ssdvs)), np.array(ssdvs)]).T
    try:
        coef, _, _, _ = np.linalg.lstsq(x, np.array(rets), rcond=None)
    except np.linalg.LinAlgError:
        return None
    else:
        return None if np.isnan(coef[1]) else coef[1]*1E6
```