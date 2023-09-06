//+------------------------------------------------------------------+
//|         Support and Resistance Expert Advisor                    |
//+------------------------------------------------------------------+
#include <Trade/Trade.mqh>

CTrade trade;
ulong posTicket;
int neighboors = 10;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   string init_message = "RSI-BOLLINGERBAND Expert Advisor has been Initialized";

   ObjectsDeleteAll(0, 0, -1);
   Print(init_message);
   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   string deinit_message = "RSI-BOLLINGERBAND Expert Advisor has been Shut Down";
   Print(deinit_message);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
// BasicSupportResistanceStrat();
   double currentClose = iClose(_Symbol, PERIOD_CURRENT, 3);
   double lastAnalyzed = 0;
   if(currentClose != lastAnalyzed)
     {
      PlotPivots(200, currentClose);
      lastAnalyzed = currentClose;
     }
   int totalObjects = ObjectsTotal(0, 0);
   for(int i = 0; i < totalObjects; i++)
     {
      string objectName = ObjectName(0, i);
      string type = StringSubstr(objectName, 0, 1); // R or S for Resistance or Support
      double level = StringSubstr(objectName, 1); // Implement placing trades if conditions are met
      //ConcludeTrade(type, level);
      test1(type, level);

     }


  }
//+------------------------------------------------------------------+
//|    Test function to see if long and short logic are being met    |
//+------------------------------------------------------------------+
void test1(string type, double level)
  {
   if(type == "R")
     {
      double prev_high2 = iHigh(_Symbol, PERIOD_CURRENT, 2);
      double prev_close2 = iClose(_Symbol, PERIOD_CURRENT, 2);
      double prev_close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
      if(prev_high2 >= level * 0.999)
        {
         if(prev_close2 < level)
           {
            if(prev_close1 > level)
              {
               Print("Condition Met for Longing Resistance");
               if(posTicket <= 0)
                    {
                     // if no pos is open, Open a Short
                     double prev_low2 = iLow(_Symbol, PERIOD_CURRENT, 1);
                     double currentclose = iClose(_Symbol, PERIOD_CURRENT, 0);
                     double distance = currentclose - prev_low2;
                     double take_profit = currentclose + (distance * 1.2);
                     trade.Buy(0.01, _Symbol, 0, prev_low2,take_profit, "S&R EA Longing resistance");
                     posTicket = trade.ResultOrder();
                    }
              }
            else
               if(prev_close1 < level)
                 {
                  Print("Condition Met for Shorting Resistance");
                  if(posTicket <= 0)
                    {
                     // if no pos is open, Open a Short
                     double prev_high2 = iHigh(_Symbol, PERIOD_CURRENT, 1);
                     double currentclose = iClose(_Symbol, PERIOD_CURRENT, 0);
                     double distance = prev_high2 - currentclose;
                     double take_profit = currentclose - (distance * 1.2);
                     trade.Sell(0.01, _Symbol, 0, prev_high2,take_profit, "S&R EA Shorting resistance");
                     posTicket = trade.ResultOrder();
                    }
                 }
           }
        }
     }
   else
      if(type == "S")
        {
         double prev_low2 = iLow(_Symbol, PERIOD_CURRENT, 2);
         double prev_close2 = iClose(_Symbol, PERIOD_CURRENT, 2);
         double prev_close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
         if(prev_low2 <= level * 1.001)
           {
            if(prev_close2 > level)
              {
               if(prev_close1 < level)
                 {
                  Print("Condition Met for Shorting Support");
                  if(posTicket <= 0)
                    {
                     // if no pos is open, Open a Short
                     double prev_high2 = iHigh(_Symbol, PERIOD_CURRENT, 1);
                     double currentclose = iClose(_Symbol, PERIOD_CURRENT, 0);
                     double distance = prev_high2 - currentclose;
                     double take_profit = currentclose - (distance * 1.2);
                     trade.Sell(0.01, _Symbol, 0, prev_high2,take_profit, "S&R EA Shorting Support");
                     posTicket = trade.ResultOrder();
                    }
                 }
               else
                  if(prev_close1 > level)
                    {
                     Print("Condition Met for Longing Support");
                     if(posTicket <= 0)
                    {
                     // if no pos is open, Open a Short
                     double prev_low2 = iLow(_Symbol, PERIOD_CURRENT, 1);
                     double currentclose = iClose(_Symbol, PERIOD_CURRENT, 0);
                     double distance = currentclose - prev_low2;
                     double take_profit = currentclose + (distance * 1.2);
                     trade.Buy(0.01, _Symbol, 0, prev_low2,take_profit, "S&R EA Longing Support");
                     posTicket = trade.ResultOrder();
                    }
                    }
              }
           }
        }
  }
//+-----------------------------------------------------------------------------------+
//|                                 Strategy function                                 |
//|Depending on the type of object, and the level define a condition to place trades. |
//|Function to determine when to open positions and what type of positions            |
//+-----------------------------------------------------------------------------------+
void ConcludeTrade(string type,double level)
  {
   if(type == 'R')
     {
      double prev_high2 = iHigh(_Symbol, PERIOD_CURRENT, 2);
      double prev_close2 = iClose(_Symbol, PERIOD_CURRENT, 2);
      double prev_close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
      if(prev_high2 >= level * 0.999)
        {
         // If 2nd prev high is in the resistance area.
         if(prev_close2 < level)
           {
            // if 2nd prev close is below the resistance area.
            if(prev_close1 > level)
              {
               // if prev close is above the resistance area. Bullish
               Print("Long possibility available");

               if(posTicket <= 0)
                 {
                  // if no open pos. Open a Long
                  trade.Buy(0.01, _Symbol);
                  posTicket = trade.ResultOrder();
                 }
               else
                  if(posTicket > 0)
                    {
                     // if pos is open, check type, if Short, close it to open a Long.
                     int positionType = PositionGetInteger(POSITION_TYPE, posTicket);
                     if(positionType == POSITION_TYPE_SELL)
                       {
                        bool result = trade.PositionClose(posTicket);
                        if(result)
                          {
                           // if result is succesfull, open a Long.
                           trade.Buy(0.01, _Symbol);
                          }
                       }
                    }
              }
            else
               if(prev_close1 < level)
                 {
                  // if prev close is below resistance area. Bearish
                  Print("Short possibility available");
                  if(posTicket <= 0)
                    {
                     // if no pos is open, Open a Short.
                     trade.Sell(0.01, _Symbol);
                     posTicket = trade.ResultOrder();
                    }
                  else
                     if(posTicket > 0)
                       {
                        // if a pos is open, Check if its a Long, Close it to open a Short.
                        int positionType = PositionGetInteger(POSITION_TYPE, posTicket);
                        if(positionType == POSITION_TYPE_BUY)
                          {
                           bool result = trade.PositionClose(posTicket);
                           if(result)
                             {
                              // if result is succesfull, open a Short.
                              trade.Sell(0.01, _Symbol);
                             }
                          }
                       }
                 }
           }
        }

     }
   else
      if(type == 'S')
        {
         double prev_low2 = iLow(_Symbol, PERIOD_CURRENT, 2);
         double prev_close2 = iClose(_Symbol, PERIOD_CURRENT, 2);
         double prev_close1 = iClose(_Symbol, PERIOD_CURRENT, 1);

         if(prev_low2 <= level * 1.001)
           {
            // 2nd Prev candle Low must reach the Support level
            if(prev_close2 > level)
              {
               // 2nd Prev candle close must be above the Support level
               if(prev_close1 < level)
                 {
                  // Prev candle close below Support level, Bearish.
                  Print("Short possibility available");
                  if(posTicket <= 0)
                    {
                     // if no pos is open, Open a Short
                     trade.Sell(0.01, _Symbol);
                     posTicket = trade.ResultOrder();
                    }
                  else
                     if(posTicket > 0)
                       {
                        // if a pos is open. Check if its a long and close it to open a short.
                        int positionType = PositionGetInteger(POSITION_TYPE, posTicket);
                        if(positionType == POSITION_TYPE_BUY)
                          {
                           bool result = trade.PositionClose(posTicket); // try to close the position.
                           if(result)
                             {
                              // if position closed succesfully, open a short.
                              trade.Sell(0.01, _Symbol);
                              posTicket = trade.ResultOrder();
                             }
                          }
                       }
                 }
               else
                  if(prev_close1 > level)
                    {
                     // Prev candle close above Suppport level. Bullish.
                     Print("Long possibility available");
                     if(posTicket <= 0)
                       {
                        // if no pos is open. Open a Long.
                        trade.Buy(0.01, _Symbol);
                        posTicket = trade.ResultOrder();
                       }
                     else
                        if(posTicket > 0)
                          {
                           // if a pos is open. Check if its a Short and close it to open a Long.
                           int positionType = PositionGetInteger(POSITION_TYPE, posTicket);

                           if(positionType == POSITION_TYPE_SELL)
                             {
                              bool result = trade.PositionClose(posTicket);
                              if(result)
                                {
                                 // if position succesfully closed, open a Long.
                                 trade.Buy(0.01, _Symbol);
                                 posTicket = trade.ResultOrder();
                                }
                             }
                          }
                    }
              }
           }
        }
  }

//+------------------------------------------------------------------+
//|          Function to draw Resistance line                        |
//+------------------------------------------------------------------+
void DrawResistance(double resistancePrice, int i)
  {
   string objectname = "R" + string(resistancePrice);
   int resistanceLine = ObjectCreate(0, objectname, OBJ_TREND, 0, i, resistancePrice, TimeCurrent(), resistancePrice);
   ObjectSetInteger(0, objectname, OBJPROP_COLOR, clrBlue);
   ObjectSetInteger(0, objectname, OBJPROP_WIDTH, 3);
  }

//+------------------------------------------------------------------+
//|           Function to draw Support line                          |
//+------------------------------------------------------------------+
void DrawSupport(double supportPrice, int i)
  {
   string objectname = "S" + string(supportPrice);
   int supportLine = ObjectCreate(0, objectname, OBJ_TREND, 0, i, supportPrice, TimeCurrent(), supportPrice);
   ObjectSetInteger(0, objectname, OBJPROP_COLOR, clrPurple);
   ObjectSetInteger(0, objectname, OBJPROP_WIDTH, 3);
  }

//+------------------------------------------------------------------+
//|           Function to define if candle is a Pivot High           |
//+------------------------------------------------------------------+
bool PivotHigh(int candleIndex)
  {
   bool isPivotHigh = false;
   if(candleIndex - neighboors >= 1)
     {
      double currentHigh = iHigh(_Symbol, PERIOD_CURRENT, candleIndex);
      int arraysize = neighboors * 2;
      double Highs[20]; // Must be double the value of neighboors

      int IndexHigh = 0;
      for(int i = 1; i <= neighboors; i++)
        {
         double High1 = iHigh(_Symbol, PERIOD_CURRENT, candleIndex - i);
         double High2 = iHigh(_Symbol, PERIOD_CURRENT, candleIndex + i);

         Highs[IndexHigh] = High1;
         IndexHigh++;
         Highs[IndexHigh] = High2;
         IndexHigh++;
        }

      double HighestHigh = findMaxValueInArray(Highs);

      if(currentHigh >= HighestHigh)
        {
         isPivotHigh = true;
        }
     }

   return isPivotHigh;
  }

//+------------------------------------------------------------------+
//|          Function to define if candle is a Pivot Low             |
//+------------------------------------------------------------------+
bool PivotLow(int candleIndex)
  {
   bool isPivotLow = false;
   if(candleIndex - neighboors >= 1)
     {
      double currentLow = iLow(_Symbol, PERIOD_CURRENT, candleIndex);
      int l = neighboors * 2;
      double Lows[20]; // Must be double the value of neighboors

      int IndexLow = 0;
      for(int i = 1; i <= neighboors; i++)
        {
         double Low1 = iLow(_Symbol, PERIOD_CURRENT, candleIndex - i);
         double Low2 = iLow(_Symbol, PERIOD_CURRENT, candleIndex + i);

         Lows[IndexLow] = Low1;
         IndexLow++;
         Lows[IndexLow] = Low2;
         IndexLow++;
        }

      double LowestLow = findMinValueInArray(Lows);

      if(currentLow <= LowestLow)
        {
         isPivotLow = true;
        }
     }

   return isPivotLow;
  }




//+------------------------------------------------------------------+
//|            Function to find max value in array                   |
//+------------------------------------------------------------------+
double findMaxValueInArray(const double& array[])
  {
   int arraySize = ArraySize(array);
   double maxValue = array[0]; // Initialize with the first element of the array

   for(int i = 1; i < arraySize; i++)
     {
      if(array[i] > maxValue)
        {
         maxValue = array[i];
        }
     }

   return maxValue;
  }

//+------------------------------------------------------------------+
//|            Function to find min value in array                   |
//+------------------------------------------------------------------+
double findMinValueInArray(const double& array[])
  {
   int arraySize = ArraySize(array);
   double minValue = array[0]; // Initialize with the first element of the array

   for(int i = 1; i < arraySize; i++)
     {
      if(array[i] < minValue)
        {
         minValue = array[i];
        }
     }

   return minValue;
  }

//+------------------------------------------------------------------------------------+
//|     Function to plot pivots points on the chart as Support or Resistance levels    |
//+------------------------------------------------------------------------------------+
void PlotPivots(int lookback, double currentClose)
  {
   for(int i = lookback - 1; i >= 1; i--)    // Start from lookback - 1 and loop backwards
     {
      double currentHigh = iHigh(_Symbol, PERIOD_CURRENT, i);
      double currentLow = iLow(_Symbol, PERIOD_CURRENT, i);
      double currentTime = iTime(_Symbol, PERIOD_CURRENT, i);

      bool isPivotHigh = PivotHigh(i);
      bool isPivotLow = PivotLow(i);


      if(isPivotHigh)
        {

         if(currentHigh > currentClose)
           {
            DrawResistance(currentHigh, currentTime);
           }
         else
            if(currentHigh < currentClose)
              {
               DrawSupport(currentHigh, currentTime);
              }
        }

      if(isPivotLow)
        {
         if(currentLow > currentClose)
           {
            DrawResistance(currentLow, currentTime);
           }
         else
            if(currentLow < currentClose)
              {
               DrawSupport(currentLow, currentTime);
              }
        }
     }
  }
//+------------------------------------------------------------------+
