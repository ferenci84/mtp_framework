//
#include "Loader.mqh"

#define SERVICE_CONTAINER_H
class CServiceContainer : public CArrayObject<CServiceProvider>
{
public:
   CServiceProvider* ServiceProvider(int i)
   {
      CObject* obj = At(i);
      if (CheckPointer(obj) != POINTER_INVALID)
         return (CServiceProvider*)obj;
      else
         return NULL;
   }
   
   int FindService(string name)
   {
      int count = Total();
      for (int i = 0; i < count; i++) {
         CServiceProvider* service = ServiceProvider(i);
         if (service.name == name) return i;
      }
      return -1;
   }
   
   int FindService(ENUM_APPLICATION_SERVICE srv)
   {
      int count = Total();
      for (int i = 0; i < count; i++) {
         CServiceProvider* service = ServiceProvider(i);
         if (service.srv == srv) return i;
      }
      Print(__FUNCTION__,": Cannot Find Service: ",EnumToString(srv));
      return -1;
   }
   
   CServiceProvider* GetService(string name)
   {
      int count = Total();
      for (int i = 0; i < count; i++) {
         CServiceProvider* service = ServiceProvider(i);
         if (service.name == name) return service;
      }
      return NULL;
   }
   
   CServiceProvider* GetService(ENUM_APPLICATION_SERVICE srv)
   {
      int count = Total();
      for (int i = 0; i < count; i++) {
         CServiceProvider* service = ServiceProvider(i);
         if (service.srv == srv) return service;
      }
      Print("not found: ",EnumToString(srv));
      return NULL;
   }
   
   bool IsRegistered(ENUM_APPLICATION_SERVICE srv)
   {
      if (srv == srvNone) return false;
      int count = Total();
      for (int i = 0; i < count; i++) {
         CServiceProvider* service = ServiceProvider(i);
         if (service.srv == srv) return true;
      }
      return false;
   }
   
   bool ReRegister(CServiceProvider* newservice)
   {
      if (newservice.srv == srvNone) return false;
      int count = Total();
      for (int i = 0; i < count; i++) {
         CServiceProvider* service = ServiceProvider(i);
         if (service.srv == newservice.srv) {
            //delete service;
            this.m_data[i].reset(newservice);
            return true;
         }
      }
      return false;
   }
   
   bool IsRegistered(string servicename)
   {
      int count = Total();
      for (int i = 0; i < count; i++) {
         CServiceProvider* service = ServiceProvider(i);
         if (service.name == servicename) return true;
      }
      return false;
   }
   
   void InitalizeServices()
   {
      int count = Total();
      for (int i = 0; i < count; i++) {
         CServiceProvider* service = ServiceProvider(i);
         if (!service.Initalized()) {
            Print("Initalizing Service ",EnumToString(service.srv)," '",service.name,"': ",EnumToString((ENUM_CLASS_NAMES)service.Type()));
            service.SetInitalized();
            service.Initalize();
            CObject* obj = NULL;
         } else {
            Print("Service Alread Initalized: ",EnumToString((ENUM_CLASS_NAMES)service.Type()));
         }
      }
   }
   
   void OnInit()
   {
      //int count = Total();
      for (int i = 0; i < Total(); i++) {
         CServiceProvider* service = ServiceProvider(i);
         if (service.use_oninit) service.OnInit();
      }
   }
   
   int OnCalculate (const int rates_total,      // size of input time series
                 const int prev_calculated,  // bars handled in previous call
   )
   {
      int ret = -1;
      for (int i = 0; i < Total(); i++) {
         CServiceProvider* service = ServiceProvider(i);
         if (service.use_oncalculate) {
            service.OnCalculate(rates_total,prev_calculated);
            if (ret >= 0) return ret;
         }
      }
      return 0;
   }
   
   void OnTick()
   {
      //int count = Total();
      for (int i = 0; i < Total(); i++) {
         CServiceProvider* service = ServiceProvider(i);
         if (service.use_ontick) {
            service.OnTick();
         }
      }
   }
   
   void OnDeinit()
   {
      //int count = Total();
      for (int i = 0; i < Total(); i++) {
         CServiceProvider* service = ServiceProvider(i);
         if (service.use_ondeinit) service.OnDeinit();
      }
   }
   
   void OnDeinit(const int reason)
   {
      //int count = Total();
      for (int i = 0; i < Total(); i++) {
         CServiceProvider* service = ServiceProvider(i);
         if (service.use_ondeinit) service.OnDeinit(reason);
      }
   }
   
   void OnChartEvent(int id, long lparam, double dparam, string sparam)
   {
      //int count = Total();
      for (int i = 0; i < Total(); i++) {
         CServiceProvider* service = ServiceProvider(i);
         if (service.use_onchartevent) service.OnChartEvent(id, lparam, dparam, sparam);
      }
   }
   
   void OnTimer()
   {
      //int count = Total();
      for (int i = 0; i < Total(); i++) {
         CServiceProvider* service = ServiceProvider(i);
         if (service.use_ontimer) service.OnTimer();
      }
   }
};