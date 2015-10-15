//+------------------------------------------------------------------+
//|                                          movingAverageEngine.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "movingAverage.mqh"
#include "enum.mqh"

#include <TextDisplay.mqh>

extern TableDisplay   table;

ENUM_TIMEFRAMES         MA_TIMEFRAME=GENERAL_TIMEFRAME;
input int               MA_PERIOD=14;
input double            SLOW_MA_MULT=2.0;
input double            MA_TRIGGER=20.0;
input double            SLOW_MA_TRIGGER_DIV=0.5;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class movingAverageEngine
  {
private:
   movingAverage     _fastMA;
   movingAverage     _slowMA;
   ENUM_DECISION     _decision;
   int               _debugIndex;

public:
                     movingAverageEngine(string symbol);
                    ~movingAverageEngine();

   static int        calcSlowMAPeriod() { return(int)(MA_PERIOD*SLOW_MA_MULT); }
   static int        calcSlowMATrigger() { return(int)(MA_TRIGGER*SLOW_MA_TRIGGER_DIV); }

   bool              init();
   void              deInit();
   bool              refresh();
   ENUM_DECISION     getDecision() { return _decision; }

   int               getDebugIndex() { return _debugIndex; }
   void              setDebugIndex(int debugIndex) { _debugIndex=debugIndex; }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
movingAverageEngine::movingAverageEngine(string symbol) : _fastMA(symbol,MA_PERIOD,MA_TIMEFRAME,MA_TRIGGER),_slowMA(symbol,calcSlowMAPeriod(),MA_TIMEFRAME,calcSlowMATrigger())
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
movingAverageEngine::~movingAverageEngine()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  movingAverageEngine::init(void)
  {
   if(_fastMA.init()==false || _slowMA.init()==false)
      return false;
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   movingAverageEngine::deInit(void)
  {
   _fastMA.deInit();
   _slowMA.deInit();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   movingAverageEngine::refresh()
  {
   if(_fastMA.refresh()==false || _slowMA.refresh()==false)
      return false;

   if(_fastMA.getDecision()==BUY && _slowMA.getDecision()==BUY)
      _decision=BUY;
   else if(_fastMA.getDecision()==SELL && _slowMA.getDecision()==SELL)
      _decision=SELL;
   else
      _decision=UNDIFINED;
      
   table.SetText(_debugIndex,EnumToString(_decision));

   return true;
  }
//+------------------------------------------------------------------+
