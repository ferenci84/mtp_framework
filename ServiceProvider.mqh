//
class CServiceProvider : public CAppObject
{
public:
   string name;
   ENUM_APPLICATION_SERVICE srv;
   
   bool use_oninit;
   bool use_ontick;
   bool use_ondeinit;
   bool use_ondeinit_reason;
   bool use_onchartevent;
   bool use_ontimer;
   
   CServiceProvider()
   {
      use_oninit = true;
      use_ontick = true;
      use_ondeinit = true;
      use_ondeinit_reason = true;
      use_onchartevent = true;
      use_ontimer = true;
   }
   
   virtual void OnInit() {
      use_oninit = false;
      //Print("Disable OnInit on class ",EnumToString((ENUM_CLASS_NAMES)Type()));
   }
   
   virtual void OnTick() {
      use_ontick = false;
      //Print("Disable OnTick on class ",EnumToString((ENUM_CLASS_NAMES)Type()));     
   }
   
   virtual void OnDeinit() {
      use_ondeinit = false;
      //Print("Disable OnDeinit on class ",EnumToString((ENUM_CLASS_NAMES)Type()));     
   }

   virtual void OnDeinit(const int reason) {
      use_ondeinit_reason = false;
      //Print("Disable OnDeinit on class ",EnumToString((ENUM_CLASS_NAMES)Type()));     
   }
   
   virtual void OnChartEvent(int id, long lparam, double dparam, string sparam) {
      use_onchartevent = false;
      //Print("Disable OnChartEvent on class ",EnumToString((ENUM_CLASS_NAMES)Type()));     
   }
   
   virtual void OnTimer() {
      use_ontimer = false;
      //Print("Disable OnDeinit on class ",EnumToString((ENUM_CLASS_NAMES)Type()));     
   }
   
};