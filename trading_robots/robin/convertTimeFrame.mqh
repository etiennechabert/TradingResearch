//+------------------------------------------------------------------+
//|                                             convertTimeFrame.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| This enum help for conversion to ENUM_TIMEFRAMES                 |
//+------------------------------------------------------------------+
enum   ENUM_TIMEFRAMES_LINEAR
  {
   CURRENT_PERIOD,
   M1_PERIOD,
   M2_PERIOD,
   M3_PERIOD,
   M4_PERIOD,
   M5_PERIOD,
   //M6_PERIOD,
   M10_PERIOD,
   M12_PERIOD,
   M15_PERIOD,
   M20_PERIOD,
   M30_PERIOD,
   H1_PERIOD,
   H2_PERIOD,
   H3_PERIOD,
   H4_PERIOD,
   H6_PERIOD,
   H8_PERIOD,
   H12_PERIOD,
   D1_PERIOD,
   W1_PERIOD,
   MN1_PERIOD
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES convertTimeFrame(ENUM_TIMEFRAMES_LINEAR timeFrame)
  {
   switch(timeFrame)
     {
      case CURRENT_PERIOD :
         return PERIOD_CURRENT;
         break;
      case M1_PERIOD :
         return PERIOD_M1;
         break;
      case M2_PERIOD :
         return PERIOD_M2;
         break;
      case M3_PERIOD :
         return PERIOD_M3;
         break;
      case M4_PERIOD :
         return PERIOD_M4;
         break;
      case M5_PERIOD :
         return PERIOD_M5;
         break;
      case M6_PERIOD :
         return PERIOD_M6;
         break;
      case M10_PERIOD :
         return PERIOD_M10;
         break;
      case M12_PERIOD :
         return PERIOD_M12;
         break;
      case M15_PERIOD :
         return PERIOD_M15;
         break;
      case M20_PERIOD :
         return PERIOD_M20;
         break;
      case M30_PERIOD :
         return PERIOD_M30;
         break;
      case H1_PERIOD :
         return PERIOD_H1;
         break;
      case H2_PERIOD :
         return PERIOD_H2;
         break;
      case H3_PERIOD :
         return PERIOD_H3;
         break;
      case H4_PERIOD :
         return PERIOD_H4;
         break;
      case H6_PERIOD :
         return PERIOD_H6;
         break;
      case H8_PERIOD :
         return PERIOD_H8;
         break;
      case H12_PERIOD :
         return PERIOD_H12;
         break;
      case D1_PERIOD :
         return PERIOD_D1;
         break;
      case W1_PERIOD :
         return PERIOD_W1;
         break;
      case MN1_PERIOD :
         return PERIOD_MN1;
         break;
      default:
         return PERIOD_CURRENT;
         break;
     }
  }
//+------------------------------------------------------------------+
int convertTimeFrameToInt(ENUM_TIMEFRAMES timeFrame)
  {
   switch(timeFrame)
     {
      case PERIOD_M1 :
         return 1;
         break;
      case PERIOD_M2 :
         return 2;
         break;
      case PERIOD_M3 :
         return 3;
         break;
      case PERIOD_M4 :
         return 4;
         break;
      case PERIOD_M5 :
         return 5;
         break;
      case PERIOD_M6 :
         return 6;
         break;
      case PERIOD_M10 :
         return 10;
         break;
      case PERIOD_M12 :
         return 12;
         break;
      case PERIOD_M15 :
         return 15;
         break;
      case PERIOD_M20 :
         return 20;
         break;
      case PERIOD_M30 :
         return 30;
         break;
      case PERIOD_H1 :
         return 60;
         break;
      case PERIOD_H2 :
         return 120;
         break;
      case PERIOD_H3 :
         return 180;
         break;
      case PERIOD_H4 :
         return 240;
         break;
      case PERIOD_H6 :
         return 360;
         break;
      case PERIOD_H8 :
         return 480;
         break;
      case PERIOD_H12 :
         return 720;
         break;
      case PERIOD_D1 :
         return 1440;
         break;
      case PERIOD_W1 :
         return 10080;
         break;
      case PERIOD_MN1 :
         return 40320;
         break;
      default:
         return PERIOD_CURRENT;
         break;
     }
  }
