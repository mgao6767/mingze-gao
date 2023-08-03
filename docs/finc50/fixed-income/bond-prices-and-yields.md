---
disqus: true
status: new
---

# Bond Prices and Yields

!!! info
    This post is still under construction.

In the [last post](./introduction.md) we introduce features of a bond. Now, let's look at how to price a _plain vanilla_ bond and examine the relation between bond price and yield.  

*[plain vanilla]: No embedded option.

## Price of a bond

First, what's the fair price of a bond?

For the investor, a bond represents a series of cashflows to receive in the future. So its price is naturally the total present value of all cashflows from the bond, including coupon payments (if any) and the repayment of principal (bond face value).

Therefore, the following equation holds true universally at all time $t$:

$$
\text{Bond Price}_{t} = \text{PV}_t(\text{future coupons}) + \text{PV}_t(\text{face value})
$$

> A bond's price at time $t$ is the present value as at time $t$ of all coupons to receive in the future, plus the present value as at time $t$ of the bond face value. Personally, I'd call this fundamental.

!!! note "Before we move on"

    Remember that all the complications we will see later are just results of uncertainties about the PVs, which utilmately are determined by cashflows and discount rates. Whenever you're lost, pause and think about how they are affected, and then reasone about how bond price may be affected.

I like examples. Suppose we are to issue a 10-year bond with a $10,000 face value that pays 5% annual coupon in arrears(1), with 8% discount rate(2), what would be the price today $t=0$ at which we can sell the bond to investors?
{ .annotate }

1. "in arrears" means that the payment is made at the end of the period. So in this case, the bond pays coupon annually at the end of the year, not any time sooner.
2. We assume that this is an effective annual rate, and is the same for all 10 years in the future.

The chart below shows the result. Specifically, the blue bars indicate the bond's cashflows, the overlaying red bars indicate their present values as at time $t=0$. The gray bar at $t=0$ is the sum of all red bars, i.e., present values, and the price of the bond today.

```vegalite
{%
  include "./vega-charts/bond-cashflows-price.json"
%}
```

!!! tip "Try it out"
    Change the parameters, see what happens to the bond price!

Now, let's have fun with the interactive chart above.

<div class="annotate" markdown>
- What's the bond price if the coupon rate is same as discount rate? (1)  
- How does the bond price change if maturity is longer?(2)
- How does the bond price change if discount rate is higher?(3)
- How does the bond price change if coupon rate is higher?(4)
- How does the bond price change if coupon is paid semiannually?(5)
</div>

1. Bond price is $10,000, same as the face value!
2. Bond price decreases, other things equal.
3. Bond price decreases, other things equal.
4. Bond price increases, other things equal.
5. Bond price increases, other things equal.

### The formula

The initial price $P_{t=0}$ of a plain vanilla $N$-year bond with face value $F$, annual coupon $C$, at a constant discount rate $r$(1), is given by
{ .annotate }

1. This discount rate $r$ is assumed to be an effective rate for a period of time between two coupons, i.e., effective annual rate in this case.

$$
P_{t=0} = \underbrace{\sum_{\tau=1}^{N} \frac{C}{(1+r)^{\tau}}}_{\text{sum of coupons' PVs}} + \underbrace{\frac{F}{(1+r)^N}}_{\text{face value's PV}}
$$

Note that this is only the ==_initial price_== when the bond is issued at time $t=0$.

## Price over time

!!! question
    So, other things equal, how does bond price changes ___over time___ as we approaches the maturity date?

Let me show you another graph. Note that in this graph, each bar represents the bond price as at a point in time.

```vegalite
{%
  include "./vega-charts/bond-price-time.json"
%}
```

!!! tip "Try it out"
    Change the discount rate to be lower than coupon rate, what do you find?  

It's not difficult to find that, as it approaches the maturity, the bond price approaches the face value, regardless of whether the bond is traded at a premium or discount.(1)
{ .annotate }

1. A bond is traded at a premium (discount) if its price is above (below) face value.

??? warning "Confused?"
    Recall earlier we said that the _longer_ the maturity, the _lower_ the bond price. This is true because we are talking about the _initial_ price at issue. For example, other things equal, the price of a 30-year bond is lower than the price of a 10-year bond.

    Here, _time_ is changing. There is _a bond_ of a given maturity (e.g., 30 years), and we study how its price changes over time as we get close to the 30-year mark.

### A slightly improved formula

The {~~initial~>time $t$~~} price $P_{t}$ of a plain vanilla $N$-year bond with face value $F$, {++$n$ remaining++} annual coupon $C$, at a constant discount rate $r$, is given by

$$
P_{t} = \underbrace{\sum_{\tau=1}^{n} \frac{C}{(1+r)^{\tau}}}_{\text{sum of coupons' PVs}} + \underbrace{\frac{F}{(1+r)^n}}_{\text{face value's PV}}
$$

From only $P_{t=0}$ to $\{P_{t}\}$ is a major improvement!

### A more improved formula

But we can still do better!

!!! question
    So far we have been assuming the next coupon is exactly one period (e.g., year) in the future, or in other words, _the last coupon has just been paid_. What if this is not the case? What if the next annual coupon is in 2 months, not in 12 months, from now?

When the coupon payment date does not align with the time at which we compute the bond price, only a simple adjustment is required.

The basic idea is, since next coupon and all future payments are closer than what's assumed in computation, we have ==over-discounted== the bond value. So, we can correct it by "growing" the undervalued price for the time since last coupon payment.

$$
P_{t} = \underbrace{\left[\sum_{\tau=1}^{n} \frac{C}{(1+r)^{\tau}} + \frac{F}{(1+r)^n}\right]}_{\text{bond price right after last coupon}} \times (1+r)^{\frac{\text{days since last coupon}}{\text{days between coupons}}}
$$

## Price: dirty and clean


## Price and yield

```vegalite
{%
  include "./vega-charts/bond-price-yield.json"
%}
```
