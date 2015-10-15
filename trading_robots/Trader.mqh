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
#include "News.mqh"
#include "Graphic.mqh"
#include "Fibo.mqh"
#include "Stoch.mqh"
#include "Decision.mqh"
#include "RVI.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Trader
  {
private:
   int               _barsNumber;
   string            _symbol;
   int               _magic;
   long              _chartId;
   TableDisplay      _display;
   Money             _money;
   Positions         _positions;
   News              _news;
   Graphic           _graphic;
   Fibo              _fibo;
   RVI               _rvi;
   Stoch             _stoch;
   Decision          _decision;

public:

public:
                     Trader(string symbol);
                    ~Trader();

   void              drawGraphic();

   bool              refresh();
   void              setMagic(int magic) { _magic=magic; _graphic.setMagic(_magic);}
   void              newNews(const string &rawNews) { _news.setRawData(rawNews); _news.refresh(); }
   string            getSymbol() { return _symbol; }

private:
   void              getChart();
   void              setChartPreference();
   void              printNewAsComment();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Trader::Trader(string symbol) : _money(symbol),
                                _positions(symbol),
                                _news(symbol),
                                _graphic(_symbol,_news.getTrade()),
                                _fibo(symbol),
                                _rvi(symbol,_display),
                                _stoch(symbol,_display),
                                _decision(symbol,_news,_positions,_money,_fibo,_rvi,_stoch,_display)
  {
   _barsNumber=0;
   _symbol=symbol;

   getChart();

   _graphic.setChartId(_chartId);
   _decision.init(_chartId);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Trader::~Trader()
  {
   _rvi.deInit();
   _stoch.deInit();
   _display.Clear();
   ChartClose(_chartId);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   Trader::refresh()
  {
   bool  activeOrder=_positions.checkActiveOrder();

   _money.refresh();
   _rvi.refresh();

   if(_news.isNewNews()==true)
     {
      _graphic.draw();
      printNewAsComment();
      _decision.newNews();
      _fibo.clean();
      ChartRedraw(_chartId);
     }

   if(activeOrder==true && _fibo.isDraw()==false)
      _fibo.updateLevels(_news.getTrade(),_positions.getActiveOrderType());
   else if(activeOrder==false && _fibo.isDraw()==true)
      _fibo.clean();

   _decision.refresh();

   ChartRedraw(_chartId);

   _graphic.setLongTrigger(_decision.getLongTrigger());
   _graphic.setShortTrigger(_decision.getShortTrigger());

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void        Trader::setChartPreference(void)
  {
   ChartSetInteger(_chartId,CHART_MODE,CHART_CANDLES);
   ChartSetInteger(_chartId,CHART_SHOW_VOLUMES,CHART_VOLUME_REAL);
   ChartSetInteger(_chartId,CHART_SHOW_GRID,0);
   ChartSetInteger(_chartId,CHART_COLOR_CANDLE_BEAR,Red);
   ChartSetInteger(_chartId,CHART_COLOR_CANDLE_BULL,Lime);
   ChartSetInteger(_chartId,CHART_COLOR_CHART_DOWN,Orange);
   ChartSetInteger(_chartId,CHART_COLOR_CHART_UP,LightGreen);
   printNewAsComment();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void        Trader::getChart(void)
  {
   long      chartId=ChartFirst();
   string   tmpSymbol;

   while(chartId!=-1)
     {
      if(StringCompare(ChartSymbol(chartId),_symbol,false)==0)
        {
         _chartId=chartId;
         if(ChartPeriod(_chartId)!=news_period)
            ChartSetSymbolPeriod(_chartId,_symbol,news_period);
         setChartPreference();
         return;
        }
      chartId=ChartNext(chartId);
     }
   _chartId=ChartOpen(_symbol,news_period);
   setChartPreference();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void      Trader::printNewAsComment(void)
  {
   ChartSetString(_chartId,CHART_COMMENT,_news.getRaw());
   ChartRedraw(_chartId);
  }
//+------------------------------------------------------------------+
