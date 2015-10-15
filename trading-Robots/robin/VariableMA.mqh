//+------------------------------------------------------------------+
//|                                                   VariableMA.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

input int               MAX_DEVIATION=300;
input ENUM_TIMEFRAMES   VARIABLE_MA_TIMEFRAME=PERIOD_H1;
//input int               VARIABLE_MA_CMO_PERIOD=9;
//input int               VARIABLE_MA_EMA_PERIOD=12;
input int               VARIABLE_MA_PERIOD=10;
input int               VARIABLE_MA_HIGH_TRIGGER=100;
input int               VARIABLE_MA_LOW_TRIGGER=50;
input bool              VARIABLE_MA_INVERTED_LOW_TRIGGER=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_VARIABLE_MA
  {
   ABOVE,
   UNDER
  };

#include "enum.mqh"
#include "Positions.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class VariableMA
  {
private:
   string            _symbol;
   int               _handler;
   int               _debugIndex;
   int               _barsNumbers;
   double            _data[];
   double            _accel;
   double            _point;
   double            _deviation;
   ENUM_DECISION     _decision;
   ENUM_VARIABLE_MA  _status;
   Positions        *_positions;

public:
                     VariableMA(string symbol,Positions &positions);
                    ~VariableMA();

   bool              init();
   void              deInit();
   bool              refresh();
   ENUM_DECISION     getDecision();
   ENUM_VARIABLE_MA  getStatus() { return _status;}
   void              setDebugIndex(int debugIndex) { _debugIndex=debugIndex; }
   bool              acceptableDeviation();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
VariableMA::VariableMA(string symbol,Positions &positions) : _symbol(symbol)
  {
   _handler=INVALID_HANDLE;
   _positions=GetPointer(positions);
   _barsNumbers=0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
VariableMA::~VariableMA()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   VariableMA::init()
  {
   if(VARIABLE_MA_LOW_TRIGGER>=VARIABLE_MA_HIGH_TRIGGER && VARIABLE_MA_INVERTED_LOW_TRIGGER==false)
      return false;

//_handler=iVIDyA(_symbol,VARIABLE_MA_TIMEFRAME,VARIABLE_MA_CMO_PERIOD,VARIABLE_MA_EMA_PERIOD,0,PRICE_CLOSE);
   _handler=iTEMA(_symbol,VARIABLE_MA_TIMEFRAME,VARIABLE_MA_PERIOD,0,PRICE_CLOSE);

   if(_handler==INVALID_HANDLE)
      return false;

   if(ArrayResize(_data,2,2)==false || ArraySetAsSeries(_data,true)==false)
      return false;

   _decision=UNDIFINED;

   _point=SymbolInfoDouble(_symbol,SYMBOL_POINT);

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   VariableMA::deInit(void)
  {
   if(_handler!=INVALID_HANDLE)
      IndicatorRelease(_handler);

   if(ArraySize(_data)>0)
      ArrayFree(_data);

   _handler=INVALID_HANDLE;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   VariableMA::refresh(void)
  {
   int      barsNumber=Bars(_symbol,VARIABLE_MA_TIMEFRAME);
   double   price=_positions.getPrice();

   if(_barsNumbers==barsNumber && EVERY_TICK==false)
      return true;

   _barsNumbers=barsNumber;
   
   acceptableDeviation();

   if(CopyBuffer(_handler,0,1,2,_data)<2)
      return false;

   if(_data[0]>price)
      _status=UNDER;
   else
      _status=ABOVE;

   _accel=((_data[0]-_data[1]))/_point;

   if(_accel>VARIABLE_MA_HIGH_TRIGGER)
      _decision=BUY;
   else if(_accel<-VARIABLE_MA_HIGH_TRIGGER)
      _decision=SELL;

   if(VARIABLE_MA_INVERTED_LOW_TRIGGER==true && ((_decision==BUY && _accel<-VARIABLE_MA_LOW_TRIGGER) || (_decision==SELL && _accel>VARIABLE_MA_LOW_TRIGGER)))
      _decision=UNDIFINED;
   else if(VARIABLE_MA_INVERTED_LOW_TRIGGER==false && ((_decision==BUY && _accel<VARIABLE_MA_LOW_TRIGGER) || (_decision==SELL && _accel>-VARIABLE_MA_LOW_TRIGGER)))
      _decision=UNDIFINED;

  // table.SetText(_debugIndex,EnumToString(_status)+" ("+DoubleToString(_deviation,1)+")");

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_DECISION     VariableMA::getDecision()
  {
   if(_decision==BUY)
     {
      if(_accel>VARIABLE_MA_LOW_TRIGGER)
         return BUY;
      else
         return UNDIFINED;
     }
   else if(_decision==SELL)
     {
      if(_accel<-VARIABLE_MA_LOW_TRIGGER)
         return SELL;
      else
         return UNDIFINED;
     }
   return UNDIFINED;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool         VariableMA::acceptableDeviation(void)
  {
   double      price;
   double      maValue[1];

   price=SymbolInfoDouble(_symbol,SYMBOL_BID);
   CopyBuffer(_handler,0,1,1,maValue);
   _deviation=MathAbs(price-maValue[0])/_point;

   if(_deviation>MAX_DEVIATION)
      return false;
   return true;
  }
//+------------------------------------------------------------------+
