---
title: Download M&A Deals from SDC Platinum
date: 2021-05-15
date-modified: 2024-01-01
tags:
  - M&A
  - SDC
categories:
  - Research Notes
---

::: {.callout-warning}
The standalone SDC Platinum PC executable has been replaced by LSEG (Refinitiv) Workspace. This post is no longer relevant. The new Workspace is much more efficient.
:::

Thomson One Banker SDC Platinum database provides comprehensive M&A transaction data from early 1980s, and is perhaps the most widely used M&A database in the world.

This post documents the steps of downloading M&A deals from the SDC Platinum database. Specifically, I show how to download the complete M&A data where:

* both the acquiror and the target are US firms,
* the acquiror is a public firm or a private firm,
* the target is a public firm, a private firm, or a subsidiary,
* the deal value is at least $1m, and
* the form of the deal is a acquisition, a merger or an acquisition of majority interest.

<!-- more -->

## Interface of SDC Platinum

The screenshot below is the interface we'll see on launch of SDC Platinum. Click on `Login` and we'll be asked to enter our initials and a project name for billing purpose.

![SDC interface](/images/sdc_interface.png)

Click on `Login` and you'll be asked to enter your initials and a project name for billing purpose.

## Database Selection

Since we're interested in M&A deals, select the `Mergers & Acquisitions` tab and check `US Targets`, so that we'll be searching in the domestic mergers database.

![SDC database selection](/images/sdc_database_selection.png)

Then select the sample period, e.g. for the entire 2020 calendar year.

![SDC deal date](/images/sdc_deal_date.png)

## Apply Filters on M&A Deals

Now we can apply various filters on the M&A deals we want to download.

![SDC search items](/images/sdc_search_items.png)

We can quickly add some filters on the target's and acquiror's nation, and make sure we check the Action to be `Select` not `Exclude`. Under the `Deal` tab, we set the deal value to be at least $1m.

![SDC deal value](/images/sdc_deal_value.png)

In case we couldn't find the desired filtering variable, we can head to `All Items` tab and search manually. We add restrictions on acquiror and target public status here.

![SDC search all](/images/sdc_search_all.png)

Lastly, for the Form of the Deal, we restrict to `A` Acquisition (Stock), `M` Merger (Stock or Assets) and `AM` Acquisition of Majority Interest (Stock). We do not want to include deals that are acquisition of partial interest, recapitalization or repurchases in this case.

Our search requests should now look like below. Strongly recommended saving this session for later reuse.

![SDC all filters](/images/sdc_all_filters.png)

## Specify Deal Variables to Download

Our effort so far is only shortlisting the M&A deals that we're interested in. We now need to specify the relevant deal variables to download by creating a new custom report.

![SDC custom report](/images/sdc_custom_report.png)

As before, we can check those variables in the `Basics` tab or search under `All Items` tab. Once done, we format the report like below by arranging the order of the variables. This order is preserved when exported to spreadsheet. One note here is that each page has a maximum width of 160, so we need to insert page at proper places. It does not affect the layout of output spreadsheet. It also recommended to save the custom report for later reuse.

![SDC custom report items](/images/sdc_custom_report_items.png)

Finally, it's time to execute the requests and download the M&A deal data.

![SDC deals download](/images/sdc_deals_download.png)

## Final Note

As a final remark, the downloaded spreadsheet can be imported into SAS and matched with CRSP/Compustat using CUSIP and Ticker (SDC doesn't have `permno` or `gvkey`). First, merge the SDC CUSIP with the first 6-digit CUSIP in CRSP or Compustat; if no match, then use SDC Primary Ticker Symbol to match with the ticker symbol in CRSP or Compustat.
