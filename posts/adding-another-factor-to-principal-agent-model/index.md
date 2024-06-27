---
title: Adding Another Factor to Principal-Agent Model
date: 2022-03-06
tags:
    - Organization Capital
    - Principal-Agent model
categories:
    - Research Notes
---

## Background

In a traditional principal-agent model, firm output is a function of the agent's effort and the principal observes only the output not agent's effort. The principal carefully designs the agent's compensation package, especially the sensitivity of the agent's pay to firm output, to maximize the firm value. Now, what if we add another factor to the relationship between firm output and agent's effort? How would the optimal pay sensitivity change?

<!-- more -->

My earlier paper [@gao_organization_2021] studied this issue by assuming such a factor, organization capital, that substitutes agent's effort in improving firm output. I find that if firm output is a function of two substituting factors (of which one is agent's effort), the optimal sensitivity of agent's pay to firm output can be both higher or lower, depending on the principal's choice.

To yield this two-way prediction, let's see a simple extension to the standard principal-agent model following @holmstrom_aggregation_1987, where the principal hires an agent (CEO) to run the firm. We added organization capital (OC) as an additional determinant of firm outcomes, but in fact we can assume any factor, e.g., intellectual property, IT infrastructure, etc., that either strengthens or weakens the relation between firm output and executive effort.

## Model

The production function is given by $V(a,o)=f(a,o)+\varepsilon$, where $a$ is the effort by the agent, $o$ is the firm’s organization capital, and $\varepsilon$ is random noise.

- $f(a,o)$ is an increasing function in both $a$ and $o$. The substitutability of OC and executive effort implies that $\frac{\partial^2}{\partial o \partial a}f(a,o)<0$, i.e., OC reduces the marginal effect of any agent action on firm outcomes.
- Without loss of generality, we assume $f(a,o)=a+(1-a)o$, where both $a$ and $o$ follow a continuous uniform distribution from 0 to 1.

The agent is paid a wage $c(V)$ and has reservation utility of $\underline U$. His objective function is given by $E\left[U\right]=E\left[u\left(v\left(c\right)-g\left(a\right)\right)\right]$.

- The increasing and weakly convex function $g$ represents the cost of effort.
- The function $u$ represents his utility function and $v$ represents his felicity function (i.e., his utility from cash), both increasing and weakly concave.
- The functions $g$, $u$ and $v$ are all twice continuously differentiable.
  
The risk-neutral principal chooses the effort level $a$ and contract $c$ to maximize the expected firm value minus the wage paid to the agent,

$$
    \max_{c(\cdot),a} E\left[V\left(a,o\right)-c\left(V\left(a,o\right)\right)\right]
$$

subject to the individual rationality or participation constraint (IR) and incentive compatibility constraint (IC) as follows:

$$
\begin{align}
&E\left[u\left(v\left(c\left(V\left(a,o\right)\right)\right)-g\left(a\right)\right)\right] \ge \underline{U} \\
&a \in \arg\max_{\hat{a}}E\left[u\left(v\left(c\left(V\left(\hat{a},o\right)\right)\right)-g\left(\hat{a}\right)\right)\right]
\end{align}
$$

We first consider the case where the optimal effort is determined endogenously. Under the @holmstrom_aggregation_1987 framework, the following assumptions are made:

1. an exponential utility function of the agent, $u(x)=-e^{-\eta x}$, where $\eta$ is the coefficient of constant absolute risk aversion,
2. $v(c)=c$, such that cost of effort is pecuniary and can be viewed as a subtraction to cash pay, 
3. a normal noise, $\varepsilon \sim N(0,\sigma^2)$, and 
4. that the agent chooses his effort continuously in a multiperiod model and the optimal contract is linear, i.e., $c=\phi+\theta V$, where $\phi$ is the fixed wage and $\theta$ represents the proportion of firm outcomes shared with the agent via compensation (i.e., $\theta$ represents the agent’s pay-for-performance sensitivity).

Further, @holmstrom_aggregation_1987 show that the problem is equivalent to a single-period static problem under these assumptions. For simplicity, we also assume a quadratic cost of effort, $g(a)=\frac{1}{2}ga^2$, so that the principal’s optimization problem becomes:

$$
    \max_{\phi,\theta,a^*} E\left[V-c\right]
$$

subject to

$$
\begin{align}
&E\left[-e^{-\eta\left(c-\frac{1}{2}ga^{*2}\right)}\right] \ge \underline{U} \\
& a^* \in \arg\max_{\hat{a}} E\left[-e^{-\eta\left(c-\frac{1}{2}g\hat{a}^2\right)}\right]
\end{align}
$$

Substituting in $c=\phi+\theta V$ and $V(a,o)=f(a,o)+\varepsilon$, maximizing the agent’s (negative exponential) utility function is equivalent to maximizing $\phi+\theta f(a,o)-\frac{1}{2}ga^2-\frac{1}{2}\eta \theta^2 \sigma^2$. 

Since $f(a,o)=a+(1-a)o$, the first-order condition of the agent’s objective function with respect to a is given by $a^*=\theta(1-o)⁄g$, which implies his effort choice is decreasing in the cost of effort $g$, decreasing in the firm’s organization capital $o$, and increasing in the pay-for-performance sensitivity $\theta$.

Moreover, his chosen effort is independent of the fixed wage $\phi$, so that the principal can adjust the fixed pay to satisfy his participation constraint without affecting the incentives. Substituting $a^*=\theta(1-o)⁄g$ into the principal’s objective function and setting the participation constraint to bind, the optimal level of pay-for-performance sensitivity is given by:

$$
    \theta = \frac{1}{1+\eta g \frac{\sigma^2}{(1-o)^2}}
$$

::: {.callout-note}
This optimal level of pay-for-performance sensitivity is derived as follows. Substituting $c=\phi + \theta V$ and $V(a,o)=f(a,o)+\varepsilon$ into the agent's objective function of $E\left[U\right]=E\left[u\left(v(c)-g(a)\right)\right]$, where $u(x)=-e^{-\eta x}$, $v(c)=c$, and $\varepsilon \sim N(0,\sigma^2)$, we obtain:

$$
\begin{align}
  E\left[U\right] &= E\left[e^{-\eta \left(\phi+\theta f(a,o)+\theta\varepsilon-\frac{1}{2}ga^2\right)}\right] \\
  &= -E\left[e^{-\eta \left(\phi+\theta f(a,o)-\frac{1}{2}ga^2\right)}\right] \times E\left[e^{-\eta \theta \varepsilon}\right]\\
  &= -e^{-\eta \left(\phi+\theta f(a,o)-\frac{1}{2}ga^2\right)} \times e^{\frac{\eta^2 \theta^2 \sigma^2}{2}} \\
  &= -e^{-\eta \left(\phi+\theta f(a,o)-\frac{1}{2}ga^2-\frac{1}{2}\eta \theta^2 \sigma^2\right)}
\end{align}
$$

The first-order condition (FOC) of the agent with respect to $a$ is given by

$$
  \frac{\partial}{\partial a}\left(\phi+\theta f(a^*,o)-\frac{1}{2}ga^{*2}-\frac{1}{2}\eta\theta^2\sigma^2\right)=0
$$

Since we assume $f(a,o)=a+(1-a)o$, this yields the agent's FOC:

$$
  a^*=\theta(1-o)/g
$$

Setting the participation constraint to bind, we have

$$
  E\left[U\right] = -e^{-\eta\left(\phi+\theta\left(a^*+(1-a^*)o\right)-\frac{1}{2}ga^{*2}-\frac{1}{2}\eta\theta^2\sigma^2\right)} = \underline{U}
$$

The above equation implies:

$$
  \phi + \theta\left(a^*+\left(1-a^*\right)o\right)-\frac{1}{2}ga^{*2}-\frac{1}{2}\eta\theta^2\sigma^2=w
$$

where $w\equiv -\ln(-\underline{U})/\eta$ is a constant determined by the agent's reservation utility and his coefficient of constant absolute risk aversion. Substituting in $a^*=\theta(1-o)/g$, we yield

$$
  E\left[c\right] = \phi + \theta E\left[V\right] \\
  = w+\frac{\theta^2(1-o)^2}{2g} +\frac{1}{2}\eta\theta^2\sigma^2
$$

Thus, by substituting $a^*=\theta(1-o)/g$ into the principal’s objective function $E\left[V-c\right]$, we yield

$$
  a^*+(1-a^*)o-\left[w+\frac{\theta^2(1-o)^2}{2g}+\frac{1}{2}\eta\theta^2\sigma^2\right] \\
  =\frac{\theta}{g}(1-o)^2+o-\left[w+\frac{\theta^2(1-o)^2}{2g}+\frac{1}{2}\eta\theta^2\sigma^2\right]
$$

The principal's FOC with respect to $\theta$ yields:

$$
  \theta = \frac{1}{1+\eta g \frac{\sigma^2}{(1-o)^2}}
$$
:::

Other things equal, we can see that the optimal pay-for-performance sensitivity $\theta$ is decreasing in the firm’s organization capital $o$. Specifically, this substitution effect is from the fact that OC reduces the marginal effect of executive effort on firm outcomes and thus reduces the optimal effort level endogenously.

On the other hand, fixing $a^*$, the required pay-for-performance sensitivity is $\theta=(a^* g)/(1-o)$, which is increasing in organization capital $o$. Thus, to elicit any given level of effort, the incentive compensation must be more high-powered ("fixed target action" as in @edmans_executive_2016.

## Implications

The relation between OC and executive pay-for-performance sensitivity depends critically on the optimal level of effort the principal wants to implement:

- If the principal wants to implement a fixed target action (e.g., $a=1$ in our case, or to induce full effort in general), the optimal $\theta$ is increasing in the firm’s organization capital.
- If the principal trades off the benefits and costs of high effort, the optimal $\theta$ is decreasing in the firm’s organization capital.

Therefore, the model offers two empirical predictions. On the one hand, high OC firms may offer higher pay-for-performance sensitivity to induce executive effort. On the other hand, pay-for-performance sensitivity may be reduced in high OC firms as a result of efficiency gains from the substitution of OC for executive effort.

Now, coming back at the question at the beginning, adding another factor to the principal-agent model may cause the optimal pay structure to change in either direction, even if such factor has a directional impact on the relation between firm output and agent's effort. In our case, such factor reduces the marginal effect of agent's effort on firm output. But one can easily find many other factors that may increase the marginal effect of agent's effort and yield similar predictions.

Perhaps, what's also interesting is that, if we know the directional effect of a factor while observing both pay-for-performance sensitivity and the level of such factor, we may be able to infer whether the principal elicits full executive effort at all costs. Paired with firm performance, could this be some indicators of governance or board ability? Seems like some future research questions.

> This post is adapted from the online appendix of @gao_organization_2021.
