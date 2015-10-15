//+------------------------------------------------------------------+
//|                                                       Trader.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "Money.mqh"
#include "Positions.mqh"
#include "convertTimeFrame.mqh"
#include "PSARTrailingStop.mqh"
#include "AcceleratorOscillator.mqh"
#include "AwesomeOscillator.mqh"
#include "TrendDetector.mqh"
#include "VariableMA.mqh"
#include "Decision.mqh"


input int   FIXED_SL=100;
input bool  TRAILING_STOP;
input bool  STOP_LOSS_SAR;
input bool  DYNAMIC_LOSS_SAR;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Trader
  {
private:
   string            _symbol;
   int               _debugIndex;
   Money             _money;
   Positions         _positions;
   PSARTrailingStop  _trailing;
   AcceleratorOscillator _accelOscillator;
   AwesomeOscillator _awesomeOscillator;
   VariableMA        _variableMA;
   TrendDetector     _trend;
   Decision          _decision;

public:
                     Trader(string symbol,int debugIndex);
                    ~Trader();

   bool              init();
   void              deInit();
   void              process();
   void              trailing();

private:
   void              updateStopLoss();
   void              tryClosePosition();
   int               getStopLoss();
   bool              endOfWeek(bool toOpen);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Trader::Trader(string symbol,int debugIndex) : _symbol(symbol),_debugIndex(debugIndex),_money(symbol),_positions(symbol),_trend(symbol),_accelOscillator(_symbol),_awesomeOscillator(_symbol),_variableMA(_symbol,_positions),_decision(_debugIndex,symbol,_positions,_trailing,_trend,_accelOscillator,_awesomeOscillator,_variableMA)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Trader::~Trader()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   Trader::init(void)
  {
//table.AddTitleObject(10,60,_debugIndex,1,_symbol,White);
//table.AddTitleObject(10,60,0,2,"PSAR",Yellow);
//table.AddTitleObject(10,60,0,3,"variableMA",Yellow);
//table.AddTitleObject(10,60,0,4,"AcceleratorOscillator",Yellow);
//table.AddTitleObject(10,60,0,5,"AwesomeOscillator",Yellow);
//table.AddTitleObject(10,60,0,6,"Trend",Yellow);
//table.AddTitleObject(10,60,0,7,"Result",Yellow);

   _decision.init();

   if(_trailing.init(_positions,_symbol)==false)
      return false;
   if(_accelOscillator.init()==false)
      return false;
   if(_awesomeOscillator.init()==false)
      return false;
   if(_variableMA.init()==false)
      return false;
   if(_trend.init()==false)
      return false;

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   Trader::deInit(void)
  {
   _trailing.deInit();
   _accelOscillator.deInit();
   _awesomeOscillator.deInit();
   _variableMA.deInit();
   _trend.deInit();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   Trader::process(void)
  {
   ENUM_DECISION position_type;

   _money.refresh();

   if(_decision.refresh()==false)
      return;

   tryClosePosition();

   position_type=_decision.openPosition();

   if(_positions.checkActiveOrder()==true)
     {
      if(TRAILING_STOP)
         updateStopLoss();
      //_trailing.updateStopLoss(_positions.getPrice());
      return;
     }

   _money.refresh();

   if(position_type==BUY)
     {
      //_positions.openLongPosition(0.01);
      _positions.openLongPosition(_money.getVolume(getStopLoss()));
      _positions.setStopLossByPoint(getStopLoss());
     }
   if(position_type==SELL)
     {
      //_positions.openShortPosition(0.01);
      _positions.openShortPosition(_money.getVolume(getStopLoss()));
      _positions.setStopLossByPoint(getStopLoss());
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   Trader::updateStopLoss(void)
  {
   double   pointsToStopLoss=_positions.getPointsToStopLoss();

   if(TRAILING_STOP==false || _positions.getProfit() < 0.0)
      return;

   if(STOP_LOSS_SAR==false)
     {
      if(pointsToStopLoss>FIXED_SL)
         _positions.setStopLossByPoint(FIXED_SL);
     }
   else
      _trailing.updateStopLoss(_positions.getPrice());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   Trader::tryClosePosition(void)
  {
   if(_positions.checkActiveOrder()==false)
      return;

   if(_decision.closePosition(_positions.getActiveOrderType())==true)
      _positions.closePosition(_decision.getCloseComment());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Trader::getStopLoss(void)
  {
   int   value;
   double   point;

   SymbolInfoDouble(_symbol,SYMBOL_POINT,point);

   if(DYNAMIC_LOSS_SAR==true)
     {
      value=(int)(MathAbs(_trailing.getPSARValue()-_positions.getPrice())/point);
      return value;
     }
   else
      return FIXED_SL;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   Trader::endOfWeek(bool toOpen)
  {
   MqlDateTime date;

   TimeGMT(date);

   if(toOpen==true)
     {
      if(date.day_of_week==5 && date.hour>=18 && date.min>1)
         return true;
      return false;
     }
   else if(_positions.checkActiveOrder()==true)
     {
      if(date.day_of_week==5 && date.hour==23 && date.min>=55)
         return true;

      if(date.day_of_week==5 && date.hour>=22)
        {
         if(_positions.getActiveOrderType()==ORDER_TYPE_BUY && _trend.getDecision()!=UP_TREND)
            return true;

         if(_positions.getActiveOrderType()==ORDER_TYPE_SELL && _trend.getDecision()!=DOWN_TREND)
            return true;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
