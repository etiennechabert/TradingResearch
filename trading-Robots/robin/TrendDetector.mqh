//+------------------------------------------------------------------+
//|                                                TrendDetector.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "enum.mqh"

input ENUM_TIMEFRAMES   TREND_TIMEFRAME=PERIOD_H1;
input int               TREND_LONG_PERIOD=100;
input int               TREND_MID_PERIOD=50;
input int               TREND_FAST_PERIOD=20;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class TrendDetector
  {
private:
   string            _symbol;
   int               _handler;
   int               _barsNumber;
   int               _debugIndex;
   ENUM_ACCEL        _trend;
   double            _data[1];

public:
                     TrendDetector(string symbol);
                    ~TrendDetector();

   bool              init();
   void              deInit();
   bool              refresh();

   void              setDebugIndex(int debugIndex) { _debugIndex=debugIndex; }
   ENUM_ACCEL        getDecision() { return _trend; }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TrendDetector::TrendDetector(string symbol) : _symbol(symbol)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TrendDetector::~TrendDetector()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   TrendDetector::init()
  {
   if (TREND_FAST_PERIOD >= TREND_MID_PERIOD || TREND_MID_PERIOD >= TREND_LONG_PERIOD)
      return false;
  
   _handler=iCustom(_symbol,TREND_TIMEFRAME,"FanTrendDetector",TREND_LONG_PERIOD,TREND_MID_PERIOD,TREND_FAST_PERIOD);
   if(_handler==INVALID_HANDLE)
      return false;

   _barsNumber=0;

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   TrendDetector::deInit(void)
  {
   if(_handler!=INVALID_HANDLE)
      IndicatorRelease(_handler);
   _handler=INVALID_HANDLE;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   TrendDetector::refresh(void)
  {
   int   barsNumber=Bars(_symbol,TREND_TIMEFRAME);

   if(_barsNumber==barsNumber && EVERY_TICK==false)
      return true;
   _barsNumber=barsNumber;

   if(CopyBuffer(_handler,0,1,1,_data)<1)
      return false;

   if(_data[0]>=1.0)
      _trend=UP_TREND;
   else if(_data[0]<=-1.0)
                     _trend=DOWN_TREND;
   else if(_data[0]==0.0)
      _trend=ACCEL_UNDIFINED;

  // table.SetText(_debugIndex,EnumToString(_trend));

   return true;
  }
//+------------------------------------------------------------------+
