//+------------------------------------------------------------------+
//|                                                    Positions.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Positions
  {
public:
                     Positions(string symbol);
                    ~Positions(void);

   bool              checkActiveOrder();
   double            getProfit();
   double            getPrice();
   double            getPoint() {return _points;}
   double            getOpenPrice(void);
   string            getSymbol() { return _symbol;}
   ENUM_POSITION_TYPE   getActiveOrderType() {return _type;}
   double            getStopLoss();
   double            getTakeProfit();
   int               getPointsToStopLoss();
   bool              openLongPosition(double volume);
   bool              openShortPosition(double volume);
   bool              closePosition(string comment,double volume);
   bool              setStopLoss(double value);
   bool              setTakeProfit(double value);
   bool              setStopLossByPoint(double point);
   bool              setTakeProfitByPoint(double point);
   bool              isPendingOrderExist();
   bool              addPendingOrder(ENUM_ORDER_TYPE orderType,double volume,double openValue,double slValue,double tpValue);
   void              cleanExpiredOrders(bool force);

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
   ENUM_POSITION_TYPE _type;
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
      _type=(ENUM_POSITION_TYPE)positionType;
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
double Positions::getTakeProfit(void)
  {
   if(PositionSelect(_symbol)==false)
      return 0.0;

   double   tp;

   PositionGetDouble(POSITION_TP,tp);
   return tp;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int    Positions::getPointsToStopLoss(void)
  {
   double   price;
   double   sl;

   price=getPrice();
   sl=getStopLoss();

   return(int)(MathAbs(price-sl)/_points);
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
      return false;
     }

   if(orderResult)
     {
      _activeOrder=true;
      _activeVolume=_result.volume;
      _type=POSITION_TYPE_BUY;
     }
   else
     {
      return false;
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
      return false;
     }

   if(orderResult)
     {
      _activeOrder=true;
      _activeVolume=_result.volume;
      _type=POSITION_TYPE_SELL;
     }
   else
     {
      return false;
     }

   return orderResult;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Positions::closePosition(string comment="",double volume=0.0)
  {
   MqlTradeCheckResult  tmpResult;

   if(checkActiveOrder()==false)
      return false; // no active order to close
   resetData(false);

   _request.action = TRADE_ACTION_DEAL;
   _request.symbol = _symbol;

   if(volume<=_activeVolume && volume>0.001)
      _request.volume=volume;
   else
      _request.volume=_activeVolume;

   _request.comment=comment;
   _request.type_filling=ORDER_FILLING_RETURN;

   if(_type==POSITION_TYPE_SELL)
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

   if(orderResult)
     {
      _activeVolume-=_request.volume;
      if(_activeVolume<0.001)
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

   if(_type==POSITION_TYPE_SELL)
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

   if(_type==POSITION_TYPE_SELL)
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
//|                                                                  |
//+------------------------------------------------------------------+
bool              Positions::addPendingOrder(ENUM_ORDER_TYPE orderTypeTmp,double volume,double openValue,double slValue,double tpValue)
  {
   MqlTradeRequest   request;
   MqlTradeResult    result;
   MqlTradeCheckResult checkResult;
   ENUM_ORDER_TYPE   orderType;
   double            price;

   price=getPrice();

   if(orderTypeTmp==ORDER_TYPE_BUY)
     {
      if(openValue>price)
         orderType=ORDER_TYPE_BUY_STOP;
      else
         orderType=ORDER_TYPE_BUY_LIMIT;
     }
   else if(orderTypeTmp==ORDER_TYPE_SELL)
     {
      if(openValue<price)
         orderType=ORDER_TYPE_SELL_STOP;
      else
         orderType=ORDER_TYPE_SELL_LIMIT;
     }
   else
      return false;

   request.action = TRADE_ACTION_PENDING;
   request.symbol = _symbol;
   request.volume = volume;
   request.sl = slValue;
   request.tp = tpValue;
   request.type=orderType;
   request.stoplimit=0;
   request.price=openValue;
   request.type_filling=ORDER_FILLING_IOC;
   request.type_time=ORDER_TIME_SPECIFIED;
   request.expiration=TimeCurrent()+3600;

   if(OrderCheck(request,checkResult)==true)
      return OrderSend(request,result);
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   Positions::isPendingOrderExist(void)
  {
   int   totalOrders=OrdersTotal();

   for(int i=0;i<totalOrders;i++)
     {
      OrderSelect(OrderGetTicket(i));
      if(OrderGetString(ORDER_SYMBOL)==_symbol)
         return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   Positions::cleanExpiredOrders(bool force=false)
  {
   int   totalOrders=OrdersTotal();
   MqlTradeRequest   request;
   MqlTradeResult    result;

   for(int i=0;i<totalOrders;i++)
     {
      if(OrderSelect(OrderGetTicket(i))==false)
         return;
      if(OrderGetString(ORDER_SYMBOL)==_symbol && force==true)
        {
         request.order=OrderGetTicket(i);
         request.action=TRADE_ACTION_REMOVE;
         OrderSend(request,result);
        }
     }
   return;
  }
//+------------------------------------------------------------------+
