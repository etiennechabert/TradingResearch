//+------------------------------------------------------------------+
//|                                                         test.mq5 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "Trader.mqh"
#include <TextDisplay.mqh>
input    double OBJECTIVE_TRADE=20;

TableDisplay   table;

Trader   trader1("EURUSD",1);
Trader   trader2("USDJPY",2);
Trader   trader3("GBPUSD",3);
//Trader   trader4("AUDUSD");
//Trader   trader5("USDCHF");
//Trader   trader6("USDCAD");
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   table.SetParams(0,0);

   if(trader1.init()==false)
      return(INIT_PARAMETERS_INCORRECT);
   if(trader2.init()==false)
      return(INIT_PARAMETERS_INCORRECT);
   if(trader3.init()==false)
      return(INIT_PARAMETERS_INCORRECT);
//if(trader4.init()==false)
//   return(INIT_PARAMETERS_INCORRECT);
//if(trader5.init()==false)
//   return(INIT_PARAMETERS_INCORRECT);
//if(trader6.init()==false)
//   return(INIT_PARAMETERS_INCORRECT);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   trader1.deInit();
   trader2.deInit();
   trader3.deInit();
//trader4.deInit();
//trader5.deInit();
//trader6.deInit();
   table.Clear();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   trader1.decision();
   trader2.decision();
   trader3.decision();
//trader4.decision();
//trader5.decision();
//trader6.decision();
  }
//+------------------------------------------------------------------+

double getProfitFactor()
  {
   if(TesterStatistics(STAT_GROSS_LOSS)==0)
      return 1;
   double val=TesterStatistics(STAT_GROSS_PROFIT)/(TesterStatistics(STAT_GROSS_LOSS)*-1);

   return val;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//double OnTester()
//  {
////double   objective_trade=OBJECTIVE_TRADE;
////double   mult_result=((TesterStatistics(STAT_TRADES)/objective_trade)/((TesterStatistics(STAT_TRADES)/objective_trade)+1))*2.0;
////if(mult_result>2)
////   mult_result=2;
//
//   if(TesterStatistics(STAT_TRADES)<1 || TesterStatistics(STAT_LOSS_TRADES)==0 || TesterStatistics(STAT_PROFIT_TRADES)==0)
//      return(0);
//
//   double   profit_factor=TesterStatistics(STAT_GROSS_PROFIT)/(-TesterStatistics(STAT_GROSS_LOSS));
//   if(profit_factor>20)
//      profit_factor=20;
//
//   double   win_factor=TesterStatistics(STAT_PROFIT_TRADES)/TesterStatistics(STAT_LOSS_TRADES);
//   if(win_factor>20)
//      win_factor=20;
//
//   double   win_average=(profit_factor+win_factor)/2;
//
////double   evolution_multiplicator=TesterStatistics(STAT_INITIAL_DEPOSIT)/(TesterStatistics(STAT_PROFIT));
////if(evolution_multiplicator>5)
////   evolution_multiplicator=5;
//
//   double   dd_factor_balance= 1 -(TesterStatistics(STAT_BALANCE_DDREL_PERCENT)/100);
//   double   dd_factor_equity = 1 -(TesterStatistics(STAT_EQUITY_DDREL_PERCENT)/100);
//
//   double   dd_factor_ratio=(dd_factor_balance+dd_factor_equity)/2.0;
//
//   if(TesterStatistics(STAT_PROFIT)<0)
//      return(TesterStatistics(STAT_PROFIT)/(win_factor*profit_factor));
//   return(win_average*TesterStatistics(STAT_PROFIT)*dd_factor_ratio*TesterStatistics(STAT_SHARPE_RATIO));
//  }
//+------------------------------------------------------------------+

double   OnTester()
  {
   double value=TesterStatistics(STAT_RECOVERY_FACTOR);

   if(value<0)
      return TesterStatistics(STAT_PROFIT);

   if(value==0)
      return -650;
      
   return value;
  }
//+------------------------------------------------------------------+
