//+------------------------------------------------------------------+
//|                                                      parsing.mqh |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class opportunityText
  {
public:
   string            symbol;
   string            source;
   string            actualTrend;
   string            weekTrend;
   string            monthTrend;
   string            target1;
   string            target2;
   string            pivot;
   string            r1;
   string            time;

public:
                     opportunityText(void) {}
                    ~opportunityText(void) {}

   bool              isNew(string &inText);
   bool              analyseText(string &inText);
private:
   bool              setElements(string key,string val);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   opportunityText::isNew(string &inText)
  {
   if(StringCompare(this.source,inText)==0)
      return false;
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  opportunityText::analyseText(string &inText)
  {
   string   tmp[];
   string   element[];
   int      tmpLenght;

   this.source=inText;
   tmpLenght=StringSplit(inText,StringGetCharacter(";",0),tmp);
   if(tmpLenght<8)
      return false;
   for(int i=0;i<tmpLenght;i++)
     {
      StringSplit(tmp[i],StringGetCharacter(":",0),element);
      if(setElements(element[0],element[1])==false)
         return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  opportunityText::setElements(string key,string val)
  {
   if(StringCompare(key,"symbol",false)==0)
     {
      this.symbol=val;
      return true;
     }
   else if(StringCompare(key,"actualTrend",false)==0)
     {
      this.actualTrend=val;
      return true;
     }
   else if(StringCompare(key,"weekTrend",false)==0)
     {
      this.weekTrend=val;
      return true;
     }
   else if(StringCompare(key,"monthTrend",false)==0)
     {
      this.monthTrend=val;
      return true;
     }
   else if(StringCompare(key,"target1",false)==0)
     {
      this.target1=val;
      return true;
     }
   else if(StringCompare(key,"target2",false)==0)
     {
      this.target2=val;
      return true;
     }
   else if(StringCompare(key,"pivot",false)==0)
     {
      this.pivot=val;
      return true;
     }
   else if(StringCompare(key,"resistance1",false)==0)
     {
      this.r1=val;
      return true;
     }
   else if(StringCompare(key,"time",false)==0)
     {
      this.time=val;
      return true;
     }
   else
     {
      return false;
     }
  }
//+------------------------------------------------------------------+
