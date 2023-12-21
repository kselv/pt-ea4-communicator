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

string GetSymbolInfo(string symbolName)
{
    SymbolInfo symbolInfo;
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

    string json = "{";
    json += "\"symbol\": \"" + symbolInfo.symbol + "\",";
    json += "\"digits\": " + DoubleToString(symbolInfo.digits) + ",";
    json += "\"maxLotSize\": " + DoubleToString(symbolInfo.maxLotSize) + ",";
    json += "\"minLotSize\": " + DoubleToString(symbolInfo.minLotSize) + ",";
    json += "\"lotStep\": " + DoubleToString(symbolInfo.lotStep) + ",";
    json += "\"point\": " + DoubleToString(symbolInfo.point) + ",";
    json += "\"tickSize\": " + DoubleToString(symbolInfo.tickSize) + ",";
    json += "\"tickValue\": " + DoubleToString(symbolInfo.tickValue) + ",";
    json += "\"swapLong\": " + DoubleToString(symbolInfo.swapLong) + ",";
    json += "\"swapShort\": " + DoubleToString(symbolInfo.swapShort) + ",";
    json += "\"stopLevel\": " + DoubleToString(symbolInfo.stopLevel);
    json += "}";

    return json;
}



// Function to retrieve all closed positions and orders
string GetClosedPositionsOrders() 
{
       string csvString = "ticket,symbol,position_type,openprice,closeprice,profit,opentime,closetime,comment\n"; // CSV header
   
       int totalOrders = OrdersHistoryTotal();
   
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
               
               string positionName = GetPositionTypeName(closedOrder.type);
               
               // Build the CSV structure
               string orderLine = StringFormat("%d,%s,%s,%.5f,%.5f,%.5f,%s,%s,%s\n",
                   closedOrder.ticket, closedOrder.symbol, positionName,
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
    string csvString = "ticket,symbol,position_type,volume,openprice,stoploss,takeprofit,opentime,profit,comment\n"; // CSV header

    int totalPositions = OrdersTotal();
    for(int i = totalPositions - 1; i >= 0; i--)
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
            
            
            string positionName = GetPositionTypeName(type);
            
            // Build the CSV structure
            string positionLine = StringFormat("%d,%s,%s,%.5f,%.5f,%.5f,%.5f,%s,%.5f,%s\n",
                ticket, symbol, positionName, volume, openPrice, stopLoss, takeProfit,
                TimeToString(openTime, TIME_DATE), profit, comment
            );
            
            // Concatenate the position line to the CSV string
            csvString += positionLine;
        }
     }

    return csvString;
}

// Function to retrieve position type name based on order type
string GetPositionTypeName(int orderType) {
    string positionName;

    switch (orderType) {
        case OP_BUY:
            positionName = "buy";
            break;
        case OP_SELL:
            positionName = "sell";
            break;
        case OP_BUYLIMIT:
            positionName = "buy_limit";
            break;
        case OP_SELLLIMIT:
            positionName = "sell_limit";
            break;
        case OP_BUYSTOP:
            positionName = "buy_stop";
            break;
        case OP_SELLSTOP:
            positionName = "sell_stop";
            break;
        default:
            positionName = "unknown";
            break;
    }
     return positionName;
   }

// Function to retrieve pending orders and store in a CSV-like string
string GetAllPendingOrders() {
    string csvString = "ticket,symbol,position_type,openprice,stoploss,takeprofit,expiration,opentime\n"; // CSV header

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
            
            string positionName = GetPositionTypeName(type);
            
            // Build the CSV structure
            string orderLine = StringFormat("%d,%s,%s,%.5f,%.5f,%.5f,%s,%s\n",
                ticket, symbol, positionName, openPrice, stopLoss, takeProfit,
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

bool isRefresh(string symbol, int periodTf, int max_tf = 0, int min_sleep = 1000){
   
   // Array with timeframes
   int tf[9] = {1, 5, 15, 30, 60, 240, 1440, 10080, 43200};
   
   // If the maximum is 0, then the current value
   max_tf = (max_tf <= 0) ? periodTf : max_tf;
   
   // Current time
   datetime period, tc = TimeCurrent();
   
   for(int i = 0; i < 9; i++){
         
      period = tf[i] * 60;
      
      if(iTime(symbol, tf[i], 1) != (int(tc / period) - 1) * period){
         Sleep(min_sleep);
         return false;   
      }
      if(max_tf < tf[i]) // If the timeframe is greater than the maximum and is also updated, then exit
         break;
   }
   Sleep(min_sleep);
   RefreshRates();
   
   return true;
}

string getXBars(string instrument, int timeframe, int numberOfBars) {
    string data = "Open,High,Low,Close,Volume,Time\n";

    MqlTick tick;

    SymbolInfoTick(instrument, tick);
    SymbolSelect(instrument, true);
    Print("Last ", instrument, "ask price: ", tick.ask);
    
    
      bool result = isRefresh(instrument, timeframe);
      if (result == false)
      {
         Print("Unable to refresh ", instrument);
      }
   
   
    int bars = MathMin(numberOfBars, iBars(instrument, timeframe));
    
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

string getXBars_V2(string instrument, int timeframe, int numberOfBars) {
    string data = "Open,High,Low,Close,Volume,Time\n";
    
      
    // Refresh rates to ensure latest data is fetched
    RefreshRates();

    // Arrays to store the historical data
    MqlRates rates[];
    
    
    
   ArraySetAsSeries(rates, true);    
   
   // Refresh rates to ensure latest data is fetched
   RefreshRates();
   int size = ArrayResize(rates, 10);
   int iNbrRecords = CopyRates(instrument, ENUM_TIMEFRAMES(timeframe), 0, 10, rates);
   Print("symbol ", instrument, " ", rates[0].time);
   // Refresh rates to ensure latest data is fetched
   RefreshRates();
   size = ArrayResize(rates, 10);
   iNbrRecords = CopyRates(instrument, ENUM_TIMEFRAMES(timeframe), 0, 10, rates);
   Print("symbol ", instrument, " ", rates[0].time);
   // Refresh rates to ensure latest data is fetched
   RefreshRates();
   size = ArrayResize(rates, 10);
   iNbrRecords = CopyRates(instrument, ENUM_TIMEFRAMES(timeframe), 0, 10, rates);
   Print("symbol ", instrument, " ", rates[0].time);

    // Resize the array to hold the required number of bars
    ArraySetAsSeries(rates, true);
    size = ArrayResize(rates, numberOfBars);
   
    // Copy the rates
    int copied = CopyRates(instrument, ENUM_TIMEFRAMES(timeframe), 0, numberOfBars, rates);
    if(copied <= 0) {
        Print("Error in CopyRates for ", instrument, ". Error code: ", GetLastError());
        return "";
    }
    
    
    // Print the latest bar time for the symbol
    if(copied > 0) {
        datetime currentTime = TimeCurrent();
        Print("Current Time: ", TimeToString(currentTime, TIME_DATE | TIME_SECONDS), " Latest Bar Time for ", instrument, ": ", TimeToString(rates[0].time, TIME_DATE | TIME_MINUTES), " Timeframe: ", timeframe, " minutes");
    }

    // Print the timeframe
    //Print("Timeframe: ", timeframe, " minutes");

    // Iterate over the copied rates
    for (int i = copied - 1; i >= 0; i--) {
        string barInfo = StringFormat("%.5f,%.5f,%.5f,%.5f,%I64d,%s\n",
                                      rates[i].open, rates[i].high, rates[i].low, rates[i].close,
                                      rates[i].tick_volume, TimeToString(rates[i].time, TIME_DATE | TIME_MINUTES));
        data += barInfo;
    }

    return data;
}



//+------------------------------------------------------------------+
