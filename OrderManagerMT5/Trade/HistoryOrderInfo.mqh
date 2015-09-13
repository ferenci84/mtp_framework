//
#include "..\Loader.mqh"

class CHistoryOrderInfo : public CObject
  {
protected:
   ulong             m_ticket;             // ticket of history order
public:
   //--- methods of access to protected data
   bool              Ticket(ulong ticket) {
      if (HistoryOrderSelect(ticket))
      {
         m_ticket=ticket;
         return(true);
      } else {
         return(false);
      }
   }
   ulong             Ticket() const       { return(m_ticket); }
   //--- fast access methods to the integer order propertyes
   datetime          TimeSetup() const;
   ENUM_ORDER_TYPE   OrderType() const;
   string            TypeDescription() const;
   ENUM_ORDER_STATE  State() const;
   string            StateDescription() const;
   datetime          TimeExpiration() const;
   datetime          TimeDone() const;
   ENUM_ORDER_TYPE_FILLING TypeFilling() const;
   string                  TypeFillingDescription() const;
   ENUM_ORDER_TYPE_TIME    TypeTime() const;
   string                  TypeTimeDescription() const;
   long              Magic() const;
   long              PositionId() const;
   //--- fast access methods to the double order propertyes
   double            VolumeInitial() const;
   double            VolumeCurrent() const;
   double            PriceOpen() const;
   double            StopLoss() const;
   double            TakeProfit() const;
   double            PriceCurrent() const;
   double            PriceStopLimit() const;
   //--- fast access methods to the string order propertyes
   string            Symbol() const;
   string            Comment() const;
   //--- access methods to the API MQL5 functions
   bool              InfoInteger(ENUM_ORDER_PROPERTY_INTEGER prop_id,long& var) const;
   bool              InfoDouble(ENUM_ORDER_PROPERTY_DOUBLE prop_id,double& var) const;
   bool              InfoString(ENUM_ORDER_PROPERTY_STRING prop_id,string& var) const;
   //--- info methods
   string            FormatType(string& str,const uint type)                    const;
   string            FormatStatus(string& str,const uint status)                const;
   string            FormatTypeFilling(string& str,const uint type)             const;
   string            FormatTypeTime(string& str,const uint type)                const;
   string            FormatOrder(string& str)                                   const;
   string            FormatPrice(string& str,const double price_order,const double price_trigger,const uint __digits) const;
   //--- method for select history order
   bool              SelectByIndex(int index);
  };
//+------------------------------------------------------------------+
//| Get the property value "ORDER_TIME_SETUP".                       |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_TIME_SETUP".                   |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
datetime CHistoryOrderInfo::TimeSetup() const
  {
   return((datetime)HistoryOrderGetInteger(m_ticket,ORDER_TIME_SETUP));
  }
//+------------------------------------------------------------------+
//| Get the property value "ORDER_TYPE".                             |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_TYPE".                         |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE CHistoryOrderInfo::OrderType() const
  {
   return((ENUM_ORDER_TYPE)HistoryOrderGetInteger(m_ticket,ORDER_TYPE));
  }
//+------------------------------------------------------------------+
//| Get the property value "ORDER_TYPE" as string.                   |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_TYPE" as string.               |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
string CHistoryOrderInfo::TypeDescription() const
  {
   string str;
//---
   return(FormatType(str,OrderType()));
  }
//+------------------------------------------------------------------+
//| Get the property value "ORDER_STATE".                            |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_STATE".                        |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
ENUM_ORDER_STATE CHistoryOrderInfo::State() const
  {
   return((ENUM_ORDER_STATE)HistoryOrderGetInteger(m_ticket,ORDER_STATE));
  }
//+------------------------------------------------------------------+
//| Get the property value "ORDER_STATE" as string.                  |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_STATE" as string.              |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
string CHistoryOrderInfo::StateDescription() const
  {
   string str;
//---
   return(FormatStatus(str,State()));
  }
//+------------------------------------------------------------------+
//| Get the property value "ORDER_TIME_EXPIRATION".                  |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_TIME_EXPIRATION".              |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
datetime CHistoryOrderInfo::TimeExpiration() const
  {
   return((datetime)HistoryOrderGetInteger(m_ticket,ORDER_TIME_EXPIRATION));
  }
//+------------------------------------------------------------------+
//| Get the property value "ORDER_TIME_DONE".                        |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_TIME_DONE".                    |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
datetime CHistoryOrderInfo::TimeDone() const
  {
   return((datetime)HistoryOrderGetInteger(m_ticket,ORDER_TIME_DONE));
  }
//+------------------------------------------------------------------+
//| Get the property value "ORDER_TYPE_FILLING".                     |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_TYPE_FILLING".                 |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE_FILLING CHistoryOrderInfo::TypeFilling() const
  {
   return((ENUM_ORDER_TYPE_FILLING)HistoryOrderGetInteger(m_ticket,ORDER_TYPE_FILLING));
  }
//+------------------------------------------------------------------+
//| Get the property value "ORDER_TYPE_FILLING" as string.           |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_TYPE_FILLING" as string.       |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
string CHistoryOrderInfo::TypeFillingDescription() const
  {
   string str;
//---
   return(FormatTypeFilling(str,TypeFilling()));
  }
//+------------------------------------------------------------------+
//| Get the property value "ORDER_TYPE_TIME".                        |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_TYPE_TIME".                    |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE_TIME CHistoryOrderInfo::TypeTime() const
  {
   return((ENUM_ORDER_TYPE_TIME)HistoryOrderGetInteger(m_ticket,ORDER_TYPE_TIME));
  }
//+------------------------------------------------------------------+
//| Get the property value "ORDER_TYPE_TIME" as string.              |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_TYPE_TIME" as string.          |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
string CHistoryOrderInfo::TypeTimeDescription() const
  {
   string str;
//---
   return(FormatTypeTime(str,TypeTime()));
  }
//+------------------------------------------------------------------+
//| Get the property value "ORDER_EXPERT".                           |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_EXPERT".                       |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
long CHistoryOrderInfo::Magic() const
  {
   return(HistoryOrderGetInteger(m_ticket,ORDER_MAGIC));
  }
//+------------------------------------------------------------------+
//| Get the property value "ORDER_POSITION_ID".                      |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_POSITION_ID".                  |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
long CHistoryOrderInfo::PositionId() const
  {
   return(HistoryOrderGetInteger(m_ticket,ORDER_POSITION_ID));
  }
//+------------------------------------------------------------------+
//| Get the property value "ORDER_VOLUME_INITIAL".                   |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_VOLUME_INITIAL".               |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
double CHistoryOrderInfo::VolumeInitial() const
  {
   return(HistoryOrderGetDouble(m_ticket,ORDER_VOLUME_INITIAL));
  }
//+------------------------------------------------------------------+
//| Get the property value "ORDER_VOLUME_CURRENT".                   |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_VOLUME_CURRENT".               |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
double CHistoryOrderInfo::VolumeCurrent() const
  {
   return(HistoryOrderGetDouble(m_ticket,ORDER_VOLUME_CURRENT));
  }
//+------------------------------------------------------------------+
//| Get the property value "ORDER_PRICE_OPEN".                       |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_PRICE_OPEN".                   |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
double CHistoryOrderInfo::PriceOpen() const
  {
   return(HistoryOrderGetDouble(m_ticket,ORDER_PRICE_OPEN));
  }
//+------------------------------------------------------------------+
//| Get the property value "ORDER_SL".                               |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_SL".                           |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
double CHistoryOrderInfo::StopLoss() const
  {
   return(HistoryOrderGetDouble(m_ticket,ORDER_SL));
  }
//+------------------------------------------------------------------+
//| Get the property value "ORDER_TP".                               |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_TP".                           |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
double CHistoryOrderInfo::TakeProfit() const
  {
   return(HistoryOrderGetDouble(m_ticket,ORDER_TP));
  }
//+------------------------------------------------------------------+
//| Get the property value "ORDER_PRICE_CURRENT".                    |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_PRICE_CURRENT".                |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
double CHistoryOrderInfo::PriceCurrent() const
  {
   return(HistoryOrderGetDouble(m_ticket,ORDER_PRICE_CURRENT));
  }
//+------------------------------------------------------------------+
//| Get the property value "ORDER_PRICE_STOPLIMIT".                  |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_PRICE_STOPLIMIT".              |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
double CHistoryOrderInfo::PriceStopLimit() const
  {
   return(HistoryOrderGetDouble(m_ticket,ORDER_PRICE_STOPLIMIT));
  }
//+------------------------------------------------------------------+
//| Get the property value "ORDER_SYMBOL".                           |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_SYMBOL".                       |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
string CHistoryOrderInfo::Symbol() const
  {
   return(HistoryOrderGetString(m_ticket,ORDER_SYMBOL));
  }
//+------------------------------------------------------------------+
//| Get the property value "ORDER_COMMENT".                          |
//| INPUT:  no.                                                      |
//| OUTPUT: the property value "ORDER_COMMENT".                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
string CHistoryOrderInfo::Comment() const
  {
   return(HistoryOrderGetString(m_ticket,ORDER_COMMENT));
  }
//+------------------------------------------------------------------+
//| Access functions OrderGetInteger(...).                           |
//| INPUT:  prop_id  -identifier integer properties,                 |
//|         var     -reference to a variable to value.               |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CHistoryOrderInfo::InfoInteger(ENUM_ORDER_PROPERTY_INTEGER prop_id,long& var) const
  {
   return(HistoryOrderGetInteger(m_ticket,prop_id,var));
  }
//+------------------------------------------------------------------+
//| Access functions OrderGetDouble(...).                            |
//| INPUT:  prop_id  -identifier double properties,                  |
//|         var     -reference to a variable to value.               |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CHistoryOrderInfo::InfoDouble(ENUM_ORDER_PROPERTY_DOUBLE prop_id,double& var) const
  {
   return(HistoryOrderGetDouble(m_ticket,prop_id,var));
  }
//+------------------------------------------------------------------+
//| Access functions OrderGetString(...).                            |
//| INPUT:  prop_id  -identifier string properties,                  |
//|         var     -reference to a variable to value.               |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CHistoryOrderInfo::InfoString(ENUM_ORDER_PROPERTY_STRING prop_id,string& var) const
  {
   return(HistoryOrderGetString(m_ticket,prop_id,var));
  }
//+------------------------------------------------------------------+
//| Converts the order type to text.                                 |
//| INPUT:  str  - receiving string,                                 |
//|         type - order type.                                       |
//| OUTPUT: formatted string.                                        |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
string CHistoryOrderInfo::FormatType(string& str,const uint type) const
  {
//--- clean
   str="";
//--- see the type
   switch(type)
     {
      case ORDER_TYPE_BUY            : str="buy";             break;
      case ORDER_TYPE_SELL           : str="sell";            break;
      case ORDER_TYPE_BUY_LIMIT      : str="buy limit";       break;
      case ORDER_TYPE_SELL_LIMIT     : str="sell limit";      break;
      case ORDER_TYPE_BUY_STOP       : str="buy stop";        break;
      case ORDER_TYPE_SELL_STOP      : str="sell stop";       break;
      case ORDER_TYPE_BUY_STOP_LIMIT : str="buy stop limit";  break;
      case ORDER_TYPE_SELL_STOP_LIMIT: str="sell stop limit"; break;

      default:
         str="unknown order type "+(string)type;
         break;
     }
//--- return the result
   return(str);
  }
//+------------------------------------------------------------------+
//| Converts the order status to text.                               |
//| INPUT:  str    - receiving string,                               |
//|         status - order status.                                   |
//| OUTPUT: formatted string.                                        |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
string CHistoryOrderInfo::FormatStatus(string& str,const uint status) const
  {
//--- clean
   str="";
//--- see the type
   switch(status)
     {
      case ORDER_STATE_STARTED : str="started";  break;
      case ORDER_STATE_PLACED  : str="placed";   break;
      case ORDER_STATE_CANCELED: str="canceled"; break;
      case ORDER_STATE_PARTIAL : str="partial";  break;
      case ORDER_STATE_FILLED  : str="filled";   break;
      case ORDER_STATE_REJECTED: str="rejected"; break;
      case ORDER_STATE_EXPIRED : str="expired";  break;

      default:
         str="unknown order status "+(string)status;
         break;
     }
//--- return the result
   return(str);
  }
//+------------------------------------------------------------------+
//| Converts the order filling type to text.                         |
//| INPUT:  str  - receiving string,                                 |
//|         type - order filling type.                               |
//| OUTPUT: formatted string.                                        |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
string CHistoryOrderInfo::FormatTypeFilling(string& str,const uint type) const
  {
//--- clean
   str="";
//--- see the type
   switch(type)
     {
      case ORDER_FILLING_RETURN: str="return remainder"; break;
      case ORDER_FILLING_IOC   : str="cancel remainder"; break;
      case ORDER_FILLING_FOK   : str="all or none";      break;

      default:
         str="unknown type filling "+(string)type;
         break;
     }
//--- return the result
   return(str);
  }
//+------------------------------------------------------------------+
//| Converts the type of order by expiration to text.                |
//| INPUT:  str  - receiving string,                                 |
//|         type - type of order by expiration.                      |
//| OUTPUT: formatted string.                                        |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
string CHistoryOrderInfo::FormatTypeTime(string& str,const uint type) const
  {
//--- clean
   str="";
//--- see the type
   switch(type)
     {
      case ORDER_TIME_GTC          : str="gtc";           break;
      case ORDER_TIME_DAY          : str="day";           break;
      case ORDER_TIME_SPECIFIED    : str="specified";     break;
      case ORDER_TIME_SPECIFIED_DAY: str="specified day"; break;

      default:
         str="unknown type time "+(string)type;
         break;
     }
//--- return the result
   return(str);
  }
//+------------------------------------------------------------------+
//| Converts the order parameters to text.                           |
//| INPUT:  str      - receiving string,                             |
//|         position - pointer at the class instance.                |
//| OUTPUT: formatted string.                                        |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
string CHistoryOrderInfo::FormatOrder(string& str) const
  {
   string      type,price;
   CSymbolInfo __symbol;
//--- set up
   __symbol.Name(Symbol());
   int __digits=__symbol.Digits();
//--- form the order description
   str = StringFormat("#%I64u %s %s %s",
                Ticket(),
                FormatType(type,OrderType()),
                DoubleToString(VolumeInitial(),2),
                Symbol());
//--- receive the price of the order
   FormatPrice(price,PriceOpen(),PriceStopLimit(),__digits);
//--- if there is price, write it
   if(price!="")
     {
      str+=" at ";
      str+=price;
     }
//--- return the result
   return(str);
  }
//+------------------------------------------------------------------+
//| Converts the order prices to text.                               |
//| INPUT:  str           - receiving string,                        |
//|         price_order   - order price,                             |
//|         price_trigger - the order trigger price.                 |
//| OUTPUT: formatted string.                                        |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
string CHistoryOrderInfo::FormatPrice(string& str,const double price_order,const double price_trigger,const uint __digits) const
  {
   string price,trigger;
//--- clean
   str="";
//--- Is there its trigger price?
   if(price_trigger)
     {
      price  =DoubleToString(price_order,__digits);
      trigger=DoubleToString(price_trigger,__digits);
      str    =StringFormat("%s (%s)",price,trigger);
     }
   else str=DoubleToString(price_order,__digits);
//--- return the result
   return(str);
  }
//+------------------------------------------------------------------+
//| Select a history order on the index.                             |
//| INPUT:  index - history order index.                             |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CHistoryOrderInfo::SelectByIndex(int index)
  {
   ulong ticket=HistoryOrderGetTicket(index);
   if(ticket==0) return(false);
   Ticket(ticket);
//---
   return(true);
  }
//+------------------------------------------------------------------+
