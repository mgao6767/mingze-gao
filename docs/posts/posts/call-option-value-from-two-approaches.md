---
authors:
  - mgao
date: 2020-05-25
hasTex: true
tags:
  - Option
categories:
  - Teaching Notes
---

# Call Option Value from Two Approaches

Suppose today the stock price is $S$ and in one year time, the stock price could
be either $S_1$ or $S_2$. You hold an European call option on this stock with an
exercise price of $X=S$, where $S_1<X<S_2$ for simplicity. So you'll exercise
the call when the stock price turns out to be $S_2$ and leave it unexercised if
$S_1$.

<!-- more -->

## 1. Replicating Portfolio Approach

|                                               | Case 1       | Case 2       |
| --------------------------------------------- | ------------ | ------------ |
| Stock Price                                   | $S_1$        | $S_2$        |
| **Option: 1 Call of cost $c$**                |              |              |
| Exercise?                                     | No           | Yes          |
| Payoff (to replicate)                         | 0            | $S_2-X$      |
| **Stock: $\delta$ shares of cost $\delta S$** |              |              |
| Payoff                                        | $\delta S_1$ | $\delta S_2$ |
| **Borrowing PV(K)**                           |              |              |
| Repay                                         | K            | K            |

So we have:

$$
\begin{equation}
\delta S_1-K=0
\end{equation}
$$

$$
\begin{equation}
\delta S_2 -K = S_2-X
\end{equation}
$$

Therefore, the call option value is given by the difference between the cost of
$\delta$ units of shares and the amount of borrowing:

$$
\begin{align} 
c_{REP} &= \delta S - PV(K) \newline
  &= \delta S - Ke^{-r_f} \newline
  &= \delta S - \delta S_1e^{-r_f}
\end{align}
$$

When $\delta$ is defined as $\frac{(S_2-X)-0}{S_2-S_1}$ as in the textbook (at
introductory level),

$$
\begin{equation}
  c_{REP}= \frac{S_2-X}{S_2-S_1}(S - S_1e^{-r_f})
\end{equation}
$$

## 2. Risk Neutral Approach

Without too much trouble, we can derive the call value using risk neutral
approach as

$$
\begin{align}
c_{RN} &= \frac{p(S_2-X)+(1-p)\times0}{e^{r_f}}\newline
&= \frac{p(S_2-X)+0}{e^{r_f}}\newline
 &= p(S_2-X) e^{-r_f}
\end{align}
$$

We know that

$$
\begin{equation}
p\times \frac{S_2}{S} + (1-p)\frac{S_1}{S} = e^{r_f}
\end{equation}
$$

so

$$
\begin{align}
p &= \frac{e^{r_f}-\frac{S_1}{S}}{\frac{S_2}{S}-\frac{S_1}{S}}\newline
&=\frac{Se^{r_f}-S_1}{S_2-S_1}
\end{align}
$$

Therefore,

$$
\begin{align}
c_{RN} &= p(S_2-X) e^{r_f}\newline
&=\frac{Se^{r_f}-S_1}{S_2-S_1}(S_2-X) e^{-r_f}\newline
&=\frac{S-S_1e^{-r_f}}{S_2-S_1}(S_2-X)
\end{align}
$$

## Identical Result from the Two Methods

It's easy to find that

$$
c_{RN} = c_{REP}
$$

Hence, the call option value from replicating portfolio is the same as from risk
neutral approach.