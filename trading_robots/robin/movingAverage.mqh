//+------------------------------------------------------------------+
//|                                                movingAverage.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "enum.mqh"

extern   bool  EVERY_TICK;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_MOVING_AVERAGE_TYPE
  {
   simpleMA,
   smoothedMA,
   linearWeightedMA,
   fractalMA,
   exponentialMA,
   doubleExponentialMA,
   tripleExponentialMA
  };

input ENUM_MOVING_AVERAGE_TYPE   MA_TYPE=simpleMA;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class movingAverage
  {
private:
   int               _handler;
   string            _symbol;
   int               _period;
   ENUM_TIMEFRAMES   _timeFrame;
   double            _symbolPoint;
   double            _triggerMA;
   int               _barsNumber;
   double            _data[];
   ENUM_DECISION     _decision;

public:
                     movingAverage(string symbol,int period,ENUM_TIMEFRAMES timeFrame,double triggerMA);
                    ~movingAverage();

   bool              init();
   void              deInit();
   bool              refresh();
   ENUM_DECISION     getDecision() { return _decision; }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
movingAverage::movingAverage(string symbol,int period,ENUM_TIMEFRAMES timeFrame,double triggerMA) : _symbol(symbol),_period(period),_timeFrame(timeFrame),_triggerMA(triggerMA)
  {
   _handler=INVALID_HANDLE;
   _barsNumber=0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
movingAverage::~movingAverage()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   movingAverage::init(void)
  {
   switch(MA_TYPE)
     {
      case simpleMA:
         _handler=iMA(_symbol,_timeFrame,_period,0,MODE_SMA,PRICE_CLOSE);
         break;
      case smoothedMA:
         _handler=iMA(_symbol,_timeFrame,_period,0,MODE_SMMA,PRICE_CLOSE);
         break;
      case exponentialMA:
         _handler=iMA(_symbol,_timeFrame,_period,0,MODE_EMA,PRICE_CLOSE);
         break;
      case linearWeightedMA:
         _handler=iMA(_symbol,_timeFrame,_period,0,MODE_LWMA,PRICE_CLOSE);
         break;
      case fractalMA:
         _handler=iFrAMA(_symbol,_timeFrame,_period,0,PRICE_CLOSE);
         break;
      case doubleExponentialMA:
         _handler=iDEMA(_symbol,_timeFrame,_period,0,PRICE_CLOSE);
         break;
      case tripleExponentialMA:
         _handler=iTEMA(_symbol,_timeFrame,_period,0,PRICE_CLOSE);
         break;
      default:
         return false;
     }

   if(_handler==INVALID_HANDLE)
      return false;

   if(ArrayResize(_data,2,2)==false)
      return false;

   if(ArraySetAsSeries(_data,true)==false)
      return false;

   if(SymbolInfoDouble(_symbol,SYMBOL_POINT,_symbolPoint)==false)
      return false;

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   movingAverage::deInit(void)
  {
   if(_handler!=INVALID_HANDLE)
      IndicatorRelease(_handler);
   _handler=INVALID_HANDLE;

   if(ArraySize(_data)>0)
      ArrayFree(_data);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   movingAverage::refresh(void)
  {
   int   barsNumber=Bars(_symbol,_timeFrame);
   double   spreadMA;

   if(barsNumber==_barsNumber && EVERY_TICK==false)
      return true;
   _barsNumber=barsNumber;

   if(CopyBuffer(_handler,0,0,2,_data)<2)
      return false;

   spreadMA=(_data[0]-_data[1])/_symbolPoint;

   if(spreadMA > 0)
      _decision = BUY;
   else if(spreadMA<0)
                     _decision=SELL;
   else
      _decision=UNDIFINED;

   return true;
  }
//+------------------------------------------------------------------+
