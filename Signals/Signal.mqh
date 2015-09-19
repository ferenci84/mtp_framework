//

#include <Arrays\ArrayObj.mqh>

enum ENUM_SIGNAL {
   SIGNAL_NONE = -1,
   SIGNAL_NO = 0,
   SIGNAL_BUY = 1,
   SIGNAL_SELL = 2,
   SIGNAL_BOTH = 3,   
};

enum ENUM_SIGNAL_RELATION {
   SIGNAL_RELATION_AND,
   SIGNAL_RELATION_OR
};

class CSignal : public CArrayObj {

public:
   CSignal* signalcontainer;

   bool opensignal_enabled;
   bool closesignal_enabled;

   bool localsignal_enabled;
   bool subsignal_enabled;

   int bar;

   ENUM_SIGNAL signal;
   ENUM_SIGNAL closesignal;
   ENUM_SIGNAL lastsignal;

   bool execute_enabled;
   bool valid;
   
   CSignal()
   {
      signal = SIGNAL_NONE;
      closesignal = SIGNAL_NONE;
      valid = true;
      execute_enabled = true;
   }

   bool Add(CObject* element)
   {
      ((CSignal*)element).signalcontainer = GetPointer(this);
      return CArrayObj::Add(element);      
   }
      
   CSignal* Subsignal(int i)
   {
      return(At(i));
   }
      
   void Run(int current_bar = -1) {
      if (current_bar >= 0) this.bar = current_bar;
      BeforeExecute();
      if (execute_enabled) {
         GetSignal(current_bar);
      }
      AfterExecute();
            
   }  
      
   virtual void GetSignal(int current_bar = -1) {
      if (current_bar >= 0) this.bar = current_bar;  
      if (localsignal_enabled)
         CalculateValues();
   
      if (subsignal_enabled)
         RunSubSignals();
   
      if (opensignal_enabled) GetOpenSignal();
      if (closesignal_enabled) GetCloseSignal();

   }
   
   virtual void RunSubSignals()
   {
      for (int i = 0; i < Total(); i++ ) {
         CSignal* subsignal = At(i);   
         subsignal.Run(bar);
      }   
   }
   
   virtual void GetOpenSignal()
   {
      signal = SIGNAL_NONE;      

      if (localsignal_enabled) {
         signal = OpenSignal();
      }
      
      if (subsignal_enabled) {
         for (int i = 0; i < Total(); i++ ) {
            CSignal* subsignal = At(i);         
            if (subsignal.opensignal_enabled) {
               AddSubOpenSignal(subsignal);
            }       
         }
         if (signal == SIGNAL_NONE) signal = SIGNAL_NO;
      } 
   }

   virtual void GetCloseSignal()
   {
      closesignal = SIGNAL_NONE;
   
      if (localsignal_enabled) {
         closesignal = CloseSignal();
      }
      
      if (subsignal_enabled) {
         for (int i = 0; i < Total(); i++ ) {
            CSignal* subsignal = At(i);
            if (subsignal.closesignal_enabled) {
               AddSubCloseSignal(subsignal);
            }            
         }
      }
   }
      
   virtual void AddSubOpenSignal(CSignal* subsignal)
   {
      if (!subsignal.valid) this.valid = false;
      signal = signaladd(signal,subsignal.signal);
   }
   
   virtual void AddSubCloseSignal(CSignal* subsignal)
   {
      closesignal = signaladd_or(closesignal,subsignal.closesignal);
   }
   
   virtual void BeforeExecute() {
      if (execute_enabled) {
         lastsignal = signal;  
      }
      valid = true;
      execute_enabled = true;
      if (!BeforeFilter()) {
         valid = false;
         execute_enabled = false;
      }
   }
   
   virtual void AfterExecute() {
      if (!AfterFilter()) {
         valid = false;
      }
   }
   
   void Reverse()
   {
      if (execute_enabled) {
         signal = signal_reverse(signal);
         closesignal = signal_reverse(closesignal);
      }
   }
   
   virtual bool BeforeFilter()
   {
      return true;
   }
   virtual bool AfterFilter()
   {
      return true;
   }

   virtual void CalculateValues() {
   
   }
   
   virtual ENUM_SIGNAL OpenSignal() {
      signal = SIGNAL_NO;
      if (BuyCondition()) signal = signaladd_or(signal,SIGNAL_BUY);
      if (SellCondition()) signal = signaladd_or(signal,SIGNAL_SELL);
      if (BothCondition()) signal = signaladd_or(signal,SIGNAL_BOTH);
      return signal;
   }
   
   virtual bool BuyCondition() {
      return false;
   }
   virtual bool SellCondition() {
      return false;
   }
   virtual bool BothCondition() {
      return false;
   }   
   
   virtual ENUM_SIGNAL CloseSignal() {
      closesignal = SIGNAL_NO;
      if (CloseBuyCondition()) closesignal = signaladd_or(closesignal,SIGNAL_SELL);
      if (CloseSellCondition()) closesignal = signaladd_or(closesignal,SIGNAL_BUY);
      if (CloseAllCondition()) closesignal = signaladd_or(closesignal,SIGNAL_BOTH);
      return closesignal;
   }

   virtual bool CloseBuyCondition() {
      return false;
   }
   virtual bool CloseSellCondition() {
      return false;
   }
   virtual bool CloseAllCondition() {
      return false;
   }   
   
   virtual void OnTick() {
      if (subsignal_enabled) {
         for (int i = 0; i < Total(); i++ ) {
            CSignal* subsignal = At(i);
            subsignal.OnTick();
         }
      }
   }
   
};

class COpenSignal : public CSignal {
public:
   COpenSignal() {
      localsignal_enabled = true;
      opensignal_enabled = true;
   }
};

class CCloseSignal : public CSignal {
public:
   CCloseSignal() {
      localsignal_enabled = true;
      closesignal_enabled = true;
   }
};

class COpenAndCloseSignal : public CSignal {
public:
   COpenAndCloseSignal() {
      localsignal_enabled = true;
      opensignal_enabled = true;
      closesignal_enabled = true;
   }
};

class CSignalContainer : public CSignal {

public:
   CSignalContainer()
   {
      subsignal_enabled = true;
      opensignal_enabled = true;
      closesignal_enabled = true;
   }
};

ENUM_SIGNAL signaladd(int signal, int signalpart)
{
   if (signal == SIGNAL_NONE || signal == SIGNAL_BOTH)
      signal = signalpart;
   else if (signal != signalpart && signalpart != -1 && signalpart != SIGNAL_BOTH)   
      signal = 0;
   
   return((ENUM_SIGNAL)signal);
}

ENUM_SIGNAL signaladd_or(int signal, int signalpart)
{
   if (signal == SIGNAL_NONE || signal == SIGNAL_NO || signalpart == SIGNAL_BOTH)
      signal = signalpart;
   else if ((signal == SIGNAL_BUY && signalpart == SIGNAL_SELL) || (signal == SIGNAL_SELL && signalpart == SIGNAL_BUY))   
      signal = SIGNAL_BOTH;
   
   return((ENUM_SIGNAL)signal);
}

ENUM_SIGNAL signal_reverse(int signal)
{
   if (signal == SIGNAL_BUY)
      return(SIGNAL_SELL);
   else if (signal == SIGNAL_SELL)
      return(SIGNAL_BUY);
   
   return((ENUM_SIGNAL)signal);
}

string signaltext(int signal, string no = "NO SIGNAL", string buy = "BUY", string sell = "SELL", string both = "BOTH")
{
   if (signal == SIGNAL_NONE) return("NONE");
   if (signal == SIGNAL_NO) return(no);
   if (signal == SIGNAL_BUY) return(buy);
   if (signal == SIGNAL_SELL) return(sell);
   if (signal == SIGNAL_BOTH) return(both);
   return("");
}

string signaltext_close(int signal)
{
   return(signaltext(signal,"NO SIGNAL","CLOSE SELL","CLOSE BUY","CLOSE ALL"));
}


ENUM_SIGNAL signal_universal(bool buycond, bool sellcond)
{
   int signal = SIGNAL_NO;
   if (buycond) signal = signaladd_or(signal,SIGNAL_BUY);
   if (sellcond) signal = signaladd_or(signal,SIGNAL_SELL);
   return((ENUM_SIGNAL)signal);
}

int signal_both(bool cond)
{
   if (cond) return(SIGNAL_BOTH);
   else return(SIGNAL_NO);
}

int signal_cross(double fast1, double fast2, double slow1, double slow2)
{
   if (fast1 > slow1 && fast2 <= slow2)
      return(SIGNAL_BUY);
   if (fast1 < slow1 && fast2 >= slow2)
      return(SIGNAL_SELL);
   return(SIGNAL_NO);
}

int signal_abovebelow(double line1, double line2)
{
   if (line1 > line2)
      return(SIGNAL_BUY);
   if (line1 < line2)
      return(SIGNAL_SELL);
   return(SIGNAL_NO);
}

ENUM_SIGNAL signal_arrow(double buy, double sell)
{
   if (buy != EMPTY_VALUE && buy != 0 && (sell == EMPTY_VALUE || sell == 0))
      return(SIGNAL_BUY);
   if (sell != EMPTY_VALUE && sell != 0 && (buy == EMPTY_VALUE || buy == 0))
      return(SIGNAL_SELL);
   return((ENUM_SIGNAL)SIGNAL_NO);
}