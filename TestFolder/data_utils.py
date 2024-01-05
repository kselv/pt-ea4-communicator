import pandas as pd
from sklearn.preprocessing import StandardScaler

def load_and_prepare_data(data_path, resample_time='15min', scaler=None):
    # Load and preprocess data
    data = pd.read_csv(data_path)
    data['Date'] = pd.to_datetime(data['Date'] + ' ' + data['Time'])
    data.drop(['Time'], axis=1, inplace=True)
    data.set_index('Date', inplace=True)

    # Resample data
    df_resampled = data.resample(resample_time).agg({
        'Open': 'first',
        'High': 'max',
        'Low': 'min',
        'Close': 'last',
        'Volume': 'sum'
    }).dropna().reset_index()
    df_resampled['Date'] = pd.to_datetime(df_resampled['Date'])
    df_resampled.set_index('Date', inplace=True)

    # Normalize data
    if scaler is None:
        scaler = StandardScaler()
        normalized_data = scaler.fit_transform(df_resampled[['Open', 'High', 'Low', 'Close', 'Volume']])
    else:
        normalized_data = scaler.transform(df_resampled[['Open', 'High', 'Low', 'Close', 'Volume']])

    normalized_df = pd.DataFrame(normalized_data, columns=['Open', 'High', 'Low', 'Close', 'Volume'], index=df_resampled.index)
    return normalized_df, scaler

