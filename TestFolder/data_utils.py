import pandas as pd
from sklearn.preprocessing import StandardScaler

import datetime
import matplotlib.pyplot as plt

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


# Plotting Results
def plot_results(rewards_history, portfolio_value_history, to_append="", show=False):
    # Get current date and time
    now = datetime.datetime.now()
    datetime_str = now.strftime("%Y-%m-%d_%H-%M-%S")

    # Plot and save Cumulative Rewards
    plt.figure(figsize=(12, 6))
    plt.plot(rewards_history, label='Cumulative Rewards')
    plt.title('Cumulative Rewards Over Time')
    plt.xlabel('Time Steps')
    plt.ylabel('Cumulative Rewards')
    plt.legend()
    plt.savefig(f"cumulative_rewards_{datetime_str}.png")  # Save the figure
    if show:
        plt.show()

    # Plot and save Portfolio Value
    plt.figure(figsize=(12, 6))
    plt.plot(portfolio_value_history, label='Portfolio Value')
    plt.title('Portfolio Value Over Time')
    plt.xlabel('Time Steps')
    plt.ylabel('Portfolio Value')
    plt.legend()
    plt.savefig(f"portfolio_value_{datetime_str}_{to_append}.png")  # Save the figure
    if show:
        plt.show()