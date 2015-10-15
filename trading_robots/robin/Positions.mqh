//+------------------------------------------------------------------+
//|                                                    Positions.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+

class Positions
  {
public:
                     Positions(string symbol);
                    ~Positions(void);

   bool              checkActiveOrder();
   double            getProfit();
   double            getPrice();
   double            getOpenPrice(void);
   string            getSymbol() { return _symbol;}
   ENUM_ORDER_TYPE   getActiveOrderType() {return _type;}
   double            getStopLoss();
   int               getPointsToStopLoss();
   bool              openLongPosition(double volume);
   bool              openShortPosition(double volume);
   bool              closePosition(string comment);
   bool              setStopLoss(double value);
   bool              setTakeProfit(double value);
   bool              setStopLossByPoint(double point);
   bool              setTakeProfitByPoint(double point);

private:
   void              resetData(bool fullClean);

private:
   string            _symbol;
   MqlTradeRequest   _request;
   MqlTradeResult    _result;
   double            _profit;
   double            _points;
   bool              _activeOrder;
   double            _activeVolume;
   ENUM_ORDER_TYPE   _type;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Positions::Positions(string symbol)
  {
   _symbol=symbol;
   _points=SymbolInfoDouble(_symbol,SYMBOL_POINT);
   resetData(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Positions::~Positions(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  Positions::checkActiveOrder(void)
  {
   long  positionType;
   bool status=PositionSelect(_symbol);

   if(status==false && _activeOrder==true)
      resetData(true);

   if(status)
     {
      PositionGetInteger(POSITION_TYPE,positionType);
      PositionGetDouble(POSITION_PROFIT,_profit);
      PositionGetDouble(POSITION_VOLUME,_activeVolume);
      _type=(ENUM_ORDER_TYPE)positionType;
     }

   return status;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Positions::getProfit(void)
  {
   checkActiveOrder();
   return _profit;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Positions::getOpenPrice(void)
  {
   if(PositionSelect(_symbol)==true)
      return PositionGetDouble(POSITION_PRICE_OPEN);
   return 0.0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Positions::getPrice(void)
  {
   double   price;

   price=SymbolInfoDouble(_symbol,SYMBOL_BID);

   return price;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Positions::getStopLoss(void)
  {
   if(PositionSelect(_symbol)==false)
      return 0.0;

   double   sl;

   PositionGetDouble(POSITION_SL,sl);
   return sl;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int    Positions::getPointsToStopLoss(void)
  {
   double   price;
   double   sl;
   
   price = getPrice();
   sl = getStopLoss();
   
   return (int)(MathAbs(price - sl) / _points);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Positions::openLongPosition(double volume)
  {
   MqlTradeCheckResult  tmpResult;
   bool orderResult=false;

   if(checkActiveOrder())
      return false; // an order is already open
   resetData(true);

   if(SymbolInfoDouble(_symbol,SYMBOL_ASK,_request.price)==false)
      return false;

   _request.action = TRADE_ACTION_DEAL;
   _request.symbol = _symbol;
   _request.volume = volume;
   _request.type_filling=ORDER_FILLING_FOK;
   _request.type=ORDER_TYPE_BUY;
   _request.deviation=10000;

   ResetLastError();
   if(OrderCheck(_request,tmpResult)==true)
      orderResult=OrderSend(_request,_result);
   else
     {
      Print(_symbol," BUY : ",GetLastError());
      return false;
     }

   if(orderResult)
     {
      _activeOrder=true;
      _activeVolume=_result.volume;
      _type=ORDER_TYPE_BUY;
     }

   return orderResult;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Positions::openShortPosition(double volume)
  {
   MqlTradeCheckResult  tmpResult;
   bool orderResult=false;

   if(checkActiveOrder())
      return false; // an order is already open
   resetData(true);

   if(SymbolInfoDouble(_symbol,SYMBOL_BID,_request.price)==false)
      return false;

   _request.action = TRADE_ACTION_DEAL;
   _request.symbol = _symbol;
   _request.volume = volume;
   _request.type_filling=ORDER_FILLING_FOK;
   _request.type=ORDER_TYPE_SELL;
   _request.deviation=10000;

   ResetLastError();
   if(OrderCheck(_request,tmpResult)==true)
      orderResult=OrderSend(_request,_result);
   else
     {
      Print(_symbol," SELL : ",GetLastError());
      return false;
     }

   if(orderResult)
     {
      _activeOrder=true;
      _activeVolume=_result.volume;
      _type=ORDER_TYPE_SELL;
     }

   return orderResult;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Positions::closePosition(string comment)
  {
   MqlTradeCheckResult  tmpResult;

   if(checkActiveOrder()==false)
      return false; // no active order to close
   resetData(false);

   _request.action = TRADE_ACTION_DEAL;
   _request.symbol = _symbol;
   _request.volume = _activeVolume;
   _request.comment = comment;
   _request.type_filling=ORDER_FILLING_RETURN;

   if(_type==ORDER_TYPE_SELL)
     {
      if(SymbolInfoDouble(_symbol,SYMBOL_ASK,_request.price)==false)
         return false;
      _request.type=ORDER_TYPE_BUY;
     }
   else
     {
      if(SymbolInfoDouble(_symbol,SYMBOL_BID,_request.price)==false)
         return false;
      _request.type=ORDER_TYPE_SELL;
     }

   ResetLastError();
   bool orderResult=OrderSend(_request,_result);
   Print(GetLastError());

   if(orderResult)
     {
      resetData(true);
     }

   return orderResult;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Positions::setStopLoss(double value)
  {
   MqlTradeCheckResult  tmpResult;

   if(checkActiveOrder()==false)
      return false;
   double lastTakeProfit=PositionGetDouble(POSITION_TP);

   _request.action=TRADE_ACTION_SLTP;
   _request.symbol=_symbol;
   _request.sl = value;
   _request.tp = lastTakeProfit;

   if(OrderCheck(_request,tmpResult)==true)
      return OrderSend(_request,_result);
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Positions::setTakeProfit(double value)
  {
   MqlTradeCheckResult  tmpResult;

   if(checkActiveOrder()==false)
      return false;
   double lastStopLoss=PositionGetDouble(POSITION_SL);

   _request.action=TRADE_ACTION_SLTP;
   _request.symbol=_symbol;
   _request.sl = lastStopLoss;
   _request.tp = value;

   if(OrderCheck(_request,tmpResult)==true)
      return OrderSend(_request,_result);
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Positions::setStopLossByPoint(double points)
  {
   double   digitsForSymbol=(double)SymbolInfoInteger(_symbol,SYMBOL_DIGITS);
   double   price;

   if(points==0.0)
      return false;

   if(_type==ORDER_TYPE_SELL)
     {
      if(SymbolInfoDouble(_symbol,SYMBOL_ASK,_request.sl)==false)
         return false;
      price=_request.sl+(points*MathPow(0.1,digitsForSymbol));
     }
   else
     {
      if(SymbolInfoDouble(_symbol,SYMBOL_BID,_request.sl)==false)
         return false;
      price=_request.sl-(points*MathPow(0.1,digitsForSymbol));
     }
   if(setStopLoss(price)==false && _activeOrder==true)
      return setStopLossByPoint(points+1);
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Positions::setTakeProfitByPoint(double points)
  {
   double   digitsForSymbol=(double)SymbolInfoInteger(_symbol,SYMBOL_DIGITS);
   double   price;

   if(points==0.0)
      return false;

   if(_type==ORDER_TYPE_SELL)
     {
      if(SymbolInfoDouble(_symbol,SYMBOL_ASK,_request.tp)==false)
         return false;
      price=_request.tp-(points*MathPow(0.1,digitsForSymbol));
     }
   else
     {
      if(SymbolInfoDouble(_symbol,SYMBOL_BID,_request.tp)==false)
         return false;
      price=_request.tp+(points*MathPow(0.1,digitsForSymbol));
     }
   if(setTakeProfit(price)==false && _activeOrder==true)
      return setTakeProfitByPoint(points+1);
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  Positions::resetData(bool fullClean=true)
  {
   ZeroMemory(_request);
   ZeroMemory(_result);
   if(fullClean)
     {
      _activeOrder=false;
      _activeVolume=0.0;
     }
  }
//+------------------------------------------------------------------+
