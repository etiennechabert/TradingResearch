//+------------------------------------------------------------------+
//|                                               TrendDetection.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "ADX.mqh"
//#include "Stochastique.mqh"
#include "enum.mqh"

input ENUM_ADX ADX_TYPE;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class TrendDetection
  {
private:
   string            _symbol;
   int               _debugIndex;
   ADX               _adx;
 //  Stochastique      _stoch;
   ENUM_ACCEL        _decision;
   ENUM_DECISION     _stochDecision;

public:
                     TrendDetection(string symbol);
                    ~TrendDetection();

   void              setDebugIndex(int debugIndex) {_debugIndex=debugIndex;}

   bool              init(int debugIndex);
   void              deInit();
   bool              refresh();
   ENUM_ACCEL        getDecision() {return _decision;}
   ENUM_ACCEL        getADXDecision() {return _adx.getDecision();}
   ENUM_DIRECTION    getADXDirection() {return _adx.getDirection();}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TrendDetection::TrendDetection(string  symbol) : _symbol(symbol),_adx(symbol)//,_stoch(symbol)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TrendDetection::~TrendDetection()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   TrendDetection::init(int debugIndex)
  {
   if(_adx.init(TYPE_ADXWILDER)==false)
      return false;

   //if(_stoch.init()==false)
   //   return false;

   //_adx.setDebugIndex(table.AddFieldObject(10,60,debugIndex,4,Yellow));
   //_stoch.setDebugIndex(table.AddFieldObject(10,60,debugIndex,5,Yellow));

   _decision=ACCEL_UNDIFINED;

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   TrendDetection::deInit(void)
  {
   _adx.deInit();
   //_stoch.deInit();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   TrendDetection::refresh(void)
  {
   _adx.refresh();
  // _stoch.refresh();
   //_stochDecision=_stoch.getDecision();

   if(_decision==DOWN_TREND)
     {
      //if((_adx.getDecision()!=DOWN_TREND && _stoch.getDecision()==BUY) || _adx.getDecision() == DEAD || _adx.getDecision() == UP_TREND)
      if(_adx.getDirection()==BULLISH || _adx.getDecision()==DEAD)
         _decision=ACCEL_UNDIFINED;
     }
   else if(_decision==UP_TREND)
     {
      //if((_adx.getDecision()!=UP_TREND && _stoch.getDecision()==SELL) || _adx.getDecision()==DEAD || _adx.getDecision()==DOWN_TREND)
      if(_adx.getDirection()==BEARISH || _adx.getDecision()==DEAD)
         _decision=ACCEL_UNDIFINED;
     }

   if(_decision==ACCEL_UNDIFINED)
     {
      if(_adx.getDecision()==UP_TREND /*&& _stoch.getDecision()==BUY*/)
         _decision=UP_TREND;
      else if(_adx.getDecision()==DOWN_TREND /*&& _stoch.getDecision()==SELL*/)
         _decision=DOWN_TREND;
     }

  // table.SetText(_debugIndex,EnumToString(_decision));

   return true;
  }
//+------------------------------------------------------------------+
