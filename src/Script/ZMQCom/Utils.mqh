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

#include <stdlib.mqh>

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
    string comment;
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
       string csvString = "ticket,symbol,type,openprice,closeprice,profit,opentime,closetime,comment\n"; // CSV header
   
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
               closedOrder.comment = OrderComment();
               
               // Build the CSV structure
               string orderLine = StringFormat("%d,%s,%d,%.5f,%.5f,%.5f,%s,%s,%s\n",
                   closedOrder.ticket, closedOrder.symbol, closedOrder.type,
                   closedOrder.openPrice, closedOrder.closePrice, closedOrder.profit,
                   TimeToString(closedOrder.openTime, TIME_DATE), TimeToString(closedOrder.closeTime, TIME_DATE), closedOrder.comment
               );
               
               // Concatenate the order line to the CSV string
               csvString += orderLine;
           }
       }
       
       return csvString;
}
    

string GetOpenPositions() {
    string csvString = "ticket,symbol,type,volume,openprice,stoploss,takeprofit,opentime,profit,comment\n"; // CSV header

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
            double profit = OrderProfit();
            datetime openTime = OrderOpenTime();
            string comment= OrderComment();
            
            // Build the CSV structure
            string positionLine = StringFormat("%d,%s,%d,%.5f,%.5f,%.5f,%.5f,%s,%.5f,%s\n",
                ticket, symbol, type, volume, openPrice, stopLoss, takeProfit,
                TimeToString(openTime, TIME_DATE), profit, comment
            );
            
            // Concatenate the position line to the CSV string
            csvString += positionLine;
        }
     }

    return csvString;
}

// Function to retrieve pending orders and store in a CSV-like string
string GetAllPendingOrders() {
    string csvString = "ticket,symbol,type,openprice,stoploss,takeprofit,expiration,opentime\n"; // CSV header

    int totalOrders = OrdersTotal();
    
    // Loop through all orders
    for (int i = 0; i < totalOrders; i++) {
        // Select order in open trades and if it is a pending order
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderType() > OP_SELL) {
            int ticket = OrderTicket();
            string symbol = OrderSymbol();
            int type = OrderType();
            double openPrice = OrderOpenPrice();
            double stopLoss = OrderStopLoss();
            double takeProfit = OrderTakeProfit();
            datetime expiration = OrderExpiration();
            datetime openTime = OrderOpenTime();
            
            // Build the CSV structure
            string orderLine = StringFormat("%d,%s,%d,%.5f,%.5f,%.5f,%s,%s\n",
                ticket, symbol, type, openPrice, stopLoss, takeProfit,
                TimeToString(expiration, TIME_DATE), TimeToString(openTime, TIME_DATE)
            );
            
            // Concatenate the order line to the CSV string
            csvString += orderLine;
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

string ModifyOrder(int ticket, double newPrice, double newStopLoss, double newTakeProfit)
{
   string result = "OK";
    if (OrderSelect(ticket, SELECT_BY_TICKET))
    {
        double currentPrice = OrderOpenPrice();
        double currentStopLoss = OrderStopLoss();
        double currentTakeProfit = OrderTakeProfit();
        
        if (newPrice == 0) 
        {
         newPrice = currentPrice;
        }

        if (!OrderModify(ticket, newPrice, NormalizeDouble(newStopLoss, Digits), NormalizeDouble(newTakeProfit, Digits), 0, Blue))
        {
            Print("Failed to modify pending order. Error code: ", GetLastError());
            result = ErrorDescription(GetLastError());
        }
        else
        {
            Print("Pending order modified.");
        }
    }
    else
    {
        Print("Order with ticket ", ticket, " does not exist or is not a pending order.");
        result = ErrorDescription(GetLastError());
    }
    
    return result;
}

string PartialClosePosition(int ticket, double volume)
{
   // Output variable
   string result = "OK";
   
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
                result = ErrorDescription(GetLastError());
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
                result = ErrorDescription(GetLastError());
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
        result = ErrorDescription(GetLastError());
    }
    
    return result;
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

int decimalPlacesForPairs(string sPair)  {
   return MarketInfo(sPair ,MODE_DIGITS);
}

string OpenOrder(string symbol, int order_type, double lotSize, double price, double stopLoss, double takeProfit, int slippage = 3, string comment="")
{
    int ticket = -1; // Order ticket number
    int symbolDigits = decimalPlacesForPairs(symbol);
    price = NormalizeDouble(price,symbolDigits);
    stopLoss = NormalizeDouble(stopLoss,symbolDigits);
    takeProfit = NormalizeDouble(takeProfit,symbolDigits);
    
    Print("Opening order ", symbol, " ", order_type, " ", lotSize," openprice ", price," SL ", stopLoss," TP ", takeProfit, " com:", comment);
    

    // Send a buy limit order
    //ticket = OrderSend(symbol, order_type, lotSize, price, slippage, stopLoss, takeProfit, comment, 0, Blue);
    ticket = OrderSend(symbol, order_type, lotSize, price, slippage, stopLoss, takeProfit, comment, 0, 0, Blue);
    // Check if the order was successfully executed
    if (ticket > 0)
    {
        Print("Order for ", symbol, " opened successfully at price ", price, ". Ticket: ", ticket);
    }
    else
    {
        Print("Failed to open order for ", symbol, ". Error code: ", GetLastError());
        Print(ErrorDescription(GetLastError()));
    }
    
    // Return converted ticket to string
    return IntegerToString(ticket);
}

int ClosePosition(int ticket) {
   string result;
   if(OrderSelect(ticket, SELECT_BY_TICKET)==true)
   {
   
      if (OrderClose(ticket,OrderLots(),0,0,Red)) {
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

string DeletePendingOrder(int ticket)
{
   string result = "OK";
   
    // Check if the order with the specified ticket exists
    if (OrderSelect(ticket, SELECT_BY_TICKET))
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
            result = IntegerToString(GetLastError());
        }
    }
    else
    {
        Print("Order with ticket ", ticket, " does not exist or is not a pending order.");
        result = IntegerToString(GetLastError());
    }
    return result;
}

struct TickData {
    string instrument;
    datetime date;
    double ask;
    double bid;
    double lastDealPrice;
    long volume;
    int spreadPoints;
    long dateInMilliseconds;
};

string getLastTickDataJSON(string instrument) {
    MqlTick tick;

    if (SymbolInfoTick(instrument, tick)) {
    
        double lastDealPrice = (tick.ask + tick.bid) / 2.0;
        double spreadPoints = (NormalizeDouble(tick.ask - tick.bid, _Digits) / Point);
        double dateInMilliseconds = tick.time * 1000;
        string jsonString = "{";
        jsonString += "\"instrument\":\"" + instrument + "\",";
        jsonString += "\"date\":" + IntegerToString(tick.time) + ",";
        jsonString += "\"ask\":" + DoubleToString(tick.ask, _Digits) + ",";
        jsonString += "\"bid\":" + DoubleToString(tick.bid, _Digits) + ",";
        jsonString += "\"lastDealPrice\":" + DoubleToString(lastDealPrice, _Digits) + ",";
        jsonString += "\"volume\":" + DoubleToString(tick.volume) + ",";
        jsonString += "\"spreadPoints\":" + IntegerToString(spreadPoints) + ",";
        jsonString += "\"dateInMilliseconds\":" + DoubleToString(dateInMilliseconds);
        jsonString += "}";

        return jsonString;
    } else {
        Print("Failed to retrieve tick data for ", instrument);
        return "{}"; // Returning an empty JSON object if retrieval fails
    }
}


string getXBars(string instrument, int timeframe, int numberOfBars) {
    string data = "Open,High,Low,Close,Volume,Time\n";


    int bars = MathMin(numberOfBars, iBars(instrument, timeframe));
    
    Print(iClose(instrument, timeframe, 0));
    for (int i = bars - 1; i >= 0; i--) {
        double open = iOpen(instrument, timeframe, i);
        double high = iHigh(instrument, timeframe, i);
        double low = iLow(instrument, timeframe, i);
        double close = iClose(instrument, timeframe, i);
        long volume = iVolume(instrument, timeframe, i);
        int time = iTime(instrument, timeframe, i);

        string barInfo = StringFormat("%.5f,%.5f,%.5f,%.5f,%I64d,%s\n", open, high, low, close, volume, TimeToString(time, TIME_DATE | TIME_MINUTES));
        data = data + barInfo;
    }

    return data;
}


//+------------------------------------------------------------------+
