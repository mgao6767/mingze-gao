import yfinance as yf
import pandas as pd
import numpy as np

link = "https://en.wikipedia.org/wiki/List_of_S%26P_500_companies#S&P_500_component_stocks"

df = pd.read_html(link, header=0)[0]
df = yf.download(tickers=df['Symbol'].tolist(), start="2022-01-01", end="2022-12-31", progress=False, rounding=True)
df = df[['Adj Close']]
df.columns = df.columns.droplevel(0)
ret = ((df.pct_change()+1).cumprod()-1).iloc[-1]
std = df.pct_change().std() * np.sqrt(252)
df = pd.DataFrame({'return': ret.values, "std": std.values, "ticker": ret.index}).round(3).dropna()
df.to_json("./spy_risk_return.json", orient="records")