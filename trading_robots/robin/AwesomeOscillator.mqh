//+------------------------------------------------------------------+
//|                                            AwesomeOscillator.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include    "enum.mqh"

input ENUM_TIMEFRAMES   AWESOME_TIMEFRAME;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class AwesomeOscillator
  {
private:
   int               _handler;
   string            _symbol;
   int               _barsNumber;
   int               _debugIndex;
   double            _data[];
   ENUM_DECISION     _decision;

public:
                     AwesomeOscillator(string symbol);
                    ~AwesomeOscillator();

   bool              init();
   void              deInit();
   bool              refresh();

   ENUM_DECISION     getDecision() { return _decision; }
   void              setDebugIndex(int debugIndex) { _debugIndex = debugIndex; }

private:
   void              refreshNegArea();
   void              refreshPosArea();

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
AwesomeOscillator::AwesomeOscillator(string symbol) : _symbol(symbol)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
AwesomeOscillator::~AwesomeOscillator()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   AwesomeOscillator::init(void)
  {
   _handler=iAO(_symbol,AWESOME_TIMEFRAME);
   if(_handler==INVALID_HANDLE)
      return false;

   if(ArrayResize(_data,2,2)==-1 || ArraySetAsSeries(_data,true)==false)
      return false;

   _barsNumber=0;

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   AwesomeOscillator::deInit(void)
  {
   if(_handler!=INVALID_HANDLE)
      IndicatorRelease(_handler);

   if(ArraySize(_data)>0)
      ArrayFree(_data);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   AwesomeOscillator::refresh(void)
  {
   int   barsNumber=Bars(_symbol,AWESOME_TIMEFRAME);

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
void   AwesomeOscillator::refreshNegArea(void)
  {
   if(_data[0]>_data[1])
      _decision=UNDIFINED;
   else
      _decision=SELL;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   AwesomeOscillator::refreshPosArea(void)
  {
   if(_data[0]<_data[1])
      _decision=UNDIFINED;
   else
      _decision=BUY;
  }

//+------------------------------------------------------------------+
