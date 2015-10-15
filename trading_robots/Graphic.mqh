//+------------------------------------------------------------------+
//|                                                      Graphic.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "News.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Graphic
  {
private:
   string            _symbol;
   int               _magic;
   const Trade      *_trade;
   double            _longTrigger;
   double            _shortTrigger;
   long              _chartId;
   int               _cpTrend;

public:
                     Graphic(string symbol,const Trade &trade);
                    ~Graphic();

   void              draw();

   void              setMagic(int magic) {_magic=magic;}
   void              setChartId(long chartId) { _chartId=chartId; }
   void              setLongTrigger(double longTrigger);
   void              setShortTrigger(double shortTrigger);

private:
   void              drawPivots();
   void              drawNews();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Graphic::Graphic(string symbol,const Trade &trade)
  {
   _trade=GetPointer(trade);
   _longTrigger=0;
   _shortTrigger=0;
   _cpTrend=0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Graphic::~Graphic()
  {
   ObjectsDeleteAll(_chartId);
   ChartClose(_chartId);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   Graphic::draw(void)
  {
   drawPivots();
   drawNews();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void     Graphic::drawPivots(void)
  {
   ObjectDelete(_chartId,"Pivot");
   ObjectDelete(_chartId,"R1");
   ObjectDelete(_chartId,"T1");

   ObjectCreate(_chartId,"Pivot",OBJ_HLINE,0, 0,_trade.pivot);
   ObjectCreate(_chartId, "R1", OBJ_HLINE, 0, 0,_trade.r1);
   ObjectCreate(_chartId, "T1", OBJ_HLINE, 0, 0,_trade.t1);

   ObjectSetInteger(_chartId,"Pivot",OBJPROP_COLOR,Yellow);
   ObjectSetInteger(_chartId,"Pivot",OBJPROP_WIDTH,3);
   ObjectSetInteger(_chartId,"R1",OBJPROP_COLOR,Red);
   ObjectSetInteger(_chartId,"R1",OBJPROP_WIDTH,3);
   ObjectSetInteger(_chartId,"T1",OBJPROP_COLOR,Green);
   ObjectSetInteger(_chartId,"T1",OBJPROP_WIDTH,3);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void      Graphic::drawNews(void)
  {
   if(_trade.trend==POSITION_TYPE_BUY)
     {
      ObjectCreate(_chartId,"Long "+IntegerToString(++_cpTrend),OBJ_ARROW_THUMB_UP,0,TimeCurrent(),_trade.price);
      ObjectSetInteger(_chartId,"Long "+IntegerToString(_cpTrend),OBJPROP_COLOR,Green);
      ObjectSetInteger(_chartId,"Long "+IntegerToString(_cpTrend),OBJPROP_WIDTH,3);
     }
   else
     {
      ObjectCreate(_chartId,"Short "+IntegerToString(++_cpTrend),OBJ_ARROW_THUMB_DOWN,0,TimeCurrent(),_trade.price);
      ObjectSetInteger(_chartId,"Short "+IntegerToString(_cpTrend),OBJPROP_COLOR,Red);
      ObjectSetInteger(_chartId,"Long "+IntegerToString(_cpTrend),OBJPROP_WIDTH,3);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   Graphic::setLongTrigger(double longTrigger)
  {
   if(_longTrigger!=longTrigger)
     {
      ObjectDelete(_chartId,"longTrigger");
      _longTrigger=longTrigger;
      ObjectCreate(_chartId,"longTrigger",OBJ_HLINE,0,0,_longTrigger);
      ObjectSetInteger(_chartId,"longTrigger",OBJPROP_COLOR,Green);
      ObjectSetInteger(_chartId,"longTrigger",OBJPROP_STYLE,STYLE_DOT);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   Graphic::setShortTrigger(double shortTrigger)
  {
   if(_shortTrigger!=shortTrigger)
     {
      ObjectDelete(_chartId,"shortTrigger");
      _shortTrigger=shortTrigger;
      ObjectCreate(_chartId,"shortTrigger",OBJ_HLINE,0,0,_shortTrigger);
      ObjectSetInteger(_chartId,"shortTrigger",OBJPROP_COLOR,Red);
      ObjectSetInteger(_chartId,"shortTrigger",OBJPROP_STYLE,STYLE_DOT);
     }
  }
//+------------------------------------------------------------------+
