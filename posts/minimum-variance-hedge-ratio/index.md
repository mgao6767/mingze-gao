---
title: Minimum Variance Hedge Ratio
date: 2020-05-26
hasTex: true
tags:
  - Hedge
categories:
  - Teaching Notes
---

This note briefly explains what's the **minimum variance hedge ratio** and how
to derive it in a cross hedge, where the asset to be hedged is not the same as
underlying asset.

<!-- more -->

## The Hedge Ratio $h$

The hedge ratio $h$ is the ratio of the size of the hedging position to the
exposure of the asset to be hedged:

- $N_A$: the units of asset held to be hedged ($A$), i.e. the risk exposure.
- $N_F$: the units of the underlying asset hedged with futures ($A'$).
  - Note that the underlying asset $A'$ may not be the same as the asset to be hedged $A$.
  - In a cross hedge, the underlying of the futures is different from the asset to be hedge.

$$
h=\frac{N_F}{N_A}=\frac{\text{size of hedging position}}{\text{size of exposure}}
$$

Apparently, if we vary $h$, the variance (risk) of the combined hedged position
will also change.

## The (Optimal) Minimum-Variance Hedge Ratio $h^*$

Our objective in hedging is to manage the variance (risk) of our position,
making it as low as possible by setting the hedge ratio $h$ to be the optimal
hedge ratio $h^*$ that minimises the variance of the combined hedged position.

### Hedge where $A'=A$

It's relatively easy when the underlying asset of the futures ($A'$) is the same
as the asset to be hedged ($A$), as they have a perfect correlation and the same
variance. Thus, as long as the hedge ratio $h=1$, where the size of hedging
position equals the exposure of the asset held, the perfect correlation and same
variance ensure the value changes in the hedging position offset the changes in
the value of asset to be hedged, so that the variance of the hedged position is
minimum at zero (ignoring other basis risks). This means, the optimal
minimum-variance hedge ratio $h^*=1$.

### Cross Hedge where $A' \neq A$

When the underlying asset of the futures ($A'$) differ from asset to be hedged
($A$), the optimal hedge ratio $h^*$ that minimises the portfolio variance is
not necessarily 1 anymore. 

Let's now derive $h^*$.

- $S_t$: the spot price of the asset to be hedged at time $t=1,2$.
- $F_t$: the price of the futures at time $t=1,2$.
- $\sigma_S$: the standard deviation of $\Delta S=S_2 - S_1$.
- $\sigma_F$: the standard deviation of $\Delta F=F_2 - F_1$.
- $\rho$: the correlation coefficient between $\Delta S$ and $\Delta F$.

Let's consider a **short hedge**, where we **long $S_t$** and **short $h\times
F_t$**, hence：

- Combined position $C=S_t-h\times F_t$
- $\Delta C=\Delta S_t-h\times \Delta F_t$

The optimal hedge ratio $h^*$ is the hedge ratio that minimises the variance of
$\Delta C$.

$$
h^* =\underset{h}{\operatorname{argmin}} \text{Var}(\Delta C)
=\underset{h}{\operatorname{argmin}} \text{Var}(\Delta S_t-h\times \Delta F_t)
$$

We also know that

$$
\text{Var}(\Delta S_t-h\times \Delta F_t) = \sigma^2_S + h^2\sigma^2_F -
2h(\rho \sigma_S \sigma_F)
$$

To minimise the variance, the first-order condition (FOC) is that

$$
\frac{\partial \text{Var}(\Delta C)}{\partial h}=2h\sigma^2_F-2(\rho \sigma_S
\sigma_F)=0
$$

The optimal hedge ratio $h^*$ is the $h$ that solves the FOC above. Therefore,

$$
h^* = \rho \frac{\sigma_S}{\sigma_F}
$$

## Intuition

The optimal hedge ratio $h^*$ describes the optimal $N_F/N_A$, so that the
optimal size of the hedging position:

$$
N_F^* = h^* \times N_A
$$

- If $F$ changes by 1%, $S$ is expected to change by $h^*$%.
- If $S$ changes by 1%, $F$ is expected to change by $(1/h^*)$%.

If $\rho=1$ and $\sigma_F=\sigma_S$, then $h^*=1$:

- $F$ and $S$ always change in the same way by the same size.
- Holding the same amount of $F$ as $S$ gives the perfect hedge.

If $\rho=1$ and $\sigma_F=2\sigma_S$, then $h^*=0.5$:

- $F$ always changes twice as much as $S$.
- Holding half as much of $F$ as $S$ gives the perfect hedge.

If $\rho<1$, then $h^*$ depends on $\rho$ and ${\sigma_S}/{\sigma_F}$:

- $F$ is _expected_ to change by $(1/h^*)$% when $S$ changes by 1%.
- Holding $h^*$ as much of $F$ as $S$ gives an imperfect hedge where the value of the hedging position is _expected_ to offset the change in $S$.
