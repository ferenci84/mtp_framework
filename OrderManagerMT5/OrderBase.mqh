//
class COrderBase : public COrderBaseBase
{
public:
   virtual int Type() const { return classMT5OrderBase; }
protected:
   CEventHandlerBase* event;
   CApplication* app() { return (CApplication*)app; }
   CSymbolInfoBase* _symbol;
   void loadsymbol(string __symbol)
   {
      _symbol = app().symbolloader.LoadSymbol(__symbol);
   }

public:
   static ushort activity; //not implemented
  
   static CTrade* trade_default;
   
   static int magic_default; //not implemented
   
   static bool delete_stoploss_objects;
   static bool delete_takeprofit_objects;
   static bool delete_entry_objects;
   static bool delete_mm_objects;

   //static bool lotround_execute;
   
   static int maxid;

   static bool waitforexecute;
   static int waitforexecute_max;
   static int waitforexecute_sleep;
   
   CTrade* trade;

   ENUM_EXECUTE_STATE executestate;

   ENUM_ORDER_STATE state;

public:
   ulong ticket;
   string symbol;
   
   ENUM_ORDER_TYPE ordertype;
   double volume;
   double price;
   datetime expiration;

public:
   int id;
   string comment;
   int magic; // magic is not sent to server, if "restore orders from server" is developed, it will be needed

   bool selectedishistory;
   COrderInfoBase *orderinfo;
   COrderInfoV *orderinfov;
   CHistoryOrderInfoV *historyorderinfov;
   
   uint retcode;
   datetime executetime;   
   datetime filltime;

   bool price_set;
   bool expiration_set;
   bool typetime_set;

   double openprice;
   double limit_price;
   ENUM_ORDER_TYPE_TIME type_time;   

public:
   
   COrderBase() {
      this.id = maxid+1;
      maxid = this.id;     

      if (trade_default == NULL) trade_default = new CTrade();

      trade = trade_default;
      
      ticket = -1;
      executestate = ES_NOT_EXECUTED;
      state = NULL;

      magic = magic_default;

  };
  
   ~COrderBase() {
     delete this.orderinfo;
     delete this.orderinfov;
     delete this.historyorderinfov;
   };
   
   virtual void Initalize()
   {
      event = ((CApplication*)AppBase()).event;   
   }
   
   bool Isset() { return(executestate != ES_NOT_EXECUTED); }
      
   COrderInfoBase* GetOrderInfo();
   bool GetOrderInfo(COrderInfoBase *_orderinfo);
   bool GetOrderInfoB();
   bool CheckOrderInfo() { if (CheckPointer(orderinfo) == POINTER_INVALID) return(false); else return(true); }   

   bool Execute();
   bool WaitForExecute();
   bool Cancel();
   
   virtual bool Modify();
   bool Modify(double m_price, ENUM_ORDER_TYPE_TIME m_type_time, datetime m_expiration);
   bool ModifyPrice(double m_price);
   virtual bool Update();
   virtual void OnTick();

   ulong GetTicket() { return(this.ticket); }
   int GetMagicNumber() { return(this.magic); }
   string GetSymbol() { return(this.symbol); }
   string GetComment() { return(this.comment); }
      
   bool Select() { if (this.executestate == ES_EXECUTED) return(GetOrderInfoB()); else return(false); } 
   
   ENUM_ORDER_STATE State();
   //void State(ENUM_ORDER_STATE newstate);
   
   double Price();
   double CurrentPrice();
   datetime GetOpenTime() { return(MathMax(this.executetime,this.filltime)); }
   double GetOpenPrice() { return(this.price); }
   
   void SetOrderType(const ENUM_ORDER_TYPE value) { if (executestate == ES_NOT_EXECUTED) ordertype=value; else Print("Cannot change executed order data (ordertype)"); }
   void SetMagic(const int value) { if (executestate == ES_NOT_EXECUTED) magic=value; else Print("Cannot change executed order data (magic)"); }
   void SetSymbol(const string value) { if (executestate == ES_NOT_EXECUTED) symbol=value; else Print("Cannot change executed order data (symbol)"); }
   void SetComment(const string value) { if (executestate == ES_NOT_EXECUTED) comment=value; else Print("Cannot change executed order data (comment)"); }
   void SetLots(const double value) { if (executestate == ES_NOT_EXECUTED) volume=value; else Print("Cannot change executed order data (lots)"); }
   
   void SetExpiration(const datetime value) { expiration_set = true; if (executestate != ES_CANCELED) expiration = value; else Print("Cannot change canceled order data (expiration)"); }
   void SetPrice(const double value) { price_set = true; if (executestate != ES_CANCELED) price = value; else Print("Cannot change canceled order data (price)"); }
   void SetTypeTime(const ENUM_ORDER_TYPE_TIME value) { typetime_set = true; if (executestate != ES_CANCELED) type_time = value; else Print("Cannot change canceled order data (typetime)"); }
   
   static void DeleteIf(CStopLoss* obj) { if (delete_stoploss_objects) delete obj; }
   static void DeleteIf(CTakeProfit* obj) { if (delete_takeprofit_objects) delete obj; }
   static void DeleteIf(CEntry* obj) { if (delete_entry_objects) delete obj; }
   static void DeleteIf(CMoneyManagement* obj) { if (delete_mm_objects) delete obj; }

};

CTrade* COrderBase::trade_default = NULL;

ushort COrderBase::activity = ACTIVITY_NOTHING;
int COrderBase::magic_default = 0;
int COrderBase::maxid = 0;

bool COrderBase::delete_stoploss_objects = true;
bool COrderBase::delete_takeprofit_objects = true;
bool COrderBase::delete_entry_objects = true;
bool COrderBase::delete_mm_objects = false;

bool COrderBase::waitforexecute = true;
int COrderBase::waitforexecute_max = 600;
int COrderBase::waitforexecute_sleep = 100;



// ***********************************************
// |--------------- COrderBase ------------------|
// ***********************************************



ENUM_ORDER_STATE COrderBase::State()
{
   if (this.executestate == ES_EXECUTED && state_undone(this.state)) {
      ENUM_ORDER_STATE oldstate = state;            
      this.state = CheckOrderInfo()?this.orderinfo.State():(ENUM_ORDER_STATE)-1;
      if (oldstate != state) {
         activity = activity | (ushort)ACTIVITY_STATECHANGE;
      }
   }
   return(this.state);
}

/*void COrderBase::State(ENUM_ORDER_STATE newstate)
{
   this.state = newstate;
}*/

double COrderBase::Price()
{      
   if (this.executestate == ES_EXECUTED) {
      double _price = 0;
      if (CheckOrderInfo()) {
         _price = this.orderinfo.PriceOpen();
      }
      return(_price);
   } else {
      return(this.price);
   }
}

double COrderBase::CurrentPrice()
{
   if (!state_filled(this.state)) return(0);
   loadsymbol(symbol);
   if (ordertype_long(this.ordertype)) return(_symbol.Bid());
   if (ordertype_short(this.ordertype)) return(_symbol.Ask());
   return(0);
}

COrderInfoBase* COrderBase::GetOrderInfo()
{
   if (!isset(this.orderinfov)) this.orderinfov = new COrderInfoV();
   if (this.orderinfov.Select(ticket)) {
      selectedishistory = false;
      orderinfo = (COrderInfoBase*)(this.orderinfov);
      return(orderinfo);
   }

   if (!isset(this.historyorderinfov)) this.historyorderinfov = new CHistoryOrderInfoV();
   if (this.historyorderinfov.Ticket(ticket)) {         
      selectedishistory = true;
      orderinfo = (COrderInfoBase*)(this.historyorderinfov);
      return(orderinfo);
   }
   this.orderinfo = NULL;
   return(NULL);
}

bool COrderBase::GetOrderInfo(COrderInfoBase *_orderinfo)
{
   _orderinfo = GetOrderInfo();
   return(orderinfo != NULL);
}

bool COrderBase::GetOrderInfoB()
{
   GetOrderInfo();
   //if (event.Verbose ()) event.Verbose ("orderinfo != NULL:"+(orderinfo != NULL),__FUNCTION__);
   return(orderinfo != NULL);
}


bool COrderBase::Execute()
{
   activity = activity | (ushort)ACTIVITY_EXECUTE;
   //if (event.Info ()) event.Info ("Execute order "+(string)this.id+" type="+(string)ordertype,__FUNCTION__);
   //CTrade trade;
   CHistoryOrderInfo historyorder;
   if (executestate == ES_NOT_EXECUTED) {
      bool success;
      if (ordertype_market(ordertype)) {
         if (price == 0) {
            loadsymbol(symbol);
            if (ordertype == ORDER_TYPE_SELL) { price = _symbol.Bid(); }
            else if (ordertype == ORDER_TYPE_BUY) { price = _symbol.Ask(); }
         }
         success = trade.PositionOpen(symbol,ordertype,volume,price,0,0,comment);
      } else if (ordertype_pending(ordertype)) {
         if (price > 0) {
            success = trade.OrderOpen(symbol,ordertype,volume,limit_price,price,0,0,type_time,expiration,comment);
         } else {
            if (event.Warning ()) event.Warning ("No Price",__FUNCTION__);
         }
      }
      if (success) {
         if (trade.ResultOrder() > 0) {
            ticket = trade.ResultOrder();
            this.retcode = trade.ResultRetcode();
            if (event.Info ()) event.Info ("Order "+(string)this.id+" Executed. Ticket:"+(string)ticket,__FUNCTION__);
            executestate = ES_EXECUTED;   
            Update();
            return(true);
         } else {
            retcode = trade.ResultRetcode();
            if (event.Warning ()) event.Warning ("No Ticket in trade result retcode: "+(string)trade.ResultRetcode(),__FUNCTION__);
         } 
      } else {
         retcode = trade.ResultRetcode();
         if (event.Warning ()) event.Warning ("Order "+(string)this.id+" Open Failed - ordertype:"+(string)ordertype+", volume:"+(string)volume+", price:"+(string)price,__FUNCTION__);         
      }
      
   } else {
      if (executestate == ES_CANCELED) {
         if (event.Info ()) event.Info ("Order "+(string)this.id+" Already Canceled");
      } else if (executestate == ES_EXECUTED) {
         if (event.Info ()) event.Info ("Order "+(string)this.id+" Already Executed");
      }
   }
   return(false);
}

bool COrderBase::WaitForExecute()
{
   if (executestate == ES_EXECUTED && ordertype_market(this.ordertype)) {
      for (int i = 0; i < waitforexecute_max; i++) {
         this.State();
         if (event.Info ()) event.Info ("Waiting for execute: "+(string)this.id,__FUNCTION__);
         if (state_filled(state)) return(true);
         if (state_canceled(state)) return(false);
         Sleep(waitforexecute_sleep);
      }
      return(false);
   } else {
      return(false);
   }
}

bool COrderBase::Cancel()
{
   activity = activity | (ushort)ACTIVITY_DELETE;      
   if (event.Verbose ()) event.Verbose ("Cancel ticket="+(string)ticket,__FUNCTION__);
   //CTrade trade;
   if (executestate == ES_EXECUTED) {
      if (state <= ORDER_STATE_PLACED) {
         if (trade.OrderDelete(ticket)) {
            Update();
         } else {
            if (event.Warning ()) event.Warning ("Order Delete Failed",__FUNCTION__);
         }
      } else if (state == ORDER_STATE_CANCELED || state == ORDER_STATE_REJECTED || state == ORDER_STATE_EXPIRED) {
         if (event.Info ()) event.Info ("Order Already Canceled, state:"+(string)state,__FUNCTION__);
      } else if (state == ORDER_STATE_PARTIAL || state == ORDER_STATE_FILLED) {
         if (event.Info ()) event.Info ("Order Already Filled, state:"+(string)state,__FUNCTION__);
      } else {
         if (event.Info ()) event.Info ("Invalid Order State",__FUNCTION__);
      }
   } else if (executestate == ES_NOT_EXECUTED) {
      executestate = ES_CANCELED;
      if (event.Info ()) event.Info ("Order Not Yet Executed, Execution Canceled",__FUNCTION__);
   } else if (executestate == ES_CANCELED) {
      if (event.Info ()) event.Info ("Order Not Executed, Execution Already Canceled",__FUNCTION__);
   } else {
      if (event.Error ()) event.Error ("Invalid Execute State",__FUNCTION__);
      return(false);
   }
   return(true);
}

bool COrderBase::Modify()
{
   activity = activity | (ushort)ACTIVITY_MODIFY;
   if (Select()) {
      loadsymbol(this.symbol);
      if (!price_set) price = this.Price();
      else price = _symbol.PriceRound(price);
      if (!expiration_set) expiration = orderinfo.TimeExpiration();
      if (!typetime_set) type_time = orderinfo.TypeTime();
      if ((price_set && price != this.Price()) || (expiration_set && expiration != orderinfo.TimeExpiration()) || (typetime_set && type_time != orderinfo.TypeTime())) {
         price_set = false;
         expiration_set = false;
         typetime_set = false;
         if (trade.OrderModify(ticket,price,0,0,type_time,expiration)) {
            Update();
            return(true);
         } else return(false);
      } else {
         price_set = false;
         expiration_set = false;
         typetime_set = false;
         return false;
      }
   } 
   return false;
}

bool COrderBase::Modify(double m_price, ENUM_ORDER_TYPE_TIME m_type_time, datetime m_expiration)
{
   SetPrice(m_price);
   SetExpiration(m_expiration);
   SetTypeTime(m_type_time);
   return(Modify());
}

bool COrderBase::ModifyPrice(double m_price)
{
   return(Modify(m_price,type_time,expiration));      
}      

bool COrderBase::Update()
{
   if (executestate == ES_EXECUTED) {      
      if (GetOrderInfoB()) {      
         //if (event.Verbose ()) event.Verbose ("order info got: ticket:"+this.ticket,__FUNCTION__);
         this.State();
         //this.state = this.orderinfo.State();
         if (executetime == 0 && state != ORDER_STATE_STARTED && state != ORDER_STATE_REJECTED) executetime = orderinfo.TimeSetup();
         if (filltime == 0 && state == ORDER_STATE_FILLED) {
            filltime = orderinfo.TimeDone();                          
         }
         return(true);
      } else {
         if (event.Verbose ()) event.Verbose ("Failed to get OrderInfo ticket:"+(string)this.ticket,__FUNCTION__);
         return(false);
      }
   } else if (executestate == ES_NOT_EXECUTED) {
      if (event.Info ()) event.Info ("Execute order",__FUNCTION__);
      if (Execute()) {
         return(true);
      } else {
         if (event.Warning ()) event.Warning ("Failed to execute order",__FUNCTION__);
         // ToDo: Add Counter to retry
         executestate = ES_CANCELED;
         return(false);
      }
   } else {
      return(false);
   }
}

void COrderBase::OnTick()
{
   this.Update();
}

