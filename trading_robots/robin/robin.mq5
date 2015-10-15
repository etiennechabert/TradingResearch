//+------------------------------------------------------------------+
//|                                                        robin.mq5 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "Trader.mqh"
//#include <TextDisplay.mqh>

//TableDisplay   table;

Trader   trader1("EURUSD",1);
Trader   trader2("USDJPY",2);
Trader   trader3("GBPUSD",3);
Trader   trader4("USDCHF",4);


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  // table.SetParams(0,0);

   if(trader1.init()==false)
      return INIT_PARAMETERS_INCORRECT;
   if(trader2.init()==false)
      return INIT_PARAMETERS_INCORRECT;
   if(trader3.init()==false)
      return INIT_PARAMETERS_INCORRECT;
   if(trader4.init()==false)
      return INIT_PARAMETERS_INCORRECT;
      
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  // table.Clear();

   trader1.deInit();
   trader2.deInit();
   trader3.deInit();
   trader4.deInit();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   trader1.process();
   trader2.process();
   trader3.process();
   trader4.process();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---

  }
//+------------------------------------------------------------------+

double   OnTester()
{
   double   profit;
   double   expectedPayoff;
   
   profit = TesterStatistics(STAT_PROFIT);
   expectedPayoff = TesterStatistics(STAT_EXPECTED_PAYOFF);
   
   
   if (profit < 0)
      return profit;
   
   return profit * TesterStatistics(STAT_RECOVERY_FACTOR) * TesterStatistics(STAT_EXPECTED_PAYOFF);   
}