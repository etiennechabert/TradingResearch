//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

input   double   pourcentRisk;
//+------------------------------------------------------------------+
//| This very simple class is an helper to calculate the good volume |
//| Function of accepted risk (in %) for each order ;)               |
//+------------------------------------------------------------------+
class Money
  {
public:
                     Money(string symbol);
                    ~Money(void);

   double            getBalance() const {return _balance;}
   double            getCredit() const {return _credit;}
   double            getProfit() const {return _profit;}

   void              refresh();
   double            getVolume(int  pointToStopLoss);

private:
   string            _symbol;
   double            _minVolume;
   double            _maxVolume;
   double            _stepVolume;
   double            _balance;
   double            _credit;
   double            _profit;
   long              _leverageRatio;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Money::Money(string symbol)
  {
   _leverageRatio=AccountInfoInteger(ACCOUNT_LEVERAGE);
   _symbol=symbol;
   _minVolume=SymbolInfoDouble(_symbol,SYMBOL_VOLUME_MIN);
   _maxVolume= SymbolInfoDouble(_symbol,SYMBOL_VOLUME_MAX);
   _stepVolume=SymbolInfoDouble(_symbol,SYMBOL_VOLUME_STEP);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Money::~Money(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  Money::refresh(void)
  {
   _balance= AccountInfoDouble(ACCOUNT_BALANCE);
   _credit = AccountInfoDouble(ACCOUNT_CREDIT);
   _profit = AccountInfoDouble(ACCOUNT_PROFIT);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double   Money::getVolume(int pointToStopLoss)
  {
   if(pointToStopLoss==0)
      return _minVolume;
   double   allowedLoss=_balance*(pourcentRisk/100.0);
   double   volume=allowedLoss/pointToStopLoss;

   if(volume<_minVolume)
      return _minVolume;
   else if(volume>_maxVolume)
      return _maxVolume;

   volume=volume-MathMod(volume,_stepVolume);

   return volume;
  }
//+------------------------------------------------------------------+
