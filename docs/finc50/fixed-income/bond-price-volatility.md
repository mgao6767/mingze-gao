---
disqus: true
status: "new"
---

# Bond Price Volatility (Sensitivity)

A (plain vanilla) bond's price $P$ is nothing but a function of some input parameters, including coupon rate $C$, time to maturity $t$, yield $y$, face value $F$, among others:

$$
P=f(C,t,y,F)
$$

Now that we have discussed the pricing function $f$ in the [previous post](/finc50/fixed-income/bond-prices-and-yields/), it is very natural to think about how $P$ responds to changes in each of the input parameters. This is precisely an examination of the partial derivate of $f$ with respect to (w.r.t.) its parameters.

!!! question "Why should we care about it?"
    As a manager of a bond portfolio, for example, you will need to understand the sensitivity of bond value: to which factors and by how much. This allows you to better manage the risk and build trading strategies.

Additionally, for a given bond, the coupon rate $C$ and face value $F$ will not change. That means we can primarily focus on a bond's price sensitivity w.r.t. yield, and how the time to maturity $t$ and other parameters affect such sensitivity.

## Price sensitivity to yield

As we have [previously discussed](/finc50/fixed-income/bond-prices-and-yields/#price-and-yield-to-maturity), a bond's price and its yield has an __inverse, non-linear__ relationship. More importantly, the non-linearity shows that ==the same unit change in yield has different impacts on bond's price==: the higher the yield is, the smaller the impact of a given unit change in yield, other things equal.

```vegalite
{%
  include "./vega-charts/bond-price-yield.json"
%}
```

This observation suggests that while the bond price is sensitive to yield, this sensitivity is not a constant.

!!! question "How to measure the bond price sensitivity to yield?"
    Can we quantify such sensitivity?
    
    Yes. It's nothing but the partial derivate of bond price $P=f(C,t,{\color{red}y},F)$ w.r.t. yield $\color{red}y$: 

    $$
    \frac{\partial P}{\partial {\color{red}y}}
    $$

## Measure of price-yield sensitivity: Duration

### Macaulay Duration

Let's take a closer look at the bond price sensitivity to yield $\frac{\partial P}{\partial y}$.

Recall that bond price $P=f(C,t,{\color{red}y},F)$, so its partial derivative w.r.t. yield $\color{red}y$ is given by: 

$$
\frac{\partial P}{\partial {\color{red}y}} = 
\frac{\partial f}{\partial {\color{red}y}} = 
\frac{\partial}{\partial {\color{red}y}}{\left[\sum_{\tau=1}^{n} \frac{C}{(1+{\color{red}y})^{\tau}} + \frac{F}{(1+{\color{red}y})^n}\right]}
$$

??? note "Be not afraid - Ask ChatGPT to derive"
    Let's differentiate the expression with respect to \(y\) step by step:

    \[
    \begin{align*}
    \frac{\partial}{\partial y} \left[\sum_{\tau=1}^{n} \frac{C}{(1+y)^{\tau}} + \frac{F}{(1+y)^n}\right] &= \sum_{\tau=1}^{n} \frac{\partial}{\partial y} \left[\frac{C}{(1+y)^{\tau}}\right] + \frac{\partial}{\partial y} \left[\frac{F}{(1+y)^n}\right] \\
    &= \sum_{\tau=1}^{n} \left[-\frac{C \cdot \tau}{(1+y)^{\tau+1}}\right] + \left[-\frac{F \cdot n}{(1+y)^{n+1}}\right] \\
    &= -\sum_{\tau=1}^{n} \frac{C \cdot \tau}{(1+y)^{\tau+1}} - \frac{F \cdot n}{(1+y)^{n+1}} \\
    &= -\frac{1}{1+y}\left[\sum_{\tau=1}^{n} \frac{C \cdot \tau}{(1+y)^{\tau}} + \frac{F \cdot n}{(1+y)^n}\right]
    \end{align*}
    \]

Therefore, the price's sensitivity to yield is:

\[
\frac{\partial P}{\partial y}= -\frac{1}{1+y}\left[\sum_{\tau=1}^{n} \frac{C \cdot \tau}{(1+y)^{\tau}} + \frac{F \cdot n}{(1+y)^n}\right]
\]

This formula is extremely interesting! Let's see what I mean.

Check out the part $\left[\sum_{\tau=1}^{n} \frac{C \cdot \tau}{(1+y)^{\tau}} + \frac{F \cdot n}{(1+y)^n}\right]$. It looks like we are multiplying the time period in each of the components in the original bond pricing formula - if we ignore the $\tau$ and $n$ in the numerators, it is exactly the formula. If we divide it by the bond price $P$, we have:

$$
\begin{align*}
  &\frac{1}{P}\left[\sum_{\tau=1}^{n} \frac{C \cdot \tau}{(1+y)^{\tau}} + \frac{F \cdot n}{(1+y)^n}\right] \\
  &=\left[\sum_{\tau=1}^{n} \frac{C/(1+y)^{\tau}}{P} \cdot \tau+ \frac{F /(1+y)^n}{P}\cdot n\right] \\
  &=\sum_{\tau=1}^{n} \underbrace{\frac{PV(\tau\text{-th coupon})}{P}}_{\text{weight of coupon}} \cdot \tau+ \underbrace{\frac{PV(\text{principal})}{P}}_{\text{weight of principal}}\cdot n \\
  &=\sum_{\tau=1}^{n} w_{\tau} \cdot \tau+ w_{F} \cdot n \equiv \text{Macaulay Duration}
\end{align*}
$$

That is, a ==PV weighted average of time to receive a bond's cashflows==. Its name is __Macaulay Duration__.

Back to the initial formula of bond price sensitivity to yield:

$$
\begin{align*}
\frac{\partial P}{\partial y} &= -\frac{1}{1+y}\left[\sum_{\tau=1}^{n} \frac{C \cdot \tau}{(1+y)^{\tau}} + \frac{F \cdot n}{(1+y)^n}\right]\\ 
&=-\frac{1}{1+y} \left[P\times{\text{Macaulay Duration}}\right]
\end{align*}
$$

### Modified Duration

If we define __Modified Duration__ as

$$
\text{Modified Duration} = \frac{\text{Macaulay Duration}}{1+y}
$$

the above formula of bond price sensitivity to yield can be simplified to:

$$
\begin{align*}
\frac{\partial P}{\partial y} 
&=-\frac{1}{1+y} \left[P\times{\text{Macaulay Duration}}\right] \\
&=-P\times{\text{Modified Duration}}
\end{align*}
$$

### How to use durations?

We can now use durations to approximate the dollar or percentage change in bond price given a small change in yield. Specifically, for a small change in yield $\Delta y$,

the dollar change in bond price $\Delta P$ is

$$
\Delta P = -P\times \text{Modified Duration} \times \Delta y
$$ 

and the percentage change $\frac{\Delta P}{P}$ is

$$
\frac{\Delta P}{P} = - \text{Modified Duration} \times \Delta y
$$

!!! note "PV01"
    People are particularly interested in the price movement of a bond given a one-basis-point change in yield, or __PV01__, which is essentially $\Delta P$ given $\Delta y=0.0001$.


### Duration of a bond portfolio

A good thing about duration is that it's additive, meaning that the duration of a portfolio of bonds is simply the value-weighted average of individual bonds' durations.

## Adjusting for Convexity

Earlier we mentioned that the price-yield relationship is non-linear and __convex__. In simple terms, it means the sensitivity of bond price to yield is decreasing in yield, i.e., when yield is high, a given unit change in yield has a smaller impact on bond price.

Intuitively, ==as yield increases, bond duration decreases==. So, looking at the bond price sensitivity formulae above, we can notice that $\partial y$ should also change durations, which were assumed constant. This failure to adjust bond duration when computing the price change due to yield change leads to an underestimation of true price. We can correct it by adjusting for bond convexity.

!!! note
    From the graph below, we can see that using only duration to approximate bond price is like assuming a linear price-yield relation. Given that the price-yield relation is convex, this means we would underestimate the bond price. The vertical difference between the curved line and dotted straight line is where adjustment for convexity comes in.

```vegalite
{%
  include "./vega-charts/bond-convexity.json"
%}
```

Mathematically, notice that bond price $P$ is a non-linear function $f$ of yield $y$ and many other parameters. Approximating $\Delta P$ using only its first partial derivative $\frac{\partial P}{\partial y}$ is of course not enough. We need to consider the second-order partial derivate, $\frac{\partial^2 P}{\partial y^2}$ too. This second derivative w.r.t. yield is exactly what we call the (dollar) ==convexity== of a bond.

$$
\Delta P = \underbrace{\frac{\partial P}{\partial y}}_{\text{related to duration}} \cdot \partial y + \underbrace{\frac{1}{2}\frac{\partial^2 P}{\partial y^2}}_{\text{related to convexity}} \cdot (\partial y)^2
$$

!!! tip "Why does it work? -- Taylor Expansion"
    This is for the math-savvy. According to [Taylor Expansion](https://en.wikipedia.org/wiki/Taylor_series), the change in a function $f$'s value at a point $y$ by $\Delta y$ is:

    $$
    f(y+\Delta y) - f(y) = f'(y) \Delta y + \frac{f''(y)}{2} (\Delta y)^2 + \cdots
    $$

    where higher order terms are ignored because they are too small.

As such, approximating a bond price's change can be better achieved using both duration and convexity.

### Impact of coupon rate on convexity

!!! warning "In the graph above, change coupon rate to 0%. What do you find?"
    Adjusting only coupon rate, the bond's yield and maturity stay unchanged. The bond price declines, duration goes up, though the slope of the tangent line at yield decreases.

For a given yield and maturity, the lower the coupon, the greater the convexity of a bond. This is because a greater portion of the bond value comes later, resulting a higher duration. A higher duration implies greater sensitivity of bond price to yield, so that for a given change in yield, the (percentage) change in price is greater -- the bond's convexity is higher.(1)
{ .annotate }

1. Note that it does not necessarily mean that the price-yield curve is more convex! In the graph above, if we change coupon rate to lower than 5%, the blue-colored curve seems less convex than the baseline red curve (5% coupon), but the low-coupon (blue) bond's convexity is higher. Remember we need to scaled by the bond price, and the low-coupon bond's price is lower.

## Approximating duration and convexity

When a bond has embedded options, an analytical solution of bond price can be hard or impossible to get. The lack of an exact bond price function means that we will not be able to compute its partial derivatives, and we have to use approximations to gauge its duration and convexity.

### Duration approximation

Conceptually, (modified) duration captures the change in bond price given a small change in yield. So, we can approximate a bond's duration by computing (1) the average price changes given a small change in yield in both directions:
{ .annotate }

1. If the exact pricing function is not available due to complex embedded options, we can try to use Monte Carlo simulations to compute an expected value.

$$
\begin{align*}
\text{approx. Modified Duration} &= \underbrace{\frac{1}{2} \left[\frac{P_{-}-P_0}{P_0} + \frac{P_0 - P_+}{P_0}\right]}_{\text{avg. pct. price change}} \times \underbrace{\frac{1}{\Delta y}}_{\text{per change in yield}} \\
&= \frac{P_--P_+}{2P_0\cdot \Delta y}
\end{align*}
$$

### Convexity approximation

Similarly and conceptually, bond convexity captures the asymmetric changes in price given a small change in yield to the positive and to the negative directions. So, we can approximate a bond's (dollar) convexity by computing (1) the difference in price changes given a small change in yield in both directions:
{ .annotate }

1. Or by simulation.

$$
\begin{align*}
\text{approx. Convexity} &= \underbrace{\left[\frac{P_{-}-P_0}{\Delta y} - \frac{P_0 - P_+}{\Delta y}\right]}_{\text{diff. in price changes given yield change}} \times \underbrace{\frac{1}{\Delta y}}_{\text{per change in yield}} \\
&= \frac{P_-+P_+-2P_0}{(\Delta y)^2}
\end{align*}
$$

!!! tip "Real world application"
    Imagine you're a manager of a bond portfolio. Some bonds in the portfolio are exotic and have complex embedded options: this is very common.

    How do you understand the risk of the portfolio, in terms of its value sensitivity to yield?

    You can have a powerful computer program that continuously compute the approximate duration and convexity of each bond in the portfolio, perhaps using Monte Carlo simulations to value those bonds with embedded options. Therefore, you can have a real-time measure of the portfolio's risk exposure to yield changes.