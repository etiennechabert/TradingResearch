//+------------------------------------------------------------------+
//|                                                     CCI.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "enum.mqh"

#include <TextDisplay.mqh>

ENUM_TIMEFRAMES         CCI_TIMEFRAME=GENERAL_TIMEFRAME;
input int               CCI_PERIOD=14;
input double            CCI_ACCEL_TRIGGER=50;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CCI
  {
private:
   int               _handler;
   string            _symbol;
   double            _data[];
   int               _debugIndex;
   int               _barsNumber;
   ENUM_DECISION     _decision;
   ENUM_ACCEL        _accel;

public:
                     CCI(string symbol);
                    ~CCI();

   bool              init(int debugIndex);
   void              deInit();
   bool              refresh();
   ENUM_DECISION     getDecision() { return _decision; }
   ENUM_ACCEL        getAccel() { return _accel; }

   int               getDebugIndex() { return _debugIndex; }
   void              setDebugIndex(int debugIndex) { _debugIndex=debugIndex; }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CCI::CCI(string symbol) : _symbol(symbol)
  {
   _handler=INVALID_HANDLE;
   _barsNumber=0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CCI::~CCI()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   CCI::init(int debugIndex)
  {
   _handler=iCCI(_symbol,CCI_TIMEFRAME,CCI_PERIOD,PRICE_CLOSE);
   if(_handler==INVALID_HANDLE)
      return false;

   _debugIndex= table.AddFieldObject(10,60,debugIndex,3,Yellow);

   if(ArrayResize(_data,2,2)==false || ArraySetAsSeries(_data,true)==false)
      return false;

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   CCI::deInit(void)
  {
   if(_handler!=INVALID_HANDLE)
      return;
   IndicatorRelease(_handler);
   _handler=INVALID_HANDLE;

   if(ArraySize(_data)>0)
      ArrayFree(_data);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   CCI::refresh()
  {
   int      barsNumber=Bars(_symbol,CCI_TIMEFRAME);

   if(_barsNumber==barsNumber && EVERY_TICK==false)
      return true;
   _barsNumber=barsNumber;

   if(CopyBuffer(_handler,0,1,2,_data)<1)
      return false;

   if(_data[0]>0)
      _decision=BUY;
   else if(_data[0]<0)
      _decision=SELL;
   else
      _decision=UNDIFINED;

   if(_data[0]-_data[1]>CCI_ACCEL_TRIGGER)
      _accel=UP_TREND;
   else if(_data[0]-_data[1]<-CCI_ACCEL_TRIGGER)
      _accel=DOWN_TREND;
   else
      _accel=ACCEL_UNDIFINED;

    table.SetText(_debugIndex,EnumToString(_decision));

   return true;
  }
//+------------------------------------------------------------------+
