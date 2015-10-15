//+------------------------------------------------------------------+
//|                                                         MACD.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include    "enum.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MACD
  {
private:
   string            _symbol;
   int               _handler;
   int               _barsNumbers;
   int               _debugIndex;
   ENUM_DECISION     _decision;
   double            _signalData[1];
   double            _macdData[1];

public:
                     MACD(string symbol);
                    ~MACD();

   bool              init();
   void              deInit();
   bool              refresh();
   ENUM_DECISION     getDecision();
   void              setDebugIndex(int debugIndex) { _debugIndex=debugIndex; }
   int               getDebugIndex() { return _debugIndex; }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MACD::MACD(string symbol) : _symbol(symbol)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MACD::~MACD()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   MACD::init()
  {
   _barsNumbers=0;

   _handler=iMACD(_symbol,GENERAL_TIMEFRAME,12,26,9,PRICE_CLOSE);
   if(_handler==INVALID_HANDLE)
      return false;
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   MACD::deInit()
  {
   if(_handler!=INVALID_HANDLE)
      IndicatorRelease(_handler);
   _handler=INVALID_HANDLE;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   MACD::refresh(void)
  {
   int   barsNumber=Bars(_symbol,GENERAL_TIMEFRAME);

   if(barsNumber==_barsNumbers && EVERY_TICK==false)
      return true;

   _barsNumbers=barsNumber;

   if(CopyBuffer(_handler,0,1,1,_macdData)<1)
      return false;

   if(CopyBuffer(_handler,1,1,1,_signalData)<1)
      return false;

   if(_macdData[0]>0 && _signalData[0]<_macdData[0])
      _decision=BUY;
   else if(_macdData[0]<0 && _signalData[0]>_macdData[0])
      _decision=SELL;
   else
      _decision=UNDIFINED;

   table.SetText(_debugIndex,EnumToString(_decision));

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_DECISION   MACD::getDecision(void)
  {
   return _decision;
  }
//+------------------------------------------------------------------+
