//* Copyright notice: This software and it's parts including any included files, except the anything from the "lib" directory is made by and is property of Dynamic Programming Solutions Corporation,
//* while the strategy elements used in it is property of the customer. Any parts can be reused in later software which doesn't violate our Non-Disclosure Agreement.
//* 
//* Non-Disclosure Agreement:
//* We pledge to hold your trading system in confidence.
//* We will not resell your expert advisor that contains your trading ideas, nor will we publish your system specifications.
//* Receipt of your system specifications or other intellectual property by us will effectively constitute a Non-Disclosure Agreement.
//* We have no obligation with respect to such information where the information:
//* 1) was known to us prior to receiving any of the Confidential Information from the customer;
//* 2) has become publicly known through no wrongful act of Recipient;
//* 3) was received by us without breach of this Agreement from a third party without restriction as to the use and disclosure of the information;
//* 4) was independently developed by us without use of the Confidential Information 
//* 
//* The customer has the following rights:
//* 1) Use the software in any instances for personal matters
//* 2) Learn the code and change it
//* 3) Ask any other programmer to make changes, under Non-Disclosure Agreement on the usage of the source code.
//* 4) Resell this EA with possibility to provide the source code under Non-Disclosure Agreement.
//* 5) Make this sofwtare available on website as a free downloadable product WITHOUT providing the source code (i.e. only the ex4 file is downloadable)

#property copyright "Dynamic Programming Solutions Corp."
#property link      "http://www.metatraderprogrammer.com"

#define CUSTOM_SERVICES srvMain,
#define CUSTOM_CLASSES classSignalManager, classEntryMethod, classOrderCommandHandler, classMain,

#include <mtp_framework_1.2\Loader.mqh>
#include <mtp_framework_1.2\DefaultServices.mqh>   

input double lotsize = 0.1;

input double stoploss = 20;
input double takeprofit = 40;

/*
#define TRAILINGSTOP
input double breakevenat = 0;
input double breakeven_profit = 0;
input double trailingstop_activate = 0;
input double trailingstop = 0;
input double trailingstop_step = 1;
*/

input int _bar = 1;
input ENUM_TIMEFRAMES timeframe = 0;

input bool reverse_strategy = false;
input bool trade_only_at_barclose = true;
input bool trade_only_signal_change = true;

input bool long_enabled = true;
input bool short_enabled = true;
input bool close_opposite_order = false;
input int maxorders = 1;

#ifdef __MQL4__
input bool sl_virtual = false;
input bool tp_virtual = false;
input bool vstops_draw_line = false;
input bool realstops_draw_line = false;
input bool orderbymarket = false;
input color cl_buy = Blue;
input color cl_sell = Red;
#endif

input int _magic = 1234;
input int slippage = 3;

input bool printcomment = false;

ulong benchmark_sum;
ulong benchmark_cnt;

class CSignal1 : public COpenSignal { public:
   double val1;
   double val2;
   virtual void CalculateValues() {
      val1 = iClose(symbol,timeframe,bar);
      val2 = iOpen(symbol,timeframe,bar);
   }
   virtual bool BuyCondition() { return (val1 > val2); }
   virtual bool SellCondition() { return (val1 < val2); }
   virtual void OnTick() {
      if (comments_enabled) addcomment("Signal: "+signaltext(this.signal)+"\n");
   }
};

class CClosesignal1 : public CCloseSignal { public:
   double val1;
   double val2;
   virtual void CalculateValues() {
      val1 = iClose(symbol,timeframe,bar);
      val2 = iOpen(symbol,timeframe,bar);
   }
   virtual bool CloseSellCondition() { return (val1 > val2); }
   virtual bool CloseBuyCondition() { return (val1 < val2); }
   virtual void OnTick() {
      if (comments_enabled) addcomment("Signal Close: "+signaltext_close(this.closesignal)+"\n");
   }
};

/* INLINE SIGNAL
class CMainSignal : public COpenAndCloseSignal
{
   CIsFirstTick* isfirsttick;
   CMainSignal()
   {
      isfirsttick = new CIsFirstTick(symbol,timeframe);
   }
   OpenSignal()
   {
      
   }
   CloseSignal()
   {
      
   }
   virtual bool BeforeFilter() {
      if (trade_only_at_barclose && !isfirsttick.isfirsttick()) return false;
      return true;
   }
   
   virtual bool AfterFilter() {
      if (reverse_strategy) Reverse();
      if (trade_only_signal_change && (lastsignal == SIGNAL_NONE || signal == lastsignal)) return false;
      return true;
   }
   
   virtual void OnTick() {
      CSignalContainer::OnTick();
      if (comments_enabled) addcomment("signal: "+signaltext(signal)+" valid:"+(string)valid+"\n");   
   }   
}
*/

class CMainSignal : public CSignalContainer
{
public:
   CIsFirstTick* isfirsttick;
   
   CMainSignal()
   {
      isfirsttick = new CIsFirstTick(symbol,timeframe);
      if (true) Add(new CSignal1());      
      if (true) Add(new CClosesignal1());
   }
   
   virtual bool BeforeFilter() {
      if (trade_only_at_barclose && !isfirsttick.isfirsttick()) return false;
      return true;
   }
   
   virtual bool AfterFilter() {
      if (reverse_strategy) Reverse();
      if (trade_only_signal_change && (lastsignal == SIGNAL_NONE || signal == lastsignal)) return false;
      return true;
   }
   
   virtual void OnTick() {
      CSignalContainer::OnTick();
      if (comments_enabled) addcomment("signal: "+signaltext(signal)+" valid:"+(string)valid+"\n");   
   }   
};

class CSignalManager : public CSignalManagerBase
{
public:
   virtual int Type() const { return classSignalManager; }   
   virtual void OnInit()
   {
      bar = _bar;
      mainsignal = new CMainSignal();      
   }
   virtual void OnDeinit()
   {
      delete mainsignal;
   }
   
};

class CEntryMethod : public CEntryMethodBase
{
public:
   virtual int Type() const { return classEntryMethod; }

   virtual bool BuySignalFilter(bool valid)
   {
      if (!short_enabled) return false;
      if (ordermanager.CntOrders(ORDERSELECT_ANY,STATESELECT_FILLED) >= maxorders) return false;
      return valid;
   }
   
   virtual bool SellSignalFilter(bool valid)
   {
      if (!long_enabled) return false;
      if (ordermanager.CntOrders(ORDERSELECT_ANY,STATESELECT_FILLED) >= maxorders) return false;
      return valid;
   }
   virtual bool CloseOpposite()
   {
      return close_opposite_order;
   }
};

class COrderCommandHandler : public COrderCommandHandlerBase
{
public:
   CStopLoss* sl;
   CTakeProfit* tp;
   CMoneyManagement* mm;

   virtual void Initalize()
   {
      COrderCommandHandlerBase::Initalize();
   }
   
   virtual void OnInit()
   {
      mm = new CMoneyManagementFixed(lotsize);
      sl = new CStopLossTicks(convertfract(stoploss));
      tp = new CTakeProfitTicks(convertfract(takeprofit));
   }

   virtual int Type() const { return classOrderCommandHandler; }
   
   virtual void CloseAll()
   {
      ordermanager.CloseAll(ORDERSELECT_ANY,STATESELECT_FILLED);
   }

   virtual void CloseBuy()
   {
      ordermanager.CloseAll(ORDERSELECT_LONG,STATESELECT_FILLED);
   }
   
   virtual void CloseSell()
   {
      ordermanager.CloseAll(ORDERSELECT_SHORT,STATESELECT_FILLED);
   }
   
   virtual void OpenBuy()
   {
      ordermanager.NewOrder(symbol,ORDER_TYPE_BUY,mm,NULL,sl,tp);
   }
   
   virtual void OpenSell()
   {
      ordermanager.NewOrder(symbol,ORDER_TYPE_SELL,mm,NULL,sl,tp);      
   }
};

#ifdef TRAILINGSTOP
class CTrailingStopManager : public CServiceProvider
{
public:
   CTrailingStop TrailingStop;

   virtual void Initalize()
   {
      this.Prepare(GetPointer(TrailingStop));
   }

   virtual void OnTick()
   {
      TrailingStop.OnAll();
   }
   
   virtual void OnInit()
   {
      TrailingStop.lockin = convertfract(breakevenat);
      TrailingStop.lockinprofit = convertfract(breakeven_profit);
      TrailingStop.activate = convertfract(trailingstop_activate);
      TrailingStop.trailingstop = convertfract(trailingstop);
      TrailingStop.step = convertfract(trailingstop_step);
   }
};
#endif

class CExpiration : public CServiceProvider
{
public:
   TraitAppAccess
   
   virtual void OnTick()
   {
      if (IsExpired()) {
         addcomment("EA Expired\n");
         if (this.App().ServiceIsRegistered(srvSignalManager)) application.DeregisterService(srvSignalManager);
         if (this.App().ServiceIsRegistered(srvScriptManager)) application.DeregisterService(srvScriptManager);
         ((COrderManager*)this.App().ordermanager).CloseAll(ORDERSELECT_ANY);
      }
   }
   
   bool IsExpired()
   {
      return (TimeCurrent() > StrToTime("2015.05.27"));
   }
};

class CChartComment : public CServiceProvider
{
public:
   TraitAppAccess
   
   virtual void OnTick()
   {
      if (comments_enabled) {
         writecomment_noformat();
         if (printcomment) printcomment();
         delcomment();
      }
   }
   
   virtual void OnInit()
   {
      if (IsTesting() && !IsVisualMode() && !printcomment) {    
         comments_enabled = false;
      }    
   }
};

class CMain : public CServiceProvider
{
public:
   virtual int Type() const { return classMain; }
   
   TraitAppAccess

   virtual void OnInit()
   {
      // TRADE
      if (COrderBase::trade_default == NULL) COrderBase::trade_default = new CTrade();
      if (IsTesting() && !IsVisualMode()) COrderBase::trade_default.LogLevel(LOG_LEVEL_ERRORS);
      else COrderBase::trade_default.LogLevel(LOG_LEVEL_ALL);
      COrderBase::trade_default.SetDeviationInPoints(slippage);
         
      #ifdef __MQL4__
   
         COrderBase::trade_default.SetColors(cl_buy, cl_sell);
         COrderBase::trade_default.SetIsEcn(orderbymarket);      
      
         // ORDER
         COrderBase::magic_default = _magic;
         COrder::sl_virtual_default = sl_virtual;
         COrder::tp_virtual_default = tp_virtual;
         COrder::vstops_draw_line = vstops_draw_line;
         COrder::realstops_draw_line = realstops_draw_line;   
      
      #endif   

      if (IsTesting() && !IsVisualMode()) {      
         application.eventhandler.SetLogLevel(E_ERROR);
      } else {
         application.eventhandler.SetLogLevel(E_NOTICE|E_WARNING|E_ERROR|E_INFO);
      }
      
      ((COrderManager*)(application.ordermanager)).retrainhistory = 1;

      #ifdef __MQL4__
         ((COrderManager*)(application.ordermanager)).LoadOpenOrders(Symbol(),_magic);
      #endif
            
   }
   
   virtual void OnDeinit()
   {
      if (benchmark_cnt > 0) Print("benchmark ("+(string)benchmark_cnt+"): "+(string)(benchmark_sum/(benchmark_cnt*1.0)));
   }
};

CApplication application;

void OnTick()
{
   application.OnTick();  
}


int OnInit()
{

   if (!application.Initalized()) {
   
      register_services();
   
      application.RegisterService(new CExpiration(),srvNone,"expiration");
      application.RegisterService(new CSignalManager(),srvSignalManager,"signalmanager");
      application.RegisterService(new CEntryMethod(),srvEntryMethod,"entrymethod");
      #ifdef TRAILINGSTOP
         application.RegisterService(new CTrailingStopManager(),srvNone,"trailingstopmanager");
      #endif
      application.RegisterService(new CMain(),srvMain,"main");
      application.RegisterService(new COrderDataSaver(), srvNone, "orderdatasaver");
      application.RegisterService(new CScriptManagerBase(),srvScriptManager,"scriptmanager");
      application.RegisterService(new COrderCommandHandler(),srvOrderCommandHandler,"ordercommandhandler");
      application.RegisterService(new COrderScriptHandler(),srvNone,"orderscripthandler");
      
      application.RegisterService(new CChartComment(),srvNone,"chartcomment");

      application.Initalize();

   }

   application.OnInit();
   
   return(0);
}

void OnDeinit(const int reason)
{
   application.OnDeinit();
}

void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
   application.OnChartEvent(id, lparam, dparam, sparam);
}