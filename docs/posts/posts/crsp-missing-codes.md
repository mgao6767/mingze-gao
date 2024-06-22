---
authors:
  - mgao
date: 2023-08-15
tags:
  - CRSP
categories:
  - Research Notes
links:
  - CRSP Prices: https://www.crsp.org/products/documentation/data-definitions-p#price-end-of-period
---

# CRSP Missing Codes

A note on the missing codes in CRSP.

<!-- more -->

## Codes

| Variable Name | C/Fortran Value | SAS Missing Code | Description                                                                                                       |
| ------------- | --------------- | ---------------- | ----------------------------------------------------------------------------------------------------------------- |
| `RET`         | -44.0           | .E               | No valid comparison for an excess return                                                                          |
|               | -55.0           | .D               | No listing information                                                                                            |
|               | -66.0           | .C               | No valid previous price                                                                                           |
|               | -77.0           | .B               | Off-exchange                                                                                                      |
|               | -88.0           | .A               | Out of Range                                                                                                      |
|               | -99.0           | .                | No valid price                                                                                                    |
| `DLRET`       | -55.0           | .S               | CRSP has no source to establish a value after delisting                                                           |
|               | -66.0           | .T               | More than 10 trading periods between a security's last price and its first available price on a new exchange      |
|               | -88.0           | .A               | Security is still active                                                                                          |
|               | -99.0           | .P               | Security trades on a new exchange after delisting, but CRSP currently h as no sources to gather price information |
| `DLRETX`      | -55.0           | .S               | CRSP has no source to establish a value after delisting                                                           |
|               | -66.0           | .T               | More than 10 trading periods between a security's last price and its first available price on a new exchange      |
|               | -88.0           | .A               | Security is still active                                                                                          |
|               | -99.0           | .P               | Security trades on a new exchange after delisting, but CRSP currently has no sources to gather price information  |
| `DCLRDT`      | 0               | .                | Declaration date cannot be found                                                                                  |
| `TRTSCD`      | 0               | .                | Unknown trading status of the issue                                                                               |
| `NMSIND`      | 0               | .                | Unknown whether or not the issue is a member of the Nasdaq National Market                                        |
| `VOL`         | -99.0           | .                |                                                                                                                   |

## Note

- `PRC`: A positive amount is an actual close for the trading date while a negative amount denotes the average between `BIDLO` and `ASKHI`.

Units:

- Most prices are represented in U.S. dollar values per share.
- `SHROUT` in thousands.
- `VOL`: The sum of the trading volumes during the month, reported in units of 100, and are not adjusted for splits during the month.

## Source

[https://wrds-www.wharton.upenn.edu/demo/crsp/form/](https://wrds-www.wharton.upenn.edu/demo/crsp/form/)
