---
authors:
  - mgao
description: Identify Chinese State-Owned Enterprise using CSMAR
date: 2020-05-22
tags:
  - CSMAR
categories:
  - Research Notes
---

# Identify Chinese State-Owned Enterprise using CSMAR

Many research papers on Chinese firms include a control variable that indicates if the firm is a state-owned enterprise (SOE). This is important as SOEs and non-SOEs differ in many aspects and may have structural differences. This post documents the way to construct this indicator variable from the CSMAR databases. 

<!-- more -->

Specifically, we need the **CSMAR China Listed Firms Shareholders - Controlling Shareholders** dataset. On WRDS, this dataset is named `hld_contrshr`, located at `/wrds/csmar/sasdata/hld`.

Inside this dataset there're a few variables identifying the ultimate controlling shareholder.

- `s0701b`: ultimate controlling shareholder.
- `s0702b`: nature of ultimate controlling shareholder.

According to the CSMAR documentation, `s0702b` can be one of the following. Apparently, `s0702b=1100` means the firm is a SOE.

| Code     | Type                                                    |
| -------- | ------------------------------------------------------- |
| 1000     | Enterprise business unit                                |
| **1100** | **State-owned Enterprise**                              |
| 1210     | Collective-owned enterprises                            |
| 1200     | Private Enterprises                                     |
| 1220     | Enterprises with funds from Hong Kong, Macau and Taiwan |
| 1230     | Foreign-funded enterprises                              |
| 2000     | Administrative departments or institutions              |
| 2100     | Central institution                                     |
| 2120     | Local institution                                       |
| 2500     | Social Organization                                     |
| 3000     | Natural Persons                                         |
| 3110     | Domestic natural persons                                |
| 3120     | Natural person from Hong Kong, Macao and Taiwan         |
| 3200     | Foreign natural person                                  |
| 9999     | Other                                                   |

Princeton University Library has [another guide](https://faq.library.princeton.edu/econ/faq/11458) on other ways to identify Chinese SOE.
