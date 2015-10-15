//+------------------------------------------------------------------+
//|                                               StochIndicator.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "enum.mqh"

input ENUM_TIMEFRAMES   STOCH_TIMEFRAME;
input double            STOCH_OVER=20.0;
input bool              STOCH_ONLY_OVERSIGNAL=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class StochIndicator
  {
private:
   string            _symbol;
   int               _barNumber;
   int               _debugIndex;
   int               _handle;
   ENUM_DECISION     _decision;
   double            _mainLine[1];
   double            _signalLine[1];

public:
                     StochIndicator(string symbol);
                    ~StochIndicator();

   bool              init();
   bool              refresh();
   ENUM_DECISION     getDecision() { return _decision; }
   void              setDebugIndex(int debugIndex) { _debugIndex=debugIndex; }
   int               getDebugIndex() { return _debugIndex; }
   void              deInit();

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
StochIndicator::StochIndicator(string symbol) : _symbol(symbol)
  {
   _handle=INVALID_HANDLE;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
StochIndicator::~StochIndicator()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  StochIndicator::init(void)
  {
   _barNumber = 0;
   _handle=iStochastic(_symbol,STOCH_TIMEFRAME,5,3,3,MODE_SMA,STO_LOWHIGH);

   if(_handle==INVALID_HANDLE)
     {
      Print("Error during creation of stochastic indicator");
      return false;
     }

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   StochIndicator::refresh(void)
  {
   int   barNumber=Bars(_symbol,STOCH_TIMEFRAME);

   if(barNumber==_barNumber)
      return true;

   _barNumber=_barNumber;
   
   if(_handle==INVALID_HANDLE)
     {
      Print("Error during refresh stoch indicator : No handle exist");
      return false;
     }

   if(CopyBuffer(_handle,0,0,1,_mainLine)<1)
      return false;

   if(CopyBuffer(_handle,1,0,1,_signalLine)<1)
      return false;

   if(_mainLine[0]<=STOCH_OVER)
      _decision=SELL;
   else if(_mainLine[0]>=(100.0-STOCH_OVER))
                         _decision=BUY;
   else if(STOCH_ONLY_OVERSIGNAL==false && _mainLine[0]>_signalLine[0])
      _decision=BUY;
   else if(STOCH_ONLY_OVERSIGNAL==false && _mainLine[0]<_signalLine[0])
      _decision=SELL;
   else
      _decision=UNDIFINED;

   table.SetText(_debugIndex,EnumToString(_decision));

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  StochIndicator::deInit(void)
  {
   if(_handle!=INVALID_HANDLE)
      IndicatorRelease(_handle);
   _handle=INVALID_HANDLE;
  }
//+------------------------------------------------------------------+
