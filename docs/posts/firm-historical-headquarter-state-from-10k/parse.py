import pandas as pd

filepath = "/Users/mgao/Downloads/LM_EDGAR_10X_Header_1994_2018.csv"

if __name__ == "__main__":

    df = pd.read_csv(filepath)
    print(df.head())
