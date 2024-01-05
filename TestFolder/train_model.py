import pandas as pd
from stable_baselines3 import PPO
from stable_baselines3.common.env_util import make_vec_env
from stable_baselines3.common.policies import ActorCriticPolicy
from stable_baselines3.common.callbacks import CheckpointCallback
import torch
from financial_market_env import FinancialMarketEnv
from data_utils import load_and_prepare_data
from stable_baselines3.common.env_checker import check_env
from stable_baselines3.common.env_util import make_vec_env

# Model Setup and Training
def setup_and_train_model(env):
    # Enhanced Exploration Strategy and Network Architecture
    policy_kwargs = dict(
        activation_fn=torch.nn.ReLU,
        net_arch=[dict(pi=[128, 128], vf=[128, 128])]
    )

    # Create vectorized environment for efficiency
    vec_env = make_vec_env(lambda: env, n_envs=1)

    # Instantiate the agent with custom policy, learning rate, and batch size
    model = PPO(
        ActorCriticPolicy,
        vec_env,
        verbose=1,
        policy_kwargs=policy_kwargs,
        learning_rate=3e-4,
        n_steps=2048,
        batch_size=32,
        ent_coef=0.01,
        device="cuda"
    )

    # Checkpoint callback to save the model
    checkpoint_callback = CheckpointCallback(save_freq=5000, save_path='./models/', name_prefix='rl_model_test_large')

    # Train the model
    model.learn(total_timesteps=20000, callback=[checkpoint_callback])
    return model

# Example usage

file_paths = [
    "C:/Users/owr3ek/Desktop/sandbox/rep/pyinvest/test_data_for2/DAT_MT_AUDNZD_M1_2019.csv",
    "C:/Users/owr3ek/Desktop/sandbox/rep/pyinvest/test_data_for2/DAT_MT_AUDNZD_M1_2020.csv",
    "C:/Users/owr3ek/Desktop/sandbox/rep/pyinvest/test_data_for2/DAT_MT_AUDNZD_M1_2021.csv"
]

# Load and process each file
dataframes = [load_and_prepare_data(file_path)[0] for file_path in file_paths]

# Combine all DataFrames into one
train_data = pd.concat(dataframes).dropna()

# train_data_path = "C:/Users/owr3ek/Desktop/sandbox/rep/pyinvest/DAT_MT_XAUUSD_M1_2022.csv"
# train_data = load_and_prepare_data(train_data_path)[0]


env = FinancialMarketEnv(train_data)
check_env(env)
model = setup_and_train_model(env)
model.save("./models/final_trained_model_large")
