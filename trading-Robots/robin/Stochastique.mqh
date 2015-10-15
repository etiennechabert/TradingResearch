//+------------------------------------------------------------------+
//|                                                 Stochastique.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "enum.mqh"

input ENUM_TIMEFRAMES   STOCH_TIMEFRAME;
input bool              STOCH_HARD_SIGNAL=true;
input int               OVER_AREA=20;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Stochastique
  {
private:
   int               _handler;
   int               _debugIndex;
   string            _symbol;
   int               _barsNumber;
   ENUM_DECISION     _decision;

public:
                     Stochastique(string symbol);
                    ~Stochastique();

   void  setDebugIndex(int debugIndex) {_debugIndex=debugIndex;}

   bool              init();
   void              deInit();
   bool              refresh();
   ENUM_DECISION     getDecision() { return _decision; }

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Stochastique::Stochastique(string symbol) : _symbol(symbol)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Stochastique::~Stochastique()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   Stochastique::init(void)
  {
   _handler=iStochastic(_symbol,STOCH_TIMEFRAME,5,3,3,MODE_SMA,STO_LOWHIGH);
   if(_handler==INVALID_HANDLE)
      return false;

   _barsNumber=0;

   _decision=UNDIFINED;

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   Stochastique::deInit(void)
  {
   if(_handler!=INVALID_HANDLE)
      IndicatorRelease(_handler);
   _handler=INVALID_HANDLE;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   Stochastique::refresh(void)
  {
   double   main_line[1];
   double   signal_line[1];
   int      barsNumbers=Bars(_symbol,STOCH_TIMEFRAME);

   if(_barsNumber==barsNumbers && EVERY_TICK==false)
      return true;

   _barsNumber=barsNumbers;

   if(CopyBuffer(_handler,0,1,1,main_line)<1)
      return false;

   if(CopyBuffer(_handler,1,1,1,signal_line)<1)
      return false;

   if(main_line[0]<OVER_AREA && signal_line[0]<OVER_AREA)
      _decision=SELL;
   else if(main_line[0]>(100-OVER_AREA) && signal_line[0]>(100-OVER_AREA))
      _decision=BUY;
   else if(STOCH_HARD_SIGNAL)
      _decision=UNDIFINED;

   // table.SetText(_debugIndex,EnumToString(_decision));

   return true;
  }
//+------------------------------------------------------------------+
