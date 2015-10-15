//+------------------------------------------------------------------+
//|                                                     Decision.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "PSARTrailingStop.mqh"
#include "TrendDetector.mqh"
#include "Positions.mqh"
#include "AcceleratorOscillator.mqh"
#include "AwesomeOscillator.mqh"
#include "VariableMA.mqh"
//#include <TextDisplay.mqh>

//extern TableDisplay   table;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Decision
  {
private:
   string            _symbol;
   int               _debugIndex;
   int               _debugResult;
   int               _barsNumber;
   string            _closeComment;
   ENUM_TIMEFRAMES   _timeFrame;
   ENUM_DECISION     _decision;
   PSARTrailingStop *_trailing;
   AcceleratorOscillator *_accelOscillator;
   AwesomeOscillator *_awesomeOscillator;
   VariableMA       *_variableMA;
   Positions        *_positions;
   TrendDetector    *_trend;

public:
                     Decision(int debugIndex,string symbol,Positions &position,PSARTrailingStop &trailing,TrendDetector &trend,AcceleratorOscillator &accelOscillator,AwesomeOscillator &awesomeOscillator,VariableMA &variableMA);
                    ~Decision();

   bool              init();
   bool              refresh();
   ENUM_DECISION     openPosition();
   bool              closePosition(ENUM_ORDER_TYPE positionType);
   string            getCloseComment() { return _closeComment; }

private:
   bool              closePositionLong();
   bool              closePositionShort();
   bool              openPositionLong();
   bool              openPositionShort();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Decision::Decision(int debugIndex,string symbol,Positions &positions,PSARTrailingStop &trailing,TrendDetector &trend,AcceleratorOscillator &accelOscillator,AwesomeOscillator &awesomeOscillator,VariableMA &variableMA) : _debugIndex(debugIndex),_symbol(symbol)
  {
   _trailing=GetPointer(trailing);
   _positions=GetPointer(positions);
   _accelOscillator=GetPointer(accelOscillator);
   _awesomeOscillator=GetPointer(awesomeOscillator);
   _variableMA=GetPointer(variableMA);
   _trend=GetPointer(trend);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Decision::~Decision()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   Decision::init(void)
  {
   _timeFrame=ACCELERATOR_TIMEFRAME;
   if(_timeFrame>VARIABLE_MA_TIMEFRAME)
      _timeFrame=VARIABLE_MA_TIMEFRAME;
   if(_timeFrame>AWESOME_TIMEFRAME)
      _timeFrame=AWESOME_TIMEFRAME;
   if(_timeFrame>TRAILING_TIMEFRAME)
      _timeFrame=TRAILING_TIMEFRAME;
   if(_timeFrame>TREND_TIMEFRAME)
      _timeFrame=TREND_TIMEFRAME;

   _decision=UNDIFINED;
   _barsNumber=0;

//_trailing.setDebugIndex(table.AddFieldObject(10,60,_debugIndex,2,Yellow));
//_variableMA.setDebugIndex(table.AddFieldObject(10,60,_debugIndex,3,Yellow));
//_accelOscillator.setDebugIndex(table.AddFieldObject(10,60,_debugIndex,4,Yellow));
//_awesomeOscillator.setDebugIndex(table.AddFieldObject(10,60,_debugIndex,5,Yellow));
//_trend.setDebugIndex(table.AddFieldObject(10,60,_debugIndex,6,Yellow));
//_debugResult=table.AddFieldObject(10,60,_debugIndex,7,Yellow);

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   Decision::refresh()
  {
   _trailing.refresh(_positions.getPrice());

   if(_accelOscillator.refresh()==false)
      return false;
   if(_awesomeOscillator.refresh()==false)
      return false;
   if(_variableMA.refresh()==false)
      return false;
   if(_trend.refresh()==false)
      return false;

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_DECISION  Decision::openPosition()
  {
   int barsNumber=Bars(_symbol,_timeFrame);

   if(barsNumber==_barsNumber)
      return UNDIFINED;
   _barsNumber=barsNumber;

   if(openPositionLong()==true)
      _decision=BUY;
   else if(openPositionShort()==true)
      _decision=SELL;
   else
      _decision=UNDIFINED;

// table.SetText(_debugResult,EnumToString(_decision));

   return _decision;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   Decision::closePosition(ENUM_ORDER_TYPE positionType)
  {
   if(positionType==ORDER_TYPE_BUY)
      return closePositionLong();
   if(positionType==ORDER_TYPE_SELL)
      return closePositionShort();
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Decision::closePositionLong(void)
  {
   double   PSARValue=_trailing.getPSARValue();
   double   price=_positions.getPrice();
   int      decision=0;

   if(_trend.getDecision()==UP_TREND && _variableMA.getStatus()==ABOVE)
      return false;
   else if(_trend.getDecision()!=UP_TREND && _variableMA.getStatus()==UNDER)
     {
      _closeComment="close 1";
      return true;
     }

   if(_trailing.getDecision()!=BUY && _accelOscillator.getDecision()!=BUY && _awesomeOscillator.getDecision()!=BUY)
     {
      _closeComment="close 2";
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Decision::closePositionShort(void)
  {
   double   PSARValue=_trailing.getPSARValue();
   double   price=_positions.getPrice();
   int      decision=0;

   if(_trend.getDecision()==DOWN_TREND && _variableMA.getStatus()==UNDER)
      return false;
   else if(_trend.getDecision()!=DOWN_TREND && _variableMA.getStatus()==UNDER)
     {
      _closeComment="close 1";
      return true;
     }

   if(_trailing.getDecision()!=BUY && _accelOscillator.getDecision()!=BUY && _awesomeOscillator.getDecision()!=BUY)
     {
      _closeComment="close 2";
      return true;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Decision::openPositionLong(void)
  {
   double   PSARValue=_trailing.getPSARValue();
   double   price=_positions.getPrice();
   int      decision=0;

   if(_trend.getDecision()!=UP_TREND || _variableMA.getStatus()!=ABOVE)
      return false;

   if(_trailing.getDecision()==BUY && _accelOscillator.getDecision()==BUY && _awesomeOscillator.getDecision()==BUY)
      return true && closePositionLong()==false && _variableMA.acceptableDeviation()==true;

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Decision::openPositionShort(void)
  {
   double   PSARValue=_trailing.getPSARValue();
   double   price=_positions.getPrice();
   int      decision=0;

   if(_trend.getDecision()!=DOWN_TREND || _variableMA.getStatus()!=UNDER)
      return false;

   if(_trailing.getDecision()==SELL && _accelOscillator.getDecision()==SELL && _awesomeOscillator.getDecision()==SELL)
      return true && closePositionShort()==false && _variableMA.acceptableDeviation()==true;

   return false;
  }
//+------------------------------------------------------------------+
