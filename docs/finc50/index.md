---
disqus: true
hide:
  - footer
---

# FINC50

**FINC50** is one half of your Finance 101. (1)
{ .annotate }

1. 🙋‍♂️ 50 is a half of 101, rounded down.

*[Finance 101]: "101" represents a basic beginning course.

The objectives are

- to introduce [modern finance topics](#course-notes) covered in undergraduate and postgraduate courses
- to experiment [interactive web-based technologies](#demo) in learning and teaching

!!! warning "Note"

    This is a proof-of-concept and _always_ a work-in-progress.

    It could take a relatively long time for me to "complete".

## Course notes

- [Fixed Income Securities](./fixed-income/)

## Demo

### Bond cashflows and price

An interactive chart and calculator of bond cashflows, present values and prices.

```vegalite
{%
  include "./fixed-income/vega-charts/bond-cashflows-price.json"
%}
```

### Bond price and yield

An interactive chart of bond price and yield.

```vegalite
{%
  include "./fixed-income/vega-charts/bond-price-yield.json"
%}
```

### Risk and return

A graph showing volatility and return of S&P500 constituents in 2022.(1)
Try to pan, zoom, select and click.
{ .annotate }

1. The data is retrieved using the following Python code.
   ```python
   {%
      include "./demo/spy_risk_return.py"
   %}  
   ```

```vegalite
{%
  include "./demo/sp500_stock_return_volatility.json"
%}
```
