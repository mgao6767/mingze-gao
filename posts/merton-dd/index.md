---
title: Estimate Merton Distance-to-Default
# description: SAS code to calculate Merton (1974) Distance-to-Default and default probability as in Bharath and Shumway (2008 RFS).
date: 2022-11-30
# date: Nov 30, 2022
hasTex: true
tags:
  - SAS
  - Code
  - Merton
  - Default Probability
slug: merton-dd
categories:
  - Research Notes
---

@merton_pricing_1974 Distance to Default (DD) model is useful in forecasting defaults. This post documents a few ways to empirically estimate Merton DD (and default probability) as in @bharath_forecasting_2008.

<!-- more -->

## The Merton Model

The total value of a firm follows geometric Brownian motion,

$$
\begin{equation}
dV = \mu Vdt+\sigma_V VdW
\end{equation}
$$ {#eq-firm-value-gbm}

where,

- $V$ is the total value of the firm
- $\mu$ is the expected return on V (continuously compounded)
- $\sigma_V$ is the volatility of firm value
- $dW$ is a standard Wiener process

Assuming the firm has one discount bond maturing in $T$ periods, the equity of the firm can be viewed as a call option on the underlying value of the firm with a strike price equal to the face value of the firm's debt and a time-to-maturity of $T$.

The equity value of the firm is hence a function of the firm's value (Black-Scholes-Merton model):

$$
\begin{equation}
E=V\mathcal{N}(d_1)-e^{-rT}F\mathcal{N}(d_2)
\end{equation}
$$ {#eq-firm-equity-value-bsm}

where,

- $E$ is the market value of the firm's equity
- $F$ is the face value of the firm's debt
- $r$ is the risk-free rate
- $\mathcal{N}(\cdot)$ is the cumulative standard normal distribution function

and,

$$
\begin{equation}
d_1 = \frac{\ln(V/F)+(r+0.5\sigma_V^2)T}{\sigma_V \sqrt{T}}
\end{equation}
$$ {#eq-merton-d1}

with $d_2 = d_1-\sigma_V \sqrt{T}$.

Moreover, the volatility of the firm's equity is related to the volatility of the firm's value, which follows from Ito's lemma,

$$
\begin{equation}
\sigma_E = \left(\frac{V}{E}\right)\frac{\partial E}{\partial V}\sigma_V
\end{equation}
$$ {#eq-firm-equity-volatility-and-firm-value-volatility}

In the Black-Scholes-Merton model, $\frac{\partial E}{\partial V}=\mathcal{N}(d_1)$, so that

$$
\begin{equation}
\sigma_E = \left(\frac{V}{E}\right)\mathcal{N}(d_1)\sigma_V
\end{equation}
$$ {#eq-firm-equity-volatility-and-firm-value-volatility-bsm}

We observe from the market:

- $E$, the equity value of the firm, the call option value
- $\sigma_E$, the volatility of equity

We then infer and solve for:

- $V$, the total value of the firm
- $\sigma_V$, the volatility of firm value

Once we have $V$ and $\sigma_V$, the distance to default (DD) can be calculated as

$$
\begin{equation}
DD=\frac{\ln(V/F)+ (\mu-0.5\sigma_V^2)T}{\sigma_V\sqrt{T}} 
\end{equation}
$$ {#eq-merton-distance-to-default}

where,

- $\mu$ is an estimate of the expected annual return of the firm's assets

The implied probability of default, or expected default frequency (EDF, registered trademark of Moody's KMV), is

$$
\begin{equation}
\pi_{Merton} = \mathcal{N}\left(-DD\right)
\end{equation}
$$ {#eq-merton-default-prob}

## Estimation

### An iterative approach

To estimate $\pi_{Merton}$, an iterative procedure can be applied instead of solving @eq-firm-equity-value-bsm and @eq-firm-equity-volatility-and-firm-value-volatility-bsm simultaneously (see @crosbie_modeling_2003, @vassalou_default_2004, @bharath_forecasting_2008, etc.).

1. Set the initial value of $\sigma_V=\sigma_E[E/(E+F)]$.
2. Use this value of $\sigma_V$ and equation (2) to infer the market value of firm's assets every day for the previous year.
3. Calculate the implied log return on assets each day, based on which generate new estimates of $\sigma_V$ and $\mu$.
4. Repeat steps 2 to 3 until $\sigma_V$ converges, i.e., the absolute difference in adjacent estimates is less than $10^{-3}$.
5. Use $\sigma_V$ and $\mu$ in equations (6) and (7) to calculate $\pi_{Merton}$.

### A naïve approach

A naïve approach by @bharath_forecasting_2008 that does not solve @eq-firm-equity-value-bsm and @eq-firm-equity-volatility-and-firm-value-volatility-bsm is constructed as below.

1. Approximate the market value of debt with the face value of debt, so that $D=F$.
2. Approximate the volatility of debt as $\sigma_D=0.05+0.25\sigma_E$, where 0.05 represents term structure volatility and 25\% of equity volatility is included to allow for volatility associated with default risk.
3. Approximate the total volatility as $\sigma_V = \frac{E}{E+D} \sigma_E + \frac{D}{E+D} \sigma_D$
4. Approximate the return on firm's assets with the firm's stock return over the previous year $r_{it-1}$.

The naïve distance to default is then

$$
\begin{equation}
\text{naïve } DD=\frac{\ln[(E+F)/F]+ (r_{it-1}-0.5\sigma_V^2)T}{\sigma_V\sqrt{T}}
\end{equation}
$$ {#eq-merton-distance-to-default-naive}

and the naïve default probability is

$$
\begin{equation}
\pi_{\text{naïve}} = \mathcal{N}(-\text{naïve } DD)
\end{equation}
$$ {#eq-merton-default-prob-naive}

## Code

The naïve method is too simple and skipped for now.

Here I discuss the iterative approach.

### Original SAS code in @bharath_forecasting_2008

The original code is enclosed in the [SSRN version](https://ssrn.com/abstract=637342) of @bharath_forecasting_2008, and was available on [Shumway's website](http://www-personal.umich.edu/~shumway/papers.dir/nuiter99_print.sas).

However, there are two issues in this version of code:

1. The initial value of $\sigma_V$ is not set to $\sigma_E[E/(E+F)]$ as described in the paper.
2. It does not use the past year's data but the past month.
   - At line 36, `cdt=100*year(date)+month(date)` accidentally restricts the "past year" daily stock returns to the "past month" later. Note that at line 42-43 it merges by `permno` and `cdt`, where `cdt` refers to a certain year-month. We can pause the program after this data step to confirm that indeed there is only a month of data for each `permno`.
   - A correction is to change line 36 to `cdt=100*&yyy.+&mmm.;`.

Other issues are minor and harmless.

A copy of this version can be found here on [GitHub](https://gist.github.com/mgao6767/12e3d99cd1bc55eee42bbe57d87fa042).

### My code

Based on the original SAS code in @bharath_forecasting_2008, I made some edits and below is a fully self-contained SAS code that executes smoothly. Note that I've corrected the above issues.

<script src="https://gist.github.com/mgao6767/1ae3cf6f8b38dd001d0cf7b6850d29a3.js"></script>

__Note__:

The interest rate data from FRB on WRDS stopped in April 2020. See [here](https://wrds-www.wharton.upenn.edu/pages/get-data/federal-reserve-bank-reports/).

To get estimates post 2020, we need to manually collect interest rate (3-month Treasury Bill) data and upload to WRDS. Then modify the relevant code, e.g. from line 96 to 117.
