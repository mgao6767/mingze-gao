---
date: 2020-06-10
authors:
  - mgao
tags:
  - SAS
  - Code
  - Discretionary Accruals
  - Jackknife
categories:
  - Research Notes
---

# Compute Jackknife Coefficient Estimates in SAS

In certain scenarios, we want to estimate a model's parameters on the sample for
each observation with itself excluded. This can be achieved by estimating the
model repeatedly on the leave-one-out samples but is very inefficient. If we
estimate the model on the full sample, however, the coefficient estimates will
certainly be biased. Thankfully, we have the Jackknife method to correct for the
bias, which produces the ***Jackknifed*** coefficient estimates for each
observation.

<!-- more -->

## Variable Definition

Let's start with some variable definitions to help with the explanation.

| Variable                                                    | Definition                                                                                                     |
| ----------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| $b(i)$                                                      | the parameter estimates after deleting the $i$th observation                                                   |
| $s^2(i)$                                                    | the variance estimate after deleting the $i$th observation                                                     |
| $X(i)$                                                      | the $X$ matrix without the $i$th observation                                                                   |
| $\hat{y}(i)$                                                | the $i$th value predicted without using the $i$th observation                                                  |
| $r_i = y_i - \hat{y}_i$                                     | the $i$th residual                                                                                             |
| $h_i = x_i(X'X)^{-1}x_i'$                                   | the $i$th diagonal of the projection matrix for the predictor space, also called the hat matrix                |
| $RStudent =\frac{r_i}{s(i) \sqrt{1-h_i}}$                   | studentized residual                                                                                           |
| $(X'X)_{jj}$                                                | the $(j,j)$th element of $(X'X)^{-1}$                                                                          |
| $DFBeta_j = \frac{b_{j} - b_{(i)j}}{s(i)\sqrt{(X'X)_{jj}}}$ | the scaled measures of the change in the $j$th parameter estimate calculated by deleting the $i$th observation |

## Objective

Compute the coefficient estiamtes with the $i$th observation excluded from the
sample, i.e. $b(i)$, or the Jackknifed coefficient estimate.

## Formula

From the table above, we can get that the $j$th Jackknifed coefficient estimate
$b_{(i)j}$ without using the $i$th observation is:

$$b_{(i)j} = b_j - DFBeta_j \times s(i) \sqrt{(X'X)_{jj}} $$

Hence,

$$b_{(i)j} = b_j - DFBeta_j \times \frac{r_i}{RStudent\times \sqrt{1-h_i}} \sqrt{(X'X)_{jj}}$$

The good thing is that `PROC REG` produces the coefficient estimate $b_j$ for
$j=1,2,...K$, where $K$ is the number of coefficients, and the `INFLUENCE` and
`I` options produce the remaining statistics just enough to compute $b(i)$:

| Variable     | Option in `PROC REG` or `MODEL` statement                        | Name in the output dataset |
| ------------ | ---------------------------------------------------------------- | -------------------------- |
| $b_j$        | `Outest=` option in `PROC REG`                                   | `<jthVariable>`            |
| $r_i$        | `OutputStatistics=` from `INFLUENCE` option in `MODEL` statement | `Residual`                 |
| $RStudent$   | `OutputStatistics=` from `INFLUENCE` option in `MODEL` statement | `RStudent`                 |
| $h_i$        | `OutputStatistics=` from `INFLUENCE` option in `MODEL` statement | `HatDiagnol`               |
| $DFBeta_j$   | `OutputStatistics=` from `INFLUENCE` option in `MODEL` statement | `DFB_<jthVariable>`        |
| $(X'X)_{jj}$ | `InvXPX=` from `I` option in `MODEL` statement                   | `<jthVariable>`            |

## Example

### Discretionary accruals
Suppose we want to calculate the firm-level [discretionary
accruals](/documentation/discretionary-accruals/) for each year using the Jones
(1991) model and Kothari et al (2005) model. For a firm $i$, we need to first
estimate the model for the industry-year excluding firm $i$, then use the
coefficient estimates to generate predicted accruals for firm $i$. The firm's
discretionary accruals is the actual accruals minus the predicted accruals.

Below is an example `PROC REG` that produces three datasets named `work.params`,
`work.outstats` and `work.xpxinv`, which contain sufficient statistics to
compute the Jackknifed estimates and thus the predicted accruals.

```sas linenums="1"
ods listing close; 
proc reg data=work.funda edf outest=work.params;
  /* industry-year regression */
  by fyear sic2;
  /* id is necessary for later matching Jackknifed coefficients to firm-year */
  id key;
  /* Jones Model */
  Jones: model tac = inv_at_l drev ppe / noint influence i;
  /* Kothari Model with ROA */
  Kothari: model tac = inv_at_l drevadj ppe roa / noint influence i;
  ods output OutputStatistics=work.outstats InvXPX=work.xpxinv;
run;
ods listing;
```

Full SAS program for estimating 5 different measures of discretionary accruals:

<script src="https://gist.github.com/mgao6767/3e1df83bbb78d76b76ed83ceb6af7993.js"></script>
