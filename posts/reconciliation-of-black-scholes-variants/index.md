---
title: Reconciliation of Black-Scholes Variants
date: 2020-05-25
tags:
  - Option
categories:
  - Teaching Notes
---

This note is just to show that the different variants of Black-Scholes formula in textbook and tutorial solutions are in fact the same.

<!-- more -->

- $S$: Underlying share price
- $t$: Time to maturity
- $\sigma$: Standard deviation of underlying share price
- $K$: Exercise price
- $r_f$: Risk-free rate

## Variant 1

This is the one shown in our formula sheet, and is also the traditional
presentation of Black-Scholes model.

$$
\begin{equation}
C=SN(d_1)-N(d_2)Ke^{-r_f t}
\end{equation}
$$ {#eq-bs-call-value}

$$
\begin{equation}
d_1=\frac{ln(\frac{S}{K})+(r_f+\frac{\sigma^2}{2})t}{\sigma \sqrt{t}}
\end{equation}
$$ {#eq-bs-d1}

$$
\begin{equation}
d_2=d_1 - \sigma \sqrt{t}
\end{equation}
$$ {#eq-bs-d2}

## Variant 2
This one comes from textbook, and looks slightly different in that $PV(K)$
replaces $K$ in the natural logarithm.

$$
\begin{equation}
C=SN(d_1)-N(d_2)PV(K)
\end{equation}
$$ {#eq-bs-call-value-v2}

$$
\begin{equation}
d_1=\frac{ln(\frac{S}{PV(K)})}{\sigma \sqrt{t}}+\frac{\sigma \sqrt{t}}{2}
\end{equation}
$$ {#eq-bs-d1-v2}

$$
\begin{equation}
d_2=d_1 - \sigma \sqrt{t}
\end{equation}
$$ {#eq-bs-d2-v2}

However, it's in fact easy to show that $d_1$ in @eq-bs-d1-v2 is the same as in @eq-bs-d1: Under continuous compounding, $PV(K)=Ke^{-r_f t}$:

$$
\begin{align}
d_1 &=\frac{ln(\frac{S}{PV(K)})}{\sigma \sqrt{t}}+\frac{\sigma \sqrt{t}}{2}\newline
&=\frac{ln(\frac{S}{Ke^{-r_f t}})}{\sigma \sqrt{t}} +\frac{\frac{\sigma^2}{2}t}{\sigma \sqrt{t}}\newline
&=\frac{ln(\frac{S}{Ke^{-r_f t}})+\frac{\sigma^2}{2}t}{\sigma \sqrt{t}}\newline
&=\frac{ln(\frac{S}{K})+r_f t+\frac{\sigma^2}{2}t}{\sigma \sqrt{t}}\newline
&=\frac{ln(\frac{S}{K})+(r_f+\frac{\sigma^2}{2})t}{\sigma \sqrt{t}}
\end{align}
$$

Therefore, the two variants are effectively the same under continuous compounding.
 