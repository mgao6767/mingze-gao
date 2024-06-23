---
# date: Nov 10, 2022
date: 2023-04-09
draft: false
hasTex: true
authors:
  - mgao
tags:
  - Econometrics
categories:
  - Research Notes
---

# Correlated Random Effects

Can we estimate the coefficient of gender while controlling for individual fixed effects? This sounds impossible as an individual's gender typically does not vary and hence would be absorbed by individual fixed effects. However, **Correlated Random Effects (CRE)** may actually help.

At last year's FMA Annual Meeting, I learned this CRE estimation technique when discussing a paper titled "Gender Gap in Returns to Publications" by Piotr Spiewanowski, Ivan Stetsyuk and Oleksandr Talavera. Let me recollect my memory and summarize the technique in this post.

<!-- more -->

## Random Intercept (Effect) Model

Consider a random intercept model for a firm-year regression, e.g., to examine the relationship between firm performance, R&D expense, and whether the firm is VC-backed,

$$
\begin{equation}
\label{eq:random_effect_model}
y_{it} = \beta_0 + \beta_1 x_{it} + \beta_2 c_i + \mu_i + \varepsilon_{it}
\end{equation}
$$

where,

- $y_{it}$ is firm-year level outcome variable, e.g., firm ROA
- $x_{it}$ is firm-year level independent variable, e.g., firm R&D expense
- $c_i$ is an time-invariant firm-level variable, e.g., if the firm is VC-backed
- $\mu_i$ is firm-level error and random intercept to capture the unobserved, time-invariant factors
- $\varepsilon_{it}$ is firm-year level error, assumed to be white noise and ignored in this post

We can estimate $\beta_0$, $\beta_1$, $\beta_2$ and $\mu_i$. Assuming that we've properly controlled for observable firm characteristics, $\beta_1$ tells the relationship between R&D expenditure and firm performance. $\beta_2$ tells the difference in firm performance between VC-backed and non-VC-backed firms.

However, we cannot rely on $\beta_2$ to assert whether VC-back firms have better or worse performance. The drawback here is that we are unable to exhaustively control for all other time-invariant firm attributes that correlate with both firm performance and VC investment, thereby leading to biased $\beta_2$ estimate due to omitted variables.

Similarly, our estimate of $\beta_1$ may also be biased if some omitted firm-specific and time-invariant attributes correlate with both R&D expenditure and firm performance.

## Fixed Effect Model

If we subtract the "between" model

$$
\begin{equation}
\label{eq:between_model}
\bar{y}_{i} = \beta_0 + \beta_1 \bar{x}_{it} + \beta_2 c_i + \mu_i + \bar{\varepsilon}_{i}
\end{equation}
$$

from Equation $\eqref{eq:random_effect_model}$, we have the fixed effect model in the demeaned form:

$$
\begin{equation}
\label{eq:demeaned_form}
(y_{it} - \bar{y}_i) = \beta_1 (x_{it}-\bar{x}_i) + (\varepsilon_{it} - \bar{\varepsilon}_{i})
\end{equation}
$$

The fixed effect model above removes the firm-level error $\mu_i$ so that the within effect (or fixed effect) estimate of $\beta_1$ is unbiased even if $E(\mu_i|x_{it}) \ne 0$. This helps a lot and is why most of the time we control for firm fixed effects when estimating firm-year regressions.

However, the firm-level variable $c_i$ is also removed. It is now impossible to estimate $\beta_2$ as in the random intercept model. In fact, we can no longer estimate the effect of any firm-level time-invariant attributes after controlling for firm fixed effects.

## Hybrid Model

So, how to estimate both $\beta_2$ when firm fixed effects are controlled for?

The same question, if paraphrased differently, is _how to estimate the within effect in a random intercept model_.

Interestingly, we can decompose the firm-year level variable $x_{it}$ into two components, a between component $\bar{x}_i$ and a cluster component $(x_{it}-\bar{x}_i)$, so that

$$
\begin{equation}
\label{eq:hybrid}
y_{it} = \beta_0 + \beta_1 (x_{it}-\bar{x}_i) + \beta_2 c_i + \beta_3 \bar{x}_i + \mu_i + \varepsilon_{it}
\end{equation}
$$

It is apparent that the $\beta_1$ estimate gives the within effect as in the fixed effect model, identical to $\beta_1$ in Equation $\eqref{eq:demeaned_form}$.

Moreover, the firm-level variable $c_i$ is kept in the model and we can estimate $\beta_2$. The inclusion of cluster mean $\bar{x}_i$ corrects the estimate of $\beta_2$ for between-cluster differences in $x_{it}$. Note that, however, for $\beta_2$ estimate to be unbiased, we still require $E(\mu_i|x_{it},c_i)=0$ and $\mu_i|x_{it},c_i \sim N(0,\sigma^2_\mu)$.

## Correlated Random Effect Model

A related model is correlated random effect model ([Wooldridge 2010](https://mitpress.mit.edu/9780262232586/econometric-analysis-of-cross-section-and-panel-data/)) that relaxes the assumption of zero correlation between the firm-level error $\mu_i$ and firm-year variable $x_{it}$. Specifically, it assumes that $\mu_i=\pi\bar{x}_i + v_i$, so Equation $\eqref{eq:random_effect_model}$ becomes

$$
\begin{align}
y_{it} &= \beta_0 + \beta_1 x_{it} + \beta_2 c_i + \mu_i + \varepsilon_{it} \\
 &= \beta_0 + \beta_1 x_{it} + \beta_2 c_i + \pi\bar{x}_i + v_i + \varepsilon_{it}
\end{align}
$$

By including the cluster mean $\bar{x}_i$, we can account for the correlation between the random effects $\mu_i$ and the independent variable $x_{it}$ and obtain consistent estimates of the coefficients. The inclusion of $\bar{x}_i$ in the random intercept (effect) model makes the estimate for $\beta_1$ the same within effect (fixed-effect) estimate as in Equation $\eqref{eq:hybrid}$.

Of course, as the time-invariant firm-specific attribute $c_i$ remains in the model, we can estimate $\beta_2$ as in the hybrid model.

## Estimation

Note that there are many caveats for estimating CRE.

To be discussed.

## Further Readings

This post is based on [Within and between Estimates in Random-Effects Models: Advantages and Drawbacks of Correlated Random Effects and Hybrid Models](https://doi.org/10.1177/1536867X1301300105).

Some other suggested readings include:

- [Correlated random effects models with unbalanced panels](http://econ.msu.edu/faculty/wooldridge/docs/cre1_r4.pdf).
- [Fitting and Interpreting Correlated Random-coefficient Models Using Stata](https://doi.org/10.1177/1536867X1801800109).
- [A correlated random effects approach to the estimation of models with multiple fixed effects](https://doi.org/10.1016/j.econlet.2022.110408).