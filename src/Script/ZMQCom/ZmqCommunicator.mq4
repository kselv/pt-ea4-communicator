#include <Zmq/Zmq.mqh>
#include "Utils.mqh"
//+------------------------------------------------------------------+
//| Hello World server in MQL                                        |
//| Binds REP socket to tcp://*:5555                                 |
//| Expects "Hello" from client, replies with "World"                |
//+------------------------------------------------------------------+


Context context("helloworld");
Socket socket(context,ZMQ_REP);
string address = "tcp://*:5557";

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
 CLOSE_POSITION = 11
};
  

void OnStart()
  {
   PrintFormat("STARTING ZMQ ASSISTANT");
    int result = socket.bind(address);
    
    if (result != 1) {
        PrintFormat("Error binding socket: %d", result);
        // Handle error condition (e.g., return INIT_FAILED or take appropriate action)
        return;
    }

    string test = GetSymbolData("EURUSD", PERIOD_H1);
    PrintFormat("Data retrieved!");

    while (!IsStopped()) {
        ZmqMsg clientCmd;
        result = socket.recv(clientCmd, ZMQ_DONTWAIT); // Set ZMQ_DONTWAIT flag
        if (result != 1) {
            // No message received, do other tasks or wait
            Sleep(500);
            continue;
        }else {
            // Message received
            string command = clientCmd.getData();
            PrintFormat("Received result %d", result);
            PrintFormat("Received: %s", command);
            
            string replyMsg = HandleCommand(command);

            ZmqMsg reply(replyMsg);
            socket.send(reply);
            
            if (command == "break^") {
               break;
            }
        }
        
        // Processed one message, then break the loop (remove break to continuously check for messages)
        //break;
    }
   
    PrintFormat("PROCESS STOPPED!!!!");
  }
  
string HandleCommand(string command)
   {
      PrintFormat("Reading command: %s", command);
      
      string result = "OK";
      int ticket = -1;
      string delimiter = "^";
      ushort u_sep=StringGetCharacter(delimiter,0);
      string parsedStrings[];
      int count = StringSplit(command, u_sep, parsedStrings);
      
      int cmdId = StringToInteger(parsedStrings[0]);
      
      switch (cmdId) {
               case OPEN_TRADE:
                  // Handle OPEN_TRADE command
                  Print("Received OPEN_TRADE command");
                  OpenOrder(parsedStrings[1], parsedStrings[2], parsedStrings[3], Ask, parsedStrings[7], parsedStrings[8], parsedStrings[5], parsedStrings[9]);
                  // Your logic for OPEN_TRADE
                  break;
               case MODIFY_POSITION:
                  // Handle MODIFY_POSITION command
                  Print("Received MODIFY_POSITION command");
                  // Your logic for MODIFY_POSITION
                  break;
               case DELETE_ORDER:
                  // Handle DELETE_ORDER command
                  Print("Received DELETE_ORDER command");
                  // Your logic for DELETE_ORDER
                  break;
               case PARTIAL_CLOSE:
                  // Handle PARTIAL_CLOSE command
                  Print("Received PARTIAL_CLOSE command");
                  // Your logic for PARTIAL_CLOSE
                  break;
               case MODIFY_PENDING_ORDER:
                  // Handle MODIFY_PENDING_ORDER command
                  Print("Received MODIFY_PENDING_ORDER command");
                  // Your logic for MODIFY_PENDING_ORDER
                  break;
               case GET_ALL_ORDERS:
                  // Handle GET_ALL_ORDERS command
                  Print("Received GET_ALL_ORDERS command");
                  // Your logic for GET_ALL_ORDERS
                  break;
               case GET_SYMBOL_INFO:
                  // Handle GET_SYMBOL_INFO command
                  Print("Received GET_SYMBOL_INFO command");
                  // Your logic for GET_SYMBOL_INFO
                  break;
               case GET_BROKER_MARKET_INSTRUMENT_LIST:
                  // Handle GET_BROKER_MARKET_INSTRUMENT_LIST command
                  Print("Received GET_BROKER_MARKET_INSTRUMENT_LIST command");
                  // Your logic for GET_BROKER_MARKET_INSTRUMENT_LIST
                  break;
               case GET_OPEN_POSITIONS:
                  // Handle GET_OPEN_POSITIONS command
                  Print("Received GET_OPEN_POSITIONS command");
                  // Your logic for GET_OPEN_POSITIONS
                  result = GetOpenPositions();
                  break;
               case GET_CLOSED_POSITIONS:
                  // Handle GET_CLOSED_POSITIONS command
                  Print("Received GET_CLOSED_POSITIONS command");
                  // Your logic for GET_CLOSED_POSITIONS
                  result = GetClosedPositionsOrders();
                  break;
               case CLOSE_POSITION:
                  // Handle CLOSE_POSITION command
                  Print("Received CLOSE_POSITION command");
                  ticket = StringToInteger(parsedStrings[1]);
                  // Your logic for CLOSE_POSITION
                  result = ClosePosition(ticket);
                  break;
               default:
                  // Handle unrecognized command
                  Print("Received unrecognized command");
                  break;
         }
      return result;
   }

void OnDeinit(const int reason)
  {
   PrintFormat("DeInit reason: %d", reason);
   
   context.shutdown();
   socket.unbind(address);
   socket.disconnect(address);
   
  }  