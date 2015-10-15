//+------------------------------------------------------------------+
//|                                                     ADX.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include <TextDisplay.mqh>
#include "enum.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_ADX
  {
   TYPE_ADX,
   TYPE_ADXWILDER
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_DIRECTION
  {
   BULLISH,
   BEARISH
  };

input ENUM_TIMEFRAMES   ADX_TIMEFRAME=PERIOD_H1;
input int               ADX_PERIOD=14;
input double            ADX_TRIGGER=10;
input double            ADX_DECCEL=0.5;
input int               ADX_TREND=20;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ADX
  {
private:
   int               _handler;
   string            _symbol;
   double            _symbolPoint;
   int               _debugIndex;
   double            _dataAdx[];
   double            _dataDiPos[];
   double            _dataDiNeg[];
   int               _barsNumber;
   ENUM_ACCEL        _decision;
   ENUM_DIRECTION    _direction;

public:
                     ADX(string symbol);
                    ~ADX();

   bool              init(ENUM_ADX adx_type);
   void              deInit();
   bool              refresh();
   ENUM_ACCEL        getDecision() { return _decision; }
   ENUM_DIRECTION    getDirection() { return _direction; }

   int               getDebugIndex() { return _debugIndex; }
   void              setDebugIndex(int debugIndex) { _debugIndex=debugIndex; }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ADX::ADX(string symbol) : _symbol(symbol)
  {
   _handler=INVALID_HANDLE;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ADX::~ADX()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ADX::init(ENUM_ADX adx_type)
  {
   if(adx_type==TYPE_ADX)
      _handler=iADX(_symbol,ADX_TIMEFRAME,ADX_PERIOD);
   else if(adx_type==TYPE_ADXWILDER)
      _handler=iADXWilder(_symbol,ADX_TIMEFRAME,ADX_PERIOD);
   if(_handler==INVALID_HANDLE)
      return false;

   if(SymbolInfoDouble(_symbol,SYMBOL_POINT,_symbolPoint)==false)
      return false;

   _barsNumber=0;

   if(ArrayResize(_dataAdx,2,2)==false)
      return false;

   if(ArraySetAsSeries(_dataAdx,true)==false)
      return false;

   if(ArrayResize(_dataDiPos,2,2)==false)
      return false;

   if(ArraySetAsSeries(_dataDiPos,true)==false)
      return false;

   if(ArrayResize(_dataDiNeg,2,2)==false)
      return false;

   if(ArraySetAsSeries(_dataDiNeg,true)==false)
      return false;

   _decision=ACCEL_UNDIFINED;

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   ADX::deInit(void)
  {
   if(_handler!=INVALID_HANDLE)
      IndicatorRelease(_handler);
   _handler=INVALID_HANDLE;

   if(ArraySize(_dataAdx)>0)
      ArrayFree(_dataAdx);

   if(ArraySize(_dataDiPos)>0)
      ArrayFree(_dataDiPos);

   if(ArraySize(_dataDiNeg)>0)
      ArrayFree(_dataDiNeg);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  ADX::refresh()
  {
   int      barsNumber=Bars(_symbol,ADX_TIMEFRAME);
   double   ADXAccel;
   double   ADXSpread;

   if(barsNumber==_barsNumber && EVERY_TICK==false)
      return true;

   _barsNumber=barsNumber;

   if(CopyBuffer(_handler,0,1,2,_dataAdx)<2)
      return false;

   if(CopyBuffer(_handler,1,1,2,_dataDiPos)<2)
      return false;

   if(CopyBuffer(_handler,2,1,2,_dataDiNeg)<2)
      return false;

   if(_dataDiPos[0]>_dataDiNeg[0])
     {
      if(_direction== BEARISH)
         _decision = ACCEL_UNDIFINED;
      _direction=BULLISH;
     }
   else if(_dataDiNeg[0]>_dataDiPos[0])
     {
      if(_direction==BULLISH)
         _decision=ACCEL_UNDIFINED;
      _direction=BEARISH;
     }

   ADXAccel=_dataAdx[0]-_dataAdx[1];

   if(_dataAdx[0]<ADX_TREND) // Si tendence faible
     {
      _decision=DEAD;
   //   table.SetText(_debugIndex,EnumToString(_decision)+"("+DoubleToString(ADXAccel,1)+")");
      return true;
     }

   if(ADXAccel<-ADX_DECCEL || (_decision==DECCEL && ADXAccel<0)) // Si regression de ADX suffisament importante
     {
      _decision=DECCEL;
   //   table.SetText(_debugIndex,EnumToString(_decision)+"("+DoubleToString(ADXAccel,1)+")");
      return true;
     }
   else if(ADXAccel<0)
     {
      _decision=ACCEL_UNDIFINED;
   //   table.SetText(_debugIndex,EnumToString(_decision)+"("+DoubleToString(ADXAccel,1)+")");
      return true;
     }

   if(ADXAccel<ADX_TRIGGER && _decision!=UP_TREND && _decision!=DOWN_TREND)
     {
      _decision=ACCEL_UNDIFINED;
   //   table.SetText(_debugIndex,EnumToString(_decision)+"("+DoubleToString(ADXAccel,1)+")");
      return true;
     }

   ADXSpread=(_dataDiPos[0]-_dataDiNeg[0]);

   if(_decision==ACCEL_UNDIFINED || _decision==DEAD || _decision==DECCEL)
     {
      if(ADXSpread>0)
         _decision=UP_TREND;
      else if(ADXSpread<0)
         _decision=DOWN_TREND;
      else
         _decision=ACCEL_UNDIFINED;
     }

  // table.SetText(_debugIndex,EnumToString(_decision)+"("+DoubleToString(ADXAccel,1)+")");

   return true;
  }
//+------------------------------------------------------------------+
