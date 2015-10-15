//+------------------------------------------------------------------+
//|                                        AcceleratorOscillator.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "enum.mqh"

input ENUM_TIMEFRAMES   ACCELERATOR_TIMEFRAME=PERIOD_H1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class AcceleratorOscillator
  {
private:
   int               _handler;
   string            _symbol;
   int               _debugIndex;
   ENUM_DECISION     _decision;
   int               _barsNumber;
   double            _data[];
   int               _revertCount;

public:
                     AcceleratorOscillator(string symbol);
                    ~AcceleratorOscillator();

   bool              init();
   void              deInit();
   bool              refresh();
   void              refreshNegArea();
   void              refreshPosArea();
   ENUM_DECISION     getDecision() { return _decision; }
   void              setDebugIndex(int debugIndex) { _debugIndex=debugIndex; }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
AcceleratorOscillator::AcceleratorOscillator(string symbol) : _symbol(symbol)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
AcceleratorOscillator::~AcceleratorOscillator()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   AcceleratorOscillator::init(void)
  {
   _handler=iAC(_symbol,ACCELERATOR_TIMEFRAME);
   if(_handler==INVALID_HANDLE)
      return false;

   if(ArrayResize(_data,2,2)==-1 || ArraySetAsSeries(_data,true)==false)
      return false;

   _revertCount=0;
   _barsNumber=0;

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   AcceleratorOscillator::deInit(void)
  {
   if(_handler!=INVALID_HANDLE)
      IndicatorRelease(_handler);

   if(ArraySize(_data)>0)
      ArrayFree(_data);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   AcceleratorOscillator::refresh(void)
  {
   int   barsNumber=Bars(_symbol,ACCELERATOR_TIMEFRAME);

   if(barsNumber==_barsNumber && EVERY_TICK==false)
      return true;
   _barsNumber=barsNumber;

   if(CopyBuffer(_handler,0,1,2,_data)<2)
      return false;

   if(_data[0]>0.0)
      refreshPosArea();
   else if(_data[0]<0.0)
      refreshNegArea();

  //table.SetText(_debugIndex,EnumToString(_decision));

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   AcceleratorOscillator::refreshNegArea(void)
  {
   if(_data[0]>_data[1])
     {
      _revertCount+=1;
      if(_revertCount>=3)
         _decision=BUY;
      else
         _decision=UNDIFINED;
     }
   else
     {
      _decision=SELL;
      _revertCount=0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   AcceleratorOscillator::refreshPosArea(void)
  {
   if(_data[0]<_data[1])
     {
      _revertCount+=1;
      if(_revertCount>=3)
         _decision=SELL;
      else
         _decision=UNDIFINED;
     }
   else
     {
      _decision=BUY;
      _revertCount=0;
     }
  }
//+------------------------------------------------------------------+
