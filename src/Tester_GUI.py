import tkinter as tk
from EACommunicator_API import EACommunicator_API

class TradingGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("Trading Interface")
        
        # Initialize API instance
        self.api = EACommunicator_API()
        self.connect_api()
        # Create buttons for different actions
        self.create_buttons()

    def getOrderInfo(self, ticket):
            result = {}
            entry_found = False

            try:
                for index, position in self.api.Get_all_open_positions().iterrows():
                    if position['ticket'] == ticket:
                        result = position
            except Exception as e:
                print("Order not found in open orders. Expection: {}".format(ticket))
                print(e)
            
            # DA CORREGGERE TODO ASSOLUTAMENTE
            try:
                a = result['ticket']
                entry_found = True
            except:
                print("Order not found in open orders")

            if entry_found == False:
                for index, position in self.api.Get_all_closed_positions().iterrows():
                    if position['ticket'] == ticket:
                        result = position
                        print("Order {} found in closed orders!".format(ticket))
            return result
        
    def create_buttons(self):
        # Connect button
        connect_btn = tk.Button(self.root, text="Connect", command=self.connect_api)
        connect_btn.pack()

        # Reconnect button
        reconnect_btn = tk.Button(self.root, text="Reconnect", command=self.reconnect_api)
        reconnect_btn.pack()

        # List all Open Orders button
        open_orders_btn = tk.Button(self.root, text="List Open Orders", command=self.list_open_orders)
        open_orders_btn.pack()

        # List all Closed Orders button
        closed_orders_btn = tk.Button(self.root, text="List Closed Orders", command=self.list_closed_orders)
        closed_orders_btn.pack()

        # List all Pending Orders button
        pending_orders_btn = tk.Button(self.root, text="List Pending Orders", command=self.list_pending_orders)
        pending_orders_btn.pack()

        # Open new order button
        open_new_order_btn = tk.Button(self.root, text="Open Buy Order", command=self.open_buy_order)
        open_new_order_btn.pack()
        
        # Open new order button
        open_new_order_btn = tk.Button(self.root, text="Open Sell Order", command=self.open_sell_order)
        open_new_order_btn.pack()

        # Modify order button
        modify_order_btn = tk.Button(self.root, text="Modify Order", command=self.modify_order)
        modify_order_btn.pack()

        # Close partial order button
        close_partial_order_btn = tk.Button(self.root, text="Close Partial Order", command=self.close_partial_order)
        close_partial_order_btn.pack()

        # Get updated ticket button
        get_updated_ticket_btn = tk.Button(self.root, text="Get Updated Ticket", command=self.get_updated_ticket)
        get_updated_ticket_btn.pack()

        # Close all button
        close_all_btn = tk.Button(self.root, text="Close All", command=self.close_all)
        close_all_btn.pack()

        # Open Pending order button
        open_pending_order_btn = tk.Button(self.root, text="Open Pending Order", command=self.open_pending_order)
        open_pending_order_btn.pack()

        # Modify Pending Order button
        modify_pending_order_btn = tk.Button(self.root, text="Modify Pending Order", command=self.modify_pending_order)
        modify_pending_order_btn.pack()

        # Delete Pending Order button
        delete_pending_order_btn = tk.Button(self.root, text="Delete Pending Order", command=self.delete_pending_order)
        delete_pending_order_btn.pack()
        
        # Delete Pending Order button
        get_bars_btn = tk.Button(self.root, text="Get Bars", command=self.get_bars)
        get_bars_btn.pack()

        # Close the connection button
        disconnect_btn = tk.Button(self.root, text="Disconnect", command=self.disconnect_api)
        disconnect_btn.pack()

    # Implement functions for each button's command

    # ...

    # List all Open Orders function
    def list_open_orders(self):
        open_orders = self.api.Get_all_open_positions()
        print(open_orders)  # Replace with display logic in GUI

    # List all Closed Orders function
    def list_closed_orders(self):
        closed_orders = self.api.Get_all_closed_positions()
        print(closed_orders)  # Replace with display logic in GUI

    # List all Pending Orders function
    def list_pending_orders(self):
        pending_orders = self.api.Get_all_orders()
        print(pending_orders)  # Replace with display logic in GUI

    # Open new order function
    def open_buy_order(self):
        self.ticket = self.api.Open_order("GOLD", 'buy', volume=0.04, stoploss=1950, takeprofit=2040, comment="Test Order")
        print("Opened ticket {}".format(self.ticket))  # Replace with display logic in GUI

    # Open new order function
    def open_sell_order(self):
        self.ticket = self.api.Open_order("GOLD", 'sell', volume=0.04, stoploss=2040, takeprofit=1950, comment="Test Order")
        print("Opened ticket {}".format(self.ticket))  # Replace with display logic in GUI

    # Modify order function
    def modify_order(self):
    
        # Modify order
        modified = self.api.Set_sl_and_tp_for_position(ticket=self.ticket, stoploss=1900, takeprofit=2100)
        print("Modified: {}".format(modified))

    # Close partial order function
    def close_partial_order(self):
        
        # Close partial order and get new ticket
        self.api.Close_position_partial_by_ticket(self.ticket, volume_to_close=0.02)

        # Get updated ticket
        self.ticket = int(self.getOrderInfo(self.ticket)['comment'].split("#")[-1])
        print("Retrieved updated position: {}".format(self.ticket))

    # Get updated ticket function
    def get_updated_ticket(self):
        # Replace with logic to get updated ticket using getOrderInfo() method
        
        # Get updated ticket
        self.ticket = int(self.getOrderInfo(self.ticket)['comment'].split("#")[-1])
        print("Retrieved updated position: {}".format(self.ticket))

    # Close all function
    def close_all(self):
        
        # Close all
        closed = self.api.Close_position_by_ticket(self.ticket)
        print("Closed: {}".format(closed))

    # Open Pending order function
    def open_pending_order(self):
        # Open Pending order
        self.ticket = self.api.Open_order("GOLD", 'buy_limit', volume=0.04, openprice=1970, stoploss=1900, takeprofit=2000, comment="Test PENDING Order")
        print("Opened ticket {}".format(self.ticket))

    # Modify Pending Order function
    def modify_pending_order(self):
        # Modify Pending Order
        modified = self.api.Set_sl_and_tp_for_position(ticket=self.ticket, stoploss=1900, takeprofit=2100)
        print("Modified: {}".format(modified))

    # Delete Pending Order function
    def delete_pending_order(self):
    
        # Delete Pending Order
        closed = self.api.Delete_order_by_ticket(ticket=self.ticket)
        print("Closed: {}".format(closed))
        
        
    # Delete Pending Order function
    def get_bars(self):
    
        # Delete Pending Order
        df = self.api.Get_last_x_bars_from_now(instrument="GOLD", timeframe='H1', nbrofbars=2000)
        print(df.tail(3))
        print(df.head(3))

    # Connect to API function
    def connect_api(self):
        # Initialize API instance
        self.api = EACommunicator_API()
        self.api.Connect(port=5555)
        print("Connected to API")

    # Reconnect to API function
    def reconnect_api(self):
        # self.api.Disconnect()
        # Initialize API instance
        self.api = EACommunicator_API()
        self.api.Connect(port=5555)
        print("Reconnected to API")

    # Disconnect from API function
    def disconnect_api(self):
        self.api.Disconnect()
        print("Disconnected from API")

def main():
    root = tk.Tk()
    app = TradingGUI(root)
    root.mainloop()

if __name__ == "__main__":
    main()
