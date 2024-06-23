---
date: 2023-10-02
tags:
  - GARCH
  - Econometrics
  - Stata
  - Python
categories:
  - Teaching Notes
  - Programming
links:
  - GARCH-CCC: https://frds.io/algorithms/garch-ccc
  - GARCH(1,1): https://frds.io/algorithms/garch
  - GJR-GARCH(1,1): https://frds.io/algorithms/gjr-garch
---

# GARCH-Constant Conditional Correlation (CCC)

This post details a multivariate GARCH Constant Conditional Correlation (CCC) model. It was somewhat surprising that I didn't find a good Python implementation of GARCH-CCC, so I wrote my own, see [documentation on frds.io](https://frds.io/algorithms/garch-ccc/). It performs very well, often generates (marginally) better estimates than in Stata based on log-likelihood.

<!-- more -->

## Multivariate GARCH-CCC

The Multivariate GARCH model generalizes the univariate [GARCH](./garch-estimation.md) framework to multiple time series, capturing not only the conditional variances but also the conditional covariances between the series. One common form is the **Constant Conditional Correlation (CCC) model** proposed by Bollerslev (1990). 

### Return equation

The return equation for a \(N\)-dimensional time series is:

\[
\mathbf{r}_t = \boldsymbol{\mu} + \boldsymbol{\epsilon}_t
\]

Here, \( \mathbf{r}_t \) is a \( N \times 1 \) vector of returns, and \( \boldsymbol{\mu} \) is a \( N \times 1 \) vector of mean returns. \( \boldsymbol{\epsilon}_t \) is the \( N \times 1 \) vector of shock terms.

!!! note "Bivariate example"
    \[
        \begin{align*}
        r_{1t} &= \mu_1 + \epsilon_{1,t-1} \\\\
        r_{2t} &= \mu_2 + \epsilon_{2,t-1}
        \end{align*}
    \]

### Shock equation

The shock term is modelled as:

\[
\boldsymbol{\epsilon}_t = \mathbf{H}_t^{1/2} \mathbf{z}_t
\]

Here, \( \mathbf{H}_t \) is a \( N \times N \) conditional covariance matrix, \( \mathbf{H}_t^{1/2} \) is a \( N \times N \) positive definite matrix, and \( \mathbf{z}_t \) is a \( N \times 1 \) vector of standard normal innovations.

!!! note "Bivariate example"
    \[
        \begin{align*}
        \epsilon_{1t} &= \sqrt{h_{1t}} \cdot z_{1t} \\\\
        \epsilon_{2t} &= \sqrt{h_{2t}} \cdot z_{2t}
        \end{align*} 
    \]

### Conditional covariance matrix

In the CCC-GARCH(1,1) model, the conditional covariance matrix \(\mathbf{H}_t\) is constructed as:

\[
\mathbf{H}_t = \mathbf{D}_t\mathbf{R}\mathbf{D}_t
\]

where \( \mathbf{D}_t = \text{diag}(\mathbf{h}_t)^{1/2} \), and \( \mathbf{h}_t \) is a \( N \times 1 \) vector whose elements are univariate GARCH(1,1) variances for each time series. \( \mathbf{R} \) is a positive definite constant conditional correlation matrix.

!!! note "Bivariate example"

    In a bivariate GARCH(1,1) setting, we have two univariate GARCH(1,1) processes, one for each return series. Specifically, the GARCH(1,1) equations for the conditional variances \( h_{1t} \) and \( h_{2t} \) can be written as:

    \[
        \begin{align*}
        h_{1t} &= \omega_1 + \alpha_1 \epsilon_{1,t-1}^2 + \beta_1 h_{1,t-1} \\\\
        h_{2t} &= \omega_2 + \alpha_2 \epsilon_{2,t-1}^2 + \beta_2 h_{2,t-1}
        \end{align*}
    \]

    where

    - \( \epsilon_{1,t-1} \) and \( \epsilon_{2,t-1} \) are past shock terms from their respective time series.
    - The parameters \( \omega_1, \alpha_1, \beta_1, \omega_2, \alpha_2, \beta_2 \) are to be estimated.

    With these individual variances, the conditional covariance matrix \( \mathbf{H}_t \) is:

    \[
    \mathbf{H}_t = \begin{pmatrix}
    h_{1t} & \rho\sqrt{h_{1t} h_{2t}} \\
    \rho\sqrt{h_{1t} h_{2t}} & h_{2t}
    \end{pmatrix}
    \]

    Here, \( \rho \) is the correlation between the two time series. It is assumed to be constant over time in the CCC-GARCH framework.

### Log-likelihood function

The log-likelihood function for the \(N\)-dimensional multivariate GARCH CCC model is:

\[
   \begin{align*}
   \ell &= -\frac{1}{2} \sum_{t=1}^T \left[ N\ln(2\pi) + \ln(|\mathbf{H}_t|) + \mathbf{\epsilon}_t' \mathbf{H}_t^{-1} \mathbf{\epsilon}_t \right] \\\\
        &= -\frac{1}{2} \sum_{t=1}^T \left[ N\ln(2\pi) + \ln(|\mathbf{D}_t\mathbf{R}\mathbf{D}_t|) + \mathbf{\epsilon}_t' \mathbf{D}_t^{-1}\mathbf{R}^{-1}\mathbf{D}_t^{-1} \mathbf{\epsilon}_t \right] \\\\
        &= -\frac{1}{2} \sum_{t=1}^T \left[ N\ln(2\pi) + 2 \ln(|\mathbf{D}_t|) + \ln(|\mathbf{R}|)+ \mathbf{z}_t' \mathbf{R}^{-1} \mathbf{z}_t \right] 
   \end{align*}
\]

where \(\mathbf{z}_t=\mathbf{D}_t^{-1}\mathbf{\epsilon}_t\) is the vector of standardized residuals.

!!! note "Bivariate example"

    In the bivariate case, the log-likelihood function can be specifically written as a function of all parameters.

    The log-likelihood function \( \ell(\Theta) \) for the bivariate case with all parameters \( \Theta = (\mu_1, \omega_1, \alpha_1, \beta_1, \mu_2, \omega_2, \alpha_2, \beta_2, \rho) \) is:

    \[
    \ell(\Theta) = -\frac{1}{2} \sum_{t=1}^T \left[ 2\ln(2\pi) + 2 \ln(|\mathbf{D}_t|) + \ln(|\mathbf{R}|) + \mathbf{z}_t' \mathbf{R}^{-1} \mathbf{z}_t \right]
    \]

    Here, \( \mathbf{z}_t' \) is the transpose of the vector of standardized residuals \( \mathbf{z}_t \):

    \[
    \mathbf{z}_t = \begin{pmatrix}
    z_{1,t} \\
    z_{2,t}
    \end{pmatrix}
    \]

    Further, \( \mathbf{D}_t \) is:

    \[
    \mathbf{D}_t = \begin{pmatrix}
    \sqrt{h_{1t}} & 0 \\
    0 & \sqrt{h_{2t}}
    \end{pmatrix}
    \]

    So the log-determinant of \( \mathbf{D}_t \) is:

    \[
    \ln(|\mathbf{D}_t|) = \frac{1}{2} \ln(h_{1t} h_{2t})
    \]

    The log-determinant of \( \mathbf{R} \) is:

    \[
    \ln(|\mathbf{R}|) = \ln(1 - \rho^2)
    \]

    The inverse of \( \mathbf{R} \) is:

    \[
    \mathbf{R}^{-1} = \frac{1}{1 - \rho^2} \begin{pmatrix}
    1 & -\rho \\
    -\rho & 1
    \end{pmatrix}
    \]

    Lastly, \( \mathbf{z}_t' \mathbf{R}^{-1} \mathbf{z}_t \) is:

    \[
    \mathbf{z}_t' \mathbf{R}^{-1} \mathbf{z}_t = \frac{1}{1 - \rho^2} \left[ z_{1t}^2 - 2\rho z_{1t} z_{2t} + z_{2t}^2 \right]
    \]

    Inserting all of these into \( \ell(\Theta) \) in equation (Eq: log_likelihood_bivariate) leads to:

    \[
    \ell(\Theta) = -\frac{1}{2} \sum_{t=1}^T \left[ 2\ln(2\pi) + \ln(h_{1t} h_{2t} (1 - \rho^2)) + \frac{1}{1 - \rho^2} \left( z_{1t}^2 - 2\rho z_{1t} z_{2t} + z_{2t}^2 \right) \right]
    \]

## Estimation techniques

[`frds.algorithms.GARCHModel_CCC`](https://frds.io/algorithms/garch-ccc/) is my implementation. Specifically, I estimate all the GARCH-DCC parameters simultaneously via maximizing the log-likelihood.

**General steps are**:

1. Use `frds.algorithms.GARCHModel` to estimate the [GARCH](/algorithms/garch) model for each of the returns.
2. Use the standardized residuals from the estimated GARCH models to compute the correlation coefficient.
3. Use as starting values the estimated parameters from above in optimizing the log-likelihood function.

## Example code

Let's import the dataset.

```python 
>>> import pandas as pd
>>> data_url = "https://www.stata-press.com/data/r18/stocks.dta"
>>> df = pd.read_stata(data_url, convert_dates=["date"])
```

Scale returns to percentage returns for better optimization results

```python 
>>> returns1 = df["toyota"].to_numpy() * 100
>>> returns2 = df["nissan"].to_numpy() * 100
```

Use `frds.algorithms.GARCHModel_CCC` to estimate a GARCH(1,1)-CCC.

```python 
>>> from frds.algorithms import GARCHModel_CCC
>>> model_ccc = GARCHModel_CCC(returns1, returns2)
>>> res = model_ccc.fit()
>>> from pprint import pprint
>>> pprint(res)
Parameters(mu1=0.02745814255283541,
           omega1=0.03401400758840226,
           alpha1=0.06593379740524756,
           beta1=0.9219575443861723,
           mu2=0.009390068254041505,
           omega2=0.058694325049554734,
           alpha2=0.0830561828957614,
           beta2=0.9040961791372522,
           rho=0.6506770477876749,
           loglikelihood=-7281.321453218112)
```

These results are comparable to the ones obtained in Stata, and even marginally 
better based on log-likelihood. In Stata, we can estimate the same model as below:

```stata
webuse stocks, clear
replace toyota = toyota * 100
replace nissan = nissan * 100
mgarch ccc (toyota nissan = ), arch(1) garch(1)
```
   
The Stata results are:

     Constant conditional correlation MGARCH model

     Sample: 1 thru 2015                                      Number of obs = 2,015
     Distribution: Gaussian                                   Wald chi2(.)  =     .
     Log likelihood = -7282.961                               Prob > chi2   =     .

     -------------------------------------------------------------------------------------
                         | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
     --------------------+----------------------------------------------------------------
     toyota              |
                 _cons   |   .0277462   .0302805     0.92   0.360    -.0316024    .0870948
     --------------------+----------------------------------------------------------------
     ARCH_toyota         |
                    arch |
                    L1.  |   .0666384   .0101597     6.56   0.000     .0467257    .0865511
                         |
                  garch  |
                    L1.  |   .9210688   .0119214    77.26   0.000     .8977032    .9444343
                         |
                  _cons  |   .0344153   .0109208     3.15   0.002      .013011    .0558197
     --------------------+----------------------------------------------------------------
     nissan              |
                  _cons  |   .0079682   .0349351     0.23   0.820    -.0605034    .0764398
     --------------------+----------------------------------------------------------------
     ARCH_nissan         |
                    arch |
                    L1.  |   .0851778   .0132656     6.42   0.000     .0591778    .1111779
                         |
                  garch  |
                    L1.  |   .9016613   .0150494    59.91   0.000     .8721649    .9311577
                         |
                  _cons  |   .0603765   .0178318     3.39   0.001     .0254269    .0953262
     --------------------+----------------------------------------------------------------
     corr(toyota,nissan) |   .6512249   .0128548    50.66   0.000       .62603    .6764199
     -------------------------------------------------------------------------------------

## References

- [Engle, R. F. (1982)](https://doi.org/10.2307/1912773), "Autoregressive Conditional Heteroskedasticity with Estimates of the Variance of United Kingdom Inflation." *Econometrica*, 50(4), 987-1007.
- [Bollerslev, T. (1990)](https://doi.org/10.2307/2109358), "Modelling the Coherence in Short-Run Nominal Exchange Rates: A Multivariate Generalized ARCH Model." *Review of Economics and Statistics*, 72(3), 498-505.
