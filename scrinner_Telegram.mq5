﻿//+------------------------------------------------------------------+
//|                                                       Test22.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <tickMOEX.mqh>
#include <main.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Telegram.mqh>

input int Period_MA=180;//период MA
input int Period_WPR=180;//период WPR
input string InpToken="<TOKEN>";//Token для Телеграмм-бота
input long InpChannelName=<ID_CHAT>;//Channel Name
input bool BotInfo=false;//Использовать бота Telegramm?

int getme_result;
int handle1[][2];
double MA[];
double WPR[];
int a1;
int total1=0;
int oDOY=0,nDOY=0;
datetime current;
string TICKER[];
int total2=0;
bool mas=false;

CCustomBot bot;
CTrade ord;
CSymbolInfo sym;
CAccountInfo acc;
CPositionInfo Pos;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
   {
//---
    if(BotInfo==true)
       {
        bot.Token(InpToken);
        getme_result=bot.GetMe();
        int res1=bot.SendMessage(InpChannelName,"Привет");
       }
    EventSetTimer(3);
    OnTimer();

    a1=ArraySize(TICK_MOEX);
    ArrayResize(handle1,a1);

    for(int i=0; i<a1; i++)
       {
        //------Блок проверки выбора инструментов в окне инструментов----------------+
        if(SymbolInfoInteger(TICK_MOEX[i],SYMBOL_SELECT) ==false && SymbolInfoInteger(TICK_MOEX[i],SYMBOL_VISIBLE)==false)
           {
            Print("Не выбран инструмент в окне инструментов. ",TICK_MOEX[i]);
            SymbolSelect(TICK_MOEX[i],true);
           }

        //---------------------------------------------------------------------------+

        //------Блок получения хэндлов индикаторов----------------------------------+
        for(int z=0; z<2; z++)
           {
            if(z==0)
               {
                handle1[i][z]=iMA(TICK_MOEX[i],PERIOD_D1,Period_MA,0,MODE_SMA,PRICE_CLOSE);
                //Print(handle1[i][z]);
               }

            if(z==1)
               {
                handle1[i][z]=iWPR(TICK_MOEX[i],PERIOD_D1,Period_WPR);
                //Print(handle1[i][z]);
               }
           }
        //-----------------------------------------------------------------------------------+


       }
    Print("Необходимые инсрументы выбраны.");
//---
    return(INIT_SUCCEEDED);
   }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
   {
//---

   }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
   {
    nDOY=DOY();

    if(nDOY!=oDOY)
       {
        Print(DOY());

        for(int i =0; i<a1; i++)
           {
            //------Блок заполнения значений индикаторов------------------+
            for(int z=0; z<2; z++)
               {
                if(z==0)
                   {
                    CopyBuffer(handle1[i][z],0,0,1,MA);
                    ArraySetAsSeries(MA,true);
                    //Print(TICK_MOEX[i]," (MA)","=",MA[0]);
                   }
                if(z==1)
                   {
                    CopyBuffer(handle1[i][z],0,0,2,WPR);
                    ArraySetAsSeries(WPR,true);
                    //Print(TICK_MOEX[i]," (WPR)","=",WPR[0]);
                   }
                //---------------------------------------------------------+
               }
            sym.Name(TICK_MOEX[i]);
            sym.RefreshRates();

            if(sym.Ask()<MA[0])//&& (WPR[1]<(-80)&& WPR[0]>(-80)))
               {

                mas=true;
                //total2=total2+1;

               }
            else
                mas=false;
            //Print(total2);
            if(mas==true)
               {
               }
           }

        //Print(TICKER[0]);
        oDOY=nDOY;
       }
   }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
   {
//---

   }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
   {
//---

   }
//+------------------------------------------------------------------+
void OnTimer()
   {
//--- show error message end exit
    if(getme_result!=0)
       {
        Comment("Error: ",GetErrorDescription(getme_result));
        return;
       }
////--- show bot name
    Comment("Bot name: ",bot.Name());
////--- reading messages
    bot.GetUpdates();
////--- processing messages
//    bot.ProcessMessages();
   }
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
