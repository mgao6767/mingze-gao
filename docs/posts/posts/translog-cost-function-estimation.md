---
date: 2023-10-15
tags:
  - Economics
  - Econometrics
  - Stata
categories:
  - Teaching Notes
  - Research Notes
---

# Translog Cost Function Estimation

This post focuses on the [translog cost function](/posts/translog-production-and-cost-functions). 
I discuss the linear homogeneity constraint, the technique to impose the constraint, and its estimation via

- [x] Ordinary Least Square (OLS)
- [x] Stochastic Frontier Analysis (SFA)

Code examples are provided, too.

<!-- more -->

## Translog Cost Function

The [translog cost function](/posts/translog-production-and-cost-functions) is used to approximate potentially very complex cost functions, and hence complex underlying production functions due to the duality between production maximization and cost minimization.

In a general form, the translog cost function \( \ln C(Q, W) \) as a function of output \( Q \) and a vector of $n$ input prices \( W \) is represented as

\[
\begin{align} 
\ln C(Q, W) &= \beta_0 + \beta_1 \ln Q + \frac{1}{2} \beta_2 (\ln Q)^2 \\
&+ \sum_{i=1}^{n} \gamma_i \ln W_i + \frac{1}{2} \sum_{i=1}^{n} \sum_{j=1}^{n} \theta_{ij} \ln W_i \ln W_j \nonumber \\
&+ \sum_{i=1}^{n} \phi_i \ln Q \ln W_i \nonumber
\label{eq:translog-cost-general}
\end{align}
\]

## Linear Homogeneity Constraint

In economic theory, a cost function is often assumed to be linearly homogeneous in input prices. This means that if all input prices \( W_i \) are scaled by a constant \( \lambda > 0 \), the total cost \( C \) should also scale by the same constant \( \lambda \). Mathematically, this is expressed as:

\[
\begin{equation}
C(Q, \lambda W) = \lambda C(Q, W)
\end{equation}
\]

Linear homogeneity is an important property because it ensures that the cost function is consistent with the idea of constant returns to scale in prices.

### Implications for parameters

If we take the total differential of the log cost, holding output constant, we have,

\[
\begin{equation}
d\ln C = \sum_{i=1}^{n} \gamma_i d\ln W_i+ \frac{1}{2}\sum_{i=1}^{n}\sum_{j=1}^{n} \theta_{ij} \ln W_j d\ln W_i + \sum_{i=1}^{n}\phi_i \ln Q d\ln W_i
\end{equation}
\]

By assumption, all input prices scale by the same factor $\lambda$ so that $d\ln W_i$ is the same across all $n$ inputs. Therefore, we can factor it out, which gives,

\[
\begin{equation}
d\ln C = d\ln \bar{W} \sum_{i=1}^{n} \gamma_i + d\ln \bar{W}^2 \frac{1}{2}\sum_{i=1}^{n}\sum_{j=1}^{n} \theta_{ij} + d\ln \bar{W} \ln Q \sum_{i=1}^{n}\phi_i
\end{equation}
\]

To ensure $\frac{d\ln C}{d\ln \bar{W}}=1$ hence linear homogeneity in the translog cost function, the following conditions must be met:

\[
\begin{align}
\label{eq:linear-homogeneity-req1}
\sum_{i=1}^{n} \gamma_i &= 1 \\
\sum_{j=1}^{n} \theta_{ij} &= 0 \quad \text{for all } i \\
\sum_{i=1}^{n} \phi_{i} &= 0
\end{align}
\]

By imposing these constraints, we ensure that the estimated translog cost function is linearly homogeneous in input prices, which is a desirable property from both a theoretical and empirical standpoint.

!!! warning "Do NOT forget to impose the constraint!"

    [Zardkoohi, Rangan, and Kolari (1986)](https://www.jstor.org/stable/2328171) published a 3-page paper on the *Journal of Finance*, essentially pointing out that some previous studies estimating translog cost functions forgot to impose the linear homogeneity constraint...

## Technique to Impose Linear Homogeneity Constraint

But thankfully we have an easy technique to avoid constrained optimization.

Scaling the cost \( C \) and input prices \( W_i \) by one of the input prices, say \( W_1 \), is a common technique to impose the linear homogeneity constraint in translog cost functions. The scaled version of the translog cost function can be written as:

\[
\begin{align}
\label{eq:scaled-translog-cost}
\ln\left(\frac{C}{W_1}\right) &= \beta_0 + \beta_1 \ln Q + \frac{1}{2} \beta_2 (\ln Q)^2 \\
&+ \sum_{i=2}^n \gamma_i \ln\left(\frac{W_i}{W_1}\right) + \frac{1}{2} \sum_{i=2}^n \sum_{j=2}^n \theta_{ij} \ln\left(\frac{W_i}{W_1}\right) \ln\left(\frac{W_j}{W_1}\right) \nonumber \\
&+ \sum_{i=2}^{n} \phi_i \ln Q \ln \left(\frac{W_i}{W_1}\right) \nonumber
\end{align}
\]

Why does it satisfies linear homogeneity? Let me work it out one by one.

### First, $\sum \gamma = 1$

We can manipulate $\eqref{eq:scaled-translog-cost}$ a bit and find that,

\[
\begin{align}
\ln C &= \beta_0 + \beta_1 \ln Q + \frac{1}{2} \beta_2 (\ln Q)^2 + \ln W_1 + \sum_{i=2}^n \gamma_i \ln\left(\frac{W_i}{W_1}\right) + \dots \\
 &= \beta_0 + \beta_1 \ln Q + \frac{1}{2} \beta_2 (\ln Q)^2 + {\color{blue}\left(1-\sum_{i=2}^n \gamma_i\right)} \ln W_1 + \sum_{i=2}^n {\color{blue}\gamma_i} \ln W_i + \dots 
\end{align}
\]

Clearly, the sum of coefficients of $\ln W_i$ is 1, satisfying the linear homogeneity requirement $\eqref{eq:linear-homogeneity-req1}$.

### Second, $\sum \phi = 0$

Focusing the part \(\sum_{i=2}^{n} \phi_i \ln Q \ln \left(\frac{W_i}{W_1}\right)\) in $\eqref{eq:scaled-translog-cost}$, we can find that,

\[
\sum_{i=2}^{n} \phi_i \ln Q \ln \left(\frac{W_i}{W_1}\right) =\sum_{i=2}^{n} {\color{blue}\phi_i} \ln Q \ln W_i {\color{blue}- \sum_{i=2}^{n} \phi_i} \ln Q \ln W_1
\]

Clearly, the sum of coefficients of the cross-terms $\ln Q \ln W_i$ is 0.

### Third, $\sum \theta = 0$

By the same rationale as above, we should be able to prove it as well. I didn't manually verify, but it should work out as expected.

!!! tip

    In summary, ==by using this scaling technique, we can estimate the translog cost function in a way that **automatically satisfies the linear homogeneity constraints**==, making the estimation process more efficient.

    > Constrained optimization is difficult... Mingze (2023)

## OLS or SFA? Efficiency Consideration

Now that we've established that we can estimate Equation $\eqref{eq:scaled-translog-cost}$ to ensure linear homogeneity constraint.
Given a firm-year panel, we can simply estimate the following model:

\[
\begin{align}
\label{eq:model-to-estimate}
\ln\tilde{C}_{mt} &= \beta_0 + \beta_1 \ln Q_{mt} + \frac{1}{2} \beta_2 (\ln Q_{mt})^2 \\
&+ \sum_{i=2}^n \gamma_i \ln\tilde{W}_{imt} + \frac{1}{2} \sum_{i=2}^n \sum_{j=2}^n \theta_{ij} \ln\tilde{W}_{imt} \ln\tilde{W}_{jmt} \nonumber \\
&+ \sum_{i=2}^{n} \phi_i \ln Q \ln \tilde{W}_{imt} + \epsilon_{mt} \nonumber
\end{align}
\]

where $m$ indexes the firm, $t$ represents time. $\tilde{C}_{mt}=\frac{C_{mt}}{W_{1mt}}$ and $\tilde{W}_{imt}=\frac{W_{imt}}{W_{1mt}}$ are the scaled total costs and input prices.

We can of course use OLS to estimate $\eqref{eq:model-to-estimate}$. However, this approach means that we do not accounting for differences in efficiency among different firms. Specifically, OLS assumes that the error term (\(\epsilon_{mt}\)) in $\eqref{eq:model-to-estimate}$ is just random noise.

On the other hand, we can model $\epsilon_{mt}=v_{mt}+u_{mt}$ such that random error $v_{mt}$ is i.i.d. normal with mean zero and variance $\sigma^2_{v}$. The $u_{mt}$ term denotes the systematic deviations from the optimal cost due to inefficiency. $u_{mt}$ can be modeled to be i.i.d. half-normal and variance $\sigma^2_{u}$ independent of $v_{mt}$. This approach is basically a **Stochastic Frontier Analysis (SFA)**, which can be estimated via MLE. 
An influential example is [Koetter, Kolari, and Spierdijk (2012)](https://doi.org/10.1162/REST_a_00155).

## Trend or Time Fixed Effects

In the literature, it is also very common to include either trend or time fixed effects in model $\eqref{eq:model-to-estimate}$.

If we include trend, the model to estimate is:

\[
\begin{align}
\label{eq:model-to-estimate-trend}
\ln\tilde{C}_{mt} &= \beta_0 + \beta_1 \ln Q_{mt} + \frac{1}{2} \beta_2 (\ln Q_{mt})^2 \\
&+ \sum_{i=2}^n \gamma_i \ln\tilde{W}_{imt} + \frac{1}{2} \sum_{i=2}^n \sum_{j=2}^n \theta_{ij} \ln\tilde{W}_{imt} \ln\tilde{W}_{jmt} \nonumber \\
&+ \sum_{i=2}^{n} \phi_i \ln Q \ln \tilde{W}_{imt} {\color{blue}+ \eta_0 trend + \eta_1 trend^2 } \nonumber\\
&{\color{blue}+ \eta_2 trend \ln Q_{mt} + \sum_{i=2}^n \omega_{i} trend \ln\tilde{W}_{imt} }+ \epsilon_{mt} \nonumber 
\end{align}
\]

If we include time fixed effects, the model to estimate is:

\[
\begin{align}
\label{eq:model-to-estimate-fe}
\ln\tilde{C}_{mt} &= \beta_0 + \beta_1 \ln Q_{mt} + \frac{1}{2} \beta_2 (\ln Q_{mt})^2 \\
&+ \sum_{i=2}^n \gamma_i \ln\tilde{W}_{imt} + \frac{1}{2} \sum_{i=2}^n \sum_{j=2}^n \theta_{ij} \ln\tilde{W}_{imt} \ln\tilde{W}_{jmt} \nonumber \\
&+ \sum_{i=2}^{n} \phi_i \ln Q \ln \tilde{W}_{imt}  {\color{blue}+ \tau_t} + \epsilon_{mt} \nonumber
\end{align}
\]

## A Note on Marginal Cost

\[
\begin{align}
MC = \frac{\partial C}{\partial Q} &= \frac{\partial C}{\partial \ln C}\frac{\partial \ln C}{\partial \ln Q}\frac{\partial \ln Q}{\partial Q} = \frac{C}{Q}\frac{\partial \ln C}{\partial \ln Q}
\end{align}
\]

The marginal cost for bank \( m \) at time \( t \) is then obtained as 

\[
\begin{align}
MC = \frac{C}{Q}\frac{\partial \ln C}{\partial \ln Q} = \frac{C}{Q}\frac{\partial (\ln \tilde{C} + \ln W_1) }{\partial \ln Q} = \frac{C}{Q}\frac{\partial \ln \tilde{C} }{\partial \ln Q}
\end{align}
\]

## References

- [Beck, De Jonghe, and Schepens (2013)](https://doi.org/10.1016/j.jfi.2012.07.001)
Bank competition and stability: Cross-country heterogeneity,
*Journal of Financial Intermediation*, 22 (2), 218–244.

- [Berger, Klapper, and Turk-Ariss (2009)](https://doi.org/10.1007/s10693-008-0050-7)
Bank Competition and Financial Stability,
*Journal of Financial Services Research*, 35, 99–118.
   
- [Koetter, Kolari, and Spierdijk (2012)](https://doi.org/10.1162/REST_a_00155)
Enjoying the Quiet Life under Deregulation? Evidence from Adjusted Lerner Indices for U.S. Banks,
*Review of Economics and Statistics*, 94 (2), 462–480.

- [Shaffer and Spierdijk (2020)](https://doi.org/10.1016/j.jbankfin.2020.105859)
Measuring multi-product banks' market power using the Lerner index,
*Journal of Banking & Finance*, Volume 117, August 2020, 105859.

- [Zardkoohi, Rangan, and Kolari (1986)](https://www.jstor.org/stable/2328171), Homogeneity Restrictions on the Translog Cost Model: A Note,
*The Journal of Finance*, 41 (5), 1153-1155.

## Code Examples

!!! note
    To be added.