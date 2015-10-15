//+------------------------------------------------------------------+
//|                                                 crowlerRobot.mq5 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "Trader.mqh"

Trader      *traders[];
string      symbols="EURUSD;"
                    +"USDJPY;"
                    +"USDCHF;"
                    +"GBPUSD;";
string      masterSymbol;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   int      tmpLenght;
   int      tradersNb=0;
   string   symbolsTab[];

   tmpLenght=StringSplit(symbols,StringGetCharacter(";",0),symbolsTab);

   ArrayResize(traders,tmpLenght,0);
   for(int i=0;i<tmpLenght;i++)
      traders[i]=new Trader(symbolsTab[i]);

   masterSymbol=symbolsTab[0];

   if(tradersNb==0)
      tradersNb=ArraySize(traders);

   crowlerNews();

   for(int i=0;i<tradersNb;i++)
      traders[i].refresh();

   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   int   arraySize=ArraySize(traders);

   for(int i=0;i<arraySize;i++)
      delete traders[i];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  crowlerNews()
  {
   string   rawData=News::netQuery();
   string   rawTab[];
   string   tmpTab[];
   int      tmpLenght;
   int      tradersSize=ArraySize(traders);

   tmpLenght=StringSplit(rawData,StringGetCharacter("\n",0),rawTab);
   for(int i=0;i<tmpLenght;i++)
     {
      StringSplit(rawTab[i],StringGetCharacter(">",0),tmpTab);
      for(int j=0;j<tradersSize;j++)
        {
         if(traders[j].getSymbol()==tmpTab[0])
            traders[j].newNews(tmpTab[1]);
        }
     }
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   static int  bars=0;
   static int  tradersNb=0;
   int         tmpBars;

   tmpBars=Bars(masterSymbol,news_period);
   if(tmpBars!=bars)
      crowlerNews();
   bars=tmpBars;

   if(tradersNb == 0)
      tradersNb = ArraySize(traders);

   for(int i=0;i<tradersNb;i++)
      traders[i].refresh();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   setMagics()
  {
   int   magicTab[];
   int   arraySize;
   int   nb;

   MathSrand(4242);

   ArrayResize(magicTab,ArraySize(traders),0);
   ArrayInitialize(magicTab,0);
   arraySize= ArraySize(magicTab);
   for(int i=0;i<arraySize;i++)
     {
      nb=0;
      while(nb==0)
        {
         nb=MathRand();
         for(int j=0;j<arraySize;j++)
            if(nb == magicTab[j])
               nb = 0;
         magicTab[i]=nb;
        }
     }

   int tradersSize=ArraySize(traders);

   for(int i=0;i<tradersSize;i++)
     {
      traders[i].setMagic(magicTab[i]);
     }
  }
//+------------------------------------------------------------------+
