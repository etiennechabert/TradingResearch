//+------------------------------------------------------------------+
//|                                                     Decision.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

input ENUM_TIMEFRAMES   trailing_timeframe=PERIOD_M30;
input double   lossPourcent=2.5;
input int      dynamic_TP=0;
input int      trigger_pourcent_pivot=5;
input int      trigger_pourcent_target=5;
input int      trigger_points_pivot=100;
input int      trigger_points_target=100;
input int      sl_pourcent_pivot=10;
input int      sl_pourcent_target=10;

#include <TextDisplay.mqh>
#include "News.mqh"
#include "Positions.mqh"
#include "PendingOrders.mqh"
#include "Fibo.mqh"
#include "Money.mqh"
#include "Indicators.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Decision
  {
private:
   string            _symbol;
   int               _bars;
   int               _debugId;
   ENUM_POSITION_TYPE _newsTrend;
   double            _longTrigger;
   double            _shortTrigger;
   double            _openLong;
   double            _openShort;
   double            _longSl;
   double            _shortSl;
   double            _longTp;
   double            _shortTp;
   double            _volumeLong;
   double            _volumeShort;
   double            _lastPendingPrice;

   Positions        *_positions;
   TableDisplay     *_display;
   News             *_news;
   Money            *_money;
   Fibo             *_fibo;
   RVI              *_rvi;
   Stoch            *_stoch;
   Indicators        _indicators;

public:
                     Decision(string symbol,News &news,Positions &positions,Money &money,Fibo &fibo,RVI &rvi,Stoch &stoch,TableDisplay &display);
                    ~Decision();

   bool              init(long chartId);

   bool              refresh();
   bool              newsOrders();
   bool              openOrders();
   double            getLongTrigger() { return _longTrigger; }
   double            getShortTrigger() { return _shortTrigger; }
   void              newNews();

private:
   void              drawGraphic();
   bool              calcTriggers();
   void              setPending(Trade *trade,double price);
   void              calcVolumeLong(double allowedLoses,double volumeStep);
   void              calcVolumeShort(double allowedLoses,double volumeStep);
   void              calcLevelsNearPivot(Trade *trade);
   void              calcLevelsNearTarget(Trade *trade);
   double            getNextSL(double open);
   double            getNextTP(double open);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Decision::Decision(string symbol,News &news,Positions &positions,Money &money,Fibo &fibo,RVI &rvi,Stoch &stoch,TableDisplay &display) : _symbol(symbol)
  {
   _bars=0;
   _display=GetPointer(display);
   _news=GetPointer(news);
   _positions=GetPointer(positions);
   _money=GetPointer(money);
   _fibo=GetPointer(fibo);
   _rvi=GetPointer(rvi);
   _stoch=GetPointer(stoch);
   _indicators.setIndicators(_stoch,_rvi);
   _lastPendingPrice=0;
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
bool   Decision::init(long chartId)
  {
   _fibo.setChartId(chartId);
   _display.SetParams(chartId,0);

   drawGraphic();

   if(_stoch.init()==false)
      return false;
   if(_rvi.init()==false)
      return false;

   _debugId=_display.AddFieldObject(10,60,1,5,Yellow);

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   Decision::refresh(void)
  {
   bool  gotNews=_news.isAvailableNews();

   if(gotNews==true)
     {
      _newsTrend=_news.getTrade().trend;
      _display.SetText(_debugId,EnumToString(_news.getTrade().trend));
     }
   else
      return false;

   if(_rvi.refresh()==false)
      return false;

   if(_stoch.refresh()==false)
      return false;

   if(_positions.isPendingOrderExist()==false)
      _lastPendingPrice=0;

   if(_positions.checkActiveOrder()==false)
      return newsOrders();

   return openOrders();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   Decision::newsOrders()
  {
   double   price=_news.getPrice();

   if(_news.isAvailableNews()==false)
      return true;

   if(calcTriggers()==true
      || 
      (
      _lastPendingPrice>0
      && 
      (
      ((price<_longTrigger && _lastPendingPrice>price) || (_lastPendingPrice<=_longTrigger && _indicators.sellDecision()==true))
      || 
      ((price>_shortTrigger && _lastPendingPrice<price) || (_lastPendingPrice>=_shortTrigger && _indicators.buyDecision()==true))
      )
      )
      )
     {
      _positions.cleanExpiredOrders(true);
      _lastPendingPrice=0.0;
     }
   else if(_lastPendingPrice>0)
      return true;

   if(_news.getTrade().trend==POSITION_TYPE_BUY)
     {
      if(price<_longTrigger && _indicators.buyDecision()==true)
        {
         _lastPendingPrice=price;
         _longSl=price-((MathAbs(_news.getTrade().pivot-_news.getTrade().t1))*(sl_pourcent_pivot/100.0));
         _openLong=price+(trigger_points_pivot*_positions.getPoint());
         calcVolumeLong(_money.getBalance()*lossPourcent/100,0.01);
         _positions.addPendingOrder(ORDER_TYPE_BUY,_volumeLong,_openLong,_longSl,_news.getTrade().t1);
         return true;
        }
      else if(price>_shortTrigger && _indicators.sellDecision()==true)
        {
         _lastPendingPrice=price;
         _shortSl=price+((MathAbs(_news.getTrade().pivot-_news.getTrade().t1))*(sl_pourcent_target/100.0));
         _openShort=price-(trigger_points_target*_positions.getPoint());
         calcVolumeShort(_money.getBalance()*lossPourcent/100,0.01);
         _positions.addPendingOrder(ORDER_TYPE_SELL,_volumeLong,_openShort,_shortSl,_news.getTrade().pivot);
         return true;
        }
     }
   else if(_news.getTrade().trend==POSITION_TYPE_SELL)
     {
      if(price>_shortTrigger && _indicators.sellDecision()==true)
        {
         _lastPendingPrice=price;
         _shortSl=price+((MathAbs(_news.getTrade().pivot-_news.getTrade().t1))*(sl_pourcent_pivot/100.0));
         _openShort=price-(trigger_points_pivot*_positions.getPoint());
         calcVolumeShort(_money.getBalance()*lossPourcent/100,0.01);
         _positions.addPendingOrder(ORDER_TYPE_SELL,_volumeLong,_openShort,_shortSl,_news.getTrade().t1);
         return true;
        }
      else if(price<_longTrigger && _indicators.buyDecision()==true)
        {
         _lastPendingPrice=price;
         _longSl=price-((MathAbs(_news.getTrade().pivot-_news.getTrade().t1))*(sl_pourcent_target/100.0));
         _openLong=price+(trigger_points_target*_positions.getPoint());
         calcVolumeLong(_money.getBalance()*lossPourcent/100,0.01);
         _positions.addPendingOrder(ORDER_TYPE_BUY,_volumeLong,_openLong,_longSl,_news.getTrade().pivot);
         return true;
        }
     }

   _lastPendingPrice=0.0;

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   Decision::openOrders()
  {
   double               new_sl;
   double               new_tp;
   double               open[1];
   double               high[1];
   double               low[1];
   double               lastSl;
   double               lastTp;
   int                  bars;
   ENUM_POSITION_TYPE   positionType=_positions.getActiveOrderType();

   if(positionType==POSITION_TYPE_BUY && _indicators.closeBuyDecision()==true)
      return _positions.closePosition();
   else if(positionType==POSITION_TYPE_SELL && _indicators.closeSellDecision()==true)
      return _positions.closePosition();

   bars=Bars(_symbol,trailing_timeframe);
   if(_bars==bars)
      return true;
   _bars=bars;

   lastSl=_positions.getStopLoss();
   lastTp=_positions.getTakeProfit();

   CopyClose(_symbol,trailing_timeframe,1,1,open);
   CopyHigh(_symbol,trailing_timeframe,0,1,high);
   CopyLow(_symbol,trailing_timeframe,0,1,low);
   if(positionType==POSITION_TYPE_BUY)
      open[0]=MathMin(low[0],open[0]);
   else
      open[0]=MathMax(high[0],open[0]);

   new_sl = getNextSL(open[0]);
   new_tp = getNextTP(open[0]);

   if(new_sl<=0.0)
      return true;

   if(positionType==POSITION_TYPE_BUY && (new_sl>lastSl || lastSl==0.0))
      _positions.setStopLoss(new_sl);
   else if(positionType==POSITION_TYPE_SELL && (new_sl<lastSl || lastSl==0.0))
      _positions.setStopLoss(new_sl);

   if(positionType==POSITION_TYPE_BUY && new_tp>lastTp && dynamic_TP==1)
      _positions.setTakeProfit(new_tp);
   else if(positionType==POSITION_TYPE_SELL && new_tp<lastTp && dynamic_TP==1)
      _positions.setTakeProfit(new_tp);

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   Decision::calcTriggers(void)
  {
   Trade *trade=_news.getTrade();
   double   tmpLong;
   double   tmpShort;

   if(trade.trend==POSITION_TYPE_BUY)
     {
      tmpLong=_longTrigger;
      tmpShort=_shortTrigger;
      _longTrigger=trade.pivot+MathAbs(trade.pivot-trade.t1) *(trigger_pourcent_pivot/100.0);
      _shortTrigger=trade.t1-MathAbs(trade.pivot-trade.t1) *(trigger_pourcent_target/100.0);
     }
   else
     {
      tmpLong=_longTrigger;
      tmpShort=_shortTrigger;
      _longTrigger=trade.t1+MathAbs(trade.pivot-trade.t1) *(trigger_pourcent_target/100.0);
      _shortTrigger=trade.pivot-MathAbs(trade.pivot-trade.t1) *(trigger_pourcent_pivot/100.0);
     }

   if(tmpLong!=_longTrigger || tmpShort!=_shortTrigger)
      return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  Decision::calcVolumeLong(double allowedLoses,double volumeStep)
  {
   double   initialLoses;

   if(_longSl<=0.0)
      return;

   if(OrderCalcProfit(ORDER_TYPE_BUY,_symbol,volumeStep,_openLong,_longSl,initialLoses)==false)
      _volumeLong=0.0;
   _volumeLong=MathAbs(MathFloor((allowedLoses/initialLoses*volumeStep)*100)/100);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  Decision::calcVolumeShort(double allowedLoses,double volumeStep)
  {
   double   initialLoses;

   if(_shortSl<=0.0)
      return;

   if(OrderCalcProfit(ORDER_TYPE_SELL,_symbol,volumeStep,_openShort,_shortSl,initialLoses)==false)
      _volumeShort=0.0;
   _volumeShort=MathAbs(MathFloor((allowedLoses/initialLoses*volumeStep)*100)/100);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   Decision::setPending(Trade *trade,double price)
  {
   if(_positions.isPendingOrderExist()==true)
      return;

   if(trade.trend==POSITION_TYPE_BUY)
     {
      if(price<=_longTrigger && price>trade.pivot)
        {
         //calcLevelsNearPivot(trade);
         _positions.addPendingOrder(ORDER_TYPE_BUY,_volumeLong,_openLong,_longSl,_longTp);
        }
      else if(price>=_shortTrigger && price<trade.t1)
        {
         //calcLevelsNearTarget(trade);
         _positions.addPendingOrder(ORDER_TYPE_SELL,_volumeShort,_openShort,_shortSl,_shortTp);
        }
     }
   else
     {
      if(price<=_longTrigger && price>trade.t1)
        {
         //calcLevelsNearTarget(trade);
         _positions.addPendingOrder(ORDER_TYPE_BUY,_volumeLong,_openLong,_longSl,_longTp);
        }
      else if(price>=_shortTrigger && price<trade.pivot)
        {
         //calcLevelsNearPivot(trade);
         _positions.addPendingOrder(ORDER_TYPE_SELL,_volumeShort,_openShort,_shortSl,_shortTp);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   Decision::newNews(void)
  {
//   _positions.cleanExpiredOrders(true);

   if(_positions.getActiveOrderType()!=_news.getTrade().trend && _newsTrend!=_news.getTrade().trend)
     {
      _positions.cleanExpiredOrders(true);
      _positions.closePosition("counter news");

      return;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   Decision::drawGraphic(void)
  {
   _display.AddTitleObject(10,60,0,2," Stoch",Yellow);
   _display.AddTitleObject(10,60,0,3," StochOver", Yellow);
   _display.AddTitleObject(10,60,0,4," RVI",Yellow);
   _display.AddTitleObject(10,60,0,5," Crowler",Yellow);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Decision::getNextSL(double open)
  {
   return _fibo.getNextSLLevel(open,_positions.getActiveOrderType());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Decision::getNextTP(double open)
  {
   return _fibo.getNextTPLevel(open,_positions.getActiveOrderType());
  }
//+------------------------------------------------------------------+
