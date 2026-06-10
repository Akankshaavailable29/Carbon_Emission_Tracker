import pandas as pd
from sklearn.preprocessing import StandardScaler

def preprocess_data(input_path, output_path):
    df = pd.read_csv(input_path)

   
    df.fillna(df.mean(numeric_only=True), inplace=True)

    feature_columns = [
        "cpu_usage",
        "network_usage",
        "data_transfer_gb",
        "active_hours",
        "emission_estimate"
    ]

    scaler = StandardScaler()
    df[feature_columns] = scaler.fit_transform(df[feature_columns])

    df.to_csv(output_path, index=False)

    return df
