---
date: 2023-09-26
tags:
  - GARCH
  - Econometrics
  - Stata
  - Python
categories:
  - Teaching Notes
links:
  - GARCH(1,1): https://frds.io/algorithms/garch
---

# GARCH Estimation

This post details GARCH(1,1) model and its estimation manually in Python, compared to using libraries and in Stata.

<!-- more -->

## GARCH(1,1) Model

The GARCH(1,1) (Generalized Autoregressive Conditional Heteroskedasticity) model is a commonly used model for capturing the time-varying volatility in financial time series data. The model can be defined as follows:

### Return equation

There are many ways to specify return dynamics. Let's focus on the simplest one assuming a constant mean.

\[
r_t = \mu + \epsilon_t
\]

Here \( r_t \) represents the return at time \( t \), and \( \mu \) is the mean return.

### Shock equation

\[
\epsilon_t = \sigma_t \cdot z_t
\]

In this equation, \( \epsilon_t \) is the shock term, \( \sigma_t \) is the conditional volatility, and \( z_t \) is a white noise error term with zero mean and unit variance (\( z_t \sim N(0,1) \)).

!!! note
    We can also assume that the noise term follows a different distribution, such as Student-t, and modify the likelihood function below accordingly.

### Volatility equation

\[
\sigma_t^2 = \omega + \alpha \cdot \epsilon_{t-1}^2 + \beta \cdot \sigma_{t-1}^2
\]

Here \( \sigma_t^2 \) is the conditional variance at time \( t \), and \( \omega \), \( \alpha \), \( \beta \) are parameters to be estimated. This equation captures how volatility evolves over time.

!!! note "The unconditional variance and persistence"
    The unconditional variance, often denoted as \(\text{Var}(\epsilon_t)\) or \(\sigma^2\), refers to the long-run average or steady-state variance of the return series. It is the variance one would expect the series to revert to over the long term, and it doesn't condition on any past information. 

    For a GARCH(1,1) model to be stationary, the __persistence__, sum of \(\alpha\) and \(\beta\), must be less than 1 (\(\alpha + \beta < 1\)). Given this condition, the unconditional variance \(\sigma^2\) can be computed as follows:

    \[
    \sigma^2 = \frac{\omega}{1 - \alpha - \beta}
    \]

    In this formulation, \(\omega\) is the constant or "base" level of volatility, while \(\alpha\) and \(\beta\) determine how shocks to returns and past volatility influence future volatility. The unconditional variance provides a long-run average level around which the conditional variance oscillates.

### Log-likelihood function

The likelihood function for a GARCH(1,1) model is used for the estimation of parameters \(\mu\), \(\omega\), \(\alpha\), and \(\beta\). Given a time series of returns \( \{ r_1, r_2, \ldots, r_T \} \), the likelihood function \( L(\mu, \omega, \alpha, \beta) \) can be written as:

\[
L(\mu, \omega, \alpha, \beta) = \prod_{t=1}^{T} \frac{1}{\sqrt{2\pi \sigma_t^2}} \exp\left(-\frac{(r_t-\mu)^2}{2\sigma_t^2}\right)
\]

Taking the natural logarithm of \( L \), we obtain the log-likelihood function \( \ell(\mu, \omega, \alpha, \beta) \):

\[
\ell(\mu, \omega, \alpha, \beta) = -\frac{1}{2} \sum_{t=1}^{T} \left( \log(2\pi)  + \log(\sigma_t^2) + \frac{(r_t-\mu)^2}{\sigma_t^2} \right)
\]

The parameters \(\mu, \omega, \alpha, \beta \) can then be estimated by maximizing this log-likelihood function.

## Estimation

Now let's use an example to showcase the estimation of GARCH(1,1).

```python
import pandas as pd

df = pd.read_stata("https://www.stata-press.com/data/r18/stocks.dta", convert_dates=['date'])
df.set_index("date", inplace=True)
```

The dataframe `df` is like below, with daily returns for stocks "toyota", "nissan" and "honda". Notice that there are gaps in the `date`, but variable `t` is without gaps.

```python
>>> df.head()
            t    toyota    nissan     honda
date
2003-01-02  1  0.015167  0.029470  0.031610
2003-01-03  2  0.004820  0.008173  0.002679
2003-01-06  3  0.019959  0.013064 -0.001606
2003-01-07  4 -0.013323 -0.007444 -0.011318
2003-01-08  5 -0.027001 -0.018857 -0.016945
```

We focus on the returns of "toyota", and scale returns to percentage returns for better optimization results.

```python
returns = df["toyota"].to_numpy() * 100
```

### Estimation using `arch` library

It's remarkably easy to estimate GARCH(1,1) with the `arch` library.

```python
from arch import arch_model

model = arch_model(returns, mean='Constant', vol='GARCH', p=1, q=1)
model.fit()
```

We have the following outputs.

```python
Iteration:      1,   Func. Count:      6,   Neg. LLF: 353027828870.51434
Iteration:      2,   Func. Count:     14,   Neg. LLF: 5686315977.791412
Iteration:      3,   Func. Count:     23,   Neg. LLF: 288989718.5625958
Iteration:      4,   Func. Count:     29,   Neg. LLF: 3757.5687528616645
Iteration:      5,   Func. Count:     35,   Neg. LLF: 6165.184701734164
Iteration:      6,   Func. Count:     41,   Neg. LLF: 3751.933155975204
Iteration:      7,   Func. Count:     47,   Neg. LLF: 3748.8551639756433
Iteration:      8,   Func. Count:     52,   Neg. LLF: 3748.8245639433794
Iteration:      9,   Func. Count:     57,   Neg. LLF: 3748.8226971150325
Iteration:     10,   Func. Count:     62,   Neg. LLF: 3748.8215357459
Iteration:     11,   Func. Count:     67,   Neg. LLF: 3748.8215327016333
Iteration:     12,   Func. Count:     71,   Neg. LLF: 3748.8215327001894
Optimization terminated successfully    (Exit mode 0)
            Current function value: 3748.8215327016333
            Iterations: 12
            Function evaluations: 71
            Gradient evaluations: 12
                     Constant Mean - GARCH Model Results                      
==============================================================================
Dep. Variable:                      y   R-squared:                       0.000
Mean Model:             Constant Mean   Adj. R-squared:                  0.000
Vol Model:                      GARCH   Log-Likelihood:               -3748.82
Distribution:                  Normal   AIC:                           7505.64
Method:            Maximum Likelihood   BIC:                           7528.08
                                        No. Observations:                 2015
Date:                Tue, Sep 26 2023   Df Residuals:                     2014
Time:                        21:36:03   Df Model:                            1
                                  Mean Model                                 
=============================================================================
                 coef    std err          t      P>|t|       95.0% Conf. Int.
-----------------------------------------------------------------------------
mu             0.0396  3.054e-02      1.297      0.195 [-2.025e-02,9.945e-02]
                              Volatility Model                              
============================================================================
                 coef    std err          t      P>|t|      95.0% Conf. Int.
----------------------------------------------------------------------------
omega          0.0279  1.374e-02      2.030  4.237e-02 [9.609e-04,5.484e-02]
alpha[1]       0.0694  1.422e-02      4.884  1.039e-06 [4.157e-02,9.730e-02]
beta[1]        0.9217  1.601e-02     57.558      0.000     [  0.890,  0.953]
============================================================================

Covariance estimator: robust
ARCHModelResult, id: 0x1cb7b8f4460
```

!!! note "GARCH(1,1) in Stata"
    To estimate GARCH(1,1) in Stata, use the following code:

    ```stata
    use https://www.stata-press.com/data/r18/stocks, clear
    replace toyota = toyota * 100
    arch toyota, arch(1) garch(1) vce(robust)
    ```

    Outputs are:

    ```stata
    (setting optimization to BHHH)
    Iteration 0:   log pseudolikelihood = -4075.9402  
    Iteration 1:   log pseudolikelihood = -3953.7987  
    Iteration 2:   log pseudolikelihood = -3911.4597  
    Iteration 3:   log pseudolikelihood = -3883.4575  
    Iteration 4:   log pseudolikelihood = -3857.2121  
    (switching optimization to BFGS)
    Iteration 5:   log pseudolikelihood =  -3837.462  
    Iteration 6:   log pseudolikelihood = -3765.4267  
    Iteration 7:   log pseudolikelihood = -3761.9975  
    Iteration 8:   log pseudolikelihood = -3753.8487  
    Iteration 9:   log pseudolikelihood = -3752.0844  
    Iteration 10:  log pseudolikelihood =  -3751.921  
    Iteration 11:  log pseudolikelihood = -3751.3856  
    Iteration 12:  log pseudolikelihood =  -3749.877  
    Iteration 13:  log pseudolikelihood = -3749.3108  
    Iteration 14:  log pseudolikelihood = -3749.2614  
    (switching optimization to BHHH)
    Iteration 15:  log pseudolikelihood =  -3749.249  
    Iteration 16:  log pseudolikelihood = -3749.2487  
    Iteration 17:  log pseudolikelihood = -3749.2487  

    ARCH family regression

    Sample: 1 thru 2015                             Number of obs     =       2015
                                                    Wald chi2(.)      =          .
    Log pseudolikelihood = -3749.249                Prob > chi2       =          .

    ------------------------------------------------------------------------------
                |             Semirobust
        toyota  | Coefficient  std. err.      z    P>|z|     [95% conf. interval]
    -------------+----------------------------------------------------------------
    toyota      |
        _cons   |   .0403521   .0305032     1.32   0.186     -.019433    .1001373
    -------------+----------------------------------------------------------------
    ARCH        |
        arch    |
            L1. |   .0703684   .0142609     4.93   0.000     .0424176    .0983192
                |
        garch   |
            L1. |   .9204512   .0161376    57.04   0.000     .8888221    .9520802
                |
        _cons   |   .0284799   .0139792     2.04   0.042     .0010812    .0558786
    ------------------------------------------------------------------------------
    ```

    There are some differences in the estimates, potentially because of the optimization algorithms and/or initial parameters. Based on the log-likelihood, it seems `arch` results are marginally better.


### Manual estimation

Let's try do this manually to see how we can use maximum likelihood estimation (MLE) to estimate the parameters.

```python
from scipy.optimize import minimize
import numpy as np

# Log-Likelihood function for GARCH(1, 1)
def garch_log_likelihood(params, returns):
    mu, omega, alpha, beta = params
    T = len(returns)
    sigma2 = np.empty(T)
    if alpha + beta < 1:
        sigma2[0] = omega / (1 - alpha - beta)
    else:
        sigma2[0] = omega / 0.001
        
    for t in range(1, T):
        sigma2[t] = omega + alpha * (returns[t-1]-mu)**2 + beta * sigma2[t-1]
        sigma2[t] = sigma2[t] if sigma2[t] > 0 else 0.001
        
    log_likelihood = 0.5 * np.sum(np.log(2*np.pi*sigma2) + ((returns-mu)**2 / sigma2))
    return log_likelihood

# Persistence of GARCH(1,1) = alpha + beta has to be smaller than 1
def constraint_persistence(params):
    _, _, alpha, beta = params
    return 1.0 - (alpha + beta)

# Initial parameter guess [mu, omega, alpha, beta]
initial_params = [returns.mean(), 0.05, 0.1, 0.88]

# Run the optimizer to maximize the log-likelihood (minimize its negative)
opt_results = minimize(garch_log_likelihood, initial_params, method="SLSQP",
                        args=(returns), 
                        bounds=[
                            # No bounds for mu
                            (-np.inf, np.inf),
                            # Lower bound for omega 
                            # because sigma[0] may be equal to omega 
                            # if alpha+beta both are zero 
                            (0.001, np.inf), 
                            # Bounds for alpha and beta
                            (0.0, 1.0), 
                            (0.0, 1.0)],
                        constraints={'type': 'ineq', 'fun': constraint_persistence})

# Extract the estimated parameters
mu_hat, w_hat, alpha_hat, beta_hat = opt_results.x

print(f'Estimated parameters: \n \
      mu={mu_hat}\n \
      omega={w_hat}\n \
      alpha={alpha_hat}\n \
      beta={beta_hat}')
print(f"Persistence: alpha+beta={alpha_hat+beta_hat}")
print(f"Log-likelihood: {-garch_log_likelihood(opt_results.x, returns)}")
```

The outputs are

```python
Estimated parameters: 
       mu=0.040173898536452125
       omega=0.02888320573536973
       alpha=0.06838623740784693
       beta=0.9214019468044863
Persistence: alpha+beta=0.9897881842123332
Log-likelihood: -3749.0392910447126
```

!!! warning "Caution"
    The code above serves only demonstration purpose.

    It appears that we have quite similar coefficient estimates from the above manual work to the `arch` results. However, we need to be super careful here because the choice of initial parameters has **significant** impact on the output.

    Further, based on the log-likelihood, the manual estimation results are not as good as in `arch`: the log-likelihood is somewhere between the Iteration 6 and 7 out of 12 in the `arch` estimation.

    I checked a bit the source code of `arch`. The authors did a lot of work in selecting the optimal initial parameters and setting bounds on the conditional volalatilies. But here in the manual work, I relied on only rough guess in selecting initial values and did not attempt to compute bounds. 

!!! note
    I leave out the estimation of standard errors in this post.

### Improvements

In this part, I explore how to improve the estimation and enhance its numerical stability. Insights are drawn from the `arch` source code.

#### Initial value of conditional variance

Note that the conditional variance in a GARCH(1,1) model is:

\[
\sigma_t^2 = \omega + \alpha \cdot \epsilon_{t-1}^2 + \beta \cdot \sigma_{t-1}^2
\]

We need a good starting value \(\sigma_0^2\) to begin with, which can be estimated via the __backcasting technique__. Once we have that \( \sigma^2_0 \) through backcasting, we can proceed to calculate the entire series of conditional variances using the standard GARCH recursion formula.

To backcast the initial variance, we can use the Exponential Weighted Moving Average (EWMA) method, setting \(\sigma^2_0\) to the EWMA of the sample variance of the first \(n \leq T\) returns:

\[
\sigma^2_0 = \sum_{t=1}^{n} w_t \cdot r_t^2
\]

where \( w_t \) are the exponentially decaying weights and \( r_t \) are residuals of returns, i.e., returns de-meaned by sample average. This \(\sigma^2_0\) is then used to derive \(\sigma^2_1\) the starting value for the conditional variance series.

#### Initial value of \(\omega\)

The starting value of \(\omega\) is relatively straightforward. Notice that earlier we have jotted down the unconditional variance \(\sigma^2 = \frac{\omega}{1-\alpha-\beta}\). Therefore, given a level of persistence (\(\alpha+\beta\)), we can set the initial guess of \(\omega\) to be the sample variance times one minus persistence:

\[
\omega = \hat{\sigma}^2 \cdot (1-\alpha-\beta)
\]

where we use the known sample variance of residuals \(\hat{\sigma}^2\) as a guess for the unconditional variance \(\sigma^2\). However, we still need to find good starting values for \(\alpha\) and \(\beta\).

#### Initial value of \(\alpha\) and \(\beta\)

Unfortunately, there is no better way to find good starting values for \(\alpha\) and \(\beta\) than a grid search. Luckily, this grid search can be relatively small.

First, we don't know ex ante the persistence level, so we need to vary the persistence level from some low values to some high values, e.g., from 0.1 to 0.98. Second, generally the \(\alpha\) parameter is not too big, for example, ranging from 0.01 to 0.2.

We can permute combinations of the persistence level and \(\alpha\), which naturally gives the corresponding \(\beta\) and hence \(\omega\). The "optimal" set of initial values of \(\omega, \alpha, \beta\) is the one that gives the highest log-likelihood.[^1]

[^1]: The initial value of \(\mu\) is reasonably set to the sample mean return.

#### Variance bounds

Another issue is that we want to ensure that in the estimation, condition variance 
does not blow up to infinity or becomes zero. Hence, we need to 
construct bounds for conditional variances during the GARCH(1,1) parameter estimation process. 

To do this, we can calculate loose lower and upper bounds for each observation.
Specifically, we can use sample variance of the residuals to compute global lower and upper 
bounds. We then use EWMA to compute the conditional variance for each time point.
The EWMA variances are then adjusted to ensure they are within global bounds.
Lastly, we scale the adjusted EWMA variances to form the variance bounds at each
time.

During the estimation process, whenever we compute the conditional variances based 
on the prevailing model parameters, we ensure that they are adjusted to be reasonably
within the bounds at each time.

!!! note
    See [frds.measures.GARCHModel](https://frds.io/algorithms/garch/) for the
    full implementation of the above improvements.
