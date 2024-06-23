---
title: Identify Retail Investors
date: 2023-12-21
tags:
  - TAQ
  - Asset pricing
categories:
  - Research Notes
---

Retail investors and their trading behaviour attract many research interests. One strand of literature uses proprietary datasets to identify retail investors. The other uses algorithms. A recent JF paper @boehmer_tracking_2021 proposes a simple one based only on the trade price, which also signs the trade direction effectively. Even more interestingly, I just read a follow-up work forthcoming on JF by @barber_subpenny_2024 ([SSRN](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4202874)). The authors placed 85,000 retail trades themselves to validate the @boehmer_tracking_2021 algorithm.

<!-- more -->

## @boehmer_tracking_2021 algorithm

A quick summary of the background info and the algorithm:

- In the U.S., retail investors' marketable orders are typically not executed on exchanges but filled from a broker's own inventory.
- These orders are publicly reported to a Financial Industry Regulatory Authority (FINRA) TRF, which is included in the TAQ consolidated tape with an exchange code `D`.
- These orders often receive minor price improvements (like 0.01, 0.1, or 0.2 cent) relative to the national best bid or offer (NBBO).
- SEC Rule 606 requires brokers to provide summary statistics on their order-routing practices for orders not directed to exchanges, which are _mostly_ retail and often receive price improvement.
- Institutional orders, in contrast, are typically executed on exchanges or dark pools and priced in round pennies, except for midpoint trades.

Therefore, the algorithm to identify retail transactions is simply:

- Retail seller transactions are reported on a TRF at prices slightly above a round penny.
- Retail buyer transactions are at prices slightly below a round penny.
- Transactions at round pennies or near half-pennies are not classified as retail.

For example, for a trade with exchange code `D` on TAQ,

- if trade price is 10.21 (round penny), it is non-retail.
- if trade price is 10.211 (slightly above a round penny), it is a retail sell.
- if trade price is 10.209 (slightly below a round penny), it is a retail buy.
- if trade price is 10.214, 10.215, or 10.216 (near half-penny), it is non-retail.

## Barber et al. (2023) experiment

I find this very interesting. The authors actually conduct an experiment by actually placing 85,000 retail trades themselves to validate the @boehmer_tracking_2021 algorithm. They find that the algorithm identifies 35% of their trades as retail, incorrectly signs 28% of identified trades.

There is no need to summarize the paper here. SSRN link is [here](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4202874).
