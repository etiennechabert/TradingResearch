//+------------------------------------------------------------------+
//|                                                calcGenerator.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "movingAverageEngine.mqh"
//+------------------------------------------------------------------+
//| This class have to be overload by a calcGeneratorMode classes    |
//+------------------------------------------------------------------+
class calcGenerator
  {
   class dataRatio
     {
   public:
      int               index;
      double            ratio;
      double            value;
      double            price;
     };

protected:
   virtual double    ratioFormula(int index,int totalMa){Print("Warning you are using a virtual class !!! "); return 0.0;};
   virtual double    baseFunction(int x) {return MathPow(x,_pow)/MathPow(_maNumber,_pow);}
public:

                     calcGenerator();
                    ~calcGenerator();

   virtual bool      init(int MaNumbers);
   virtual void      addMa(int index);
   virtual void      addValue(int index,double value,double price);
   virtual double    getResult();
   virtual double    getMidPrice() {return _midPrice;}

   virtual void      deInit();

protected:
   dataRatio         _movingAverageEngine[];
   int               _maNumber;
   double            _pow;
   double            _midPrice;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
calcGenerator::calcGenerator()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
calcGenerator::~calcGenerator()
  {
  }
//+------------------------------------------------------------------+
bool     calcGenerator::init(int maNumber)
  {
   _maNumber=maNumber;

   if(ArrayResize(_movingAverageEngine,maNumber,maNumber)==false)
      return(false);

   ZeroMemory(_movingAverageEngine);

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   calcGenerator::addMa(int index)
  {
   if(index>_maNumber)
      return;

   _movingAverageEngine[index].index=index;
   _movingAverageEngine[index].ratio=ratioFormula(index, _maNumber);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   calcGenerator::addValue(int index,double value,double price)
  {
   if(index>_maNumber)
      return;

   _movingAverageEngine[index].value=value;
   _movingAverageEngine[index].price=price;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calcGenerator::getResult()
  {
   double result=0.0;

   _midPrice = 0;

   for(int cp=0;cp<_maNumber;cp++)
      result+=(_movingAverageEngine[cp].value*_movingAverageEngine[cp].ratio);

   for(int cp=0;cp<_maNumber;cp++)
      _midPrice+=(_movingAverageEngine[cp].price*_movingAverageEngine[cp].ratio);

   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  calcGenerator::deInit(void)
  {
   ArrayFree(_movingAverageEngine);
  }
//+------------------------------------------------------------------+
