---
title: Translog Cost Function Estimation
date: 2023-10-15
tags:
  - Economics
  - Econometrics
  - Stata
categories:
  - Teaching Notes
  - Research Notes
---

This post focuses on the [translog cost function](/posts/translog-production-and-cost-functions). 
I discuss the linear homogeneity constraint, the technique to impose the constraint, and its estimation via

- Ordinary Least Square (OLS)
- Stochastic Frontier Analysis (SFA)

Code examples are provided, too.

<!-- more -->

## Translog Cost Function

The [translog cost function](/posts/translog-production-and-cost-functions) is used to approximate potentially very complex cost functions, and hence complex underlying production functions due to the duality between production maximization and cost minimization.

In a general form, the translog cost function $\ln C(Q, W)$ as a function of output $Q$ and a vector of $n$ input prices $W$ is represented as

$$
\begin{align} 
\ln C(Q, W) &= \beta_0 + \beta_1 \ln Q + \frac{1}{2} \beta_2 (\ln Q)^2 \\
&+ \sum_{i=1}^{n} \gamma_i \ln W_i + \frac{1}{2} \sum_{i=1}^{n} \sum_{j=1}^{n} \theta_{ij} \ln W_i \ln W_j \nonumber \\
&+ \sum_{i=1}^{n} \phi_i \ln Q \ln W_i \nonumber
\end{align}
$$ {#eq-translog-cost-general}

## Linear Homogeneity Constraint

In economic theory, a cost function is often assumed to be linearly homogeneous in input prices. This means that if all input prices $W_i$ are scaled by a constant $\lambda > 0$, the total cost $C$ should also scale by the same constant $\lambda$. Mathematically, this is expressed as:

$$
\begin{equation}
C(Q, \lambda W) = \lambda C(Q, W)
\end{equation}
$$ {#eq-cost-func-linear-homogeneity}

Linear homogeneity @eq-cost-func-linear-homogeneity is an important property because it ensures that the cost function is consistent with the idea of constant returns to scale in prices.

### Implications for parameters

If we take the total differential of the log cost, holding output constant, we have,

$$
\begin{equation}
d\ln C = \sum_{i=1}^{n} \gamma_i d\ln W_i+ \frac{1}{2}\sum_{i=1}^{n}\sum_{j=1}^{n} \theta_{ij} \ln W_j d\ln W_i + \sum_{i=1}^{n}\phi_i \ln Q d\ln W_i
\end{equation}
$$

By assumption, all input prices scale by the same factor $\lambda$ so that $d\ln W_i$ is the same across all $n$ inputs. Therefore, we can factor it out, which gives,

$$
\begin{equation}
d\ln C = d\ln \bar{W} \sum_{i=1}^{n} \gamma_i + d\ln \bar{W}^2 \frac{1}{2}\sum_{i=1}^{n}\sum_{j=1}^{n} \theta_{ij} + d\ln \bar{W} \ln Q \sum_{i=1}^{n}\phi_i
\end{equation}
$$

To ensure $\frac{d\ln C}{d\ln \bar{W}}=1$ hence linear homogeneity in the translog cost function, the following conditions must be met:

$$
\begin{align}
\label{eq:linear-homogeneity-req1}
\sum_{i=1}^{n} \gamma_i &= 1 \\
\sum_{j=1}^{n} \theta_{ij} &= 0 \quad \text{for all } i \\
\sum_{i=1}^{n} \phi_{i} &= 0
\end{align}
$$ {#eq-linear-homogeneity-req1}

By imposing these constraints, we ensure that the estimated translog cost function is linearly homogeneous in input prices, which is a desirable property from both a theoretical and empirical standpoint.

::: {.callout-warning title="Do NOT forget to impose the constraint!"}
@zardkoohi_homogeneity_1986 published a 3-page paper on the _Journal of Finance_, essentially pointing out that some previous studies estimating translog cost functions forgot to impose the linear homogeneity constraint...
:::

## Technique to Impose Linear Homogeneity Constraint

But thankfully we have an easy technique to avoid constrained optimization.

Scaling the cost $C$ and input prices $W_i$ by one of the input prices, say $W_1$, is a common technique to impose the linear homogeneity constraint in translog cost functions. The scaled version of the translog cost function can be written as:

$$
\begin{align}
\label{eq:scaled-translog-cost}
\ln\left(\frac{C}{W_1}\right) &= \beta_0 + \beta_1 \ln Q + \frac{1}{2} \beta_2 (\ln Q)^2 \\
&+ \sum_{i=2}^n \gamma_i \ln\left(\frac{W_i}{W_1}\right) + \frac{1}{2} \sum_{i=2}^n \sum_{j=2}^n \theta_{ij} \ln\left(\frac{W_i}{W_1}\right) \ln\left(\frac{W_j}{W_1}\right) \nonumber \\
&+ \sum_{i=2}^{n} \phi_i \ln Q \ln \left(\frac{W_i}{W_1}\right) \nonumber
\end{align}
$$ {#eq-scaled-translog-cost}

Why does it satisfies linear homogeneity? Let me work it out one by one.

### First, $\sum \gamma = 1$

We can manipulate @eq-scaled-translog-cost a bit and find that,

$$
\begin{align}
\ln C &= \beta_0 + \beta_1 \ln Q + \frac{1}{2} \beta_2 (\ln Q)^2 + \ln W_1 + \sum_{i=2}^n \gamma_i \ln\left(\frac{W_i}{W_1}\right) + \dots \\
 &= \beta_0 + \beta_1 \ln Q + \frac{1}{2} \beta_2 (\ln Q)^2 + {\color{blue}\left(1-\sum_{i=2}^n \gamma_i\right)} \ln W_1 + \sum_{i=2}^n {\color{blue}\gamma_i} \ln W_i + \dots 
\end{align}
$$

Clearly, the sum of coefficients of $\ln W_i$ is 1, satisfying the linear homogeneity requirement @eq-linear-homogeneity-req1.

### Second, $\sum \phi = 0$

Focusing the part $\sum_{i=2}^{n} \phi_i \ln Q \ln \left(\frac{W_i}{W_1}\right)$ in @eq-scaled-translog-cost, we can find that,

$$
\sum_{i=2}^{n} \phi_i \ln Q \ln \left(\frac{W_i}{W_1}\right) =\sum_{i=2}^{n} {\color{blue}\phi_i} \ln Q \ln W_i {\color{blue}- \sum_{i=2}^{n} \phi_i} \ln Q \ln W_1
$$

Clearly, the sum of coefficients of the cross-terms $\ln Q \ln W_i$ is 0.

### Third, $\sum \theta = 0$

By the same rationale as above, we should be able to prove it as well. I didn't manually verify, but it should work out as expected.

::: {.callout-tip}
In summary, by using this scaling technique, we can estimate the translog cost function in a way that **automatically satisfies the linear homogeneity constraints**, making the estimation process more efficient.

After all, constrained optimization is difficult...
:::

## OLS or SFA? Efficiency Consideration

Now that we've established that we can estimate Equation @eq-scaled-translog-cost to ensure linear homogeneity constraint.
Given a firm-year panel, we can simply estimate the following model:

$$
\begin{align}
\label{eq:model-to-estimate}
\ln\tilde{C}_{mt} &= \beta_0 + \beta_1 \ln Q_{mt} + \frac{1}{2} \beta_2 (\ln Q_{mt})^2 \\
&+ \sum_{i=2}^n \gamma_i \ln\tilde{W}_{imt} + \frac{1}{2} \sum_{i=2}^n \sum_{j=2}^n \theta_{ij} \ln\tilde{W}_{imt} \ln\tilde{W}_{jmt} \nonumber \\
&+ \sum_{i=2}^{n} \phi_i \ln Q \ln \tilde{W}_{imt} + \epsilon_{mt} \nonumber
\end{align}
$$ {#eq-model-to-estimate}

where $m$ indexes the firm, $t$ represents time. $\tilde{C}_{mt}=\frac{C_{mt}}{W_{1mt}}$ and $\tilde{W}_{imt}=\frac{W_{imt}}{W_{1mt}}$ are the scaled total costs and input prices.

We can of course use OLS to estimate @eq-model-to-estimate. However, this approach means that we do not accounting for differences in efficiency among different firms. Specifically, OLS assumes that the error term ($\epsilon_{mt}$) in @eq-model-to-estimate is just random noise.

On the other hand, we can model $\epsilon_{mt}=v_{mt}+u_{mt}$ such that random error $v_{mt}$ is i.i.d. normal with mean zero and variance $\sigma^2_{v}$. The $u_{mt}$ term denotes the systematic deviations from the optimal cost due to inefficiency. $u_{mt}$ can be modeled to be i.i.d. half-normal and variance $\sigma^2_{u}$ independent of $v_{mt}$. This approach is basically a **Stochastic Frontier Analysis (SFA)**, which can be estimated via MLE.
An influential example is @koetter_enjoying_2012.

::: {.callout-note title="SFA: pooled or panel?"}
There are many further considerations when applying SFA, for example, whether a pooled "cross-sectional" SFA or a panel SFA. The former assumes a single efficient frontier for all firm-years, while the latter assumes a time-varying frontier. Moreover, in a panel SFA, we can further assume a time-invariant firm inefficiency, or a time-decaying firm inefficiency.

Based on my limited reading, it seems that the literature typically does not use panel SFA. I do not attempt to discuss which one to use, but will provide code examples for all.
:::

## Trend or Time Fixed Effects

In the literature, it is also very common to include either trend or time fixed effects in model @eq-model-to-estimate.

If we include trend, the model to estimate is:

$$
\begin{align}
\label{eq:model-to-estimate-trend}
\ln\tilde{C}_{mt} &= \beta_0 + \beta_1 \ln Q_{mt} + \frac{1}{2} \beta_2 (\ln Q_{mt})^2 \\
&+ \sum_{i=2}^n \gamma_i \ln\tilde{W}_{imt} + \frac{1}{2} \sum_{i=2}^n \sum_{j=2}^n \theta_{ij} \ln\tilde{W}_{imt} \ln\tilde{W}_{jmt} \nonumber \\
&+ \sum_{i=2}^{n} \phi_i \ln Q \ln \tilde{W}_{imt} {\color{blue}+ \eta_0 trend + \eta_1 trend^2 } \nonumber\\
&{\color{blue}+ \eta_2 trend \ln Q_{mt} + \sum_{i=2}^n \omega_{i} trend \ln\tilde{W}_{imt} }+ \epsilon_{mt} \nonumber 
\end{align}
$$ {#eq-model-to-estimate-trend}

If we include time fixed effects, the model to estimate is:

$$
\begin{align}
\label{eq:model-to-estimate-fe}
\ln\tilde{C}_{mt} &= \beta_0 + \beta_1 \ln Q_{mt} + \frac{1}{2} \beta_2 (\ln Q_{mt})^2 \\
&+ \sum_{i=2}^n \gamma_i \ln\tilde{W}_{imt} + \frac{1}{2} \sum_{i=2}^n \sum_{j=2}^n \theta_{ij} \ln\tilde{W}_{imt} \ln\tilde{W}_{jmt} \nonumber \\
&+ \sum_{i=2}^{n} \phi_i \ln Q \ln \tilde{W}_{imt}  {\color{blue}+ \tau_t} + \epsilon_{mt} \nonumber
\end{align}
$$ {#eq-model-to-estimate-fe}

## A Note on Marginal Cost

$$
\begin{align}
MC = \frac{\partial C}{\partial Q} &= \frac{\partial C}{\partial \ln C}\frac{\partial \ln C}{\partial \ln Q}\frac{\partial \ln Q}{\partial Q} = \frac{C}{Q}\frac{\partial \ln C}{\partial \ln Q}
\end{align}
$$

The marginal cost for bank $m$ at time $t$ is then obtained as

$$
\begin{align}
MC = \frac{C}{Q}\frac{\partial \ln C}{\partial \ln Q} = \frac{C}{Q}\frac{\partial (\ln \tilde{C} + \ln W_1) }{\partial \ln Q} = \frac{C}{Q}\frac{\partial \ln \tilde{C} }{\partial \ln Q}
\end{align}
$$

## Some related papers

- @beck_bank_2013
- @berger_bank_2009
- @shaffer_measuring_2020

## Code Examples

Here I demonstrate how to estimate translog function for banks. Specifically, I start with the bank-year data from BankScope downloaded via WRDS.

```stata
keep if ctrycode == "US"
keep if special == "Commercial banks"
// Use year-end data
keep if closdate == mdy(12, 31, year(closdate))
keep if 2015<=year(closdate) & year(closdate)<=2020
// Unit can be "0", "th", etc. 
// Most credit unions use "0" unit; Commercial banks use "th" (thousands)
keep if unit == "th"
// C1: statement of a mother bank integrating the statements of its controlled 
// subsidiaries or branches with no unconsolidated companion
keep if consol == "C1"

gen year = year(closdate)
encode bvdidnum, gen(bvdid)
xtset bvdid year

rename data91100 total_assets
rename data72500 staff_expenses
rename data72800 total_operating_expenses
rename data72700 other_operating_expenses
rename data72600 other_admin_expenses
rename data91300 total_customer_deposits
rename data82450 total_interest_customer_deposits

gen Q  = total_assets
gen C  = total_operating_expenses
gen W1 = staff_expenses / total_assets
gen W2 = total_interest_customer_deposits / total_customer_deposits
gen W3 = (other_operating_expenses+other_admin_expenses) / total_assets

winsor2 Q C W1 W2 W3, cut(1 99) replace

// Scale cost and input prices
gen C_s  = C / W1
gen W2_s = W2 / W1
gen W3_s = W3 / W1

gen logQ  = log(Q)
gen logC  = log(C_s)
gen logW2 = log(W2_s)
gen logW3 = log(W3_s)
```

Now it comes to the estimation. In some cases, like the one below with time fixed effects, Stata may fail to start the MLE process with an error "initial values not feasible".

```stata
frontier logC c.logQ##(c.logQ c.logW2 c.logW3) c.logW2#c.logW3 i.year, cost
```

According to this [Stata mail list](https://www.stata.com/statalist/archive/2003-05/msg00650.html), the reason is because Stata uses a method of moments estimator to find the starting values for MLE. For some datasets, especially those with almost no inefficiency effect, these starting values will not be feasible.

The solution, as I summarize, is to supply the starting values using `from()` (for half-normal or exponential models) or `ufrom()` (for truncated-normal model). Specifically,

1. Use a simple linear regression to get starting values for the
coefficients.
1. Use the natural log of the square of RMSE as the starting value for `lnsig2v` parameter, the natural log of variance of the idiosyncratic error.
1. Use a small positive number, say 0.1, as the starting value for the `lnsig2u` parameter, the natural log of the variance of the log of the inefficiency term.

```stata
// A simple linear regression
global rhs = "c.logQ##(c.logQ c.logW2 c.logW3) c.logW2#c.logW3 i.year"
regress  logC ${rhs}
// matrix b0_hnormal is [b..., lnsig2v, lnsig2u]
matrix b0_hnormal = e(b), ln(e(rmse)^2) , .1
```

Then, estimate SFA with the given starting values `b0_hnormal`. I additionally specify options `difficult` to automatically switch optimization algorithm. `iter` option may be used to limit the maximum number of iterations.

```stata
frontier logC ${rhs}, cost from(b0_hnormal, copy) dist(hnormal) difficult iter(25)
```

This time the estimation successfully complete. We can compute the margin cost MC as

```stata
gen MC = C/Q * (_b[logQ] + 2*_b[logQ#logQ]*logQ + _b[logQ#logW2]*logW2 + _b[logQ#logW3]*logW3)
```

If we use trend model instead, the above becomes

```stata
gen trend = year - 2015

global rhs = "c.logQ##(c.logQ c.logW2 c.logW3) c.logW2#c.logW3 c.trend c.trend#c.trend c.trend#c.logQ c.trend#(c.logW2 c.logW3)"
regress  logC ${rhs}

// matrix b0 is [b..., lnsig2v, lnsig2u]
matrix b0_hnormal = e(b), ln(e(rmse)^2) , .1

frontier logC ${rhs}, cost from(b0_hnormal, copy) dist(hnormal) difficult iter(25)

gen MC_trend = C/Q * (_b[logQ] + 2*_b[logQ#logQ]*logQ + _b[logQ#logW2]*logW2 + _b[logQ#logW3]*logW3 + _b[trend#logQ]*trend)
```

In this case, `MC` and `MC_trend` have a correlation of 1.0, so the two models (time fixed effects and trend) are basically the same.

Panel SFA can be done via `xtfrontier` in Stata (`xtfrontier` assumes truncated-normal).

```stata
global rhs = "c.logQ##(c.logQ c.logW2 c.logW3) c.logW2#c.logW3"
regress  logC ${rhs}
// matrix b0_xtfront is [b..., lnsigma2, lgtgamma, mu]
// see Stata help xtfrontier for the meaning of the params
matrix b0_xtfront = e(b), ln(e(rmse)^2) , .1 , .1

xtfrontier logC ${rhs}, cost ti from(b0_xtfront, copy) difficult iter(25)
```

Note that with panel SFA, the `ti` option specifies a time-invariant firm inefficient. Yet the inefficiency estimate is again highly correlated with the pooled SFA.
