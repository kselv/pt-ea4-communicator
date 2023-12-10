from commands import TradingCommands
from EACommunicator_API import EACommunicator_API


api = EACommunicator_API()

api.Connect(port=5557)

# api.Disconnect()
# # result = api.send_command(TradingCommands.DELETE_ORDER)
# api.Open_order("EURUSD")
# api.Get_all_open_positions()
# api.Get_all_closed_positions()
# api.Close_position_by_ticket(402194584)
api.Set_sl_and_tp_for_position(402185189)
# print(result)
print()

