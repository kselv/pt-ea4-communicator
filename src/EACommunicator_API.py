# Pytrader API for MT4 and MT5
# Version V3_01
import zmq
import numpy as np
import pandas as pd

from commands import TradingCommands

class EACommunicator_API:
    
    contextManager = None
    connected = False
    
    def __init__(self):
        # Socket to talk to the server
        self.context = zmq.Context()
        self.socket = self.context.socket(zmq.REQ)

    def Disconnect(self):
        """
        Closes the socket connection to a MT4 or MT5 EA bot.

        Args:
            None
        Returns:
            bool: True or False
        """
        
        print(f"Sending DISCONNECT command")
        self.socket.send_string("break^")

        self.socket.close()
        self.context.term()
        return True

    def Connect(self,
                server: str = 'localhost',
                port: int = 5555) -> bool:
        """
        Connects to a MT4 or MT5 EA/Bot.

        Args:
            server: Server IP address, like -> '127.0.0.1', '192.168.5.1'
            port: port number
        Returns:
            bool: True or False
        """
        self.contextManager = self.socket.connect("tcp://{}:{}".format(server, port)) 

    def Check_connection(self) -> bool:
        """
        Checks if connection with MT terminal/Ea bot is still active.
        Args:
            None
        Returns:
            bool: True or False
        """
        # Send check command
        # Wait for reply
        pass

    @property
    def IsConnected(self) -> bool:
        """Returns connection status.
        Returns:
            bool: True or False
        """
        return self.connected




    def Get_instrument_info(self,
                            instrument: str = 'EURUSD') -> dict:
        """
        Retrieves instrument information.

        Args:
            instrument: instrument name
        Returns: Dictionary with:
            instrument,
            digits,
            max_lotsize,
            min_lotsize,
            lot_step,
            point,
            tick_size,
            tick_value
            swap_long
            swap_short
            stop_level for sl and tp distance
        """
        pass


    def Get_instruments(self) ->list:
        """
        Retrieves broker market instruments list.

        Args:
            None
        Returns:
            List: All market symbols as universal instrument names
        """
        pass
       


    def Get_last_x_ticks_from_now(self,
                                  instrument: str = 'EURUSD',
                                  nbrofticks: int = 2000) -> np.array:
        """
        Retrieves last x ticks from an instrument.

        Args:
            instrument: instrument name
            nbrofticks: number of ticks to retriev
        Returns: numpy array with:
            date,
            ask,
            bid,
            last volume,
            volume
        """
        pass


    def Get_last_x_bars_from_now(self,
                                 instrument: str = 'EURUSD',
                                 timeframe: int = 16408,
                                 nbrofbars: int = 1000) -> np.array:
        """
        Retrieves last x bars from a MT4 or MT5 EA bot.

        Args:
            instrument: name of instrument like EURUSD
            timeframe: timeframe like 'H4'
            nbrofbars: Number of bars to retrieve
        Returns: numpy array with:
            date,
            open,
            high,
            low,
            close,
            volume
        """
        pass

    def Get_all_orders(self) -> pd.DataFrame:
        
        """
        Retrieves all pending orders.
        
        Args:

        Returns:
            data array(panda) with all order information:
            ticket,
            instrument,
            order_type,
            magic number,
            volume/lotsize,
            open price,
            open_time,
            stop_loss,
            take_profit,
            comment
        """
        pass
    
    def Get_all_open_positions(self) -> pd.DataFrame:

        """
        Retrieves all open positions, market orders for MT4.

        Args:
            none

        Returns:
            data array(panda) with all position information:
            ticket,
            instrument,
            order_ticket, for MT5 deal ticket, for MT4 order ticket
            position_type,
            magic_number,
            volume/lotsize,
            open_price,
            open_time,
            stopp_loss,
            take_profit,
            comment,
            profit,
            swap,
            commission
        """
        self.send_command(TradingCommands.GET_OPEN_POSITIONS)


    def Get_all_closed_positions(self) -> pd.DataFrame:
        """ 
            Retrieves all closed positions/orders.
            For MT4 all must be visible in the history tab of the MT4 terminal

        Args:
            
        Returns:
            data array(panda) with all position information:
            ticket,
            instrument,
            order_ticket,
            position_type,
            magic_number,
            volume,
            open_price,
            open_time,
            stop_loss,
            take_profit,
            close_price,
            close_time,
            comment,
            profit,
            swap,
            commission
        """
        self.send_command(TradingCommands.GET_CLOSED_POSITIONS)

    def Open_order(self,
                   instrument: str = '',
                   ordertype: str = 'buy',
                   volume: float = 0.01,
                   openprice: float = 0.0,
                   slippage: int = 5,
                   magicnumber: int = 0,
                   stoploss: float = 0.0,
                   takeprofit: float = 0.0,
                   comment: str = '',
                   market: bool = False
                   ) -> int:
        """
        Open an order.

        Args:
            instrument: instrument
            ordertype: type of order, buy, sell, buy stop, sell stop, buy limit, sell limit
            volume: order volume/lot size
            open price: open price for order, 0.0 for market orders
            slippage: allowed slippage
            magicnumber: magic number for this order
            stoploss: order stop loss price, actual price, so not relative to open price
            takeprofit: order take profit, actual price, so not relative to open price
            comment: order comment
        Returns:
            int: ticket number. If -1, open order failed
        """
        arguments = f"{instrument}^{ordertype}^{volume}^{openprice}^{slippage}^{magicnumber}^{stoploss}^{takeprofit}^{comment}^{market}"
        reply = self.send_command(TradingCommands.OPEN_TRADE, arguments)
        

    def Close_position_by_ticket(self,
                                 ticket: int = 0) -> bool:
        """
        Close a position.

        Args:
            ticket: ticket of position to close

        Returns:
            bool: True or False
        """
        self.send_command(TradingCommands.CLOSE_POSITION, str(ticket))
        

    def Close_position_partial_by_ticket(self,
                                         ticket: int = 0,
                                         volume_to_close: float = 0.01) -> bool:
        """
        Close a position partial.

        Args:
            ticket: ticket of position to close
            volume_to_close: volume part to close, must be small then order volume
        Returns:
            bool: True or False
        """
        pass

    def Delete_order_by_ticket(self,
                               ticket: int = 0) -> bool:
        """
        Delete an order.

        Args:
            ticket: ticket of order(pending) to delete

        Returns:
            bool: True or False
        """
        pass

    def Set_sl_and_tp_for_position(self,
                                   ticket: int = 0,
                                   stoploss: float = 0.0,
                                   takeprofit: float = 0.0) -> bool:
        """
        Change stop loss and take profit for a position.

        Args:
            ticket: ticket of position to change
            stoploss; new stop loss value, must be actual price value
            takeprofit: new take profit value, must be actual price value

        Returns:
            bool: True or False
        """
        pass

    def Set_sl_and_tp_for_order(self,
                                ticket: int = 0,
                                stoploss: float = 0.0,
                                takeprofit: float = 0.0) -> bool:
        """
        Change stop loss and take profit for an order.

        Args:
            ticket: ticket of order to change
            stoploss; new stop loss value, must be actual price value
            takeprofit: new take profit value, must be actual price value

        Returns:
            bool: True or False
        """
        pass


    def Change_settings_for_pending_order(self,
                                ticket: int = 0,
                                price: float = -1.0,
                                stoploss: float = -1.0,
                                takeprofit: float = -1.0) -> bool:
        """
        Change settings for a pending order.
        
        Args:
            ticket: ticket of order to change
            price: new price value, if value=-1.0 no change
            stoploss: new stop loss value, if value=-1.0 no change
            takeprofit: new take profit value, if value=-1.0 no change
            
        Returns:
            bool: True or False
        
        """
        pass
            
    
    def send_command(self,
                     command: TradingCommands, arguments: str = ''):
        
        msg = "{}^{}".format(command.value, arguments)
        print(f"Sending command: {msg}")
        self.socket.send_string(str(msg))

        # Receive the reply from the server
        reply = self.socket.recv_string()
        print(f"Received reply: {reply}")
        
        return reply


    def get_timeframe_value(self,
                            timeframe: str = 'D1') -> int:

        self.tf = 16408  # mt5.TIMEFRAME_D1
        timeframe.upper()
        if timeframe == 'MN1':
            self.tf = 49153  # mt5.TIMEFRAME_MN1                                                 
        if timeframe == 'W1':
            self.tf = 32769  # mt5.TIMEFRAME_W1
        if timeframe == 'D1':
            self.tf = 16408  # mt5.TIMEFRAME_D1
        if timeframe == 'H12':
            self.tf = 16396  # mt5.TIMEFRAME_H12
        if timeframe == 'H8':
            self.tf = 16392  # mt5.TIMEFRAME_H8
        if timeframe == 'H6':
            self.tf = 16390  # mt5.TIMEFRAME_H6
        if timeframe == 'H4':
            self.tf = 16388  # mt5.TIMEFRAME_H4
        if timeframe == 'H3':
            self.tf = 16387  # mt5.TIMEFRAME_H3
        if timeframe == 'H2':
            self.tf = 16386  # mt5.TIMEFRAME_H2
        if timeframe == 'H1':
            self.tf = 16385  # mt5.TIMEFRAME_H1
        if timeframe == 'M30':
            self.tf = 30  # mt5.TIMEFRAME_M30
        if timeframe == 'M20':
            self.tf = 20  # mt5.TIMEFRAME_M20
        if timeframe == 'M15':
            self.tf = 15  # mt5.TIMEFRAME_M15
        if timeframe == 'M12':
            self.tf = 12  # mt5.TIMEFRAME_M12
        if timeframe == 'M10':
            self.tf = 10  # mt5.TIMEFRAME_M10
        if timeframe == 'M6':
            self.tf = 6  # mt5.TIMEFRAME_M6
        if timeframe == 'M5':
            self.tf = 5  # mt5.TIMEFRAME_M5
        if timeframe == 'M4':
            self.tf = 4  # mt5.TIMEFRAME_M4
        if timeframe == 'M3':
            self.tf = 3  # mt5.TIMEFRAME_M3
        if timeframe == 'M2':
            self.tf = 2  # mt5.TIMEFRAME_M2
        if timeframe == 'M1':
            self.tf = 1  # mt5.TIMEFRAME_M1

        return self.tf