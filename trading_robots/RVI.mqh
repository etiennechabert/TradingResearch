//+------------------------------------------------------------------+
//|                                                     RVI.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include <TextDisplay.mqh>

input int               RVI_MODE=1;
input ENUM_TIMEFRAMES   RVI_TIMEFRAME=PERIOD_H1;
input int               RVI_PERIOD=10;
input int               RVI_EVERYTICK=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum RVI_STATE
  {
   UNDIFINED,
   BUY,
   SELL
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class RVI
  {
private:
   string            _symbol;
   long              _chartId;
   int               _handler;
   int               _bars;
   RVI_STATE         _state;
   TableDisplay     *_display;
   int               _displayIndex;

public:
                     RVI(string symbol,TableDisplay &display);
                    ~RVI();

   RVI_STATE         getState()                 {return _state;}
   void              setChartId(long chartId)   { _chartId = chartId; }

   bool              init();
   void              deInit();
   bool              refresh();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
RVI::RVI(string symbol,TableDisplay &display) : _symbol(symbol)
  {
   _display=GetPointer(display);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
RVI::~RVI()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   RVI::init(void)
  {
   _handler=iRVI(_symbol,RVI_TIMEFRAME,RVI_PERIOD);

   _displayIndex=_display.AddFieldObject(10,60,1,4,Yellow);

//ChartIndicatorAdd(_chartId,0,_handler);
//ChartRedraw(_chartId);

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   RVI::deInit(void)
  {
   IndicatorRelease(_handler);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   RVI::refresh(void)
  {
   double   mainData[1];
   double   signalData[1];
   int      tmpBars;

   tmpBars=Bars(_symbol,RVI_TIMEFRAME);
   if(_bars==tmpBars && RVI_EVERYTICK==0)
      return true;

   _bars=tmpBars;

   CopyBuffer(_handler,0,1-RVI_EVERYTICK,1,mainData);
   CopyBuffer(_handler,1,1-RVI_EVERYTICK,1,signalData);

   if(RVI_MODE==0)
     {
      if(mainData[0]>signalData[0])
         _state=BUY;
      else if(mainData[0]<signalData[0])
         _state=SELL;
      else
         _state=UNDIFINED;
     }

   if(RVI_MODE==1)
     {
      if(mainData[0]>0)
         _state=BUY;
      else if(mainData[0]<0)
         _state=SELL;
      else
         _state=UNDIFINED;
     }

   if(RVI_MODE==2)
     {
      if(mainData[0]>signalData[0] && mainData[0]>0)
         _state=BUY;
      else if(mainData[0]<signalData[0] && mainData[0]<0)
         _state=SELL;
      else
         _state=UNDIFINED;
     }

   _display.SetText(_displayIndex,EnumToString(_state));

   if(_state==BUY)
      _display.SetColor(_displayIndex,Green);
   else if(_state==SELL)
      _display.SetColor(_displayIndex,Red);
   else
      _display.SetColor(_displayIndex,Silver);

   return true;
  }
//+------------------------------------------------------------------+
