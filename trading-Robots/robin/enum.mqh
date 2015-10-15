//+------------------------------------------------------------------+
//|                                                         enum.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

//input ENUM_TIMEFRAMES   GENERAL_TIMEFRAME=PERIOD_H1;
input bool              EVERY_TICK;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_DECISION
  {
   UNDIFINED,
   SELL,
   BUY
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_ACCEL
  {
   UP_TREND,
   DOWN_TREND,
   ACCEL_UNDIFINED,
   DECCEL,
   DEAD
  };
//+------------------------------------------------------------------+
