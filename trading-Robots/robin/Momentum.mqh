//+------------------------------------------------------------------+
//|                                                     Momentum.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "enum.mqh"

#include <TextDisplay.mqh>

extern TableDisplay   table;

input ENUM_TIMEFRAMES   MOMENTUM_TIMEFRAME=PERIOD_H1;
input int               MOMENTUM_PERIOD=14;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Momentum
  {
private:
   int               _handler;
   string            _symbol;
   int               _debugIndex;
   int               _barsNumber;
   ENUM_DECISION     _decision;

public:
                     Momentum(string symbol);
                    ~Momentum();

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
Momentum::Momentum(string symbol) : _symbol(symbol)
  {
   _handler=INVALID_HANDLE;
   _barsNumber=0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Momentum::~Momentum()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   Momentum::init(void)
  {
   _handler=iMomentum(_symbol,MOMENTUM_TIMEFRAME,MOMENTUM_PERIOD,PRICE_CLOSE);
   if(_handler==INVALID_HANDLE)
      return false;

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   Momentum::deInit(void)
  {
   if(_handler!=INVALID_HANDLE)
      return;
   IndicatorRelease(_handler);
   _handler=INVALID_HANDLE;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   Momentum::refresh()
  {
   double   data[1];
   int      barsNumber=Bars(_symbol,MOMENTUM_TIMEFRAME);

   if(_barsNumber==barsNumber && EVERY_TICK==false)
      return true;
   _barsNumber=barsNumber;

   if(CopyBuffer(_handler,0,1,1,data)<1)
      return false;

   if(data[0]>100.0)
      _decision=BUY;
   else if(data[0]<100.0)
      _decision=SELL;
   else
      _decision=UNDIFINED;

 //  table.SetText(_debugIndex,EnumToString(_decision));

   return true;
  }
//+------------------------------------------------------------------+
