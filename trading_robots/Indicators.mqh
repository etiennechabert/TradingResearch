//+------------------------------------------------------------------+
//|                                                   indicators.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "Stoch.mqh"
#include "RVI.mqh"

input int   indicator_close_mode=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Indicators
  {
private:

public:
                     Indicators() {};
                    ~Indicators() {};

   void              setIndicators(Stoch *stoch,RVI *rvi) {_stoch=stoch; _rvi=rvi;}
   bool              sellDecision();
   bool              buyDecision();
   bool              closeSellDecision();
   bool              closeBuyDecision();

private:
   RVI              *_rvi;
   Stoch            *_stoch;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  Indicators::sellDecision(void)
  {
   if(_stoch.getOverSituation()!=OVERBUY && stoch_over_require==1)
      return false;

   if(_stoch.getOverSituation()==OVERSELL && stoch_over_require==2)
      return false;

   if(_stoch.getState()==POSITION_TYPE_SELL && _rvi.getState()==SELL)
      return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  Indicators::buyDecision(void)
  {
   if(_stoch.getOverSituation()!=OVERSELL && stoch_over_require==1)
      return false;

   if(_stoch.getOverSituation()==OVERBUY && stoch_over_require==2)
      return false;

   if(_stoch.getState()==POSITION_TYPE_BUY && _rvi.getState()==BUY)
      return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  Indicators::closeSellDecision(void)
  {
   if(indicator_close_mode==0 && _stoch.getState()==POSITION_TYPE_BUY && _rvi.getState()==BUY)
      return true;
   if(indicator_close_mode==1 && _stoch.getState()==POSITION_TYPE_BUY && _rvi.getState()==BUY && _stoch.getOverSituation()==OVERSELL)
      return true;
   else if(indicator_close_mode==2 && (_stoch.getState()==POSITION_TYPE_BUY || _rvi.getState()==BUY))
      return true;
   else if(indicator_close_mode==3 && _stoch.getState()==POSITION_TYPE_BUY)
      return true;
   else if(indicator_close_mode==4 && _stoch.getState()==POSITION_TYPE_BUY && _stoch.getOverSituation()==OVERSELL)
      return true;
   else if(indicator_close_mode==5 && _rvi.getState()==BUY)
      return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  Indicators::closeBuyDecision(void)
  {
   if(indicator_close_mode==0 && _stoch.getState()==POSITION_TYPE_SELL && _rvi.getState()==SELL)
      return true;
   if(indicator_close_mode==1 && _stoch.getState()==POSITION_TYPE_SELL && _rvi.getState()==SELL && _stoch.getOverSituation()==OVERBUY)
      return true;
   else if(indicator_close_mode==2 && (_stoch.getState()==POSITION_TYPE_SELL || _rvi.getState()==SELL))
      return true;
   else if(indicator_close_mode==3 && _stoch.getState()==POSITION_TYPE_SELL)
      return true;
   else if(indicator_close_mode==4 && _stoch.getState()==POSITION_TYPE_SELL && _stoch.getOverSituation()==OVERBUY)
      return true;
   else if(indicator_close_mode==5 && _rvi.getState()==SELL)
      return true;
   return false;
  }
//+------------------------------------------------------------------+
