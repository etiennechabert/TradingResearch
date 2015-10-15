//+------------------------------------------------------------------+
//|                                                     WizGator.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include "movingAverageEngine.mqh"
#include "calcGeneratorMode.mqh"

input CalcTechnics  CALC_TECHNIC_MA=EQUAL;
//+------------------------------------------------------------------+
//| Funny name to describe a class working on N (optimised parameter)|
//| Moving Average. The calculation technics is also optimised       |
//+------------------------------------------------------------------+
class WizGator
  {
private:
   int               _debugIndex;
   int               _debugAccel;
   string            _symbol;
   ENUM_TIMEFRAMES   _timeFrame;
   movingAverageEngine *_movingAverageEngines[];
   calcGenerator    *_calcEngine;
   double            _result;
   double            _accel;
   int               _barNumber;

public:
                     WizGator(const string &symbol,ENUM_TIMEFRAMES timeFrame);
                    ~WizGator(void);

   bool              init(void);
   void              setDebugIndex(int index) {_debugIndex=index;}
   int               getDebugIndex() {return _debugIndex;}
   void              setDebugAccel(int index) {_debugAccel=index;}
   int               getDebugAccel() {return _debugAccel;}
   double            refresh(void);
   double            getMidPrice() {return _calcEngine.getMidPrice();}
   double            getAccel() {return _accel;}
   bool              deInit(void);

private:
   bool              initParametersCheck(void) const;
   bool              initMaAllocations(void);
  };
//+------------------------------------------------------------------+
//|  Wizgator suce des bites SkillyMaster ca rox plus                                                                |
//+------------------------------------------------------------------+
WizGator::WizGator(const string &symbol,ENUM_TIMEFRAMES timeFrame)
  {
   _symbol=symbol;
   _timeFrame=timeFrame;
   _barNumber=0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
WizGator::~WizGator()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  WizGator::init(void)
  {
   if(movingAverageEngine::checkParameters()==false)
      return false;

   ArrayResize(_movingAverageEngines,MA_NUMBER,MA_NUMBER);
   ZeroMemory(_movingAverageEngines);

   if(initMaAllocations()==false)
      return false;

   switch(CALC_TECHNIC_MA)
     {
      case EQUAL:
         _calcEngine=new CalcEqual();
         break;
      case ASC_LINEAR:
         _calcEngine=new CalcASCLinear();
         break;
      case ASC_SIMPLE_EXPO:
         _calcEngine=new CalcASCExponential();
         break;
      case ASC_DOUBLE_EXPO:
         _calcEngine=new CalcASCDoubleExponential();
         break;
      case ASC_TRILE_EXPO:
         _calcEngine=new CalcASCTrilpleExponential();
         break;
      case DSC_LINEAR:
         _calcEngine=new CalcDSCLinear();
         break;
      case DSC_SIMPLE_EXPO:
         _calcEngine=new CalcDSCExponential();
         break;
      case DSC_DOUBLE_EXPO:
         _calcEngine=new CalcDSCDoubleExponential();
         break;
      case DSC_TRILE_EXPO:
         _calcEngine=new CalcDSCTripleExponential();
         break;
      default:
         _calcEngine=NULL;
         break;
     }

   if(_calcEngine==NULL || _calcEngine.init(MA_NUMBER-1)==false)
      return false;

   for(int cp=0;cp<MA_NUMBER-1;cp++)
      _calcEngine.addMa(cp);

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double   WizGator::refresh(void)
  {
   int   newBarsNumber=Bars(_symbol,_timeFrame);
   double accelAverage= 0;

   if(_barNumber<newBarsNumber)
      _barNumber=newBarsNumber;
   else
      return _result;

   if(MA_NUMBER>1)
      _movingAverageEngines[0].refresh();

   for(int cp=1;cp<MA_NUMBER;cp++)
     {
      _movingAverageEngines[cp].refresh();
      accelAverage+=_movingAverageEngines[cp].getAccel();
      _calcEngine.addValue(cp-1,_movingAverageEngines[cp].getResult(),_movingAverageEngines[cp].getValue(0));
     }

   _accel = accelAverage / (MA_NUMBER - 1);
   _result=_calcEngine.getResult();

   return _result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   WizGator::deInit(void)
  {
   int   handlerSize=ArraySize(_movingAverageEngines);

   for(int cp=0; cp<handlerSize;++cp)
      if(_movingAverageEngines[cp]!=NULL)
        {
         delete _movingAverageEngines[cp];
         _movingAverageEngines[cp]=NULL;
        }

   if(_calcEngine)
      _calcEngine.deInit();
   delete _calcEngine;

   ArrayFree(_movingAverageEngines);

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  WizGator::initMaAllocations(void)
  {
   movingAverageEngine *ptr=NULL;

   for(int cp=0;cp<MA_NUMBER;cp++)
     {
      _movingAverageEngines[cp]=new movingAverageEngine(_symbol,_timeFrame,cp,ptr);
      ptr=_movingAverageEngines[cp];
     }
   return true;
  }
//+------------------------------------------------------------------+
