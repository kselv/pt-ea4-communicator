import gym
import numpy as np
from gym import spaces
import talib

class FinancialMarketEnv(gym.Env):

    INITIAL_BALANCE = 100000
    
    def __init__(self, data):
        super(FinancialMarketEnv, self).__init__()
        self.data = self.add_technical_indicators(data)
        self.current_step = 0

        self.balance = self.INITIAL_BALANCE
        self.holdings = 0
        self.total_trades = 0
        self.portfolio_value = self.INITIAL_BALANCE

        self.action_space = spaces.Discrete(3)

        # Update the observation space to include technical indicators
        self.observation_space = spaces.Box(low=-np.inf, high=np.inf, shape=(9,), dtype=np.float32)

        self.returns = []  # List to keep track of daily returns for Sharpe Ratio calculation
        
        
        self.position_open = False
        self.position_type = None  # 'buy' or 'sell'
        self.entry_price = 0
        self.stop_loss = 0
        self.take_profit = 0

    def add_technical_indicators(self, data):
        data['RSI'] = talib.RSI(data['Close'].values, timeperiod=14)
        data['SMA'] = talib.SMA(data['Close'].values, timeperiod=20)
        data['UpperBand'], _, data['LowerBand'] = talib.BBANDS(data['Close'].values, timeperiod=20, nbdevup=2, nbdevdn=2, matype=0)
        return data.dropna()

    def _next_observation(self):
        obs = self.data.iloc[self.current_step].fillna(0)
        observation = np.array([
            obs['Open'], obs['High'], obs['Low'], obs['Close'], obs['Volume'],
            obs['RSI'], obs['SMA'], obs['UpperBand'], obs['LowerBand']
        ], dtype=np.float32)
        return observation



    def reset(self):
        self.current_step = 0
        observation = self._next_observation()
        return observation
    
    def step(self, action, debug_log=False):

        if self.current_step >= len(self.data) - 1:
            done = True
            return self._next_observation(), 0, done, {}
        # Ensure we don't pass the end of the data
        done = self.current_step >= len(self.data) - 1

        # Current price and next price (to calculate slippage and market impact)
        current_price = self.data.iloc[self.current_step]['Close']
        next_price = self.data.iloc[self.current_step + 1]['Close'] if not done else current_price

        # Initialize reward
        reward = 0

        # Transaction cost percentage
        transaction_cost_percent = 0.1 / 100  # 0.1%

        # Slippage and market impact factors
        slippage_factor = 0.05 / 100  # 0.05%
        market_impact_factor = 0.1 / 100  # 0.1%

        # Calculate the slippage and market impact
        slippage = slippage_factor * current_price
        market_impact = market_impact_factor * current_price
        
        
        # Update the reward calculation to include Sharpe ratio component
        new_val = self.holdings * next_price + self.balance
        self.returns.append(new_val - self.portfolio_value)  # Track daily returns
        sharpe_ratio = self.calculate_sharpe_ratio(self.returns)
        reward += sharpe_ratio  # Incorporate Sharpe Ratio into the reward
        self.portfolio_value = new_val
        

        
        current_price = self.data.iloc[self.current_step]['Close']

        # Define stop_loss_value (as an example, a fixed value)
        stop_loss_value = 5  # This value should be adjusted based on your strategy
        some_factor = 2 
        
        # Handling an open position
        if self.position_open:
            if self.position_type == 'buy':
                # Check if stop loss or take profit is hit, or if holding in profit
                if current_price <= self.stop_loss:
                    reward -= self.calculate_loss_reward(self.entry_price, self.stop_loss)
                    self.position_open = False
                elif current_price >= self.take_profit:
                    reward += self.calculate_profit_reward(self.entry_price, self.take_profit)
                    self.position_open = False  # Close the position when take profit is hit
                elif current_price > self.entry_price:
                    # Reward for holding a profitable position (buy)
                    reward += (current_price - self.entry_price) * some_factor  # some_factor is a scaling factor for the reward
            elif self.position_type == 'sell':
                # Implementing logic for sell position
                if current_price >= self.stop_loss:
                    reward -= self.calculate_loss_reward(self.entry_price, self.stop_loss)
                    self.position_open = False
                elif current_price <= self.take_profit:
                    reward += self.calculate_profit_reward(self.entry_price, self.take_profit)
                    self.position_open = False  # Close the position when take profit is hit
                elif current_price < self.entry_price:
                    # Reward for holding a profitable position (sell)
                    reward += (self.entry_price - current_price) * some_factor  # some_factor is a scaling factor for the reward


        # Implement action logic for opening positions
        if action == 0 and not self.position_open:  # Buy
            self.position_open = True
            self.position_type = 'buy'
            self.entry_price = current_price
            self.stop_loss = current_price - stop_loss_value
            self.take_profit = current_price + (2 * stop_loss_value)  # Example for 1:2 ratio

        elif action == 1 and not self.position_open:  # Sell
            self.position_open = True
            self.position_type = 'sell'
            self.entry_price = current_price
            self.stop_loss = current_price + stop_loss_value
            self.take_profit = current_price - (2 * stop_loss_value)  # Example for 1:2 ratio

        # Implement action logic for closing positions
        if action == 1 and self.position_type == 'buy':  # Close buy position
            self.position_open = False
            reward += self.calculate_closing_reward(self.entry_price, current_price)
            # Reset position parameters

        elif action == 0 and self.position_type == 'sell':  # Close sell position
            self.position_open = False
            reward += self.calculate_closing_reward(self.entry_price, current_price)
            # Reset position parameters

        # Implement action logic
        if action == 0:  # Buy
            cost = current_price + slippage + market_impact
            total_cost = cost + cost * transaction_cost_percent
            if self.balance >= total_cost:
                self.balance -= total_cost
                self.holdings += 1
                self.total_trades += 1
                reward -= total_cost * transaction_cost_percent  # Negative reward for costs
            else:
                reward -= 10  # Penalty for trying to buy without sufficient funds

        elif action == 1:  # Sell
            if self.holdings > 0:
                revenue = current_price - slippage - market_impact
                total_revenue = revenue - revenue * transaction_cost_percent
                self.balance += total_revenue
                self.holdings -= 1
                self.total_trades += 1
                reward += total_revenue * transaction_cost_percent  # Reward for successful sell
            else:
                reward -= 10  # Penalty for trying to sell without holdings

        # Calculate reward based on change in net asset value
        if action != 2:  # If not holding
            new_val = self.holdings * next_price + self.balance
            reward += new_val - self.portfolio_value - abs(reward)
            self.portfolio_value = new_val

        # Update the current step
        self.current_step += 1

        # Get the next state
        next_state = self._next_observation()

        if debug_log:
            # Debugging log
            print(f"Step: {self.current_step}, Action: {action}, Reward: {reward}, Portfolio Value: {self.portfolio_value}")

        return next_state, reward, done, {}
    
    def calculate_loss_reward(self, entry_price, stop_loss_price):
        # Negative reward proportional to the loss
        return -abs(entry_price - stop_loss_price)

    def calculate_profit_reward(self, entry_price, take_profit_price):
        # Positive reward proportional to the profit
        return abs(take_profit_price - entry_price)

    def calculate_closing_reward(self, entry_price, closing_price):
        # Reward based on actual profit/loss
        return closing_price - entry_price  # Adjust as needed

    def calculate_sharpe_ratio(self, returns):
        if len(returns) < 2:
            return 0
        return np.mean(returns) / np.std(returns) if np.std(returns) != 0 else 0

    def render(self, mode='console'):
        if mode == 'console':
            print(f'Step: {self.current_step}')
            
    