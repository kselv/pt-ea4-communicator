//+------------------------------------------------------------------+
//|                                            ZmqCommunicatorEA.mq4 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
#include <Zmq/Zmq.mqh>
#include "Utils.mqh"

// Possible commands sent by the client
enum EnumCommands {
 OPEN_TRADE = 1,
 MODIFY_POSITION = 2,
 DELETE_ORDER = 3,
 PARTIAL_CLOSE = 4,
 MODIFY_PENDING_ORDER = 5,
 GET_ALL_ORDERS = 6,
 GET_SYMBOL_INFO = 7,
 GET_BROKER_MARKET_INSTRUMENT_LIST = 8,
 GET_OPEN_POSITIONS = 9,
 GET_CLOSED_POSITIONS = 10,
 CLOSE_POSITION = 11,
 GET_LAST_TICK_DATA = 12,
 GET_X_BARS = 13
};

Context context("helloworld");
Socket socket(context,ZMQ_REP);
string address = "tcp://*:5555";

int OnInit()
  {
//---
   
   PrintFormat("STARTING ZMQ ASSISTANT");
   int result = socket.bind(address);
   
   if (result != 1) {
     PrintFormat("Error binding socket: %d", result);
     // Handle error condition (e.g., return INIT_FAILED or take appropriate action)
     return(INIT_FAILED);
   }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
   PrintFormat("DeInit reason: %d", reason);
   
   context.shutdown();
   socket.unbind(address);
   socket.disconnect(address);
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    ZmqMsg clientCmd;
    int waitIterations = 100; // Adjust this based on your tick frequency and desired 1-second delay
    
    for (int i = 0; i < waitIterations; ++i) {
        int result = socket.recv(clientCmd, ZMQ_DONTWAIT); // Set ZMQ_DONTWAIT flag
        
        if (result == 1) {
            // Message received
            string command = clientCmd.getData();
            //PrintFormat("Received result %d", result);
            //PrintFormat("Received: %s", command);
            
            string replyMsg = HandleCommand(command);
        
            ZmqMsg reply(replyMsg);
            socket.send(reply);
            
            if (command == "break^") {
                // DeInit Everything
                //break;
            }
            
            //return; // Exit the loop and the function after processing the message
        }
        
        Sleep(1); // Wait 100 milliseconds (0.1 seconds)
    }
}



  
  
 int order_type_LUT(string order_type) {
   int result = -1;
   if (order_type == "buy")
   {
      result = OP_BUY;
   } else if (order_type == "sell") 
   {
      result = OP_SELL;
   } else if (order_type == "buy_limit") 
   {
      result = OP_BUYLIMIT;
   } else if (order_type == "sell_limit") 
   {
      result = OP_SELLLIMIT;
   } else if (order_type == "buy_stop") 
   {
      result = OP_BUYSTOP;
   } else if (order_type == "sell_stop") 
   {
      result = OP_SELLSTOP;
   } 
   
   return result;
 }
string HandleCommand(string command)
   {
      // PrintFormat("Reading command: %s", command);
      
      string result = "OK";
      int ticket = -1;
      string delimiter = "^";
      ushort u_sep=StringGetCharacter(delimiter,0);
      string parsedStrings[];
      int count = StringSplit(command, u_sep, parsedStrings);
      double askValue;
      int cmdId = StringToInteger(parsedStrings[0]);
      int order_type;
      
      switch (cmdId) {
               case OPEN_TRADE:
                  // Handle OPEN_TRADE command
                  //Print("Received OPEN_TRADE command");
                  // askValue = SymbolInfoDouble(parsedStrings[1], SYMBOL_ASK);
                  order_type = order_type_LUT(parsedStrings[2]);
                  result = OpenOrder(parsedStrings[1], order_type, parsedStrings[3], parsedStrings[4], parsedStrings[7], parsedStrings[8], parsedStrings[5], parsedStrings[9]);
                  // Your logic for OPEN_TRADE
                  break;
               case MODIFY_POSITION:
                  // Handle MODIFY_POSITION command
                  //Print("Received MODIFY_POSITION command");
                  result = ModifyOrder(parsedStrings[1], parsedStrings[2], parsedStrings[3], parsedStrings[4]);
                  // Your logic for MODIFY_POSITION
                  break;
               case DELETE_ORDER:
                  // Handle DELETE_ORDER command
                  //Print("Received DELETE_ORDER command");
                  // Your logic for DELETE_ORDER
                  result = DeletePendingOrder(parsedStrings[1]);
                  break;
               case PARTIAL_CLOSE:
                  // Handle PARTIAL_CLOSE command
                  //Print("Received PARTIAL_CLOSE command");
                  // Your logic for PARTIAL_CLOSE
                  result = PartialClosePosition(parsedStrings[1], parsedStrings[2]);
                  
                  break;
               case MODIFY_PENDING_ORDER:
                  // Handle MODIFY_PENDING_ORDER command
                  //Print("Received MODIFY_PENDING_ORDER command");
                  // Your logic for MODIFY_PENDING_ORDER
                  break;
               case GET_ALL_ORDERS:
                  // Handle GET_ALL_ORDERS command
                  //Print("Received GET_ALL_ORDERS command");
                  // Your logic for GET_ALL_ORDERS
                  result = GetAllPendingOrders();
                  break;
               case GET_SYMBOL_INFO:
                  // Handle GET_SYMBOL_INFO command
                  //Print("Received GET_SYMBOL_INFO command");
                  // Your logic for GET_SYMBOL_INFO
                  result = GetSymbolInfo(parsedStrings[1]);
                  break;
               case GET_BROKER_MARKET_INSTRUMENT_LIST:
                  // Handle GET_BROKER_MARKET_INSTRUMENT_LIST command
                  //Print("Received GET_BROKER_MARKET_INSTRUMENT_LIST command");
                  // Your logic for GET_BROKER_MARKET_INSTRUMENT_LIST
                  break;
               case GET_OPEN_POSITIONS:
                  // Handle GET_OPEN_POSITIONS command
                  //Print("Received GET_OPEN_POSITIONS command");
                  // Your logic for GET_OPEN_POSITIONS
                  result = GetOpenPositions();
                  break;
               case GET_CLOSED_POSITIONS:
                  // Handle GET_CLOSED_POSITIONS command
                  //Print("Received GET_CLOSED_POSITIONS command");
                  // Your logic for GET_CLOSED_POSITIONS
                  result = GetClosedPositionsOrders();
                  break;
               case CLOSE_POSITION:
                  // Handle CLOSE_POSITION command
                  //Print("Received CLOSE_POSITION command");
                  ticket = StringToInteger(parsedStrings[1]);
                  // Your logic for CLOSE_POSITION
                  result = ClosePosition(ticket);
                  break;
               case GET_LAST_TICK_DATA:
                  // Handle GET_LAST_TICK_DATA command
                  //Print("Received GET_LAST_TICK_DATA command");
                  // Your logic for GET_LAST_TICK_DATA
                  result = getLastTickDataJSON(parsedStrings[1]);
                  break;
               case GET_X_BARS:
                  // Handle GET_X_BARS command
                  //Print("Received GET_X_BARS command");
                  // Your logic for GET_X_BARS
                  result = getXBars_V2(parsedStrings[1], parsedStrings[2], parsedStrings[3]);
                  break;
               default:
                  // Handle unrecognized command
                  //Print("Received unrecognized command");
                  result = "Received unrecognized command";
                  break;
         }
      return result;
   }

//+------------------------------------------------------------------+
