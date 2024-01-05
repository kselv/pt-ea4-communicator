import matplotlib.pyplot as plt
from stable_baselines3 import PPO
from financial_market_env import FinancialMarketEnv
from data_utils import load_and_prepare_data, plot_results
from stable_baselines3.common.policies import ActorCriticPolicy



# Example usage
# test_data_path = "C:/Users/owr3ek/Desktop/sandbox/rep/pyinvest/DAT_MT_XAUUSD_M1_2021.csv"
test_data_path = "C:/Users/owr3ek/Desktop/sandbox/rep/pyinvest/test_data_for2/DAT_MT_AUDNZD_M1_2022.csv"
test_data = load_and_prepare_data(test_data_path)[0]

test_env = FinancialMarketEnv(test_data)
obs = test_env.reset()
total_rewards = 0
rewards_history = []
portfolio_value_history = []
done = False


# LOAD MODEL
model = PPO.load("./models/final_trained_model_large", custom_objects={"policy": ActorCriticPolicy})

while not done:
    action, _states = model.predict(obs, deterministic=False)
    obs, reward, done, info = test_env.step(action, debug_log=False)
    total_rewards += reward
    rewards_history.append(total_rewards)
    portfolio_value_history.append(test_env.portfolio_value)
    if done:
        break


plot_results(rewards_history, portfolio_value_history)
