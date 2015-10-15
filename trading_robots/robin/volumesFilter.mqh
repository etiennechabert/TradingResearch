//+------------------------------------------------------------------+
//|                                                 volumeFilter.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "enum.mqh"

input ENUM_TIMEFRAMES   VOLUME_TIMEFRAME=PERIOD_H1;
//input int DEPTH_VOLUME=5;
//input int SMOOTHING_VOLUME=13;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class volumesFilter
  {
private:
   ENUM_DECISION     refreshState();
   void              refreshSignal();
   bool              refreshData();

public:
                     volumesFilter(string symbol);
                    ~volumesFilter();

   bool              init();
   bool              refresh();
   ENUM_DECISION     getState();
   void              setDebugIndex(int debugIndex) { _debugIndex=debugIndex; }
   int               getDebugIndex() { return _debugIndex; }
   bool              cutSignal();
   void              deInit();

private:
   ENUM_TIMEFRAMES   _timeFrame;
   string            _symbol;
   int               _debugIndex;
   int               _handler;
   int               _barNumber;
   ENUM_DECISION     _state;
   double            _pvtData[2];
   double            _signalPvtData[2];
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
volumesFilter::volumesFilter(string symbol) : _symbol(symbol)
  {
   _timeFrame=VOLUME_TIMEFRAME;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
volumesFilter::~volumesFilter()
  {
  }
//+------------------------------------------------------------------+

bool              volumesFilter::init()
  {
   _handler=iCustom(_symbol,VOLUME_TIMEFRAME,"XPVT");
   if(_handler==INVALID_HANDLE)
      return false;

   _barNumber=0;

   ZeroMemory(_pvtData);
   ZeroMemory(_signalPvtData);
   _state=UNDIFINED;

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool            volumesFilter::refreshData(void)
  {
   if(CopyBuffer(_handler,0,1,1,_pvtData)<1)
     {
      //      Print("False Copy");
      return false;
     }
   if(CopyBuffer(_handler,1,1,1,_signalPvtData)<1)
     {
      //      Print("False Copy");
      return false;
     }

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_DECISION       volumesFilter::refreshState()
  {
   if(_pvtData[0]>_signalPvtData[0])
      return BUY;
   if(_pvtData[0]<_signalPvtData[0])
      return SELL;

   return UNDIFINED;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void         volumesFilter::refreshSignal(void)
  {
   _state=refreshState();

   table.SetText(_debugIndex,EnumToString(_state));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool              volumesFilter::refresh()
  {
   int   barNumber=Bars(_symbol,_timeFrame);

   if(barNumber==_barNumber && EVERY_TICK==false)
      return true;

   _barNumber=barNumber;

   if(refreshData()==false)
      return false;

   refreshSignal();

//   Print("State = ",EnumToString(getState())," CUT Signal = ",cutSignal()," CutSignal = ",_reloadCutSignal);

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_DECISION    volumesFilter::getState()
  {
   return _state;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void              volumesFilter::deInit()
  {
   if(_handler!=INVALID_HANDLE)
      IndicatorRelease(_handler);
  }
//+------------------------------------------------------------------+
