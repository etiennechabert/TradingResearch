//+------------------------------------------------------------------+
//|                                            calcGeneratorMode.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "calcGenerator.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum CalcTechnics
  {
   EQUAL,
   ASC_LINEAR,
   ASC_SIMPLE_EXPO,
   ASC_DOUBLE_EXPO,
   ASC_TRILE_EXPO,
   DSC_LINEAR,
   DSC_SIMPLE_EXPO,
   DSC_DOUBLE_EXPO,
   DSC_TRILE_EXPO
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CalcASC : public calcGenerator
  {
public:
                     CalcASC(void){};
                    ~CalcASC(void){};
   virtual   double   ratioFormula(int index,int totalMa)
     {
      double value;

      value=baseFunction(index+1)-baseFunction(index);

      return value;
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CalcDSC : public calcGenerator
  {
public:
                     CalcDSC(void){};
                    ~CalcDSC(void){};
   virtual   double   baseRatioFormula(int index,int totalMa)
     {
      double value;

      value=baseFunction(index+1)-baseFunction(index);

      return value;
     }

   virtual   double   ratioFormula(int index,int totalMa)
     {
      double value;

      value=baseRatioFormula(totalMa-index-1, totalMa);

      return value;
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CalcEqual : public CalcASC
  {
public:
                     CalcEqual(void){_pow = 1.0;};
                    ~CalcEqual(void){};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CalcASCLinear : public CalcASC
  {
public:
                     CalcASCLinear(void){_pow = 1.58496250072115;}
                    ~CalcASCLinear(void){};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CalcASCExponential : public CalcASC
  {
public:
                     CalcASCExponential(void){_pow = 2;}
                    ~CalcASCExponential(void){};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CalcASCDoubleExponential : public CalcASC
  {
public:
                     CalcASCDoubleExponential(void){_pow = 3;}
                    ~CalcASCDoubleExponential(void){};

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CalcASCTrilpleExponential : public CalcASC
  {
public:
                     CalcASCTrilpleExponential(void){_pow = 4;}
                    ~CalcASCTrilpleExponential(void){};

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CalcDSCLinear : public CalcDSC
  {
public:
                     CalcDSCLinear(void){_pow = 1.58496250072115;}
                    ~CalcDSCLinear(void){};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CalcDSCExponential : public CalcDSC
  {
public:
                     CalcDSCExponential(void){_pow = 2;}
                    ~CalcDSCExponential(void){};

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CalcDSCDoubleExponential :  public CalcDSC
  {
public:
                     CalcDSCDoubleExponential(void){_pow = 3;}
                    ~CalcDSCDoubleExponential(void){};

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CalcDSCTripleExponential :  public CalcDSC
  {
public:
                     CalcDSCTripleExponential(void){_pow = 4;}
                    ~CalcDSCTripleExponential(void){};

  };
//+------------------------------------------------------------------+
