import matplotlib.pyplot as plt
from stable_baselines3 import PPO
from financial_market_env import FinancialMarketEnv
from data_utils import load_and_prepare_data, plot_results
from stable_baselines3.common.policies import ActorCriticPolicy
import datetime
import os
import pandas as pd

def test_model(model_path, test_env):
    model = PPO.load(model_path, custom_objects={"policy": ActorCriticPolicy})
    obs = test_env.reset()
    total_rewards = 0
    rewards_history = []
    portfolio_value_history = []
    done = False

    while not done:
        action, _states = model.predict(obs, deterministic=False)
        obs, reward, done, info = test_env.step(action, debug_log=False)
        total_rewards += reward
        rewards_history.append(total_rewards)
        portfolio_value_history.append(test_env.portfolio_value)
    return total_rewards, test_env.portfolio_value, rewards_history, portfolio_value_history



test_data_path = "C:/Users/owr3ek/Desktop/sandbox/rep/pyinvest/test_data_for2/DAT_MT_AUDNZD_M1_2022.csv"
test_data = load_and_prepare_data(test_data_path)[0]

test_env = FinancialMarketEnv(test_data)

# Directory containing models
models_dir = "./models/"
model_files = [f for f in os.listdir(models_dir) if f.endswith('.zip')]

# Dictionary to store results
model_performance = {}

# Test each model
for model_file in model_files:
    print("Testing {}...".format(model_file))
    model_path = os.path.join(models_dir, model_file)
    total_rewards, final_portfolio_value, rewards_history, portfolio_value_history = test_model(model_path, test_env)
    model_performance[model_file] = {
        "Total Rewards": total_rewards,
        "Final Portfolio Value": final_portfolio_value
    }
    plot_results(rewards_history, portfolio_value_history)

# Determine the best model
best_model = max(model_performance, key=lambda k: model_performance[k]["Total Rewards"])

# Create a DataFrame for the report
report_df = pd.DataFrame.from_dict(model_performance, orient='index')
report_df['Best Model'] = (report_df.index == best_model)

# Save the report
report_filename = f"model_performance_report_{datetime.datetime.now().strftime('%Y-%m-%d_%H-%M-%S')}.csv"
report_df.to_csv(report_filename)

# Print out the best model
print(f"Best performing model: {best_model}")
