//+------------------------------------------------------------------+
//|                                                         News.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "InternetLib.mqh"
#include "Parsing.mqh"

input string            host="sd-24298.dedibox.fr";
input ENUM_TIMEFRAMES   news_period=PERIOD_M30;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Trade
  {
public:
   string            symbol;
   ENUM_POSITION_TYPE trend;
   int               time;
   double            volume;
   double            pivot;
   double            price;
   double            t1;
   double            t2;
   double            r1;
   double            ratio;
   double            totalPoint;
   double            entryPoint;
   double            sl;
   double            tp;

   int               getPointToSL()
     {
      long            point;
      double         val;

      point=SymbolInfoInteger(symbol,SYMBOL_DIGITS);
      val=MathAbs(pivot-price)*MathPow(10,point);
      return(int)val;
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class News
  {
private:
   string            _symbol;
   bool              _availableNews;
   string            _rawData;
   opportunityText   _parser;
   Trade             _trade;
   int               _barsNumber;
   bool              _newNews;

public:
                     News(string symbol);
                    ~News();

   bool              isAvailableNews() {return _availableNews;}
   void              setRawData(const string &rawData) { _rawData = rawData; }
   bool              refresh();
   Trade             *getTrade() {return GetPointer(_trade);}
   bool              isNewNews() {bool tmp = _newNews; _newNews = false; return tmp; }
   string            getRaw();
   double            getPrice();
   static string     netQuery();
private:
   bool              analyseNews();
   void              setTrade();
   void              calcPriceAndRatio();
   ENUM_POSITION_TYPE getTrend();
  };

MqlNet            iNet;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
News::News(string symbol)
  {
   _symbol=symbol;
   _availableNews=false;
   _barsNumber=0;
   _newNews=false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
News::~News()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   News::refresh()
  {  
   if(this.analyseNews()==false)
      return false;

   calcPriceAndRatio();

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string   News::netQuery(void)
  {
   bool        status;
   tagRequest  req;
   string   request;
   string   result;
   long time=TimeCurrent() -(3600*2);

   status=iNet.Open(host,80,"","",INTERNET_SERVICE_HTTP);
   if(status==false)
      return "";

   req.Init("GET","/fullQuery.php?" + "time="+IntegerToString(time),"Content-Type: application/x-www-form-urlencoded",request,false,result,false);
   status=iNet.Request(req);
   iNet.Close();

   return req.stOut;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   News::analyseNews()
  {
   if(_parser.isNew(_rawData)==false)
      return true;

   if(_parser.analyseText(_rawData)==false)
      return false;

   this.setTrade();
   _availableNews=true;
   _newNews=true;

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   News::setTrade(void)
  {
   _trade.symbol= _symbol;
   _trade.pivot = StringToDouble(_parser.pivot);
   _trade.r1 = StringToDouble(_parser.r1);
   _trade.t1 = StringToDouble(_parser.target1);
   _trade.t2 = StringToDouble(_parser.target2);
   _trade.time = (int)StringToInteger(_parser.time);
   _trade.trend=getTrend();
   _trade.price=getPrice();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   News::calcPriceAndRatio()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double News::getPrice(void)
  {
   if(_trade.trend==POSITION_TYPE_SELL)
      return SymbolInfoDouble(_symbol,SYMBOL_ASK);
   else if(_trade.trend==POSITION_TYPE_BUY)
      return SymbolInfoDouble(_symbol,SYMBOL_BID);
   else
      return 0.0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_POSITION_TYPE News::getTrend()
  {
   if(StringCompare(_parser.actualTrend,"short",false)==0)
      return POSITION_TYPE_SELL;
   else
      return POSITION_TYPE_BUY;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string News::getRaw()
  {
   if(_availableNews)
      return TimeToString(_trade.time+(3600*2))+" : "+_parser.actualTrend+" Pivot : "+_parser.pivot+" target : "+_parser.target1+" pointValue : "+DoubleToString(SymbolInfoDouble(_symbol,SYMBOL_TRADE_TICK_VALUE));
   else
      return "No news";
  }
//+------------------------------------------------------------------+
