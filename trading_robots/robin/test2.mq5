//+------------------------------------------------------------------+
//|                                                        test2.mq5 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "volumeFilter.mqh"

volumesFilter  filter(PERIOD_CURRENT,_Symbol);
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(filter.init()==false)
      return INIT_FAILED;
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   filter.deInit();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   static   ENUM_STATE  state;
   
   filter.refresh();
   if(state!=filter.getState())
      Print("State = ",EnumToString(filter.getState())," cut signal = ",filter.cutSignal() == true ? " TRUE -----------------------------" : " false");
   state=filter.getState();
  }
//+------------------------------------------------------------------+
