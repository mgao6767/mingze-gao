---
date: 2020-03-24
authors:
    - mgao
hasTex: true
tags:
  - Beta
categories:
  - Teaching Notes
slug: beta-unlevered-and-levered
---

# Beta - Unlevered and Levered

Beta is a measure of market risk. This post tries to explain the unlevered and levered betas.

<!-- more -->

## Unlevered Firm ***u***

If a firm has no debt, it's all equity-financed and thus its equity's beta
$\beta_{E}$ equals its asset's beta $\beta_{A}$. This beta is also the
**unlevered beta**, $\beta_{\text{unlevered}}$, since it's unaffected by
leverage. The unlevered beta measures the market risk exposure of the firm's
shareholders. Let's call this firm $u$, Hence, we have:

\begin{equation}
\beta_{\text{unlevered}}=\beta_E^u=\beta_A^u
\end{equation}

This equality says that in an unlevered firm, the unlevered beta equals its
equity beta and its asset beta.

## Levered Firm ***l***

If the ***same*** firm is partly financed by debt, let's call it firm $l$. The
asset of the levered firm $l$ is financed by both equity and debt, and hence the
asset's market risk is from both equity and debt. The asset's beta is a weighted
average of its equity beta and debt beta.


\begin{equation}
\beta_A^l = \frac{E}{E+D(1-t)} \beta_E^l + \frac{D(1-t)}{E+D(1-t)} \beta_D^l
\end{equation}


>  $\beta_A^l$ measures the change in the return on a portfolio of all firm
>  $l$'s securities (debt and equity) for each additional one percent change in
>  the market return.

This part is not very hard to understand. The beta of a portfolio is the
weighted average beta of its constituents. If you believe that debt beta is zero
since the value of debt may not be affected by the equity market, then
$\beta_D^l=0$ and the equation (2) can be simplified to:

$$
\begin{align}
\beta_A^l &= \frac{E}{E+D(1-t)} \beta_E^l \newline
    &= \frac{1}{1+\frac{D}{E}(1-t)} \beta_E^l
\end{align}
$$

However, this firm's shareholders are now more exposed to the market risk than
before, because leverage increases the variation in the payoff to shareholders.
This means the equity's beta of this levered firm is higher than the equity's
beta of the unlevered firm, i.e. $\beta_E^l>\beta_E^u$.

Note that, the **levered beta** $\beta_{\text{levered}}$ that we talk about
refers to $\beta_E^l$, which is the equity beta of the levered firm $l$.

## Unlevered vs Levered

On the other hand, firm $u$ and firm $l$ differ only in capital structure whilst
both have the same asset. Let's say we have a portfolio of firm $u$'s asset and
the other portfolio of firm $l$'s asset, then these two portfolios *should* have
the same expected return and market risk exposure.[^1] This means the two
portfolios have the same beta, implying:

$$\begin{equation}\beta_A^u = \beta_A^l \end{equation}$$

If we substitue in the definition of unlevered and levered beta (equation (1)
and (4)):

$$
\begin{equation}
\beta_{\text{unlevered}} =  \frac{1}{1+\frac{D}{E}(1-t)} \beta_{\text{levered}}
\end{equation}
$$

or

$$
\begin{equation} \beta_{\text{levered}} =  \left( 1+\frac{D}{E}(1-t) \right)
\beta_{\text{unlevered}} \end{equation}
$$

This is the formula that we use to lever and unlever beta.[^2] 

[^2]: This eq.(7) is also named **Hamada Equation**, where we assumed a zero
debt beta. It draws on the Modigliani-Miller theorem on capital structure, and
appeared in Prof. Robert Hamada's paper ["The Effect of the Firm's Capital
Structure on the Systematic Risk of Common
Stocks"](https://www.jstor.org/stable/2978486) in the *Journal of Finance* in
1972.

## Further Clarification

The equity beta of a firm with debts is **levered**. To remove the impact of
leverage on shareholders' market risk exposure, we need to **unlever** this beta
in order to get the **unlevered beta**. This unlevered beta is also called the
**asset beta**.

Note that the **asset beta** is a syncronym for **unlevered beta**. It is not,
however, the asset's beta $\beta_A^l$ when the firm is leveraged as in equation
(2) to (4). This convention is confusing indeed, so throughout this post, I'm
using *asset's beta* to refer to the beta of a portfolio of all securities (debt
and equity) of the levered firm.

<!-- To acquire a certain set of assets, the firm can choose to either finance 
through equity only, or using a combination of equity and debt, which should 
not affect how these assets are valued.[^1]  -->


## Notations

- $\beta_E^u$: the equity's beta of the unlevered firm
- $\beta_A^u$: the asset's beta of the unlevered firm
- $\beta_E^l$: the equity's beta of the levered firm
- $\beta_D^l$: the debt's beta of the levered firm
- $\beta_A^l$: the asset's beta of the levered firm
- $D$: the size of the firm's debt
- $E$: the size of the firm's equity
- $t$: the tax rate
- $\beta_{\text{unleverd}}$: **unlevered beta**, the equity (asset) beta of the
  unlevered version of the firm
- $\beta_{\text{leverd}}$: **levered beta**, the equity beta of the levered
  version of the firm
  

[^1]: Modigliani-Miller theorem states that the capital structure should not
affect a firm's value.