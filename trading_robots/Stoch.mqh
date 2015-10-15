//+------------------------------------------------------------------+
//|                                               Stoch.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include <TextDisplay.mqh>

input ENUM_TIMEFRAMES stoch_timeframe=PERIOD_H1;
input int             stoch_overarea=20;
input int             stoch_everytick=0;
input int             stoch_over_require=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_OVER_STOCH
  {
   NONE,
   OVERBUY,
   OVERSELL
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Stoch
  {
private:
   string            _symbol;
   int               _handler;
   int               _barsNumber;
   long              _chartId;
   ENUM_POSITION_TYPE _state;
   ENUM_OVER_STOCH   _overSituation;
   TableDisplay     *_display;
   int               _displayIndex;
   int               _displayIndexOver;

public:
                     Stoch(string symbol,TableDisplay &display);
                    ~Stoch();

   void                 setChartId(long chartId) { _chartId=chartId; }
   bool              init();
   void              deInit();

   bool              refresh();

   ENUM_POSITION_TYPE   getState() {return _state;}
   ENUM_OVER_STOCH      getOverSituation() {return _overSituation;}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Stoch::Stoch(string symbol,TableDisplay &display) : _symbol(symbol)
  {
   _handler=INVALID_HANDLE;
   _display= GetPointer(display);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Stoch::~Stoch()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   Stoch::init(void)
  {
   _barsNumber = 0;
   if(_handler!=INVALID_HANDLE)
      IndicatorRelease(_handler);

   _handler=iStochastic(_symbol,stoch_timeframe,5,3,3,MODE_SMA,STO_LOWHIGH);
   if(_handler==INVALID_HANDLE)
      return false;

   _displayIndex=_display.AddFieldObject(10,60,1,2,Yellow);
   _displayIndexOver=_display.AddFieldObject(10,60,1,3,Yellow);

//ChartIndicatorAdd(_chartId,0,_handler);
//ChartRedraw(_chartId);

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   Stoch::refresh(void)
  {
   double   bufferMain[1];
   double   bufferSignal[1];
   int      barsNumber;

   barsNumber=Bars(_symbol,stoch_timeframe);
   if(barsNumber==_barsNumber && stoch_everytick==0)
      return true;
   _barsNumber=barsNumber;

   if(CopyBuffer(_handler,0,1-stoch_everytick,1,bufferMain)<1 || CopyBuffer(_handler,1,1-stoch_everytick,1,bufferSignal)<1)
      return false;

   if(bufferMain[0]>bufferSignal[0])
      _state=POSITION_TYPE_BUY;
   else
      _state=POSITION_TYPE_SELL;

   if(bufferMain[0]>=100-stoch_overarea)
      _overSituation=OVERBUY;
   else if(bufferMain[0]<=stoch_overarea)
                          _overSituation=OVERSELL;
   else
      _overSituation=NONE;

   _display.SetText(_displayIndex,EnumToString(_state));
   _display.SetText(_displayIndexOver,EnumToString(_overSituation));

   if(_state==POSITION_TYPE_BUY)
      _display.SetColor(_displayIndex,Green);
   else
      _display.SetColor(_displayIndex,Red);

   if(_overSituation==OVERSELL)
      _display.SetColor(_displayIndexOver,Green);
   else if(_overSituation==NONE)
      _display.SetColor(_displayIndexOver,Silver);
   else
      _display.SetColor(_displayIndexOver,Red);

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   Stoch::deInit(void)
  {
   if(_handler!=INVALID_HANDLE)
      IndicatorRelease(_handler);
   _handler=INVALID_HANDLE;
  }
//+------------------------------------------------------------------+
