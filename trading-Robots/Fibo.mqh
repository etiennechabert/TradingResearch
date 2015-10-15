//+------------------------------------------------------------------+
//|                                                         Fibo.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "News.mqh"

input int   fibo_gap = 1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Fibo
  {
private:
   string            _symbol;
   long              _chartId;
   bool              _retracementRdy;
   double            _levelValues[9];
   double            _retracements[9];
   bool              _isDraw;
public:
                     Fibo(string symbol);
                    ~Fibo();

   bool              isDraw() {return _isDraw;}
   void              updateLevels(const Trade &trade,ENUM_POSITION_TYPE posType);
   void              clean();
   void              setChartId(long chartId) { _chartId=chartId; }
   double            getNextSLLevel(double price,ENUM_POSITION_TYPE);
   double            getNextSLLevelInverted(double price,ENUM_POSITION_TYPE);
   double            getNextTPLevel(double price,ENUM_POSITION_TYPE);
   double            getNextTPLevelInverted(double price,ENUM_POSITION_TYPE);
   bool              isUnderFifty(double val,ENUM_POSITION_TYPE posType);
private:
   void              draw(const Trade &trade,ENUM_POSITION_TYPE posType);
   bool              setRetracements();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Fibo::Fibo(string symbol) : _symbol(symbol)
  {
   _retracementRdy=false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Fibo::~Fibo()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool            Fibo::setRetracements(void)
  {
   bool         status=true;

   _retracements[0] = 0.0;
   _retracements[1] = 0.236;
   _retracements[2] = 0.382;
   _retracements[3] = 0.500;
   _retracements[4] = 0.618;
   _retracements[5] = 1.000;
   _retracements[6] = 1.618;
   _retracements[7] = 2.618;
   _retracements[8] = 4.236;

   _retracementRdy=status;

   return status;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void         Fibo::clean(void)
  {
   ObjectDelete(_chartId,"Fibo");

   _isDraw=false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void      Fibo::draw(const Trade &trade,ENUM_POSITION_TYPE posType)
  {
   if(trade.trend==posType)
      ObjectCreate(_chartId,"Fibo",OBJ_FIBO,0,TimeGMT(),trade.t1,TimeGMT() -(3600*24*7),trade.pivot);
   else
      ObjectCreate(_chartId,"Fibo",OBJ_FIBO,0,TimeGMT(),trade.pivot,TimeGMT() -(3600*24*7),trade.t1);

   ObjectSetInteger(_chartId,"Fibo",OBJPROP_COLOR,Black);

   for(int i=0;i<9;i++)
     {
      ObjectSetInteger(_chartId,"Fibo",OBJPROP_LEVELSTYLE,i,STYLE_DOT);
      ObjectSetInteger(_chartId,"Fibo",OBJPROP_LEVELCOLOR,i,Silver);
     }

   _isDraw=true;

   ChartRedraw(_chartId);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void            Fibo::updateLevels(const Trade &trade,ENUM_POSITION_TYPE posType)
  {
   double val=MathAbs(trade.pivot-trade.t1);
   double point=MathPow(10,(double)SymbolInfoInteger(_symbol,SYMBOL_DIGITS));

   clean();
   draw(trade,posType);

   if(_retracementRdy==false)
      setRetracements();

   if(trade.trend==posType)
     {
      for(int i=0;i<9;i++)
        {
         if(trade.trend==POSITION_TYPE_BUY)
            _levelValues[i]=trade.pivot+(val*_retracements[i]);
         else
            _levelValues[i]=trade.pivot -(val*_retracements[i]);
         _levelValues[i]=(double)((int)(_levelValues[i]*point)/1.0)/point;
        }
     }
   else
     {
      for(int i=0;i<9;i++)
        {
         if(trade.trend==POSITION_TYPE_BUY)
            _levelValues[i]=trade.t1-(val*_retracements[i]);
         else
            _levelValues[i]=trade.t1+(val*_retracements[i]);
         _levelValues[i]=(double)((int)(_levelValues[i]*point)/1.0)/point;
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double       Fibo::getNextSLLevel(double value,ENUM_POSITION_TYPE posType)
  {
   int         arraySize;
   int         level;

   level=-1;
   arraySize= ArraySize(_levelValues);
   for(int i=0;i<arraySize;i++)
     {
      if(posType==POSITION_TYPE_BUY && value>_levelValues[i])
         level=i;
      else if(posType==POSITION_TYPE_SELL && _levelValues[i]>value)
         level=i;
      else
         break;
     }

   if(level>=fibo_gap)
      return _levelValues[level-fibo_gap];

   return 0.0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double       Fibo::getNextTPLevel(double value,ENUM_POSITION_TYPE posType)
  {
   int         arraySize;
   int         level;

   level=-1;
   arraySize= ArraySize(_levelValues);
   for(int i=0;i<arraySize;i++)
     {
      if(posType==POSITION_TYPE_BUY && value>_levelValues[i])
         level=i;
      else if(posType==POSITION_TYPE_SELL && _levelValues[i]>value)
         level=i;
      else
         break;
     }

   if(level<arraySize-2)
      return _levelValues[level+2];

   return 0.0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   Fibo::isUnderFifty(double val,ENUM_POSITION_TYPE posType)
  {
   if(_levelValues[3]>val)
      return(true==(posType==POSITION_TYPE_BUY));
   else
      return(false==(posType==POSITION_TYPE_BUY));
  }
//+------------------------------------------------------------------+
