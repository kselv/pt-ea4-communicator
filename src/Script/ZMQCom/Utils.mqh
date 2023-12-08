//+------------------------------------------------------------------+
//|                                                        Utils.mq4 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+

struct SymbolInfo {
    string symbol;
    int digits;
    double maxLotSize;
    double minLotSize;
    double lotStep;
    double point;
    double tickSize;
    double tickValue;
    double swapLong;
    double swapShort;
    int stopLevel;
};


struct ClosedOrder {
    int ticket;
    string symbol;
    ENUM_ORDER_TYPE type;
    double openPrice;
    double closePrice;
    double profit;
    datetime openTime;
    datetime closeTime;
};

void GetSymbolInfo(string symbolName, SymbolInfo& symbolInfo)
{
    symbolInfo.symbol = symbolName;
    symbolInfo.digits = MarketInfo(symbolName, MODE_DIGITS);
    symbolInfo.maxLotSize = MarketInfo(symbolName, MODE_MAXLOT);
    symbolInfo.minLotSize = MarketInfo(symbolName, MODE_MINLOT);
    symbolInfo.lotStep = MarketInfo(symbolName, MODE_LOTSTEP);
    symbolInfo.point = MarketInfo(symbolName, MODE_POINT);
    symbolInfo.tickSize = MarketInfo(symbolName, MODE_TICKSIZE);
    symbolInfo.tickValue = MarketInfo(symbolName, MODE_TICKVALUE);
    symbolInfo.swapLong = MarketInfo(symbolName, MODE_SWAPLONG);
    symbolInfo.swapShort = MarketInfo(symbolName, MODE_SWAPSHORT);
    symbolInfo.stopLevel = MarketInfo(symbolName, MODE_STOPLEVEL);
}


// Function to retrieve all closed positions and orders
string GetClosedPositionsOrders() 
{
       string csvString = "Ticket,Symbol,Type,OpenPrice,ClosePrice,Profit,OpenTime,CloseTime\n"; // CSV header
   
       int totalOrders = OrdersHistoryTotal();
       PrintFormat("Total orders: %d", totalOrders);
   
       // Loop through closed orders
       for (int i = 0; i < totalOrders; i++) {
           if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) && OrderCloseTime() > 0) {
               ClosedOrder closedOrder;
               closedOrder.ticket = OrderTicket();
               closedOrder.symbol = OrderSymbol();
               closedOrder.type = OrderType();
               closedOrder.openPrice = OrderOpenPrice();
               closedOrder.closePrice = OrderClosePrice();
               closedOrder.profit = OrderProfit();
               closedOrder.openTime = OrderOpenTime();
               closedOrder.closeTime = OrderCloseTime();
               
               // Build the CSV structure
               string orderLine = StringFormat("%d,%s,%d,%.5f,%.5f,%.5f,%s,%s\n",
                   closedOrder.ticket, closedOrder.symbol, closedOrder.type,
                   closedOrder.openPrice, closedOrder.closePrice, closedOrder.profit,
                   TimeToString(closedOrder.openTime, TIME_DATE), TimeToString(closedOrder.closeTime, TIME_DATE)
               );
               
               // Concatenate the order line to the CSV string
               csvString += orderLine;
           }
       }
       
       return csvString;
}
    

string GetOpenPositions() {
    string csvString = "Ticket,Symbol,Type,Volume,OpenPrice,StopLoss,TakeProfit,OpenTime\n"; // CSV header

    int totalPositions = OrdersTotal();
    for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
        {
            int ticket = OrderTicket();
            string symbol = OrderSymbol();
            int type = OrderType();
            double volume = OrderLots();
            double openPrice = OrderOpenPrice();
            double stopLoss = OrderStopLoss();
            double takeProfit = OrderTakeProfit();
            datetime openTime = OrderOpenTime();
            
            // Build the CSV structure
            string positionLine = StringFormat("%d,%s,%d,%.5f,%.5f,%.5f,%.5f,%s\n",
                ticket, symbol, type, volume, openPrice, stopLoss, takeProfit,
                TimeToString(openTime, TIME_DATE)
            );
            
            // Concatenate the position line to the CSV string
            csvString += positionLine;
        }
     }

    return csvString;
}


string GetSymbolData(string symbol, int timeframe)
{
    string ratesCSV = ""; // Variable to store rates in CSV format
    MqlRates rates[]; // Declare an array to hold historical data

    datetime startDateTime = iTime(symbol, timeframe, 0); // Get the start datetime
    int copied = CopyRates(symbol, timeframe, startDateTime, 2000, rates); // Copy 100 bars of historical data

    if (copied > 0)
    {
        // Loop through the received data
        for (int i = 0; i < copied; i++)
        {
            string timeStr = TimeToString(rates[i].time, TIME_DATE|TIME_MINUTES); // Convert timestamp to string
            string line = StringFormat("%s,%G,%G,%G,%G,%I64d\n", timeStr, rates[i].open, rates[i].high, rates[i].low, rates[i].close, rates[i].tick_volume);

            ratesCSV += line; // Append the CSV line
        }
    }
    else
    {
        Print("Failed to copy rates. Error code: ", GetLastError());
    }
    return ratesCSV;
}

void ModifyPendingOrder(int ticket, double newPrice, double newStopLoss, double newTakeProfit)
{
    if (OrderSelect(ticket, SELECT_BY_TICKET) && OrderType() > OP_SELLLIMIT)
    {
        double currentPrice = OrderOpenPrice();
        double currentStopLoss = OrderStopLoss();
        double currentTakeProfit = OrderTakeProfit();

        if (!OrderModify(ticket, newPrice, NormalizeDouble(newStopLoss, Digits), NormalizeDouble(newTakeProfit, Digits), 0, Blue))
        {
            Print("Failed to modify pending order. Error code: ", GetLastError());
        }
        else
        {
            Print("Pending order modified.");
        }
    }
    else
    {
        Print("Order with ticket ", ticket, " does not exist or is not a pending order.");
    }
}

void PartialClosePosition(int ticket, double volume)
{
    // Check if the order with the specified ticket exists
    if (OrderSelect(ticket, SELECT_BY_TICKET))
    {
        double orderVolume = OrderLots(); // Retrieve the current volume of the order

        if (volume >= orderVolume)
        {
            // If the requested volume to close is greater or equal to the order volume, close the entire position
            if (!OrderClose(ticket, orderVolume, MarketInfo(OrderSymbol(), MODE_BID), 3))
            {
                Print("Failed to close position fully. Error code: ", GetLastError());
            }
            else
            {
                Print("Position fully closed.");
            }
        }
        else
        {
            // Partially close the position
            if (!OrderClose(ticket, volume, MarketInfo(OrderSymbol(), MODE_BID), 3))
            {
                Print("Failed to partially close position. Error code: ", GetLastError());
            }
            else
            {
                Print("Position partially closed.");
            }
        }
    }
    else
    {
        Print("Order with ticket ", ticket, " does not exist.");
    }
}

void GetBrokerMarketInstrumentList()
{
    int totalSymbols = SymbolsTotal(false); // Get the total number of symbols in Market Watch

    for (int i = 0; i < totalSymbols; i++)
    {
        string symbolName = SymbolName(i, false); // Get the symbol name
        Print("Symbol: ", symbolName);
    }
}



int OpenOrder(string symbol, int order_type, double lotSize, double price, double stopLoss, double takeProfit, int slippage = 3, string comment="")
{
    int ticket = -1; // Order ticket number

    // Send a buy limit order
    ticket = OrderSend(symbol, order_type, lotSize, price, slippage, stopLoss, takeProfit, comment, 0, Blue);

    // Check if the order was successfully executed
    if (ticket > 0)
    {
        Print("Buy limit order for ", symbol, " opened successfully at price ", price, ". Ticket: ", ticket);
    }
    else
    {
        Print("Failed to open buy limit order for ", symbol, ". Error code: ", GetLastError());
    }
    return ticket;
}

int ClosePosition(int ticket) {
   string result;
   if(OrderSelect(ticket, SELECT_BY_TICKET)==true)
   {
   
      if (OrderClose(ticket,OrderLots(),Ask,0,Red)) {
         Print("Position closed successfully. Ticket: ", ticket);
         result = IntegerToString(ticket);
      } else {
         Print("Failed to close position. Error: ", GetLastError());
         result = IntegerToString(GetLastError());
      }
   }
   else 
   {
      Print("OrderSelect returned the error of ",GetLastError());
      result = IntegerToString(GetLastError());
   }
   
   
   return result;
}

void DeletePendingOrder(int ticket)
{
    // Check if the order with the specified ticket exists
    if (OrderSelect(ticket, SELECT_BY_TICKET) && OrderType() <= OP_SELLLIMIT)
    {
        bool deleted = OrderDelete(ticket); // Attempt to delete the order

        // Check if the order was successfully deleted
        if (deleted)
        {
            Print("Pending order with ticket ", ticket, " deleted successfully.");
        }
        else
        {
            Print("Failed to delete pending order with ticket ", ticket, ". Error code: ", GetLastError());
        }
    }
    else
    {
        Print("Order with ticket ", ticket, " does not exist or is not a pending order.");
    }
}

//+------------------------------------------------------------------+
