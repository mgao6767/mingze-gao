import pandas as pd

filepath = "/Users/mgao/Downloads/LM_EDGAR_10X_Header_1994_2018.csv"

if __name__ == "__main__":

    df = pd.read_csv(
        filepath,
        usecols=["cik", "file_date", "state_of_incorp", "ba_state"],
        dtype={"cik": str},
    )
    print(df.drop_duplicates().head())
    df.drop_duplicates().to_csv(
        "/Users/mgao/Downloads/historical_state.csv", index=False
    )
