//+------------------------------------------------------------------+
//|                                                 SkillyMaster.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| MultiFrame Class for WizGator indicators                         |
//+------------------------------------------------------------------+

#include "convertTimeFrame.mqh"
#include "WizGator.mqh"
#include <TextDisplay.mqh>

//extern TableDisplay table;
extern int debugRefresh;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


input ENUM_TIMEFRAMES_LINEAR  FAST_PERIOD=M1_PERIOD;
ENUM_TIMEFRAMES_LINEAR        SLOW_PERIOD=H1_PERIOD;
input int                     GAP_FAST_PERIOD=1;
input int                     STEP_PERIOD=11;
input CalcTechnics            CALC_TECHNIC_PERIOD=EQUAL;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class SkillyMaster
  {
private:
   string            _symbol;
   double            _result;
   double            _accel;
   int               _debugCol;
   int               _debugIndexResult;
   int               _debugIndexAccel;
   WizGator         *_indicators[];
   calcGenerator    *_calcEngine;

public:
                     SkillyMaster(string symbol,int debugIndex);
                    ~SkillyMaster();

   bool              init();
   void              refresh();
   double            getResult() {return _result;}
   double            getAccel() {return _accel;}
   double            getMidPrice() {return _calcEngine.getMidPrice();}
   void              deInit();

private:
   bool              allocateGators();
   bool              allocateGator(int index,ENUM_TIMEFRAMES_LINEAR timeFrame);
   int               calcTotalPeriods();

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SkillyMaster::SkillyMaster(string symbol,int debugIndex)
  {
   _symbol=symbol;
   _debugCol=debugIndex;
   
   SLOW_PERIOD=(ENUM_TIMEFRAMES_LINEAR)((int)FAST_PERIOD+GAP_FAST_PERIOD);
   if ((int)SLOW_PERIOD > (int)MN1_PERIOD)
      SLOW_PERIOD = MN1_PERIOD;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SkillyMaster::~SkillyMaster()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool     SkillyMaster::init(void)
  {
   if(FAST_PERIOD>SLOW_PERIOD)
      return false;
   if(STEP_PERIOD==0)
      return false;
   if(calcTotalPeriods()==0)
      return false;

   switch(CALC_TECHNIC_PERIOD)
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

   if(_calcEngine==NULL || _calcEngine.init(calcTotalPeriods())==false)
      return false;

   for(int cp=0;cp<calcTotalPeriods();cp++)
      _calcEngine.addMa(cp);

   return allocateGators();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SkillyMaster::refresh(void)
  {
   double   tmpResult;
   double   tmpAccel=0;
   double   result=0;
   int      cp=0;
   int      indicatorsNumber=calcTotalPeriods();

   while(cp<indicatorsNumber)
     {
      tmpResult=_indicators[cp].refresh();
      tmpAccel+=_indicators[cp].getAccel();
      table.SetText(_indicators[cp].getDebugAccel(),DoubleToString(_indicators[cp].getAccel(),2));
      table.SetText(_indicators[cp].getDebugIndex(),DoubleToString(tmpResult,2));
      _calcEngine.addValue(cp,tmpResult,_indicators[cp].getMidPrice());
      cp++;
     }

   result=_calcEngine.getResult();

   table.SetText(_debugIndexResult,DoubleToString(result, 2));
   table.SetText(_debugIndexAccel,DoubleToString(tmpAccel/indicatorsNumber, 2));

   _result= result;
   _accel = tmpAccel/indicatorsNumber;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   SkillyMaster::deInit(void)
  {
   int      indicatorsNumber=ArraySize(_indicators);

   for(int cp=0;cp<indicatorsNumber;cp++)
     {
      if(_indicators[cp])
        {
         _indicators[cp].deInit();
         delete _indicators[cp];
        }
     }

   ArrayFree(_indicators);

   if(_calcEngine)
      _calcEngine.deInit();
   delete _calcEngine;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool     SkillyMaster::allocateGators(void)
  {
   int   numberPeriod=calcTotalPeriods();

   ArrayResize(_indicators,numberPeriod,numberPeriod);
   ZeroMemory(_indicators);

   table.AddTitleObject(10,60,0,3,"TOTAL",White);

   for(int cp=0;cp<numberPeriod;cp++)
      if(allocateGator(cp,(ENUM_TIMEFRAMES_LINEAR)((int)FAST_PERIOD+((int)STEP_PERIOD*cp)))==false)
         return false;

   _debugIndexResult=table.AddFieldObject(40,60,_debugCol * 4 - 1,3,Yellow);
   _debugIndexAccel = table.AddFieldObject(40,60,_debugCol * 4 + 1,3,Yellow);

   return true;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool     SkillyMaster::allocateGator(int index,ENUM_TIMEFRAMES_LINEAR timeFrame)
  {
   if((int)timeFrame>(int)SLOW_PERIOD)
      timeFrame=SLOW_PERIOD;

   ENUM_TIMEFRAMES   mqlTimeFrame=convertTimeFrame(timeFrame);

   _indicators[index]=new WizGator(_symbol,mqlTimeFrame);

   if(_indicators[index].init()==false)
      return false;

   table.AddTitleObject(20,60,0,index+4,EnumToString(mqlTimeFrame),White);

   _indicators[index].setDebugIndex(table.AddFieldObject(40,60,_debugCol * 4 - 1,index+4,Yellow));
   _indicators[index].setDebugAccel(table.AddFieldObject(40,60,_debugCol * 4 + 1,index+4,Yellow));

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int      SkillyMaster::calcTotalPeriods(void)
  {
   int   periodGap;

   periodGap=((SLOW_PERIOD-FAST_PERIOD)/STEP_PERIOD)+1;

   if(((periodGap-1)*STEP_PERIOD+(int)FAST_PERIOD)<(int)SLOW_PERIOD)
      periodGap+=1;

   return periodGap;
  }
//+------------------------------------------------------------------+
