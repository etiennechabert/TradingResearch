//+------------------------------------------------------------------+
//|                                             PSARTrailingStop.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "Positions.mqh"
#include "enum.mqh"

input    ENUM_TIMEFRAMES   TRAILING_TIMEFRAME=PERIOD_H1;
extern   bool  EVERY_TICK;
//input ENUM_TIMEFRAMES TRAILING_TIMEFRAME=PERIOD_H1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class PSARTrailingStop
  {
private:
   double            getLastValue();
public:
                     PSARTrailingStop(){};
                    ~PSARTrailingStop(){};

   bool              init(Positions &position,string symbol);
   bool              refresh(double price);
   bool              updateStopLoss(double price);
   double            getPSARValue();
   ENUM_DECISION     getDecision() { return _decision; }
   int               getDebugIndex() { return _debugIndex; }
   void              setDebugIndex(int debugIndex) { _debugIndex=debugIndex; }
   void              deInit();

private:
   string            _symbol;
   int               _debugIndex;
   int               _barNumber;
   Positions        *_position;
   ENUM_TIMEFRAMES   _timeFrame;
   ENUM_DECISION     _decision;
   int               _handler;
   double            _data[1];
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool              PSARTrailingStop::init(Positions &position,string symbol)
  {
   _barNumber=0;
   _position=GetPointer(position);
   _symbol=symbol;
   _timeFrame=TRAILING_TIMEFRAME;
   _handler=iSAR(_symbol,_timeFrame,0.02,0.2);
   if(_handler==INVALID_HANDLE)
      return false;
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool            PSARTrailingStop::refresh(double price)
  {
   int   barNumber=Bars(_symbol,_timeFrame);

   if(barNumber==_barNumber && EVERY_TICK==false)
      return true;

   _barNumber=_barNumber;

   if(CopyBuffer(_handler,0,0,1,_data)==0)
      return false;

   if(_data[0]>price)
      _decision=SELL;
   else if(_data[0]<price)
      _decision=BUY;
   else
      _decision=UNDIFINED;

 //  table.SetText(_debugIndex,EnumToString(_decision));

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool         PSARTrailingStop::updateStopLoss(double price)
  {
   double       lastSL;
   long         spread;
   double       newSL;
   long         positionType;

   if(_position.getProfit()<0)
      return false;

   if(_position.checkActiveOrder()==false)
      return false;

   if(PositionSelect(_symbol)==false || PositionGetDouble(POSITION_SL,lastSL)==false || PositionGetInteger(POSITION_TYPE,positionType)==false)
      return false;

   SymbolInfoInteger(_symbol,SYMBOL_SPREAD,spread);

   if((ENUM_POSITION_TYPE)positionType==POSITION_TYPE_BUY && lastSL>=_data[0])
      return false;
   else if((ENUM_POSITION_TYPE)positionType==POSITION_TYPE_SELL && lastSL<=_data[0])
                                                                           return false;

   //if((ENUM_POSITION_TYPE)positionType==POSITION_TYPE_BUY)
   //   newSL=_data[0]-(spread * SymbolInfoDouble(_symbol,SYMBOL_POINT));
   //else if((ENUM_POSITION_TYPE)positionType==POSITION_TYPE_SELL)
   //   newSL=_data[0]+(spread * SymbolInfoDouble(_symbol,SYMBOL_POINT));
   
   newSL = _data[0];

   return _position.setStopLoss(newSL);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double       PSARTrailingStop::getPSARValue(void)
  {  
   CopyBuffer(_handler,0,0,1,_data);

   return _data[0];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void              PSARTrailingStop::deInit()
  {
   IndicatorRelease(_handler);
  }

//+------------------------------------------------------------------+
