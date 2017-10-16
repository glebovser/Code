//+------------------------------------------------------------------+
//|                                        Pol_282_v1.mq4 |
//|                                                              GSS |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "GSS"
#property link      ""

//+------------------------------------------------------------------+
//|  Пробой флэта / двойной ордер
//+------------------------------------------------------------------+
/*      

27,0 - работа по двум утреним флэтам (до 9,15 и 11,30)
28,0- полная работа с ордерами от прошлых дней
28.3 - добавление в анализ OLD-ордеров

*/

int MAGICMA=19102015;

extern int Number_Orders=2;  // Количество ордеров в одном направлении  //v20,0
int Numb_Orders[3];   // Переменный параметр для ECN.PRO
int Number_Point=6;

extern uchar Mode_Flat=3;  // 1-только первый флэт, 2-только второй флэт, 3- первый и второй флэт

extern double     Flat1_op_1=6.0; //  8.25;      // Начало утреннего флэта, в часах
extern double     Flat1_cl_1=9.25; // 11.00;      // Конец утреннего флэта, в часах 

extern double     Flat1_op_2=9.0; //  8.25;      // Начало утреннего флэта, в часах
extern double     Flat1_cl_2=11.5; // 11.00;      // Конец утреннего флэта, в часах 

extern double     Time_work_max_1=20.25; //  18.75  // 20/25   //  Максимальный час, до которого работаем в течении дня
extern double     Time_work_max_2=20.25;
double     Time_work_max[2];

extern int     Flat_max=450;  // расчетное - 284; //340      //  Максимальное значения флэта для работы
extern  int    Flat_min=190;       //  минимальное значения флэта для работы 16.2
                                   ///*extern*/ int     Flat_Delta[INDEX]     = 0;  //-20;       //  Дельта к флэту  
double Lots=0;    // Количество лотов,если ноль, то расчитваем автоматом 
double Percent=0;   // Процент выделенных средств 
extern double Loss_Percent=12;  // Расчет лота по возможным потерям
double Loss_Percent_max=10;

double Lots_New[2];       // расчетное количество лотов для новых ордеров (вычисляется)
                          //double Ticket__ [Index][7];        // для закрытия ореров с правильным лотом

int        Slippage=5;

int    Proskalz_delta=10;   // значения проскальзывания при закрытии, при котором работаем по v14
int    Proskalz_bar=145;  // Большой бар при закрытии ордера, после которого отслеживаем закрытие по барам

extern int TakeProfit_close_min=270;   // для v 17.0 
extern int TakeProfit_close=450; //350;   // для v 11.0
extern int TakeProfit_close_max=750;   // для v 17.0 

extern int TakeProfit=800;

extern int        Proskalz_SL=320; //274;   // фиксация первого минимального положительного SL при большом проскальзывнии 14.0
extern int        Proskalz_TP=2000;   // фиксация максимального TP при большом проскальзывнии 14.0
extern int        Proskalz_Level_2=600; //500;  // 18.2  Уровень цены, при котором делаем второе подтягивание

double Lot_koof_cl=0.5;  // коэффициент отношения двух частей закрываемого ордера
double Lot_koof_cl_big = 0.5; //   17.4  коэффициент отношения двух частей закрываемого ордера
double Lot_koof_1part = 0.5;  // 18,6  закрытие части при проскальзывании первой части


extern double Bezubytok_point=180;  //  Превод в безубыток при достижении уровня прибыли
int Bezubytok_profit_0 = -20; // профит при переводе в безубыток
int Bezubytok_profit_1 =  24; // профит при переводе в безубыток

extern double  Spred=14;  // Значения среднего спреда в пунктах(для EUR/USD = 14)

extern bool Agressiv=false; //24.3 для агрессивного счета
extern bool Test=true;  // тест системы с минимальным лотом в случае превышения флэта 1-вкл, 0-выкл
extern bool check_orders= true;  // Проверка на наличие открытых сегодня ордеров 1-вкл, 0-выкл
extern bool DoubleClose = true;  // Закоытие двумя частями  v 17/0
extern bool DoubleClose_big=true;  // Закрытие одной части по хорошей большой цене v 17.4
extern bool One_part_long_cl=false;
extern bool Two_part_long_cl=true;

bool Fast_flat_open=false;  // 18,7,1 для открытия рыночных ордеров утром на границе флэта

extern int Zig_number=0;//20;  // Кол-во уровней зиг зага
datetime Zig_time_old;  // для уменьшения расчетов ЗигЗага

double Price_SL[2];  //16.0.2
int  flag_Limit[2];         // Флаг определения  границ флэта (приравниваю ко дню в году)
                            // int  flag_s, flag_b, 
int flag_no_flat[2],flag_order_op[2];   // флаги: отсутствия флэта и открытия первых ордеров дня
                                        // int flag_order_back;  // флаг установки ордера в обратном направлении в надежде на разворот (из v8.0)
int flag_no_open[2];   // флаг не открытия ордеров с утра

double Flat_Hich[2],Flat_Low[2],Flat_Delta[2],Flat_Medium[2],Flat_1_3_L[2],Flat_1_3_H[2];

double spred;

bool Lost_s[2]={0,0};  // флаг неоткрытия объемов PRO.ECN
bool Lost_b[2]={0,0};

int GLE;  // код последней ошибки

int n_op[2]={1,1};   // счеткик попыток повторного открытия

datetime   Time_Bar_old_i[2];               // для определения формирования нового бара 

                                            //datetime Start_t[INDEX],Stop_t[INDEX];   // для интелектуального поиска границ   26,0
//int Flag_i_Limit[INDEX];    // // 26.0  0-еще не запускалось, 1 - запуск уже был хотя бы один раз, 
extern int Delta_lim=20;
extern int Flat_1_3=250;
double flat_1_3;

//double Sell_NoOpen,Buy_NoOpen,Sell_NoOpen_Lim,Buy_NoOpen_Lim;    //   цены для отслеживания неоткрытия по утрам /v13

double Rol_koef;   // коэффициент изменения баланса в ролловер
int Ticket_rol;   // билет последнего ролловера
int Check_cl_ROL;
string Rollover_name="Ticket_ROL";   // Имя глобальной переменной для ролловера

extern int Balance=0;

int k,m;
bool b;
int INDEX,INDEX_min,INDEX_max,INDEX_Old;

bool Flag_Old;

//#Служебные массивы
double Ticket_b[3][10][15]; //  0 - тикет, 1 - цена безубытка, 2 -состояние по отслеживанию, 3 - TakeProfit_close, 4-TakeProfit_close_min, 5-TakeProfit_close_max, 6-Proskalz_Level_2, 7-лот для закрытия, 8-флаг проскальзывания.
double Ticket_s[3][10][15]; //  9 - цены при неоткрытии утром Buy_NoOpen_Lim/Sell_NoOpen_Lim, 10 - цены при неоткрытии утром Sell_NoOpen/Buy_NoOpen, 11 - лот,запланированный к открытию, 12 - сколько лотов не дооткрылось

datetime Time_b[3][10][4]; // 0 -отслежоание баров при закрытии второй части, 1-время открытия ордера для VeryNevs, 2 -время баров для безу
datetime Time_s[3][10][4];

string Text_b[3][10][4];   // 0 - комментарий ордера
string Text_s[3][10][4];
//-----------------------------------------------------------
uchar Flag_i_Limit[2];
int Test_flag[2];
datetime Start_t[2],Stop_t[2];

double Flat1_op[2];
double Flat1_cl[2];
//жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+
void  init()
  {
   Alert(Symbol()," v.27.  _**********Советник начал работу**** ",AccountCompany(),"  Депозит в ",AccountCurrency());
   Alert(Symbol(),"Текущий Сервер ",AccountServer()); // Alpari-Pro.ECN
//--------------------------
   Numb_Orders[0]=Number_Orders; Numb_Orders[1]=Number_Orders;
   Time_work_max[0]=Time_work_max_1; Time_work_max[1]=Time_work_max_2;
   Flat1_op[0]=Flat1_op_1;Flat1_op[1]=Flat1_op_2;
   Flat1_cl[0]=Flat1_cl_1;Flat1_cl[1]=Flat1_cl_2;

   switch(Mode_Flat)
     {
      case 1: INDEX_min = 0; INDEX_max = 1; INDEX_Old =2; Alert("! Только   ПЕРВЫЙ   флэт");break;
      case 2: INDEX_min = 1; INDEX_max = 2; INDEX_Old =2; Alert("! Только   ВТОРОЙ   флэт");break;
      case 3: INDEX_min = 0; INDEX_max = 2; INDEX_Old =2; Alert("! ПЕРВЫЙ и ВТОРОЙ   флэт");break;

      default:INDEX_min=0; INDEX_max=2; INDEX_Old=2; Alert("! ошибка, ОБА флэта");break;
     }
//--------------------------   
   spred=Spred*Point;
   flat_1_3=Flat_1_3*Point;
   if(TakeProfit_close_min==0 || TakeProfit_close_min==TakeProfit_close) DoubleClose=false;
   if(IsTradeAllowed()==false) Alert(Symbol(),"   !! !! Торговля запрещена !! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
   if(Hour()+Minute()/60.0<Time_work_max[INDEX] && Hour()+Minute()/60.0>=Flat1_cl_1)
     {
      if(check_orders==true) Order_open_analiz();  // Проверка ранее открытых и отработанных ордеров
     }

   Ticket_rol=GlobalVariableGet(Rollover_name);
   Alert("Последний рол во внешней переменной = ",Ticket_rol);
   Rol_Check();
  }
//жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+
void  deinit()
  {
/*   if(Hour()+Minute()/60.0>=Time_work_max[INDEX] || Hour()+Minute()/60.0<Flat1_cl[INDEX])
     {
      // !!!!      if(Ticket!=0) Check_for_Close_5(); // модификация отслеживаемого ордера в нерабочее время при закрытии проги
     }
*/
  }
//жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+   START ----

void start()
  {
   for(INDEX=INDEX_min; INDEX<INDEX_max; INDEX++) // 27.0
     {

      if(Hour()+Minute()/60.0>=Time_work_max[INDEX] || Hour()+Minute()/60.0<Flat1_cl[INDEX])
        {

         if(Flag_Old==0)
           {
            Old_Copy();
            Flag_Old=1;
           }

         Old_Check();

         if(INDEX==INDEX_min)Rollover();
         return;
        }

      //----------------------------------------------------------------

      if(flag_Limit[INDEX]!=DayOfYear()) // Первое в день определение границ флэта
        {
         //        Alert(INDEX,"]]",Symbol(),"_","flag_Limit уже устарел и =",flag_Limit[INDEX]);

         Flag_i_Limit[INDEX]=0;
         flag_order_op[INDEX]=0;
         flag_no_open[INDEX]=0; n_op[INDEX]=0;
         Test_flag[INDEX]=0;
         Price_SL[INDEX]=0;
         Lost_b[INDEX]=0; Lost_s[INDEX]=0;
         Flag_Old=0;

         i_Limit_Search();
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(IsTradeAllowed()==false) // 
           {
            Alert(INDEX,"]]",Symbol(),"   !! !! Торговля запрещена !! !!");
            flag_no_flat[INDEX]=1; Test_flag[INDEX]=0;Flag_i_Limit[INDEX]=6;
            return;
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
/*      if((flag_no_flat[INDEX]==0 || Test_flag[INDEX]==1) && Ticket!=0) // 17.5 - полное отслеживание закрытия вчерашнего ордера, если сегодня не будем работать
        {
!!!         Check_for_Close_5();                       // если сегодня работаем, то старый ордер модифицирую и забываю
        }
*/
         if(Agressiv==false && Nonfarm()==true)
           {
            flag_no_flat[INDEX]=1; Test_flag[INDEX]=0;Flag_i_Limit[INDEX]=6;
           }
        }

      if(Flag_i_Limit[INDEX]!=6) i_Limit_Search();
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      if(flag_no_flat[INDEX]==0 || Test_flag[INDEX]==1) // Если флет а пределах максимального, то работаем в течении дня
        {
         if(flag_order_op[INDEX]==0)
           {

            if(Lot()==true)
              {
               Numb_Orders[INDEX]=Number_Orders;

               for(k=0; k<ArrayRange(Ticket_b,1); k++)
                 {
                  for(m=0; m<ArrayRange(Ticket_b,2); m++)
                    {
                     Ticket_b[INDEX][k][m]=0; Ticket_s[INDEX][k][m]=0;
                    }
                 }

               for(k=0; k<ArrayRange(Time_b,1); k++)
                 {
                  for(m=0; m<ArrayRange(Time_b,2); m++)
                    {
                     Time_b[INDEX][k][m]=0; Time_s[INDEX][k][m]=0;
                    }
                 }

               Alert(INDEX,"]]",Symbol(),"_","Размер лота= ",Lots_New[INDEX]);

               if( Send_Orders(4 , 0)== -1) flag_no_open[INDEX] = 1;
               if( Send_Orders(5 , 0)== -1) flag_no_open[INDEX] = 1;

               if(Number_Orders>1)
                 {
                  if( Send_Orders(4 , 1)== -1) flag_no_open[INDEX] = 1;
                  if( Send_Orders(5 , 1)== -1) flag_no_open[INDEX] = 1;
                 }

               if(flag_no_open[INDEX]==1) { Alert(INDEX,"]]","!! !! !!!!!!!!  Не все ордера открылись  !!!!!");}
               if(flag_no_open[INDEX]==1) { No_open();}   // Попытка повторного открытия ордеров v10

               Bezubyt_price();
               if(INDEX==INDEX_min) Zigzag(Zig_number);
              }
            else
              {
               Alert(INDEX,"]]",Symbol(),"_","Денег нет, игра окончена");
               flag_no_flat[INDEX]=1;
              }

            flag_order_op[INDEX]=1;
           }

         Check_for_Close();                           // V 11.0 - отслеживание цены закрытия 

         Proskalz ();                                  // Проверка на проскальзывания         
         VeryNews ();                                  // v 9.0 - Защита от быстрых движений в новостях
         Bezubyt_check();

         if(Lost_b[INDEX]==1 || Lost_s[INDEX]==1) LostLot();

         if(flag_no_open[INDEX]==1) { No_open();  if(flag_no_open[INDEX]==0) Bezubyt_price(); }

        }
/*       
      else  // что делаем, если днем работы нет
        {
        
         for(k=0; k<Numb_Orders[INDEX]; k++)
            //+------------------------------------------------------------------+
            //|                                                                  |
            //+------------------------------------------------------------------+
           {
            if((Ticket_b[INDEX][k][2]!=0 && Ticket_b[INDEX][k][2]!=5) || (Ticket_s[INDEX][k][2]!=0 && Ticket_s[INDEX][k][2]!=5)) // полное отслеживание закрытия ордера 17.5
              {
               Check_for_Close();
               Bezubyt_check();
               break;
              }
           }
        }*/
     }
//------------------------------------------------------------------------
   Old_Check();
  }
//жжжжжжжжжжжжжжжж Конец функции void start()жжжжжжжжжжжжжжжжжжжжжжж+  

//--------------------------------------------------------------------------------------------------------------------------------------
void Old_Copy() // копирование ордеров в массив отслеживания после конца рабочего дня  28,0
  {
   int num;
   for(INDEX=INDEX_min; INDEX<INDEX_max; INDEX++) // 27.0
     {
      for(k=0; k<Numb_Orders[INDEX]; k++)
        {
         //------------ баи--        
         if(Ticket_b[INDEX][k][2]!=0 && Ticket_b[INDEX][k][2]!=5)
           {
            num=Numb_Orders[INDEX_Old];
            Alert("Копирую дневной бай [",k,"], тикет №",Ticket_b[INDEX][k][0],"в OLD массив за № [",num,"]");
            for(m=0; m<ArrayRange(Ticket_b,2); m++)
              {
               Ticket_b[INDEX_Old][num][m]=Ticket_b[INDEX][k][m];
               Time_b[INDEX_Old][num][m]=Time_b[INDEX][k][m];
               Text_b[INDEX_Old][num][m]=Text_b[INDEX][k][m];
              }
            Numb_Orders[INDEX_Old]++;
           }

         //------------ селлы --        
         if(Ticket_s[INDEX][k][2]!=0 && Ticket_s[INDEX][k][2]!=5)
           {
            num=Numb_Orders[INDEX_Old];
            Alert("Копирую дневной селл [",k,"], тикет №",Ticket_s[INDEX][k][0],"в OLD массив за № [",num,"]");
            for(m=0; m<ArrayRange(Ticket_s,2); m++)
              {
               Ticket_s[INDEX_Old][num][m]=Ticket_s[INDEX][k][m];
               Time_s[INDEX_Old][num][m]=Time_s[INDEX][k][m];
               Text_s[INDEX_Old][num][m]=Text_s[INDEX][k][m];
              }
            Numb_Orders[INDEX_Old]++;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//--------------------------------------------------------------------------------------------------------------------------------------
void Old_Check() // 28.0 отслеживание ордеров от прошлых дней
  {
   INDEX=INDEX_Old;   // 28.0 отслеживание ордеров от прошлых дней

   if(Numb_Orders[INDEX]>0)
     {
      Check_for_Close();
      Bezubyt_check();

      for(k=0; k<Numb_Orders[INDEX]; k++)
        {
         if(Ticket_b[INDEX][k][0]!=0 && (Ticket_b[INDEX][k][2]==0 || Ticket_b[INDEX][k][2]==5)) Ticket_b[INDEX][k][0] = 0;
         if(Ticket_s[INDEX][k][0]!=0 && (Ticket_s[INDEX][k][2]==0 || Ticket_s[INDEX][k][2]==5)) Ticket_s[INDEX][k][0] = 0;
        }

      int num=Numb_Orders[INDEX];
      Numb_Orders[INDEX]=0;
      for(k=0; k<num; k++)
        {
         if(Ticket_b[INDEX][k][0]!=0 || Ticket_s[INDEX][k][0]!=0) Numb_Orders[INDEX]=num+1;
        }

      if(Numb_Orders[INDEX]==0)
         Alert("_____Обнулился массив старых отслеживаний!!!");

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//--------------------------------------------------------------------------------------------------------------------------------------
void i_Limit_Search() // Интеллектуальное Определение границ флэта и отрисовка его уровней  v26.0
  {
   int Start_bar;
//-------------------------------------------------------------------------------------
   if(Flag_i_Limit[INDEX]==0) // первый запуск интеллекта
     {
      Alert(INDEX,"]]","Первый запуск интелекта");
      datetime BeginDay=MathFloor(TimeCurrent()/86400)*86400;
      Start_t[INDEX]= BeginDay+Flat1_op[INDEX] *3600;
      Stop_t[INDEX] =  BeginDay+Flat1_cl[INDEX] *3600;
      Limit_Time(clrYellow);

      double zz;
      int ExtDepth=12,ExtDeviation=5,ExtBackstep=3;   //   Можно сделать период - почаще
      Start_bar=iBarShift(Symbol(),0,Start_t[INDEX],true);

      for(m=Start_bar+1; m<=Start_bar+2; m++) // скоко баров назад проверяем переустановку открытия
        {
         zz=iCustom(NULL,0,"ZigZag",ExtDepth,ExtDeviation,ExtBackstep,0,m);
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(zz!=0)
           {
            Alert(INDEX,"]]","Обновил стартовое время флэта, бар =",m);
            Start_t[INDEX]=iTime(NULL,0,m);        // --- Установка границы старта
           }
        }
      Flag_i_Limit[INDEX]=1;
      flag_no_flat[INDEX]=1;
      flag_Limit[INDEX]=DayOfYear();
     }
//-------------------------------------------------------------------------------------
   if(Flag_i_Limit[INDEX]==5) // последний запуск интеллекта
     {
      Limit_Search();
      Flag_i_Limit[INDEX]=6;
      return;
     }

//-------------------------------------------------------------------------------------
   if(Time_Bar_old_i[INDEX]!=iTime(NULL,0,0)) // поиск новых параметров на каждом баре
     {
      //     Alert(INDEX,"]]","Обновил СТОПовое время флэта до нового бара");
      Stop_t[INDEX]=iTime(NULL,0,0);
      Limit_Time(clrYellow);

      Start_bar=iBarShift(Symbol(),0,Start_t[INDEX],true);
      for(k=0; k<=Start_bar; k++)
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
        {
         if(High[k]==Flat_Hich[INDEX] && Low[k]==Flat_Low[INDEX])
           {
            //           Alert(INDEX,"]]","Последняя граница - ВЕРХНЕ/НИЖНЯЯ. Чего делать то???? бар №",k);
            break;
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(High[k]==Flat_Hich[INDEX])
           {
            Flag_i_Limit[INDEX]=2;
            Alert(INDEX,"]]","Последняя граница - верхняя, бар №",k);
            break;
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(Low[k]==Flat_Low[INDEX])
           {
            Flag_i_Limit[INDEX]=3;
            //      Alert(INDEX,"]]","Последняя граница - нижняя, бар №",k);
            break;
           }
        }
      Time_Bar_old_i[INDEX]=iTime(NULL,0,0);
     }
//-------------------------------------------------------------------------------------

   if(Low[0] <= Flat_Low[INDEX] || High[0] >= Flat_Hich[INDEX] ) return;

   if(Ask + 40*Point > Flat_Hich[INDEX]  || Bid - 40*Point < Flat_Low[INDEX] ) return;

   if(Flat_Delta[INDEX] < Flat_min * Point) return;

//-------------------------------------------------------------------------------------

   if(Flat_Delta[INDEX]>=flat_1_3)
     {
      if((Flag_i_Limit[INDEX]==2 && Low[0]<Flat_1_3_H[INDEX]) || (Flag_i_Limit[INDEX]==3 && High[0]>Flat_1_3_L[INDEX])) //Бар откатился на одну треть
        {
         Stop_t[INDEX]=TimeCurrent();
         Limit_Time(clrGreen);
         Flag_i_Limit[INDEX]=5;
         return;
        }
     }
   else
     {
      if((Flag_i_Limit[INDEX]==2 && Low[0]<Flat_Medium[INDEX]) || (Flag_i_Limit[INDEX]==3 && High[0]>Flat_Medium[INDEX])) //Бар откатился в середину флэта
        {
         Stop_t[INDEX]=TimeCurrent();
         Limit_Time(clrGreen);
         Flag_i_Limit[INDEX]=5;
         return;
        }
     }

//  Flag_i_Limit[INDEX]=1;    // 0-еще не запускалось, 1 - запуск уже был хотя бы один раз, 2 - последняя граница Верхняя, 3 - последняя граница Нижняя, 5 - интеллект границы определили, 6 - старый Limit_Search отработал

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------------------------+
void Limit_Time(color Color)
  {
   int Start_time =   iBarShift(Symbol(),0, Start_t[INDEX],true);
   int Stop_time  =   iBarShift(Symbol(),0, Stop_t[INDEX] ,true);

   Flat_Low[INDEX]=Low[iLowest(NULL,0,MODE_LOW,Start_time-Stop_time+1,Stop_time)];
   Flat_Hich[INDEX]=High[iHighest(NULL,0,MODE_HIGH,Start_time-Stop_time+1,Stop_time)];
   Flat_Medium[INDEX]=(Flat_Low[INDEX]+Flat_Hich[INDEX])/2;
   Flat_1_3_L[INDEX] = (Flat_Hich[INDEX]-Flat_Low[INDEX])/3 + Flat_Low[INDEX];
   Flat_1_3_H[INDEX] = (Flat_Low[INDEX]-Flat_Hich[INDEX])/3 + Flat_Hich[INDEX];
   Flat_Delta[INDEX]=Flat_Hich[INDEX]-Flat_Low[INDEX];

   Limit_Paint(Color);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Limit_Paint(color Color)
  {
//--------- отрисовка уровней---------------------------------------------------   
   int fl_delta=Flat_Delta[INDEX]/Point;

   datetime time_1 = Start_t[INDEX];
   datetime time_2 =(MathFloor(TimeCurrent()/86400)*86400)+(Time_work_max[INDEX]*3600);

   string Name[6];

   Name[0]=INDEX+"_flet "+DayOfYear();  // это текст
   Name[1] = INDEX+"_hich " + DayOfYear();
   Name[2] = INDEX+"_low " + DayOfYear();
   Name[3] = INDEX+"_medi " + DayOfYear();
   Name[4] = INDEX+"_1/3_L " + DayOfYear();
   Name[5] = INDEX+"_1/3_H " + DayOfYear();

   for(k=0; k<6; k++)
     {ObjectDelete(Name[k]);}

   ObjectCreate(Name[0],OBJ_TEXT,0,time_1,Flat_Hich[INDEX]);
   ObjectCreate(Name[1],OBJ_TREND,0,time_1,Flat_Hich[INDEX],time_2,Flat_Hich[INDEX]);
   ObjectCreate(Name[2],OBJ_TREND,0,time_1,Flat_Low[INDEX],time_2,Flat_Low[INDEX]);
   ObjectCreate(Name[3],OBJ_TREND,0,time_1,Flat_Medium[INDEX],time_2,Flat_Medium[INDEX]);
   ObjectCreate(Name[4],OBJ_TREND,0,time_1,Flat_1_3_L[INDEX],time_2,Flat_1_3_L[INDEX]);
   ObjectCreate(Name[5],OBJ_TREND,0,time_1,Flat_1_3_H[INDEX],time_2,Flat_1_3_H[INDEX]);

   ObjectSetString(0,Name[0],OBJPROP_TEXT,fl_delta);  ObjectSetInteger(0,Name[0],OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER);  ObjectSetInteger(0,Name[0],OBJPROP_COLOR,Color);

   for(k=1; k<6; k++)
     {
      ObjectSet(Name[k],OBJPROP_RAY_RIGHT,false);
      ObjectSet(Name[k],OBJPROP_COLOR,Color);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//--------------------------------------------------------------------------------------------------------------------------------------
void Limit_Search() // Определение границ флэта и отрисовка его уровней
  {
   int fl_delta=Flat_Delta[INDEX]/Point;

   if(fl_delta>Flat_max) // если разнос слишком большой
     {
      //      flag_Limit[INDEX]=DayOfYear();
      //      Flag_i_Limit[INDEX]=6;
      flag_no_flat[INDEX]=1;
      Alert(INDEX,"]]",Symbol(),"_","Разнос флэта слишком большой");
      Limit_Paint(clrMagenta);
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      // --------- работа в тестовом режиме ---------------

      if(Test==true)
        {
         if(fl_delta<Flat_max*2.0)
           {
            Alert(INDEX,"]]",Symbol(),"_Работаем в тестовом режиме");
            Test_flag[INDEX]=1;
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         else
           {
            Alert(INDEX,"]]",Symbol(),"_Разнос большой даже для Теста");
           }
        }
     }
   else
     {
      flag_no_flat[INDEX]=0;
      //     Flag_i_Limit[INDEX]=6;
      //     flag_Limit[INDEX]=DayOfYear();
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//жжжжжжжжжжжжжжжж Открытие ордеров жжжжжжжжжжжжжжжжжжжжжжж+  

int Send_Orders(int Type,int Index) // Типы ордеров: 0-BUY, 1-SELL, 2-BUY-lim, 3-SELL-lim,  4 - BUY-st,  5 - SELL-st
  {

   datetime BeginDay=MathFloor(TimeCurrent()/86400)*86400;     // Расчет времени начала текущих суток
   int      Start_time=iBarShift(Symbol(),0,BeginDay+Flat1_op[INDEX]*3600,true);     // Бар, соответсвующий началу работы 
   datetime end_work=BeginDay+Time_work_max[INDEX]*3600;
   double Points_n;
   int    Point_n;

   double Price,SL,TP;
   int    MG;
//   int    MG=MAGICMA;
   int    Tick_b,Tick_s;
//   int GLE;  // Код ошибки

//------------------------  ордер BUY (0)  ---------------------

   if(Type==0)
     {
      Point_n = Order_form (Index, "Pips");
      Points_n=Point_n*Point;

      Price=Ask;
      SL = Flat_Low[INDEX] + Points_n;
      TP = Flat_Hich[INDEX] + Point*TakeProfit + Points_n;
      MG=MAGICMA+Point_n+INDEX;

      Tick_b=OrderSend(Symbol(),OP_BUY,Lots_New[INDEX],Price,Slippage,SL,TP,"buy "+Point_n,MG,end_work,Blue);
      if(Tick_b==-1)
        {
         Alert(INDEX,"]]","Ошибка по buy =",GetLastError()," цена Ask=",DoubleToStr(Ask,Digits)," цена Bid=",DoubleToStr(Bid,Digits)," цена откр=",DoubleToStr(Price,Digits));
        }
      else   Ticket_b[INDEX][Index][0]=Tick_b;
      return (Tick_b);
     }
//------------------------  ордер SELL (1)  ---------------------

   if(Type==1)
     {
      Point_n = -1 * Order_form (Index, "Pips");
      Points_n=Point_n*Point;

      Price=Bid;
      SL = Flat_Hich[INDEX] + spred + Points_n;
      TP = Flat_Low[INDEX] - Point*TakeProfit + spred + Points_n;
      MG=MAGICMA+Point_n+INDEX;

      Tick_s=OrderSend(Symbol(),OP_SELL,Lots_New[INDEX],Price,Slippage,SL,TP,"sell"+Point_n,MG,end_work,Red);
      if(Tick_s==-1)
        {
         Alert(INDEX,"]]","Ошибка по sell =",GetLastError()," цена Bid=",DoubleToStr(Bid,Digits)," цена Ask=",DoubleToStr(Ask,Digits)," цена откр=",DoubleToStr(Price,Digits));
        }
      else   Ticket_s[INDEX][Index][0]=Tick_s;
      return (Tick_s);
     }
//------------------------  ордер BUY STOP (4)  ---------------------

   if(Type==4)
     {
      Point_n = Order_form (Index, "Pips");
      Points_n=Point_n*Point;

      Price=Flat_Hich[INDEX]+spred+Points_n;
      SL = Flat_Low[INDEX] + Points_n;
      TP = Flat_Hich[INDEX] + Point*TakeProfit + Points_n;
      MG=MAGICMA+Point_n+INDEX;

      Tick_b=OrderSend(Symbol(),OP_BUYSTOP,Lots_New[INDEX],Price,Slippage,SL,TP,"buy "+Point_n,MG,end_work,Blue);
      if(Tick_b==-1)
        {
         Alert(INDEX,"]]","Ошибка по buy stop =",GetLastError()," цена Ask=",DoubleToStr(Ask,Digits)," цена Bid=",DoubleToStr(Bid,Digits)," цена откр=",DoubleToStr(Price,Digits));
         Ticket_b[INDEX][Index][10]=Ask;
         if(Ticket_b[INDEX][Index][9]==0) Ticket_b[INDEX][Index][9]=Price-spred;
        }
      else   Ticket_b[INDEX][Index][0]=Tick_b;
      return (Tick_b);
     }
//------------------------  ордер SELL STOP (5)  ---------------------

   if(Type==5)
     {
      Point_n = -1 * Order_form (Index, "Pips");
      Points_n=Point_n*Point;

      Price=Flat_Low[INDEX]+Points_n;
      SL = Flat_Hich[INDEX] + spred + Points_n;
      TP = Flat_Low[INDEX] - Point*TakeProfit + spred + Points_n;
      MG=MAGICMA+Point_n+INDEX;

      Tick_s=OrderSend(Symbol(),OP_SELLSTOP,Lots_New[INDEX],Price,Slippage,SL,TP,"sell"+Point_n,MG,end_work,Red);
      if(Tick_s==-1)
        {
         Alert(INDEX,"]]","Ошибка по sell stop =",GetLastError()," цена Bid=",DoubleToStr(Bid,Digits)," цена Ask=",DoubleToStr(Ask,Digits)," цена откр=",DoubleToStr(Price,Digits));
         //   RefreshRates();
         Ticket_s[INDEX][Index][10]=Bid;
         if(Ticket_s[INDEX][Index][9]==0) Ticket_s[INDEX][Index][9]=Price;
        }
      else   Ticket_s[INDEX][Index][0]=Tick_s;
      return (Tick_s);
     }
   return (-1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// ----------------------------  Функция повторного открытия неоткрывшихся первых ордеров -----------------------------------------------------------------------

void No_open()
  {
   double Price;

   for(k=0; k<Numb_Orders[INDEX]; k++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      // -----------------------  неоткрытие BUY ---
      if(Ticket_b[INDEX][k][0]==0)
        {
         Price=Flat_Hich[INDEX]+spred;
         RefreshRates();
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(Ask>=Price && Ask<=Price+Slippage && Fast_flat_open)
           {
/*         Alert(INDEX,"]]",Symbol(),"Попытка переоткрытия по ТЕКУЩЕЙ цене Ask (+ slippage) = ",DoubleToStr(Ask,Digits));
         if(Send_Orders(0)!=-1)
           {flag_no_open[INDEX]=0; Alert(INDEX,"]]",Symbol(),"Ордер BUY открылся - таки"); return;}*/

           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(Bid>Ticket_b[INDEX][k][9])
           {
            Alert(INDEX,"]]",Symbol(),"Попытка переоткрытия при более ВЫСОКОЙ цене Ask = ",DoubleToStr(Ask,Digits));
            if(Send_Orders(2,k)!=-1)
              { Alert(INDEX,"]]",Symbol(),"Ордер BUY открылся - таки [",k); Alert(INDEX,"]]",Symbol(),"Вынос от Bid =",((Bid-Ticket_b[INDEX][k][9])/Point)); return;}
            else
              {
               n_op[INDEX]++;
               Ticket_b[INDEX][k][9]=Bid;
               if(n_op[INDEX]>60)
                 {
                  Alert(INDEX,"]]",Symbol(),"Превышено максимальное число попыток открытия, STOP");
                  flag_no_open[INDEX]=0;
                  Ticket_b[INDEX][k][0]=1000;
                 }
              }
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(Ask<Ticket_b[INDEX][k][10])
           {
            Alert(INDEX,"]]",Symbol(),"Попытка переоткрытия по более НИЗКОЙ цене Ask = ",DoubleToStr(Ask,Digits));
            if(Send_Orders(4,k)!=-1)
              { Alert(INDEX,"]]",Symbol(),"Ордер BUY открылся - таки [",k); Alert(INDEX,"]]",Symbol(),"Вынос от Ask =",((Ticket_b[INDEX][k][10]-Ask)/Point));  return;}
            else
              {
               n_op[INDEX]++;
               Ticket_b[INDEX][k][10]=Ask;
               if(n_op[INDEX]>60)
                 {
                  Alert(INDEX,"]]",Symbol(),"Превышено максимальное число попыток открытия, STOP");
                  flag_no_open[INDEX]=0;
                  Ticket_b[INDEX][k][0]=1000;
                 }
              }
           }
        }
      // -----------------------  неоткрытие SELL ---

      if(Ticket_s[INDEX][k][0]==0)
        {
         Price=Flat_Low[INDEX];
         RefreshRates();
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(Bid<=Price && Bid>=Price-Slippage && Fast_flat_open)
           {
/*         Alert(INDEX,"]]",Symbol(),"Попытка переоткрытия по ТЕКУЩЕЙ цене Bid (- slippage) = ",DoubleToStr(Bid,Digits));
         if(Send_Orders(1)!=-1)
           {flag_no_open[INDEX]=0; Alert(INDEX,"]]",Symbol(),"Ордер SELL открылся - таки"); return;}  */

           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(Ask<Ticket_s[INDEX][k][9])
           {
            Alert(INDEX,"]]",Symbol(),"Попытка переоткрытия при более НИЗКОЙ цене Bid = ",DoubleToStr(Bid,Digits));
            if(Send_Orders(3,k)!=-1)
              { Alert(INDEX,"]]",Symbol(),"Ордер SELL открылся - таки [",k); Alert(INDEX,"]]",Symbol(),"Вынос от Ask =",(Ticket_s[INDEX][k][9]-Ask)/Point); return;}
            else
              {
               n_op[INDEX]++;
               Ticket_s[INDEX][k][9]=Ask;
               if(n_op[INDEX]>60)
                 {
                  Alert(INDEX,"]]",Symbol(),"Превышено максимальное число попыток открытия, STOP");
                  flag_no_open[INDEX]=0;
                  Ticket_s[INDEX][k][0]=1001;
                 }
              }
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(Bid>Ticket_s[INDEX][k][10])
           {
            Alert(INDEX,"]]",Symbol(),"Попытка переоткрытия по более ВЫСОКОЙ цене Bid = ",DoubleToStr(Bid,Digits));
            if(Send_Orders(5,k)!=-1)
              { Alert(INDEX,"]]",Symbol(),"Ордер SELL открылся - таки [",k); Alert(INDEX,"]]",Symbol(),"Вынос от Bid =",(Bid-Ticket_s[INDEX][k][10])/Point); return;}
            else
              {
               n_op[INDEX]++;
               Ticket_s[INDEX][k][10]=Bid;
               if(n_op[INDEX]>60)
                 {
                  Alert(INDEX,"]]",Symbol(),"Превышено максимальное число попыток открытия, STOP");
                  flag_no_open[INDEX]=0;
                  Ticket_s[INDEX][k][0]=1001;
                 }
              }
           }
        }
     }

   for(k=0; k<Numb_Orders[INDEX]; k++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(Ticket_b[INDEX][k][0] == 0) return;
      if(Ticket_s[INDEX][k][0] == 0) return;

      flag_no_open[INDEX]=0;
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Lot() // Функция вычисления количества лотов.
  {
// double Lots_New[INDEX] - количество лотов для новых ордеров (вычисляется)
// double Lots     - желаемое количество лотов, заданное пользовател.
// int Percent     - процент средств, заданный пользователем
// Возвращаемые значения:
// true  - если средств хватает на минимальный лот
// false - если средств не хватает на минимальный лот
//--------------------------------------------------------------- 2 --
   string Symb=Symbol();                    // Финансовый инструм.
   double Leverage=AccountLeverage();
   double One_Lot=MarketInfo(Symb,MODE_MARGINREQUIRED);//Стоим. 1 лота
                                                       //Alert ("Стоимость одного лота= ",One_Lot );   
   double Min_Lot=MarketInfo(Symb,MODE_MINLOT);// Мин. размер. лотов
                                               //Alert ("Стоимость минимального лота= ",Min_Lot );      
   double Step=MarketInfo(Symb,MODE_LOTSTEP);//Шаг изменен размера
   double Free=AccountFreeMargin()/Number_Orders/(INDEX_max-INDEX_min);         // Свободные средства  // v20.0
   Alert("Расчетные средства на счете =",Free);
   double Percent_test=0.15;  // тестовый лот в процентах,  v18.5 // 20.0

//-----------------------------------------+
// По расчету убытка

   double Price_minLot=0.01; //  прибыль $ / 1 пункт минимального лота,    Наверно можно как то посчитать 0,01 - для EUR/USD
                             //   double Percent_t=Loss_Percent*Min_Lot*One_Lot/Price_minLot/(Flat_Delta[INDEX]/Point+Spred);
   double Percent_t=Loss_Percent*Min_Lot*One_Lot/Price_minLot/(Flat_Delta[INDEX]/Point+Spred)*Leverage/500;   // v 21.7 Изменение установленногоо плеча
   Alert(INDEX,"]]","Разнос флэта = ",Flat_Delta[INDEX]/Point);
//--------валюты----------------------   
   double Kurs;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(AccountCurrency()=="RUR")
     {
      Kurs=(MarketInfo("USDRUB",MODE_BID)+MarketInfo("USDRUB",MODE_ASK))/2;
      Percent=Percent_t/Kurs;
      Alert(INDEX,"]]","!!!! Валюта депо - рубль, расчетный курс = ",Kurs);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(AccountCurrency()=="EUR")
     {
      Kurs=(MarketInfo("EURUSD",MODE_BID)+MarketInfo("EURUSD",MODE_ASK))/2;
      Percent=Percent_t*Kurs;
      Alert(INDEX,"]]","!!!! Валюта депо - евро, расчетный курс = ",Kurs);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(AccountCurrency()=="USD")
     {
      Percent=Percent_t;
     }

//--------------------------------------------
   double Loss_Percent_max_2=Loss_Percent_max *(Loss_Percent/12);      // 21.6
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(Percent>Loss_Percent_max_2)
     {
      Alert(INDEX,"]]","Расчетный процент большой, и = ",Percent,". Ограничиваю по максимальному");
      Percent=Loss_Percent_max_2;
     }

   Alert(INDEX,"]]","Расчетный процент потерь = ",Loss_Percent,", процент лотов на сегодня = ",Percent);
//-----------------------------------------+

   if(Test_flag[INDEX]==1) // v14.1   в режиме теста советника на счете
     {
      Lots_New[INDEX]=MathFloor(Free*Percent_test *(500/Leverage)/100/One_Lot/Step)*Step;//Расч     21,8 
                                                                                         //   Lots_New[INDEX] = Min_Lot;
      if(Lots_New[INDEX]<Min_Lot) // Если меньше допуст..
         Lots_New[INDEX]=Min_Lot;                        // .. то миниамальный
      if(Lots_New[INDEX]*One_Lot>Free) // Не хватает даже..
        {                                         // ..на минимальн. лот:(
         Alert(INDEX,"]]",Symbol(),"_","Не хватает денег");                    // Сообщение..
         Test_flag[INDEX]=0;
         return(false);                           // ..и выход 
        }
      return(true);
     }
//--------------------------------------------------------------- 3 --
   if(Lots>0) // Лоты заданы явно..
     {                                         // ..проверим это
      double Money=Lots*One_Lot;               // Стоимость ордера
      if(Money<=Free) // Средств хватает..
         Lots_New[INDEX]=Lots;                        // ..принимаем заданное
      else                                     // Если не хватает..
      Lots_New[INDEX]=MathFloor(Free *(500/Leverage)/One_Lot/Step)*Step;// Расчёт лотов  21,8
     }
//--------------------------------------------------------------- 4 --
   else                                        // Если лоты не заданы
     {                                         // ..то берём процент
      if(Percent>100) // Задано ошибочно ..
         //         Percent=100;                          // .. то не более 100
         return(false);
      if(Percent==0) // Если установлен 0 ..
         Lots_New[INDEX]=Min_Lot;                     // ..то минимальный лот
      else                                     // Желаем. колич.лотов:
      Lots_New[INDEX]=MathFloor(Free*Percent *(500/Leverage)/100/One_Lot/Step)*Step;//Расч 21,8
     }
//--------------------------------------------------------------- 5 --
   if(Lots_New[INDEX]<Min_Lot) // Если меньше допуст..
      Lots_New[INDEX]=Min_Lot;                        // .. то миниамальный
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(Lots_New[INDEX]*One_Lot>Free) // Не хватает даже..
     {                                         // ..на минимальн. лот:(
      Alert(INDEX,"]]",Symbol(),"_","Не хватает денег");                    // Сообщение..
      return(false);                           // ..и выход 
     }
   return(true);                               // Выход из польз. ф-ии
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// -----------------------------  БЕЗУБЫТОК -------------------------------------------------------------------------------------

void Bezubyt_price() //  функция определения цен перевода в безубыток 
  {
   double Price_bez;
   double Bezubytok=Bezubytok_point*Point;

   for(k=0; k<Numb_Orders[INDEX]; k++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {

      //---- баи  --------     
      if(OrderSelect(Ticket_b[INDEX][k][0],SELECT_BY_TICKET)==true)
        {
         if(OrderCloseTime()==0)
           {
            Price_bez=OrderOpenPrice()+Bezubytok;
            Ticket_b[INDEX][k][1]=Price_bez;
            Ticket_b[INDEX][k][11]=OrderLots();
            Text_b[INDEX][k][0]=OrderComment();
           }
        }
      Alert(INDEX,"]]",Symbol(),"_","Билет: BUY_",k," =",Ticket_b[INDEX][k][0],", безубыток =",DoubleToStr(Ticket_b[INDEX][k][1],Digits));
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //---- селлы  --------

      if(OrderSelect(Ticket_s[INDEX][k][0],SELECT_BY_TICKET)==true)
        {
         if(OrderCloseTime()==0)
           {
            Price_bez=OrderOpenPrice()-Bezubytok;//-spred;
            Ticket_s[INDEX][k][1]=Price_bez;
            Ticket_s[INDEX][k][11]=OrderLots();
            Text_s[INDEX][k][0]=OrderComment();

           }
        }
      Alert(INDEX,"]]",Symbol(),"_","Билет: SELL_",k," =",Ticket_s[INDEX][k][0],", безубыток =",DoubleToStr(Ticket_s[INDEX][k][1],Digits));

     }

   Bezubyt_line();         // рисуем уровни безубытка

  }
//-----------------------------------------------------------------------------------------------------

void Bezubyt_price_OLD() //  функция определения цен перевода в безубыток для OLD
  {
   double Price_bez;
   double Bezubytok=Bezubytok_point*Point;

   for(k=0; k<Numb_Orders[INDEX_Old]; k++)
     {

      //---- баи  --------     
      if(OrderSelect(Ticket_b[INDEX_Old][k][0],SELECT_BY_TICKET)==true)
        {
         if(OrderCloseTime()==0)
           {
            Price_bez=OrderOpenPrice()+Bezubytok;
            Ticket_b[INDEX_Old][k][1]=Price_bez;
            Ticket_b[INDEX_Old][k][11]=OrderLots();
            Text_b[INDEX_Old][k][0]=OrderComment();
           }
        }
      Alert(INDEX_Old,"]]",Symbol(),"_","Билет: BUY_",k," =",Ticket_b[INDEX_Old][k][0],", безубыток =",DoubleToStr(Ticket_b[INDEX_Old][k][1],Digits));
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //---- селлы  --------

      if(OrderSelect(Ticket_s[INDEX_Old][k][0],SELECT_BY_TICKET)==true)
        {
         if(OrderCloseTime()==0)
           {
            Price_bez=OrderOpenPrice()-Bezubytok;//-spred;
            Ticket_s[INDEX_Old][k][1]=Price_bez;
            Ticket_s[INDEX_Old][k][11]=OrderLots();
            Text_s[INDEX_Old][k][0]=OrderComment();

           }
        }
      Alert(INDEX_Old,"]]",Symbol(),"_","Билет: SELL_",k," =",Ticket_s[INDEX_Old][k][0],", безубыток =",DoubleToStr(Ticket_s[INDEX_Old][k][1],Digits));

     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+----------------------------------------------------------------------------------
void Bezubyt_check() // Проверка для перевода в безубыток
//----------------------------
  {
   for(k=0; k<Numb_Orders[INDEX]; k++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      //----------баи------------------   
      //      if(Ticket_b[INDEX][k][1]!=0 && Ticket_b[INDEX][k][1]<=Bid)
      if(Ticket_b[INDEX][k][1]!=0 && Ticket_b[INDEX][k][1]<=High[0])
        {
         if(!OrderSelect(Ticket_b[INDEX][k][0],SELECT_BY_TICKET))
           {
            Alert(INDEX,"]]",Ticket_b[INDEX][k][0]," Ошибка выбора ордера бай модификации № ",GetLastError());
            Ticket_b[INDEX][k][1]=0;
            continue;
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(OrderCloseTime()==0)
           {
            Alert(INDEX,"]]",Symbol(),"_","Функция модификация ордера BUY в безубыток _",k,"] ",Ticket_b[INDEX][k][0]);
            Alert(INDEX,"]]","Сейчас текущая прибыль в пунктах = ",(Bid-OrderOpenPrice())/Point);

            double Bezub_b=OrderOpenPrice()+Order_form(k,"Bezub")*Point;
            double TP_b=OrderOpenPrice()+Proskalz_TP*Point;

            if(Low[0]<Flat_Hich[INDEX] && Bezub_b>Low[0])
              {
               Bezub_b=Low[0];  // подтягиваю к минимуму текущего бара
               Alert(INDEX,"]]","!_!_Подтягиваю в б/у к минимуму текущего бара, уровень = ",Bezub_b);
               Time_b[INDEX][k][2]=iTime(NULL,0,0);
              }
            //           else
            //              Bezub_b=OrderOpenPrice()+Order_form(k,"Bezub")*Point;

            if(Bezub_b<OrderStopLoss())
              {
               Alert(INDEX,"]]"," Отказ от подтягивания, и так SL лучше");
               Ticket_b[INDEX][k][1]=0;
               continue;
              }

            if(OrderModify(Ticket_b[INDEX][k][0],OrderOpenPrice(),Bezub_b,TP_b,0,Magenta)==false)
              {
               Alert(INDEX,"]]",Symbol(),"_","Ошибка модификации № ",GetLastError());
               continue;
              }
           }
         else Alert(INDEX,"]]",Ticket_b[INDEX][k][0]," Ордер для модификации уже закрыт ");

         Ticket_b[INDEX][k][1]=0;
         continue;
        }
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //-----------селы-----------------   
      //      if(/*Ticket_s[INDEX][k][1]!=0 &&*/ Ticket_s[INDEX][k][1]>=Ask)
      if(/*Ticket_s[INDEX][k][1]!=0 &&*/ Ticket_s[INDEX][k][1]>=Low[0])

        {
         if(!OrderSelect(Ticket_s[INDEX][k][0],SELECT_BY_TICKET))
           {
            Alert(INDEX,"]]",Ticket_s[INDEX][k][0]," Ошибка выбора ордера селл модификации № ",GetLastError());
            Ticket_s[INDEX][k][1]=0;
            continue;
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(OrderCloseTime()==0)
           {
            Alert(INDEX,"]]",Symbol(),"_","Функция модификация ордера SELL в безубыток _",k,"] ",Ticket_s[INDEX][k][0]);
            Alert(INDEX,"]]","Сейчас текущая прибыль в пунктах = ",(OrderOpenPrice()-Ask)/Point);

            double Bezub_s=OrderOpenPrice()-Order_form(k,"Bezub")*Point;
            double TP_s=OrderOpenPrice()-Proskalz_TP*Point;

            if(High[0]+spred>Flat_Low[INDEX] && Bezub_b<High[0]+spred)
              {
               Bezub_s=High[0]+spred;  // подтягиваю к максимуму текущего бара
               Alert(INDEX,"]]","!_!_Подтягиваю в б/у к максимуму текущего бара, уровень = ",Bezub_s);
               Time_s[INDEX][k][2]=iTime(NULL,0,0);
              }
            //           else
            //              Bezub_s=OrderOpenPrice()-Order_form(k,"Bezub")*Point;

            if(Bezub_s>OrderStopLoss())
              {
               Alert(INDEX,"]]"," Отказ от подтягивания, и так SL лучше");
               Ticket_s[INDEX][k][1]=0;
               continue;
              }

            if(OrderModify(Ticket_s[INDEX][k][0],OrderOpenPrice(),Bezub_s,TP_s,0,Magenta)==false)
              {
               Alert(INDEX,"]]",Symbol(),"_","Ошибка модификации № ",GetLastError());
               continue;
              }
           }
         else Alert(INDEX,"]]",Ticket_s[INDEX][k][0]," Ордер для модификации уже закрыт");

         Ticket_s[INDEX][k][1]=0;
         continue;
        }

      //---------------------------------------------------------------------
      int Bar_now=iBarShift(Symbol(),0,TimeCurrent(),true);
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //---------------------------------------------------------------------
      if(Time_b[INDEX][k][2]!=0 && iBarShift(Symbol(),0,Time_b[INDEX][k][2],true)!=Bar_now)
        {
         if(!OrderSelect(Ticket_b[INDEX][k][0],SELECT_BY_TICKET))
           {
            Alert(INDEX,"]]",Ticket_b[INDEX][k][0]," Ошибка выбора ордера бай модификации_2 № ",GetLastError());
            Time_b[INDEX][k][2]=0;
            continue;
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(OrderCloseTime()==0)
           {
            Alert(INDEX,"]]",Symbol(),"_","Модификация_2 ордера BUY в нормальный безубыток _",k,"] ",Ticket_b[INDEX][k][0]);
            Bezub_b=OrderOpenPrice()+Order_form(k,"Bezub")*Point;

            if(Bezub_b<OrderStopLoss())
              {
               Alert(INDEX,"]]"," Отказ от подтягивания_2, и так SL лучше");
               Time_b[INDEX][k][2]=0;
               continue;
              }

            if(OrderModify(Ticket_b[INDEX][k][0],OrderOpenPrice(),Bezub_b,OrderTakeProfit(),0,Magenta)==false)
              {
               Alert(INDEX,"]]",Symbol(),"_","Ошибка модификации № ",GetLastError());
               continue;
              }
           }
         else Alert(INDEX,"]]",Ticket_b[INDEX][k][0]," Ордер для модификации_2 уже закрыт ");

         Time_b[INDEX][k][2]=0;
         continue;
        }
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //---------------------------------------------------------------------
      if(Time_s[INDEX][k][2]!=0 && iBarShift(Symbol(),0,Time_s[INDEX][k][2],true)!=Bar_now)
        {
         if(!OrderSelect(Ticket_s[INDEX][k][0],SELECT_BY_TICKET))
           {
            Alert(INDEX,"]]",Ticket_s[INDEX][k][0]," Ошибка выбора ордера селл модификации_2 № ",GetLastError());
            Time_s[INDEX][k][2]=0;
            continue;
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(OrderCloseTime()==0)
           {
            Alert(INDEX,"]]",Symbol(),"_","Модификация_2 ордера SELL в нормальный безубыток _",k,"] ",Ticket_s[INDEX][k][0]);
            Bezub_s=OrderOpenPrice()-Order_form(k,"Bezub")*Point;

            if(Bezub_s>OrderStopLoss())
              {
               Alert(INDEX,"]]"," Отказ от подтягивания_2, и так SL лучше");
               Time_s[INDEX][k][2]=0;
               continue;
              }

            if(OrderModify(Ticket_s[INDEX][k][0],OrderOpenPrice(),Bezub_s,OrderTakeProfit(),0,Magenta)==false)
              {
               Alert(INDEX,"]]",Symbol(),"_","Ошибка модификации № ",GetLastError());
               continue;
              }
           }
         else Alert(INDEX,"]]",Ticket_s[INDEX][k][0]," Ордер для модификации_2 уже закрыт");

         Time_s[INDEX][k][2]=0;
         continue;
        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// ----------------- отрисовка уровней безубытка -------------------------

void Bezubyt_line()
  {
   string b_name,s_name;
   datetime BeginDay=MathFloor(TimeCurrent()/86400)*86400;

   datetime time_1 = BeginDay+Flat1_cl[INDEX]*3600;
   datetime time_2 = BeginDay+Time_work_max[INDEX]*3600;

   for(k=0; k<Numb_Orders[INDEX]; k++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      b_name = INDEX+"_buy_bez_" +k+ " " + DayOfYear();
      s_name = INDEX+"_sell_bez_"+k+ " " + DayOfYear();

      ObjectDelete(b_name); ObjectDelete(s_name);

      ObjectCreate(b_name,OBJ_TREND,0,time_1,Ticket_b[INDEX][k][1],time_2,Ticket_b[INDEX][k][1]);
      ObjectCreate(s_name,OBJ_TREND,0,time_1,Ticket_s[INDEX][k][1],time_2,Ticket_s[INDEX][k][1]);

      ObjectSet(b_name,OBJPROP_RAY_RIGHT,false);  ObjectSet(b_name,OBJPROP_COLOR,clrDarkOrchid);
      ObjectSet(s_name,OBJPROP_RAY_RIGHT,false);   ObjectSet(s_name,OBJPROP_COLOR,clrDarkOrchid);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |;8
//+------------------------------------------------------------------+
// ----------  Проверка открытых и отработаных торговых ордеров --------
void Order_open_analiz()
  {
   int    Point_n;
   int b_old,s_old;

   for(INDEX=INDEX_min; INDEX<INDEX_max; INDEX++) // 27.0
     {
      for(k=0; k<ArrayRange(Ticket_b,1); k++)
        {
         for(m=0; m<ArrayRange(Ticket_b,2); m++)
           {
            Ticket_b[INDEX][k][m]=0; Ticket_s[INDEX][k][m]=0;
           }
        }

      for(k=0; k<ArrayRange(Time_b,1); k++)
        {
         for(m=0; m<ArrayRange(Time_b,2); m++)
           {
            Time_b[INDEX][k][m]=0; Time_s[INDEX][k][m]=0;
           }
        }
      //---------------

      for(k=0; k<Numb_Orders[INDEX]; k++) // 
        {
         Point_n=Order_form(k,"Pips");

         for(int i=0;i<OrdersTotal();i++)
            //+------------------------------------------------------------------+
            //|                                                                  |
            //+------------------------------------------------------------------+
           {
            b=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
            //          Alert(INDEX,"]]","ПРоход в текущих ",i);
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA+Point_n+INDEX)
              {
               if(TimeDayOfYear(OrderOpenTime())==DayOfYear())
                 {
                  Alert(INDEX,"]]","Нашел ордер для анализа в текущих № ",OrderTicket());
                  if(OrderType() == OP_BUY || OrderType() == OP_BUYSTOP || OrderType() == OP_BUYLIMIT ) Ticket_b[INDEX][0][0] = OrderTicket ();
                  if(OrderType() == OP_SELL || OrderType() == OP_SELLSTOP || OrderType() == OP_SELLLIMIT ) Ticket_s[INDEX][1][0] = OrderTicket ();
                 }
               else
                 {
                  Alert(INDEX,"]]","Нашел !!!  OLD - ордер для анализа в текущих № ",OrderTicket());
                  if(OrderType() == OP_BUY  )    {Ticket_b[INDEX_Old][b_old][0] = OrderTicket (); b_old++; }
                  if(OrderType() == OP_SELL )    {Ticket_s[INDEX_Old][s_old][0] = OrderTicket (); s_old++; }
                 }
              }

            if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA-Point_n+INDEX)
              {
               if(TimeDayOfYear(OrderOpenTime())==DayOfYear())
                 {
                  Alert(INDEX,"]]","Нашел ордер для анализа в текущих № ",OrderTicket());
                  if(OrderType() == OP_BUY || OrderType() == OP_BUYSTOP || OrderType() == OP_BUYLIMIT ) Ticket_b[INDEX][1][0] = OrderTicket ();
                  if(OrderType() == OP_SELL || OrderType() == OP_SELLSTOP || OrderType() == OP_SELLLIMIT ) Ticket_s[INDEX][0][0] = OrderTicket ();
                 }
               else
                 {
                  Alert(INDEX,"]]","Нашел !!!  OLD - ордер для анализа в текущих № ",OrderTicket());
                  if(OrderType() == OP_BUY  )    {Ticket_b[INDEX_Old][b_old][0] = OrderTicket (); b_old++; }
                  if(OrderType() == OP_SELL )    {Ticket_s[INDEX_Old][s_old][0] = OrderTicket (); s_old++; }
                 }
              }
           }
        }
      // ----------  Проверка закрытых торговых ордеров в истории --------     

      for(k=0; k<Numb_Orders[INDEX]; k++) // 
        {
         Point_n=Order_form(k,"Pips");

         for(int j=OrdersHistoryTotal()-1;j>=0;j--)
            //+------------------------------------------------------------------+
            //|                                                                  |
            //+------------------------------------------------------------------+
           {

            b=OrderSelect(j,SELECT_BY_POS,MODE_HISTORY);
            //      Alert(INDEX,"]]","ПРоход в закрытых ",j);
            if(TimeDayOfYear(OrderOpenTime())<DayOfYear()) break;

            if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA+Point_n+INDEX && TimeDayOfYear(OrderOpenTime())==DayOfYear() && (OrderType()==0 || OrderType()==1))
              {
               Alert(INDEX,"]]","Нашел ордер для анализа в закрытых № ",OrderTicket());
               if(OrderType() == OP_BUY)  {Ticket_b[INDEX][0][0] = OrderTicket (); Ticket_b[INDEX][0][8]=1;}
               if(OrderType() == OP_SELL) {Ticket_s[INDEX][1][0] = OrderTicket (); Ticket_s[INDEX][1][8]=1;}
              }

            if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA-Point_n+INDEX && TimeDayOfYear(OrderOpenTime())==DayOfYear() && (OrderType()==0 || OrderType()==1))
              {
               Alert(INDEX,"]]","Нашел ордер для анализа в закрытых № ",OrderTicket());
               if(OrderType() == OP_BUY)  {Ticket_b[INDEX][1][0] = OrderTicket ();Ticket_b[INDEX][1][8]=1;}
               if(OrderType() == OP_SELL) {Ticket_s[INDEX][0][0] = OrderTicket ();Ticket_s[INDEX][0][8]=1;}
              }
           }
        }
      Alert(INDEX,"]]",Symbol(),"_","Открытые сегодня Ticket_b[0]=",Ticket_b[INDEX][0][0],", Ticket_b[1]=",Ticket_b[INDEX][1][0]);
      Alert(INDEX,"]]",Symbol(),"_","Открытые сегодня Ticket_s[0]=",Ticket_s[INDEX][0][0],", Ticket_s[1]=",Ticket_s[INDEX][1][0]);

      Alert(INDEX_Old,"]]",Symbol(),"_","Открытые  OLD Ticket_b[0]=",Ticket_b[INDEX_Old][0][0],", Ticket_b[1]=",Ticket_b[INDEX_Old][1][0],", Ticket_b[2]=",Ticket_b[INDEX_Old][2][0]);
      Alert(INDEX_Old,"]]",Symbol(),"_","Открытые  OLD Ticket_s[0]=",Ticket_s[INDEX_Old][0][0],", Ticket_s[1]=",Ticket_s[INDEX_Old][1][0],", Ticket_s[2]=",Ticket_s[INDEX_Old][2][0]);
      if(b_old>s_old) Numb_Orders[INDEX_Old]=b_old; else  Numb_Orders[INDEX_Old]=s_old;
      Bezubyt_price_OLD();
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      if(Ticket_b[INDEX][0][0]!=0 || Ticket_b[INDEX][1][0]!=0 || Ticket_s[INDEX][0][0]!=0 || Ticket_s[INDEX][1][0]!=0)
        {
         if(Hour()+Minute()/60.0<=Time_work_max[INDEX] || Hour()+Minute()/60.0>Flat1_cl[INDEX])
           {
            datetime BeginDay=MathFloor(TimeCurrent()/86400)*86400;
            datetime end_work=BeginDay+Time_work_max[INDEX]*3600;
            Start_t[INDEX]= BeginDay+Flat1_op[INDEX] *3600;
            Stop_t[INDEX] =  BeginDay+Flat1_cl[INDEX] *3600;
            Limit_Time(clrPowderBlue);
            Limit_Search();
            Bezubyt_price();
            Flag_i_Limit[INDEX]=6;
            flag_order_op[INDEX]=1;
            flag_Limit[INDEX]=DayOfYear();
           }
         Lot(); Alert(INDEX,"]]",Symbol(),"_","Расчетное значение лота = ",Lots_New[INDEX]);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// ----------------------------  Функция определения ПРОСКАЛЬЗЫВАНИЯ ---------------------------
void Proskalz()
  {

   for(k=0; k<Numb_Orders[INDEX]; k++) // 
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {

      if(Ticket_s[INDEX][k][8]==0)
        {
         if(OrderSelect(Ticket_s[INDEX][k][0],SELECT_BY_TICKET))
           {
            if(OrderType()==OP_SELL) //  Открылся ордер SELL
              {
               if(OrderCloseTime()!=0)
                 {
                  Ticket_s[INDEX][k][8]=1;
                  continue;
                 }
               int pr_s=(Flat_Low[INDEX]-OrderOpenPrice())/Point+(OrderMagicNumber()-MAGICMA-INDEX);
               Alert(INDEX,"]]",Symbol(),"_Открылся ордер SELL [",k,"] , его проскальзывание = ",pr_s);
               //               Alert ("Flat_Low[INDEX]-OrderOpenPrice = ", (Flat_Low[INDEX]-OrderOpenPrice())/Point, ", OrderMagicNumber-MAGICMA = ", (OrderMagicNumber()-MAGICMA) );
               Ticket_s[INDEX][k][8]=1;
               Time_s[INDEX][k][1]=OrderOpenTime();

               if(pr_s>Slippage)
                 {
                  Alert(INDEX,"]]","Проскальзывание слишком большое, модифицируем SL и TP ордера");
/*
                  int Point_ns= Order_form(k,"Pips");
                  double SL_s = Flat_Hich[k]+spred+Point_ns *Point;
                  if(OrderStopLoss()!=SL_s)
                    {
                     Alert(INDEX,"]]"," Ордер раньше уже модифицировался, отбой");
                  continue;
                  }
*/
                  if(OrderModify(Ticket_s[INDEX][k][0],OrderOpenPrice(),OrderStopLoss()-pr_s*Point,OrderTakeProfit()-pr_s*Point,0,Blue)==false)
                    {
                     GLE=GetLastError();
                     Alert(INDEX,"]]","Ошибка модификации=",GLE);
                     if(Errors(GLE)==true)
                       {
                        if(OrderModify(Ticket_s[INDEX][k][0],OrderOpenPrice(),OrderStopLoss()-pr_s*Point,OrderTakeProfit()-pr_s*Point,0,Blue)==false)
                           Alert(INDEX,"]]","Новая ошибка модификации=",GetLastError());
                       }
                    }
                 }
              }
           }
        }
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      if(Ticket_b[INDEX][k][8]==0)
        {
         if(OrderSelect(Ticket_b[INDEX][k][0],SELECT_BY_TICKET))
           {
            if(OrderType()==OP_BUY) //  Открылся ордер BUY
              {
               if(OrderCloseTime()!=0)
                 {
                  Ticket_b[INDEX][k][8]=1;
                  continue;
                 }
               int pr_b=(OrderOpenPrice()-Flat_Hich[INDEX]-spred)/Point-OrderMagicNumber()+MAGICMA+INDEX;
               Alert(INDEX,"]]",Symbol(),"_Открылся ордер BUY[",k,"],его проскальзывание=",pr_b);
               //               Alert ("OrderOpenPrice()-Flat_Hich[INDEX]-spred=", (OrderOpenPrice()-Flat_Hich[INDEX]-spred)/Point, ",OrderMagicNumber-MAGICMA=", (OrderMagicNumber()-MAGICMA) );
               Ticket_b[INDEX][k][8]=1;
               Time_b[INDEX][k][1]=OrderOpenTime();

               if(pr_b>Slippage)
                 {
                  Alert(INDEX,"]]","Проскальзывание слишком большое,модифицируем SL и TP ордера");
/*                  
                  int Point_nb = Order_form(k, "Pips");
                  double SL_b = Flat_Low[k] + Point_nb *Point;
                  if (OrderStopLoss() != SL_b)
                  {
                  Alert(INDEX,"]]"," Ордер раньше уже модифицировался,отбой");
                     continue;
                    }
*/
                  if(OrderModify(Ticket_b[INDEX][k][0],OrderOpenPrice(),OrderStopLoss()+pr_b*Point,OrderTakeProfit()+pr_b*Point,0,Blue)==false)
                    {
                     GLE=GetLastError();
                     Alert(INDEX,"]]","Ошибка модификации = ",GLE);
                     if(Errors(GLE)==true)
                       {
                        if(OrderModify(Ticket_b[INDEX][k][0],OrderOpenPrice(),OrderStopLoss()+pr_b*Point,OrderTakeProfit()+pr_b*Point,0,Blue)==false)
                           Alert(INDEX,"]]","Новая ошибка модификации = ",GetLastError());
                       }
                    }
                 }
              }
           }
        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// ----------------------------  Функция защиты от резких движений в одном баре ---------------------------
void VeryNews()
  {
   int Bar_now=iBarShift(Symbol(),0,TimeCurrent(),true);
   int Tick_end=Number_Orders-1;
//-------------Если открылся SELL, а BUY еще нет-----
   if(Ticket_s[INDEX][0][2]>0 && Ticket_s[INDEX][Tick_end][2]>0 && Ticket_b[INDEX][0][2]==0 && Ticket_b[INDEX][Tick_end][2]==0)
     {
      if(iBarShift(Symbol(),0,Time_s[INDEX][Tick_end][1],true)==Bar_now)
        {
         for(k=0; k<Number_Orders; k++)
            //+------------------------------------------------------------------+
            //|                                                                  |
            //+------------------------------------------------------------------+
           {
            if(OrderSelect(Ticket_b[INDEX][k][0],SELECT_BY_TICKET))
              {
               if(OrderCloseTime()==0)
                 {
                  if(OrderDelete(Ticket_b[INDEX][k][0],Green)) Ticket_b[INDEX][k][0]=0;
                  //           Alert(INDEX,"]]","Удалил ордер покупки до начала следующего бара [",k);
                 }
               else
                 {
                  Ticket_b[INDEX][k][0]=0;
                  Alert(INDEX,"]]","Ордер покупки уже кто то удалил [",k);
                 }
              }
           }
         return;
        }
      else
        {

         for(k=0; k<Number_Orders; k++)
            //+------------------------------------------------------------------+
            //|                                                                  |
            //+------------------------------------------------------------------+
           {
            if(Ticket_b[INDEX][k][0]==0)
              {
               if(Bid>=Flat_Hich[INDEX])
                 {
                  Alert(INDEX,"]]",k,"] Цена уже ушла вверх, ордера БАЙ не открываю больше [",k);
                  Ticket_b[INDEX][k][2]=5;
                  Ticket_b[INDEX][k][1]=0;
                 }
               else
                 {
                  if(Ticket_b[INDEX][k][0]==0) Ticket_b[INDEX][k][0]=Send_Orders(4,k);
                  //            Alert(INDEX,"]]","Открыл ордер бай [",k,"__",Ticket_b[INDEX][k][0]);
                 }
              }
           }
        }
     }
//-------------Если открылся BUY , а SELL еще нет-----
   if(Ticket_s[INDEX][0][2]==0 && Ticket_s[INDEX][Tick_end][2]==0 && Ticket_b[INDEX][0][2]>0 && Ticket_b[INDEX][Tick_end][2]>0)
     {
      if(iBarShift(Symbol(),0,Time_b[INDEX][Tick_end][1],true)==Bar_now)
        {
         for(k=0; k<Number_Orders; k++)
            //+------------------------------------------------------------------+
            //|                                                                  |
            //+------------------------------------------------------------------+
           {
            if(OrderSelect(Ticket_s[INDEX][k][0],SELECT_BY_TICKET))
              {
               if(OrderCloseTime()==0)
                 {
                  if(OrderDelete(Ticket_s[INDEX][k][0],Green)) Ticket_s[INDEX][k][0]=0;
                  //          Alert(INDEX,"]]","Удалил ордер продажи до начала следующего бара [",k);
                 }
               else
                 {
                  Ticket_s[INDEX][k][0]=0;
                  Alert(INDEX,"]]","Ордер продажи уже кто то удалил [",k);
                 }
              }
           }
         return;
        }
      else
        {
         for(k=0; k<Number_Orders; k++)
            //+------------------------------------------------------------------+
            //|                                                                  |
            //+------------------------------------------------------------------+
           {
            if(Ticket_s[INDEX][k][0]==0)
              {
               if(Ask<=Flat_Low[INDEX])
                 {
                  Alert(INDEX,"]]",k,"] Цена уже ушла вниз, ордера СЕЛЛ не открываю больше [",k);
                  Ticket_s[INDEX][k][2]=5;
                  Ticket_s[INDEX][k][1]=0;
                 }
               else
                 {
                  if(Ticket_s[INDEX][k][0]==0) Ticket_s[INDEX][k][0]=Send_Orders(5,k);
                  //          Alert(INDEX,"]]","Открыл ордер СЕЛЛ [",k,"__",Ticket_s[INDEX][k][0]);

                 }
              }
           }
        }
     }
//---------------------------- 24,3  Agressiv ---------------------------------- Открытие третьих ордеров за день     

   if(Agressiv==true) // не хватает правил для (Number_Orders==1||
     {
      //-------------Если открылся SELL 1, BUY 1 уже закрылся,  а BUY 2 и SELL 2 еще нет-----
      if(Ticket_s[INDEX][0][2]>0 && Ticket_s[INDEX][Tick_end][2]>0 && Ticket_b[INDEX][0][2]==5 && Ticket_b[INDEX][Number_Orders][0]==0 && Ticket_s[INDEX][Number_Orders][0]==0)
        {
         if(iBarShift(Symbol(),0,Time_s[INDEX][Tick_end][1],true)!=Bar_now)
           {
            for(k=Number_Orders; k<Number_Orders*2; k++)
              {
               if(Bid>=Flat_Hich[INDEX])
                 {
                  Alert(INDEX,"]]",k,"] АГР Цена уже ушла вверх, ордера БАЙ_2 не открываю больше");
                  Ticket_b[INDEX][k][2]=5;
                  Ticket_b[INDEX][k][1]=0;
                  Ticket_b[INDEX][k][0]=1000;
                 }
               else
                 {
                  if(Ticket_b[INDEX][k][0]==0)
                    {
                     Ticket_b[INDEX][k][0]=Send_Orders(4,k);
                     Alert(INDEX,"]]","АГР Открыл ордер бай [",k,"__",Ticket_b[INDEX][k][0]);
                     if(Numb_Orders[INDEX]<Number_Orders*2) Numb_Orders[INDEX]++;
                    }
                 }
              }
            Bezubyt_price();
           }
        }
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //-------------Если открылся BUY 1, SELL 1 уже закрылся, а BUY 2 и SELL 2 еще нет-----
      if(Ticket_b[INDEX][0][2]>0 && Ticket_b[INDEX][Tick_end][2]>0 && Ticket_s[INDEX][0][2]==5 && Ticket_s[INDEX][Number_Orders][0]==0 && Ticket_b[INDEX][Number_Orders][0]==0)
        {
         if(iBarShift(Symbol(),0,Time_b[INDEX][Tick_end][1],true)!=Bar_now)
           {
            for(k=Number_Orders; k<Number_Orders*2; k++)
              {
               if(Ask<=Flat_Low[INDEX])
                 {
                  Alert(INDEX,"]]",k,"] АГР Цена уже ушла вниз, ордера СЕЛЛ_2 не открываю больше");
                  Ticket_s[INDEX][k][2]=5;
                  Ticket_s[INDEX][k][1]=0;
                  Ticket_s[INDEX][k][0]=1000;
                 }
               else
                 {
                  if(Ticket_s[INDEX][k][0]==0)
                    {
                     Ticket_s[INDEX][k][0]=Send_Orders(5,k);
                     Alert(INDEX,"]]","АГР Открыл ордер селл [",k,"__",Ticket_s[INDEX][k][0]);
                     if(Numb_Orders[INDEX]<Number_Orders*2) Numb_Orders[INDEX]++;
                    }
                 }
              }
            Bezubyt_price();
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//------------------------------  v24 Поиск недостающего объема для ECN PRO -----------------------------------------------

void LostLot()
  {
   bool Tick;
   for(k=0; k<Numb_Orders[INDEX]; k++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //-------Баи---------  
     {
      if(Ticket_b[INDEX][k][12]!=0)
        {
         for(int i=0;i<OrdersTotal();i++)
            //+------------------------------------------------------------------+
            //|                                                                  |
            //+------------------------------------------------------------------+
           {
            b=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

            int Point_b=Order_form(k,"Pips");
            int MG_b=MAGICMA+Point_b+INDEX;

            if(OrderType()==OP_BUY && OrderMagicNumber()==MG_b && OrderLots()<=Ticket_b[INDEX][k][12]) // Когда решится с комментарием, надо сюда его добавить вместо всех
              {
               Tick=0;
               for(m=0; m<Numb_Orders[INDEX]; m++)
                 {
                  if(Ticket_b[INDEX][m][0]==OrderTicket())
                    {
                     Tick=0;
                     break;
                    }
                  Tick=1;
                 }
               if(Tick==1) // Нашел ордер доп объема
                 {
                  Alert(INDEX,"]]","Нашел ордер доп.объема № ",OrderTicket(),". Его объем =",OrderLots(),". Его коммент: ",OrderComment());

                  double Lot_b=Ticket_b[INDEX][k][12]-OrderLots();
                  Ticket_b[INDEX][k][12]=Lot_b;

                  if(Lot_b==0)
                    {
                     Alert(INDEX,"]]",k,"] Объем БАЙ ордера собран полностью");

                     double LL_b=0;
                     for(int bb=0; bb<Numb_Orders[INDEX]; bb++)
                       {
                        LL_b+=Ticket_b[INDEX][bb][12];
                       }
                     if(LL_b==0)
                       {Lost_b[INDEX]=0; Alert(INDEX,"]]","Поиск объемов БАЙ полностью закончен");}
                    }
                  else
                    {
                     Alert(INDEX,"]]",k,"] Объем БАЙ еще собран неполностью, не хватает ",Lot_b);
                    }

                  for(m=Number_Orders; m<Numb_Orders[INDEX]+1; m++)
                    {
                     if(Ticket_b[INDEX][m][0]==0)
                       {
                        if(m==Numb_Orders[INDEX]) Numb_Orders[INDEX]++;
                        Ticket_b[INDEX][m][0]=OrderTicket();
                        Ticket_b[INDEX][m][1]=Ticket_b[INDEX][k][1];
                        Ticket_b[INDEX][m][11]=OrderLots();
                        Text_b[INDEX][m][0]=OrderComment();

                        Check_for_Close_1(Ticket_b[INDEX][m][0],m);
                        break;
                       }
                    }
                 }
              }
           }
        }
     }
//-------СЕЛЛЫ---------  
     {
      if(Ticket_s[INDEX][k][12]!=0)
        {
         for(int j=0;j<OrdersTotal();j++)
            //+------------------------------------------------------------------+
            //|                                                                  |
            //+------------------------------------------------------------------+
           {
            b=OrderSelect(j,SELECT_BY_POS,MODE_TRADES);

            int Point_s=-1*Order_form(k,"Pips");
            int MG_s=MAGICMA+Point_s+INDEX;

            if(OrderType()==OP_SELL && OrderMagicNumber()==MG_s && OrderLots()<=Ticket_s[INDEX][k][12]) // Когда решится с комментарием, надо сюда его добавить вместо всех
              {
               Tick=0;
               for(m=0; m<Numb_Orders[INDEX]; m++)
                 {
                  if(Ticket_s[INDEX][m][0]==OrderTicket())
                    {
                     Tick=0;
                     break;
                    }
                  Tick=1;
                 }
               if(Tick==1) // Нашел ордер доп объема
                 {
                  Alert(INDEX,"]]","Нашел ордер доп.объема № ",OrderTicket(),". Его объем =",OrderLots(),". Его коммент: ",OrderComment());

                  double Lot_s=Ticket_s[INDEX][k][12]-OrderLots();
                  if(Lot_s==0)
                    {
                     Alert(INDEX,"]]",k,"] Объем СЕЛЛ ордера собран полностью");

                     double LL_s=0;
                     for(int ss=0; ss<Numb_Orders[INDEX]; ss++)
                       {
                        LL_s+=Ticket_s[INDEX][ss][12];
                       }
                     if(LL_s==0)
                       {Lost_s[INDEX]=0; Alert(INDEX,"]]","Поиск объемов СЕЛЛ полностью закончен");}
                    }
                  else
                    {
                     Alert(INDEX,"]]",k,"] Объем СЕЛЛ еще собран неполностью, не хватает ",Lot_s);
                    }
                  Ticket_s[INDEX][k][12]=Lot_s;

                  for(m=Number_Orders; m<Numb_Orders[INDEX]+1; m++)
                    {
                     if(Ticket_s[INDEX][m][0]==0)
                       {
                        if(m==Numb_Orders[INDEX]) Numb_Orders[INDEX]++;
                        Ticket_s[INDEX][m][0]=OrderTicket();
                        Ticket_s[INDEX][m][1]=Ticket_s[INDEX][k][1];
                        Ticket_s[INDEX][m][11]=OrderLots();
                        Text_s[INDEX][m][0]=OrderComment();

                        Check_for_Close_1(Ticket_s[INDEX][m][0],m);
                        break;
                       }
                    }
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// ----------------------------  Функция отслежования закрытия ордеров советником(v11) --------------------------- !!!!!  

void Check_for_Close()
  {
/*[2] 0-не открыт
      1-открыт, отслеживаю
      2-закрылась первая часть
      3-вторая часть отслеживается по барам
      4-
      5-ордер закрыт
*/

//--------------------------        
   for(k=0; k<Numb_Orders[INDEX]; k++) // прогонка отслеживаемых ордеров в первую очередь
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(Ticket_b[INDEX][k][2]==1 || Ticket_b[INDEX][k][2]==2) Check_for_Close_2(Ticket_b[INDEX][k][0],k);   //закрытие первой части \\ первая часть уже закрыта
      if(Ticket_s[INDEX][k][2]== 1 || Ticket_s[INDEX] [k][2] == 2)  Check_for_Close_2(Ticket_s[INDEX] [k][0] , k);

      if(Ticket_b[INDEX][k][2]==3) Check_for_Close_3(Ticket_b[INDEX][k][0],k);  // вторая часть закрывается по барам
      if(Ticket_s[INDEX][k][2]== 3)  Check_for_Close_3(Ticket_s[INDEX] [k][0] , k);
     }

//--------------------------        
   for(k=0; k<Numb_Orders[INDEX]; k++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(Ticket_b[INDEX][k][2]==0) Check_for_Close_1(Ticket_b[INDEX][k][0],k);  // поиск открывшихся ордеров
      if(Ticket_s[INDEX][k][2]== 0)  Check_for_Close_1(Ticket_s[INDEX] [k][0] , k);

      if(Ticket_b[INDEX][k][2]!=0 && Ticket_b[INDEX][k][2]!=5) Check_for_Close_0(Ticket_b[INDEX][k][0],k);      // поиск закрывшихся ордеров    
      if(Ticket_s[INDEX][k][2]!= 0 && Ticket_s[INDEX] [k][2] != 5) Check_for_Close_0(Ticket_s[INDEX] [k][0] , k);
     }

//-------------------------- 

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+--------------------------------------------------------------------------------------------------------------------------------+

void Check_for_Close_0(int Ticket,int Index) // определения закрытия ордера
  {
   b=OrderSelect(Ticket,SELECT_BY_TICKET);         // если ордер уже сам закрылся, больше не отслеживаем
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(OrderCloseTime()!=0)
     {
      int Check_cl_new;
      Alert(INDEX,"]]",Ticket," Ордер закрылся, его коментарий: ",OrderComment());

      //-----------селы--------------------------------            
      if(OrderType()==OP_SELL)
        {
         if(OrderProfit()>0)
            Alert(INDEX,"]]",Symbol(),Index,"]_Прибыль при закрытии =",((OrderOpenPrice()-OrderClosePrice())/Point)," пунктов");
         else
            Alert(INDEX,"]]",Symbol(),Index,"]_Убыток при закрытии ",((-OrderOpenPrice()+OrderClosePrice())/Point),". Проскальзывание от SL =",((OrderClosePrice()-OrderStopLoss())/Point)," пунктов");
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if("to #"==StringSubstr(OrderComment(),0,4)) //  подхват закрываемой вручную части позиции
           {
            Check_cl_new=StringSubstr(OrderComment(),4,StrToInteger(StringLen(OrderComment())-4));
            Alert(INDEX,"]]","Остаток номера из коментария - ",StringSubstr(OrderComment(),4,StringLen(OrderComment())-4));
            Alert(INDEX,"]]","Подхватил новый SELL № ",Check_cl_new);
            Ticket_s[INDEX][Index][0]=Check_cl_new;
            //            Alert(INDEX,"]]","Новый ордер в массиве ",Ticket_s[INDEX][Index][0]);
            Ticket_s[INDEX][Index][7]=Ticket_s[INDEX][Index][7]-OrderLots();
            Alert(INDEX,"]]","Новый лот для закрытия = ",Ticket_s[INDEX][Index][7]);
            return;
           }
         Ticket_s[INDEX][Index][2]=5; Ticket_s[INDEX][Index][1]=0;
         //                Alert ("Параметр 5 для ", Ticket_s[INDEX] [Index][0]);
         return;
        }

      //-----------баи--------------------------------            
      if(OrderType()==OP_BUY)
        {
         if(OrderProfit()>0)
            Alert(INDEX,"]]",Symbol(),Index,"]_Прибыль при закрытии =",(( OrderClosePrice()-OrderOpenPrice())/Point)," пунктов");
         else
            Alert(INDEX,"]]",Symbol(),Index,"]_Убыток при закрытии ",(( -OrderClosePrice()+OrderOpenPrice())/Point),". Проскальзывание от SL =",((OrderStopLoss()-OrderClosePrice())/Point)," пунктов");
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if("to #"==StringSubstr(OrderComment(),0,4)) //  подхват закрываемой вручную части позиции
           {
            Check_cl_new=StringSubstr(OrderComment(),4,StrToInteger(StringLen(OrderComment())-4));
            Alert(INDEX,"]]","Остаток номера из коментария - ",StringSubstr(OrderComment(),4,StringLen(OrderComment())-4));
            Alert(INDEX,"]]","Подхватил новый BUY ",Check_cl_new);
            Ticket_b[INDEX][Index][0]=Check_cl_new;
            //            Alert(INDEX,"]]","Новый ордер в массиве ",Ticket_b[INDEX][Index][0]);
            Ticket_b[INDEX][Index][7]=Ticket_b[INDEX][Index][7]-OrderLots();
            Alert(INDEX,"]]","Новый лот для закрытия = ",Ticket_b[INDEX][Index][7]);
            return;
           }
         Ticket_b[INDEX][Index][2]=5; Ticket_b[INDEX][Index][1]=0;
         //              Alert ("Параметр 5 для ", Ticket_b[INDEX] [Index][0]);                 
         return;
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+--------------------------------------------------------------------------------------------------------------------------------+
void Check_for_Close_1(int Ticket,int Index) // выбираем отслеживаемый ордер
  {
   if(OrderSelect(Ticket,SELECT_BY_TICKET))
     {
      //----------------     
      if(OrderType()==OP_SELL) // ордер стал SELL
        {
         if(OrderCloseTime()!=0) // ордер уже закрылся где-то
           {
            Ticket_s[INDEX][Index][2]=5; Ticket_s[INDEX][Index][1]=0;
            return;
           }
         Ticket_s[INDEX][Index][2]=1;  // отслеживаем

                                       //         Ticket_s[INDEX] [Index][3]=OrderOpenPrice()-Point*TakeProfit_close;
         //         Ticket_s[INDEX] [Index][4]=OrderOpenPrice()-Point*TakeProfit_close_min;
         Ticket_s[INDEX] [Index][3]=OrderOpenPrice()-Point*Order_form (Index, "Take_midl");
         Ticket_s[INDEX] [Index][4]=OrderOpenPrice()-Point*Order_form (Index, "Take_min");
         Ticket_s[INDEX] [Index][5]=OrderOpenPrice()-Point*TakeProfit_close_max;
         Ticket_s[INDEX] [Index][6]=OrderOpenPrice()-Point*Proskalz_Level_2;
         Ticket_s[INDEX] [Index][7]=OrderLots();
         Ray(INDEX+"_Close_check_s_"+Index+DayOfYear(),TimeCurrent()+12000,Ticket_s[INDEX][Index][3],clrBlue,2);
         Ray(INDEX+"_Close_big_s_"+Index+DayOfYear(),TimeCurrent()+12000,Ticket_s[INDEX][Index][5],clrMaroon,2);
         if(DoubleClose)
           {Ray(INDEX+"_Close_check_s2_"+Index+DayOfYear(),TimeCurrent()+12000,Ticket_s[INDEX][Index][4],clrBlue,2);}
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         //         Alert(INDEX,"]]","!-!-!-!-!-!-!Следак Нашел открытый ордер s_",Index,"]  ",Ticket);

         if(OrderLots()!=Ticket_s[INDEX][Index][11])
           {
            Alert(INDEX,"]]",Index,"] Нужный объем СЕЛЛ не открылся, ордер № ",OrderTicket(),". Не хватило лотов = ",Ticket_s[INDEX][Index][11]-OrderLots());
            Ticket_s[INDEX][Index][12]=Ticket_s[INDEX][Index][11]-OrderLots();
            Lost_s[INDEX]=1;
           }

         return;
        }
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //----------------     
      if(OrderType()==OP_BUY)
        {
         if(OrderCloseTime()!=0) // ордер уже закрылся где-то
           {
            Ticket_b[INDEX][Index][2]=5; Ticket_b[INDEX][Index][1]=0;
            return;
           }
         Ticket_b[INDEX][Index][2]=1;  // отслеживаем

                                       //Ticket_b[INDEX] [Index][3]=OrderOpenPrice()+Point*TakeProfit_close;
         //Ticket_b[INDEX] [Index][4]=OrderOpenPrice()+Point*TakeProfit_close_min;
         Ticket_b[INDEX] [Index][3]=OrderOpenPrice()+Point*Order_form (Index, "Take_midl");
         Ticket_b[INDEX] [Index][4]=OrderOpenPrice()+Point*Order_form (Index, "Take_min");
         Ticket_b[INDEX] [Index][5]=OrderOpenPrice()+Point*TakeProfit_close_max;
         Ticket_b[INDEX] [Index][6]=OrderOpenPrice()+Point*Proskalz_Level_2;
         Ticket_b[INDEX] [Index][7]=OrderLots();
         Ray(INDEX+"_Close_check_b_"+Index+DayOfYear(),TimeCurrent()+12000,Ticket_b[INDEX][Index][3],clrBlue,2);
         Ray(INDEX+"_Close_big_b_"+Index+DayOfYear(),TimeCurrent()+12000,Ticket_b[INDEX][Index][5],clrMaroon,2);
         if(DoubleClose)
           {Ray(INDEX+"_Close_check_b2_"+Index+DayOfYear(),TimeCurrent()+12000,Ticket_b[INDEX][Index][4],clrBlue,2);}
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         //         Alert(INDEX,"]]","!-!-!-!-!-!-!Следак Нашел открытый ордер b_",Index,"]  ",Ticket);

         if(OrderLots()!=Ticket_b[INDEX][Index][11])
           {
            Alert(INDEX,"]]",Index,"] Нужный объем БАЙ не открылся, ордер № ",OrderTicket(),". Не хватило лотов = ",Ticket_b[INDEX][Index][11]-OrderLots());
            Ticket_b[INDEX][Index][12]=Ticket_b[INDEX][Index][11]-OrderLots();
            Lost_b[INDEX]=1;
           }

         return;
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+-----------------------------------------------------------------------------------------------------------------------------------------------------+
void Check_for_Close_2(int Ticket,int Index) //  срабатывание при достижении заданной цены
  {
   double Lot_clos_s,Lot_clos_b;

   b=OrderSelect(Ticket,SELECT_BY_TICKET);
//--Селы--
   if(OrderType()==OP_SELL)
     {
      //-----Закрытие первой части---
      if(Ticket_s[INDEX][Index][2]==1 && Ask<=Ticket_s[INDEX][Index][4] && DoubleClose) //   v17 закрытие первой части
        {
         if(One_part_long_cl==true)
           {
            if(Ticket_s[INDEX][Index][4]-Ask>Proskalz_delta*Point || High[0]-Ticket_s[INDEX][Index][4]>Proskalz_bar*Point)
              {
               Alert(INDEX,"]]",Symbol(),Index,"] Проскальзывание по закрытию 1ч составило =",(Ticket_s[INDEX][Index][4]-Ask)/Point);
               Alert(INDEX,"]]",Symbol(),Index,"] Большой бар по закрытию 1ч составил =",(High[0]-Ticket_s[INDEX][Index][4])/Point);

               Lot_clos_s=NormalizeDouble(Ticket_s[INDEX][Index][7]*Lot_koof_cl*Lot_koof_1part,2);   //  !!!!Нормолизация лота до 2х знаков после запятой - может не везде работать           
               if(Close_Ord(Ticket,Lot_clos_s)==true) {Ticket_s[INDEX][Index][2]=2;}

               return;
              }
           }
         Alert(INDEX,"]]",Symbol(),Index,"] Закрываю первую часть ордера. Ask =",DoubleToStr(Ask,Digits));

         Lot_clos_s=NormalizeDouble(Ticket_s[INDEX][Index][7]*Lot_koof_cl,2);   //  !!!!Нормолизация лота до 2х знаков после запятой - может не везде работать

         RefreshRates();
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(Ask<=Ticket_s[INDEX][Index][4]) // Защита от резкого отскока цены
           {

            if(OrderClose(Ticket,Lot_clos_s,Ask,Slippage,clrRed))
              {
               Ray(INDEX+"_Close_s2"+Index+DayOfYear(),TimeCurrent()+6000,Ask,clrAqua,2);
               b=OrderSelect(Ticket,SELECT_BY_TICKET);     //  отслеживания выйгрыша по v11 
               Alert(INDEX,"]]","Задавал цену =",DoubleToStr(Ask,Digits),", закрылось по = ",DoubleToStr(OrderClosePrice(),Digits));
               Alert(INDEX,"]]",Symbol(),Index,"]_Выйгрыш по закрытию первой части = ",(Ticket_s[INDEX][Index][4]-OrderClosePrice())/Point," пунктов + ",(OrderOpenPrice()-Ticket_s[INDEX][Index][4])/Point);

               if(Ticket_s[INDEX][Index][7]>MarketInfo(Symbol(),MODE_MINLOT)) // Мин. размер. лотов)
                 {
                  for(int pos=0;pos<=OrdersTotal();pos++) // поиск нового ордера
                    {
                     if(OrderSelect(pos,SELECT_BY_POS,MODE_TRADES)==false) continue;
                     if(OrderComment()=="from #"+Ticket) { int Tikt_s=OrderTicket(); break; }  // можно поменять условие выбора на открытость, бай / селл, валюта, маджик
                    }

                  Ticket_s[INDEX][Index][0]=Tikt_s;
                  Ticket=Tikt_s;
                  Ticket_s[INDEX][Index][7]=Ticket_s[INDEX][Index][7]-Lot_clos_s;

                  Alert(INDEX,"]]",Symbol(),Index,"] Новый ордер отслеживания = ",Ticket);
                  b=OrderSelect(Ticket,SELECT_BY_TICKET);
                  Alert(INDEX,"]]","Его магическое число= ",OrderMagicNumber(),", а коментарий = ",OrderComment());
                  Alert(INDEX,"]]",Symbol(),Index,"] Новый лот для закрытия = ",Ticket_s[INDEX][Index][7]);
                  Ticket_s[INDEX][Index][2]=2;
                 }
               return;
              }
            else
              {
               Alert(INDEX,"]]","Ошибка закрытия sell = ",GetLastError());
               Alert(INDEX,"]]",Ticket,", ",Lot_clos_s,", ",DoubleToStr(Ask,Digits));
              }
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         else
           {
            Alert(INDEX,"]]","Цена резко отскочила, советник не успел. Ask = ",DoubleToStr(Ask,Digits));
            return;
           }

        }
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //-----Закрытие второй части---
      if(Ask<=Ticket_s[INDEX][Index][3])
        {
         if(Two_part_long_cl)
           {
            if(Ticket_s[INDEX][Index][3]-Ask>Proskalz_delta*Point)
              {
               Alert(INDEX,"]]",Symbol(),Index,"] Проскальзывание по 2 закрытию большое и составило =",(Ticket_s[INDEX][Index][3]-Ask)/Point);
               Alert(INDEX,"]]",Symbol(),Index,"] Большой бар по закрытию при этом составил =",(High[0]-Ticket_s[INDEX][Index][3])/Point);
               Check_for_Close_3(Ticket,Index);
               return;
              }

            if(High[0]-Ticket_s[INDEX][Index][3]>Proskalz_bar*Point)
              {
               Alert(INDEX,"]]",Symbol(),Index,"] Большой бар по 2 закрытию составил =",(High[0]-Ticket_s[INDEX][Index][3])/Point);
               Alert(INDEX,"]]",Symbol(),Index,"] Проскальзывание по закрытию при этом составило =",(Ticket_s[INDEX][Index][3]-Ask)/Point);
               Check_for_Close_3(Ticket,Index);
               return;
              }
           }

         RefreshRates();
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(Ask<=Ticket_s[INDEX][Index][3]) // Защита от резкого отскока цены
           {
            if(OrderClose(Ticket,Ticket_s[INDEX][Index][7],Ask,Slippage,clrRed))
              {
               Ray(INDEX+"_Close_s"+Index+DayOfYear(),TimeCurrent()+6000,Ask,clrAqua,2);
               b=OrderSelect(Ticket,SELECT_BY_TICKET);     //  отслеживания выйгрыша по v11 
               Alert(INDEX,"]]","Задавал цену =",DoubleToStr(Ask,Digits),", закрылось по = ",DoubleToStr(OrderClosePrice(),Digits));
               Alert(INDEX,"]]",Symbol(),Index,"]_Выйгрыш по закрытию = ",(Ticket_s[INDEX][Index][3]-OrderClosePrice())/Point," пунктов + ",(OrderOpenPrice()-Ticket_s[INDEX][Index][3])/Point);
               Ticket_s[INDEX][Index][2]=5; Ticket_s[INDEX][Index][1]=0;
               return;
              }
            else
              {
               Alert(INDEX,"]]","Ошибка закрытия sell = ",GetLastError());
               Alert(INDEX,"]]",Ticket,", ",Ticket_s[INDEX][Index][7],", ",DoubleToStr(Ask,Digits));
              }
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         else
           {
            Alert(INDEX,"]]","Цена 2го закрытия резко отскочила, советник не успел. Ask = ",DoubleToStr(Ask,Digits));
            return;
           }
        }
     }
//--Баи--
   if(OrderType()==OP_BUY)
     {
      //-----Закрытие первой части---
      if(Ticket_b[INDEX][Index][2]==1 && Bid>=Ticket_b[INDEX][Index][4] && DoubleClose) //   v17 закрытие первой части
        {
         if(One_part_long_cl==true)
           {
            if(Bid-Ticket_b[INDEX][Index][4]>Proskalz_delta*Point || Ticket_b[INDEX][Index][4]-Low[0]>Proskalz_bar*Point)
              {
               Alert(INDEX,"]]",Symbol(),Index,"] Проскальзывание по закрытию 1ч составило =",(Bid-Ticket_b[INDEX][Index][4])/Point);
               Alert(INDEX,"]]",Symbol(),Index,"] Большой бар по закрытию 1ч составил =",(Ticket_b[INDEX][Index][4]-Low[0])/Point);

               Lot_clos_b=NormalizeDouble(Ticket_b[INDEX][Index][7]*Lot_koof_cl*Lot_koof_1part,2);   //  !!!!Нормолизация лота до 2х знаков после запятой - может не везде работать           
               if(Close_Ord(Ticket,Lot_clos_b)) Ticket_b[INDEX][Index][2]=2;

               return;
              }
           }

         Alert(INDEX,"]]",Symbol(),Index,"] Закрываю первую часть ордера. Bid =",DoubleToStr(Bid,Digits));

         Lot_clos_b=NormalizeDouble(Ticket_b[INDEX][Index][7]*Lot_koof_cl,2);   //  !!!!Нормолизация лота до 2х знаков после запятой - может не везде работать

         RefreshRates();
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(Bid>=Ticket_b[INDEX][Index][4]) // Защита от резкого отскока цены
           {

            if(OrderClose(Ticket,Lot_clos_b,Bid,Slippage,clrRed))
              {
               Ray(INDEX+"_Close_b2"+Index+DayOfYear(),TimeCurrent()+6000,Bid,clrAqua,2);
               b=OrderSelect(Ticket,SELECT_BY_TICKET);     //  отслеживания выйгрыша по v11 
               Alert(INDEX,"]]","Задавал цену =",DoubleToStr(Bid,Digits),", закрылось по = ",DoubleToStr(OrderClosePrice(),Digits));
               Alert(INDEX,"]]",Symbol(),Index,"]_Выйгрыш по закрытию первой части = ",(OrderClosePrice()-Ticket_b[INDEX][Index][4])/Point," пунктов + ",(Ticket_b[INDEX][Index][4]-OrderOpenPrice())/Point);

               if(Ticket_b[INDEX][Index][7]>MarketInfo(Symbol(),MODE_MINLOT)) // Мин. размер. лотов)
                 {

                  for(int poss=0;poss<=OrdersTotal();poss++) // поиск нового ордера
                    {
                     if(OrderSelect(poss,SELECT_BY_POS,MODE_TRADES)==false) continue;
                     if(OrderComment()=="from #"+Ticket) { int Tikt_b=OrderTicket(); break; }  // можно поменять условие выбора на открытость, бай / селл, валюта, маджик
                    }

                  Ticket_b[INDEX][Index][0]=Tikt_b;
                  Ticket=Tikt_b;
                  Ticket_b[INDEX][Index][7]=Ticket_b[INDEX][Index][7]-Lot_clos_b;

                  Alert(INDEX,"]]",Symbol(),Index,"] Новый ордер отслеживания = ",Ticket);
                  b=OrderSelect(Ticket,SELECT_BY_TICKET);
                  Alert(INDEX,"]]","Его магическое число= ",OrderMagicNumber(),", а коментарий = ",OrderComment());
                  Alert(INDEX,"]]",Symbol()," Новый лот для закрытия = ",Ticket_b[INDEX][Index][7]);
                  Ticket_b[INDEX][Index][2]=2;
                 }
               return;
              }
            else
              {
               Alert(INDEX,"]]","Ошибка закрытия buy = ",GetLastError());
               Alert(INDEX,"]]",Ticket,", ",Lot_clos_b,", ",DoubleToStr(Bid,Digits));
              }
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         else
           {
            Alert(INDEX,"]]","Цена резко отскочила, советник не успел. Bid = ",DoubleToStr(Bid,Digits));
            return;
           }

        }
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //-----Закрытие второй части---
      if(Bid>=Ticket_b[INDEX][Index][3])
        {
         if(Two_part_long_cl)
           {
            if(Bid-Ticket_b[INDEX][Index][3]>Proskalz_delta*Point)
              {
               Alert(INDEX,"]]",Symbol(),Index,"] Проскальзывание по 2 закрытию большое и составило =",(Bid-Ticket_b[INDEX][Index][3])/Point);
               Alert(INDEX,"]]",Symbol(),Index,"] Большой бар по закрытию при этом составил =",(Ticket_b[INDEX][Index][3]-Low[0])/Point);
               Check_for_Close_3(Ticket,Index);
               return;
              }

            if(Ticket_b[INDEX][Index][3]-Low[0]>Proskalz_bar*Point)
              {
               Alert(INDEX,"]]",Symbol(),Index,"] Большой бар по 2 закрытию составил =",(Ticket_b[INDEX][Index][3]-Low[0])/Point);
               Alert(INDEX,"]]",Symbol(),Index,"] Проскальзывание по закрытию при этом составило =",(Bid-Ticket_b[INDEX][Index][3])/Point);
               Check_for_Close_3(Ticket,Index);
               return;
              }
           }

         RefreshRates();
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(Bid>=Ticket_b[INDEX][Index][3]) // Защита от резкого отскока цены
           {
            if(OrderClose(Ticket,Ticket_b[INDEX][Index][7],Bid,Slippage,clrRed))
              {
               Ray(INDEX+"_Close_b"+Index+DayOfYear(),TimeCurrent()+6000,Bid,clrAqua,2);
               b=OrderSelect(Ticket,SELECT_BY_TICKET);     //  отслеживания выйгрыша по v11 
               Alert(INDEX,"]]","Задавал цену =",DoubleToStr(Bid,Digits),", закрылось по = ",DoubleToStr(OrderClosePrice(),Digits));
               Alert(INDEX,"]]",Symbol(),Index,"]_Выйгрыш по закрытию = ",(OrderClosePrice()-Ticket_b[INDEX][Index][3])/Point," пунктов + ",(Ticket_b[INDEX][Index][3]-OrderOpenPrice())/Point);
               Ticket_b[INDEX][Index][2]=5; Ticket_b[INDEX][Index][1]=0;
               return;
              }
            else
              {
               Alert(INDEX,"]]","Ошибка закрытия buy = ",GetLastError());
               Alert(INDEX,"]]",Ticket,", ",Ticket_b[INDEX][Index][7],", ",DoubleToStr(Bid,Digits));
              }
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         else
           {
            Alert(INDEX,"]]","Цена 2го закрытия резко отскочила, советник не успел. Bid = ",DoubleToStr(Bid,Digits));
            return;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void Check_for_Close_3(int Ticket,int Index) // Если проскальзывание при закрытии большое, то хочу закрыть по минимумам баров при резком скачке (тренде)
  {
   double SL,TP;

   b=OrderSelect(Ticket,SELECT_BY_TICKET);
   if(OrderCloseTime()!=0) return;
//--Селы--
   if(OrderType()==OP_SELL)
     {
      if(Ticket_s[INDEX][Index][2]!=3)
        {
         if(High[0]+spred>Flat_Low[INDEX])
           {
            Alert(INDEX,"]]",Index,"]_Хотел подтянуть к уровню ",Proskalz_SL,", но текущий бар слишком большой.");
            Ticket_s[INDEX][Index][2]=3;
            Time_s[INDEX][Index][0]=iTime(NULL,0,0);

            TP=OrderOpenPrice()-Proskalz_TP*Point;
            if(OrderTakeProfit()!=TP)
              {
               Alert(INDEX,"]] Обнаружил что TP еще не увеличивался, увеличиваю ");
               if(OrderModify(Ticket,OrderOpenPrice(),OrderStopLoss(),TP,0,clrDodgerBlue)==false)
                 {
                  Alert(INDEX,"]]",Symbol()," Ошибка модернизации ордера = ",GetLastError(),"___",Ticket,"_",OrderOpenPrice(),"_",OrderStopLoss(),"_",TP," Больше не пробую");
                 }
              }
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         else
           {
            Alert(INDEX,"]]",Symbol(),Index,"] Подтягиваем SL по большому проскальзыванию или бару на = ",Proskalz_SL);
            SL = OrderOpenPrice()- Proskalz_SL * Point;
            TP = OrderOpenPrice()- Proskalz_TP * Point;

            if(OrderModify(Ticket,OrderOpenPrice(),SL,TP,0,clrDodgerBlue)==false)
              {
               Alert(INDEX,"]]",Symbol()," Ошибка модернизации ордера по большому проскальзыванию = ",GetLastError(),"___",Ticket,"_",OrderOpenPrice(),"_",SL,"_",TP);
               return;
              }
            Ticket_s[INDEX][Index][2]=3;
            Time_s[INDEX][Index][0]=iTime(NULL,0,0);
           }
        }
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      if(Ticket_s[INDEX][Index][6]!=0 && Ask<=Ticket_s[INDEX][Index][6]) //   v18.2 Подтягивание ко второму уровню
        {

         if(High[0]+spred>Flat_Low[INDEX])
           {
            Alert(INDEX,"]]",Index,"]_Хотел подтянуть ко второму уровню ",TakeProfit_close,", но текущий бар еще слишком большой");
            Ticket_s[INDEX][Index][6]=0;
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         else
           {
            Alert(INDEX,"]]",Symbol(),Index,"] Подтягиваю SL ордера ко второму уровню на = ",TakeProfit_close);

            b=OrderSelect(Ticket,SELECT_BY_TICKET);
            SL = OrderOpenPrice()- TakeProfit_close * Point;
            TP = OrderOpenPrice()- Proskalz_TP * Point;

            if(OrderStopLoss()<=SL)
              {
               Alert(INDEX,"]]","Хотел подтянуть SL по второму уровню, но SL уже лучше. ");
               Ticket_s[INDEX][Index][6]=0;

               if(OrderTakeProfit()!=TP)
                 {
                  Alert(INDEX,"]] Обнаружил что TP еще не увеличивался, увеличиваю ");
                  if(OrderModify(Ticket,OrderOpenPrice(),OrderStopLoss(),TP,0,clrDodgerBlue)==false)
                    {
                     Alert(INDEX,"]]",Symbol()," Ошибка модернизации ордера = ",GetLastError(),"___",Ticket,"_",OrderOpenPrice(),"_",OrderStopLoss(),"_",TP," Больше не пробую");
                    }
                 }

               return;
              }

            if(OrderModify(Ticket,OrderOpenPrice(),SL,TP,0,clrDodgerBlue)==false)
              {
               Alert(INDEX,"]]",Symbol()," Ошибка модернизации ордера по второму уровню = ",GetLastError(),"___",Ticket,"_",OrderOpenPrice(),"_",SL,"_",TP," Больше не пробую");
               return;
              }
            Ticket_s[INDEX][Index][6]=0;
           }
        }

      if(Ticket_s[INDEX][Index][5]!=0 && Ask<=Ticket_s[INDEX][Index][5] && DoubleClose_big) //   v17.4 закрытие первой части по большой цене
        {
         Alert(INDEX,"]]",Symbol(),Index,"] Закрываю часть ордера по большой цене");
         double Lot_clos_s=NormalizeDouble(Ticket_s[INDEX][Index][7]*Lot_koof_cl_big,2);   //  !!!!Нормолизация лота до 2х знаков после запятой - может не везде работать            
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(OrderClose(Ticket,Lot_clos_s,Ask,Slippage,clrRed))
           {
            Ray(INDEX+"_Close_big_s2"+Index+DayOfYear(),TimeCurrent()+6000,Bid,clrAqua,2);
            b=OrderSelect(Ticket,SELECT_BY_TICKET);     //  отслеживания выйгрыша по v11 
            Alert(INDEX,"]]","Задавал цену =",DoubleToStr(Ask,Digits),", закрылось по = ",DoubleToStr(OrderClosePrice(),Digits));
            Alert(INDEX,"]]",Symbol(),Index,"]_Выйгрыш по закрытию части = ",(Ticket_s[INDEX][Index][5]-OrderClosePrice())/Point," пунктов + ",TakeProfit_close_max);

            for(int pos=0;pos<=OrdersTotal();pos++) // поиск нового ордера
              {
               if(OrderSelect(pos,SELECT_BY_POS,MODE_TRADES)==false) continue;
               if(OrderComment()=="from #"+Ticket) { int Tikt_s=OrderTicket(); break; }  // можно поменять условие выбора на открытость, бай / селл, валюта, маджик
              }
            Ticket_s[INDEX][Index][0]=Tikt_s;
            Ticket=Tikt_s;
            Ticket_s[INDEX][Index][7]=Ticket_s[INDEX][Index][7]-Lot_clos_s;

            Alert(INDEX,"]]",Symbol(),Index,"] Новый ордер отслеживания = ",Ticket);
            b=OrderSelect(Ticket,SELECT_BY_TICKET);
            Alert(INDEX,"]]","Его магическое число= ",OrderMagicNumber(),", а коментарий = ",OrderComment());
            Alert(INDEX,"]]",Symbol()," Новый лот для закрытия = ",Ticket_s[INDEX][Index][7]);
            Ticket_s[INDEX][Index][5]=0;
            return;
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         else
           {
            Alert(INDEX,"]]","Ошибка закрытия SELL = ",GetLastError());
            Alert(INDEX,"]]",Ticket,", ",Lot_clos_s,", ",DoubleToStr(Ask,Digits));
           }
        }

      if(Time_s[INDEX][Index][0]!=iTime(NULL,0,0)) //  Функция работы с приходом нового бара
        {
         SL=iHigh(NULL,0,1)+spred;
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(OrderSelect(Ticket,SELECT_BY_TICKET))
           {
            if(SL>=OrderStopLoss()) // если новый SL хуже старого, то не подтягиваю 
              {
               Time_s[INDEX][Index][0]=iTime(NULL,0,0);
               return;
              }

            if(Price_SL[INDEX]==0 || Price_SL[INDEX]>Ask)
              {

               Alert(INDEX,"]]",Symbol(),Index,"] Подтягиваем SL по максимуму предыдущего бара");
               if(OrderModify(Ticket,OrderOpenPrice(),SL,OrderTakeProfit(),0,clrDodgerBlue)==false)
                 {
                  Alert(INDEX,"]]",Symbol()," Ошибка модернизации ордера по подтягиванию SL = ",GetLastError(),"_",Ticket,"_",OrderOpenPrice(),"_",SL,"_",OrderTakeProfit());
                  Alert(INDEX,"]]","Между новым SL и Ask ",(SL-Ask)/Point," пунктов");
                  Price_SL[INDEX]=Ask;
                  return;
                 }
               else
                 {
                  Alert(INDEX,"]]",Symbol(),Index,"] Ордер уже заработал ",((OrderOpenPrice()-SL)/Point)," пунктов");
                  Time_s[INDEX][Index][0]=iTime(NULL,0,0);
                  Price_SL[INDEX]=0;
                 }
              }
           }
        }
     }
//------------------------------------------------------------------------------

//--Баи--
   if(OrderType()==OP_BUY)
     {
      if(Ticket_b[INDEX][Index][2]!=3)
        {

         if(Low[0]<Flat_Hich[INDEX])
           {
            Alert(INDEX,"]]",Index,"]_Хотел подтянуть к уровню ",Proskalz_SL,", но текущий бар слишком большой.");
            Ticket_b[INDEX][Index][2]=3;
            Time_b[INDEX][Index][0]=iTime(NULL,0,0);

            TP=OrderOpenPrice()+Proskalz_TP*Point;
            if(OrderTakeProfit()!=TP)
              {
               Alert(INDEX,"]] Обнаружил что TP еще не увеличивался, увеличиваю ");
               if(OrderModify(Ticket,OrderOpenPrice(),OrderStopLoss(),TP,0,clrDodgerBlue)==false)
                 {
                  Alert(INDEX,"]]",Symbol()," Ошибка модернизации ордера = ",GetLastError(),"___",Ticket,"_",OrderOpenPrice(),"_",OrderStopLoss(),"_",TP," Больше не пробую");
                 }
              }

           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         else
           {

            Alert(INDEX,"]]",Symbol(),Index,"] Подтягиваем SL по большому проскальзыванию или бару на =",Proskalz_SL);
            SL = OrderOpenPrice()+ Proskalz_SL * Point;
            TP = OrderOpenPrice()+ Proskalz_TP * Point;
            if(OrderModify(Ticket,OrderOpenPrice(),SL,TP,0,clrDodgerBlue)==false)
              {
               Alert(INDEX,"]]",Symbol()," Ошибка модернизации ордера по большому проскальзыванию = ",GetLastError(),"___",Ticket,"_",OrderOpenPrice(),"_",SL,"_",TP);
               return;
              }
            Ticket_b[INDEX][Index][2]=3;
            Time_b[INDEX][Index][0]=iTime(NULL,0,0);
           }
        }
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      if(Ticket_b[INDEX][Index][6]!=0 && Bid>=Ticket_b[INDEX][Index][6]) //   v18.2 Подтягивание ко второму уровню
        {
         if(Low[0]<Flat_Hich[INDEX])
           {
            Alert(INDEX,"]]",Index,"]_Хотел подтянуть ко второму уровню ",TakeProfit_close,", но текущий бар еще слишком большой");
            Ticket_b[INDEX][Index][6]=0;
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         else
           {

            Alert(INDEX,"]]",Symbol(),Index,"] Подтягиваю SL ордера ко второму уровню на = ",TakeProfit_close);

            b=OrderSelect(Ticket,SELECT_BY_TICKET);
            SL = OrderOpenPrice()+ TakeProfit_close * Point;
            TP = OrderOpenPrice()+ Proskalz_TP * Point;

            if(OrderStopLoss()>=SL)
              {
               Alert(INDEX,"]]","Хотел подтянуть SL по второму уровню, но SL уже лучше. ");
               Ticket_b[INDEX][Index][6]=0;

               if(OrderTakeProfit()!=TP)
                 {
                  Alert(INDEX,"]] Обнаружил что TP еще не увеличивался, увеличиваю ");
                  if(OrderModify(Ticket,OrderOpenPrice(),OrderStopLoss(),TP,0,clrDodgerBlue)==false)
                    {
                     Alert(INDEX,"]]",Symbol()," Ошибка модернизации ордера = ",GetLastError(),"___",Ticket,"_",OrderOpenPrice(),"_",OrderStopLoss(),"_",TP," Больше не пробую");
                    }
                 }

               return;
              }

            if(OrderModify(Ticket,OrderOpenPrice(),SL,TP,0,clrDodgerBlue)==false)
              {
               Alert(INDEX,"]]",Symbol()," Ошибка модернизации ордера по второму уровню = ",GetLastError(),"___",Ticket,"_",OrderOpenPrice(),"_",SL,"_",TP);
               return;
              }
            Ticket_b[INDEX][Index][6]=0;
           }
        }

      if(Ticket_b[INDEX][Index][5]!=0 && Bid>=Ticket_b[INDEX][Index][5] && DoubleClose_big) //   v17.4 закрытие первой части по большой цене
        {
         Alert(INDEX,"]]",Symbol(),Index,"] Закрываю часть ордера по большой цене");
         double Lot_clos_b=NormalizeDouble(Ticket_b[INDEX][Index][7]*Lot_koof_cl_big,2);   //  !!!!Нормолизация лота до 2х знаков после запятой - может не везде работать            
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(OrderClose(Ticket,Lot_clos_b,Bid,Slippage,clrRed))
           {
            Ray(INDEX+"_Close_big_b2"+Index+DayOfYear(),TimeCurrent()+6000,Bid,clrAqua,2);
            b=OrderSelect(Ticket,SELECT_BY_TICKET);     //  отслеживания выйгрыша по v11 
            Alert(INDEX,"]]","Задавал цену =",DoubleToStr(Bid,Digits),", закрылось по = ",DoubleToStr(OrderClosePrice(),Digits));
            Alert(INDEX,"]]",Symbol(),Index,"]_Выйгрыш по закрытию части = ",(OrderClosePrice()-Ticket_b[INDEX][Index][5])/Point," пунктов + ",TakeProfit_close_max);

            for(int poss=0;poss<=OrdersTotal();poss++) // поиск нового ордера
              {
               if(OrderSelect(poss,SELECT_BY_POS,MODE_TRADES)==false) continue;
               if(OrderComment()=="from #"+Ticket) { int Tikt_b=OrderTicket(); break; }  // можно поменять условие выбора на открытость, бай / селл, валюта, маджик
              }
            Ticket_b[INDEX][Index][0]=Tikt_b;
            Ticket=Tikt_b;
            Ticket_b[INDEX][Index][7]=Ticket_b[INDEX][Index][7]-Lot_clos_b;

            Alert(INDEX,"]]",Symbol(),Index,"] Новый ордер отслеживания = ",Ticket);
            b=OrderSelect(Ticket,SELECT_BY_TICKET);
            Alert(INDEX,"]]","Его магическое число= ",OrderMagicNumber(),", а коментарий = ",OrderComment());
            Alert(INDEX,"]]",Symbol()," Новый лот для закрытия = ",Ticket_b[INDEX][Index][7]);
            Ticket_b[INDEX][Index][5]=0;
            return;
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         else
           {
            Alert(INDEX,"]]","Ошибка закрытия BUY = ",GetLastError());
            Alert(INDEX,"]]",Ticket,", ",Lot_clos_b,", ",DoubleToStr(Bid,Digits));
           }
        }

      if(Time_b[INDEX][Index][0]!=iTime(NULL,0,0)) //  Функция работы с приходом нового бара
        {
         SL=iLow(NULL,0,1);
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(OrderSelect(Ticket,SELECT_BY_TICKET))
           {
            if(SL<=OrderStopLoss()) // если новый SL хуже старого, то не подтягиваю 
              {
               Time_b[INDEX][Index][0]=iTime(NULL,0,0);
               return;
              }

            if(Price_SL[INDEX]==0 || Price_SL[INDEX]<Bid)
              {
               Alert(INDEX,"]]",Symbol(),Index,"] Подтягиваем SL по минимуму предыдущего бара");
               if(OrderModify(Ticket,OrderOpenPrice(),SL,OrderTakeProfit(),0,clrDodgerBlue)==false)
                 {
                  Alert(INDEX,"]]",Symbol()," Ошибка модернизации ордера по подтягиванию SL = ",GetLastError(),"___",Ticket,"_",OrderOpenPrice(),"_",SL,"_",OrderTakeProfit());
                  Alert(INDEX,"]]","Между новым Bid и SL ",(Bid-SL)/Point," пунктов");
                  Price_SL[INDEX]=Bid;
                  return;
                 }
               else
                 {
                  Alert(INDEX,"]]",Symbol(),Index,"] Ордер уже заработал ",((SL-OrderOpenPrice())/Point)," пунктов");
                  Time_b[INDEX][Index][0]=iTime(NULL,0,0);
                  Price_SL[INDEX]=0;
                 }
              }
           }
        }
     }
  }

//+------------------------------------------------------------------------------------------------------------------------------------------------------+
void Check_for_Close_5() // установка тейка на стандартный уровень, после конца рабочего дня
  {/*
         double TP;

         if(Ticket == Ticket_s[INDEX] || Ticket == Ticket_s2 ) TP = Ticket_s[INDEX] [Index][3];
         if(Ticket == Ticket_b[INDEX] || Ticket == Ticket_b2 ) TP = Ticket_b[INDEX] [Index][3];
         Alert(INDEX,"]]",Symbol(),"_Модификация TP вечером, по закрытию или новому дню. Уровень = ",TP);
         if(OrderSelect(Ticket,SELECT_BY_TICKET))
           {
            if(OrderModify(Ticket,OrderOpenPrice(),OrderStopLoss(),TP,0,clrMagenta)==false)
               Alert(INDEX,"]]",Symbol(),"_ Ошибка модификации закрытия = ",GetLastError());
            Alert(INDEX,"]]",Symbol(),"_ Цена Bid = ",Bid," цена Ask = ",Ask);
            Ticket = 0; return;
           }
   */     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Check_for_Close_6() //  срабатывание при достижении заданной цены без всяких заморочек
  {/*
         if(Ticket==Ticket_s[INDEX] || Ticket==Ticket_s2) // ????  может в шапку вынести
           {

            if(Ask<=Ticket_s[INDEX] [Index][3])
              {

               if(OrderClose(Ticket,Ticket__ [Index][7],Ask,Slippage,clrRed))
                 {
                  Ray(INDEX+"_Close_s",TimeCurrent()+6000,Ask,clrAqua,2);
                  OrderSelect(Ticket,SELECT_BY_TICKET);     //  отслеживания выйгрыша по v11 
                  Alert(INDEX,"]]",Symbol(),"_Выйгрыш по закрытию = ",(Ticket_s[INDEX] [Index][3]-OrderClosePrice())/Point," пунктов");
                  Ticket=0;
                  return;
                 }
               else
                 {
                  Alert(INDEX,"]]","Ошибка закрытия sell = ",GetLastError());
                  Alert(INDEX,"]]",Ticket,", ",Ticket__ [Index][7],", ",Ask);
                 }
              }
           }

         if(Ticket==Ticket_b[INDEX] || Ticket==Ticket_b2) // ????  может в шапку вынести
           {

            if(Bid>=Ticket_b[INDEX] [Index][3])
              {
               if(OrderClose(Ticket,Ticket__ [Index][7],Bid,Slippage,clrRed))
                 {
                  Ray(INDEX+"_Close_b",TimeCurrent()+6000,Bid,clrAqua,2);
                  OrderSelect(Ticket,SELECT_BY_TICKET);     //  отслеживания выйгрыша по v11 
                  Alert(INDEX,"]]",Symbol(),"_Выйгрыш по закрытию = ",(OrderClosePrice()-Ticket_b[INDEX] [Index][3])/Point," пунктов");
                  Ticket=0;
                  return;
                 }
               else
                 {
                  Alert(INDEX,"]]","Ошибка закрытия buy = ",GetLastError());
                  Alert(INDEX,"]]",Ticket,", ",Ticket__ [Index][7],", ",Bid);
                 }
              }
           }
    */    }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//--- Отрисовка прямого луча из точки ------------------------------------------------------------------------------------------------------------------------

void Ray(string Name,datetime Time1,double Level,color Clr,int Width)

  {
   string R_name=Name+"_"+DayOfYear();
   datetime Time2=TimeCurrent();
   ObjectDelete(R_name);
   ObjectCreate(R_name,OBJ_TREND,0,Time1,Level,Time2,Level);//  ,Time1+100000,Level);

   ObjectSet(R_name,OBJPROP_RAY_LEFT,false);  ObjectSet(R_name,OBJPROP_RAY_RIGHT,false);
   ObjectSet(R_name,OBJPROP_COLOR,Clr);
   ObjectSet(R_name,OBJPROP_WIDTH,Width);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//--------------------------------------------------------------------
// Errors.mqh
// Предназначен для использования в качестве примера в учебнике MQL4.
//--------------------------------------------------------------- 1 --
// Функция обработки ошибок.
// Возвращаемые значения:
// true  - если ошибка преодолимая (т.е. можно продолжать работу)
// false - если ошибка критическая (т.е. торговать нельзя)
//--------------------------------------------------------------- 2 --
bool Errors(int Error) // Пользовательская функция
  {
// Error             // Номер ошибки   
//   if(Error==0)
//      return(false);                      // Нет ошибки
//--------------------------------------------------------------- 3 --
   switch(Error)
     {   // Преодолимые ошибки:
      case 129:         // Неправильная цена
      case 135:         // Цена изменилась
         RefreshRates();                  // Обновим данные
         return(true);                    // Ошибка преодолимая
      case 136:         // Нет цен. Ждём новый тик.
         while(RefreshRates()==false) // До нового тика
         Sleep(1);                     // Задержка в цикле
         return(true);                    // Ошибка преодолимая
      case 146:         // Подсистема торговли занята
         Sleep(500);                      // Простое решение
         RefreshRates();                  // Обновим данные
         return(true);                    // Ошибка преодолимая

                                          // Критические ошибки:
      case 2 :          // Общая ошибка
      case 5 :          // Старая версия клиентского терминала
      case 64:          // Счет заблокирован
      case 133:         // Торговля запрещена
         return(false);                   // Критическая ошибка

      default:          // Другие варианты      
         return(true);                   // Если ничего не подошло, то занаво
     }
//--------------------------------------------------------------- 4 --
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//--- Экстремумы из ЗигЗага  ------------------------------------------------------------------------------------------------------------------------

void Zigzag(int Chikl)
  {
   int i,j;
//  int k;
//  int m=0;  // для уменьшения расчетов, если нового ЗигЗага нет
   m=0;  // для уменьшения расчетов, если нового ЗигЗага нет
   int zzbar[],zzp[];
   double zz;
   int ExtDepth=12,ExtDeviation=5,ExtBackstep=3;

   for(i=0,j=0;i<Bars && j<Chikl;i++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      zz=iCustom(NULL,0,"ZigZag",ExtDepth,ExtDeviation,ExtBackstep,0,i);
      if(zz!=0)
        {
         zzbar[j]=i;
         zzp[j]=zz;
         //Alert ("Значение зига =", zz); 
         datetime ZZ_time=iTime(NULL,0,i);
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(m==0) // для уменьшения расчетов, если нового ЗигЗага нет при повторном запуске функции
           {
            if(Zig_time_old == ZZ_time) return;
            Zig_time_old=ZZ_time;
            m=1;
           }

         if(iLow(NULL,0,i)==zz) Ray(INDEX+"_Zig_"+j,ZZ_time,zz,clrRed,0);
         if(iHigh(NULL,0,i)==zz) Ray(INDEX+"_Zig_"+j,ZZ_time,zz,clrBlue,0);

         j++;
        }
     }

   for(k=j;k<100;k++) // удаляем старые уровни  при повторном запуске функции
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(ObjectDelete("Zig_"+k+"_"+DayOfYear()));
      else break;  // если закончились, то выходим
     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//------------------------------------------------------------------------------------------------------------------------------------------------
// закрытие ордера по лоту

bool Close_Ord(int Ticket,double Lot) //  закрытие ордера 
  {
   Alert(INDEX,"]]","Закрываю часть ордера № ",Ticket," лотом = ",Lot);
   if(OrderSelect(Ticket,SELECT_BY_TICKET)==false)
     { Alert(INDEX,"]]",Symbol(),"Ошибка выбора ордера № ",GetLastError()); return(true); }

   double Price;
   if(OrderType()!=OP_BUY && OrderType()!=OP_SELL)
     { Alert(INDEX,"]]",Symbol(),"Ордер # ",Ticket," не рыночный"); return(true); }

   if(Lot>OrderLots() || Lot==0) Lot=OrderLots();

   RefreshRates();
   if(OrderType() == OP_BUY ) Price = Bid;
   if(OrderType() == OP_SELL ) Price = Ask;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(OrderClose(Ticket,Lot,Price,Slippage,clrRed))
     {
      Alert(INDEX,"]]","Задавал цену = ",DoubleToStr(Price,Digits),", закрылось по = ",DoubleToStr(OrderClosePrice(),Digits));
      return (true);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      Alert(INDEX,"]]",Symbol()," Ошибка закрытия ордера # ",Ticket,", ошибка # ",GetLastError());
      Alert(INDEX,"]]",Ticket," , ",Lot," , ",DoubleToStr(Price,Digits));
      return (false);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------
double Order_form(int Index,string Form)
  {
///-----Всего один ордер в сторону (старая схема)--------------------------------------------------  

   if(Number_Orders==1)
     {
      if(Form=="Bezub") return(1);
      if(Form=="Pips") return(0);
      if(Form=="Take_min") return (TakeProfit_close_min);
      if(Form=="Take_midl") return (TakeProfit_close);

      Alert(INDEX,"]]","Ошибка в функции Order_form  ",Index," , ",Form);
      return (1000000000);
     }
///----------------------------------------------------------     
   if(Form=="Bezub")
     {
      if(Index==0||Index==2) return( Bezubytok_profit_0 );
      if(Index==1||Index==3) return( Bezubytok_profit_1 );
     }
///---------------------------------------------------------------     
   if(Form=="Pips")
     {
      if(Index==0||Index==2) return(-Number_Point);
      if(Index==1||Index==3) return ( Number_Point);
     }
///---------------------------------------------------------------     
   if(Form=="Take_min")
     {
      if(Index==0||Index==2) return (TakeProfit_close_min);

      if(Index==1 || Index==3)
        {
         if((TakeProfit_close_min+TakeProfit_close)/2>(Flat_Delta[INDEX]/Point+Spred) || Test_flag[INDEX]==1)
            return ( TakeProfit_close_min );
         else
            return ( Flat_Delta[INDEX]/Point - 100 + Spred );
        }
     }
///---------------------------------------------------------------     
   if(Form=="Take_midl")
     {
      if(Index==0||Index==2) return (TakeProfit_close);

      if(Index==1 || Index==3)
        {
         if((TakeProfit_close_min+TakeProfit_close)/2>(Flat_Delta[INDEX]/Point+Spred) || Test_flag[INDEX]==1)
            return ( TakeProfit_close );
         else
            return (Flat_Delta[INDEX]/Point + 100 + Spred );
        }
     }

   Alert(INDEX,"]]","Ошибка в функции Order_form  ",Index," , ",Form);
   return (1000000000);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//------------------------------------------------------------ РОЛЛОВЕРЫ --------------------------------------------------------------------- 

void Rollover()
  {
   Rol_Check();
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(Rol_koef<0) // уменьшение
     {
      Decrease();
      //     Delayed_cor();
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(Rol_koef>0) // увеличение  
     {
      Increase();
      //    Delayed_cor();
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+ Проверка ролловеров
void Rol_Check() // Проверка ролловеров
  {
   int Rol_ti,Rol_pr=0;
   double Balance_Change=0.0,Equity;

   int total=OrdersHistoryTotal();
   for(int i=total; i>0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      b=OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
      if(OrderType()==6) // балансовая операция   
        {
         Rol_ti=OrderTicket();
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(Rol_ti>Ticket_rol)
           {
            Alert(INDEX,"]]","=-=-=-=- Учитываю операцию ролловера № ",OrderTicket());
            Balance_Change+=OrderProfit();   // общее изменение баланса на ролловерах
            if(Rol_ti>Rol_pr) Rol_pr=Rol_ti;
           }
         else break;  //   если проверяемые ордера уже старее или равен Ticket_rol 
        }
     }

   if(Balance!=0) Alert(INDEX,"]]","Вводной баланс = ",Balance);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(Rol_pr!=0 || Balance!=0)
     {
      if(Rol_pr!=0) Ticket_rol=Rol_pr;
      GlobalVariableSet(Rollover_name,Ticket_rol);   // глобальная переменная ролловера

      if(OrdersTotal()==0)
        {
         Rol_koef=0;
         Alert(INDEX,"]]","Открытых ордеров для корректировки нет");
         return;
        }

      Equity=AccountEquity();
      if(Equity!=Balance_Change)// защита от ошибки деления на 0  
         //         Rol_koef=Balance_Change/(Equity-Balance_Change);
         Rol_koef=(Balance_Change+Balance)/(Equity-Balance_Change-Balance);
      else Rol_koef=0.0000001;

      Balance=0;

      Alert(INDEX,"]]","Изменение баланса по неучтенным ролам =                                          ",Balance_Change);
      Alert(INDEX,"]]","Баланс до изменения на роловере = ",Equity-Balance_Change);
      Alert(INDEX,"]]","Новый последний ролловер № ",Ticket_rol);
      Alert(INDEX,"]]","Коэффициент ролловера = ",Rol_koef);
      double Lotstep=MarketInfo(Symbol(),MODE_LOTSTEP);
      Alert(INDEX,"]]","Необходимо добавить/убавить лотов = ",MathFloor((Equity-Balance_Change)*Rol_koef/Lotstep)*Lotstep);

      if(Rol_koef<-1)
        {
         Alert(INDEX,"]]","Ошибка в расчетах, возвращаю 0");
         Rol_koef=0;
        }
     }
   else Rol_koef=0;    // если не было балансовых операций
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+ Уменьшение в ролловер
void Decrease() // Уменьшение
  {
   Alert(INDEX,"]]","Запуск функции уменьшения объема");
//   string sym;

   int total=Mass_Order_PF();
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(total==0)
     {
      Alert(INDEX,"]]","Открытых рыночных ордеров нет, корректировать нечего");
      return;
     }
/*
   if(total==1)
     {
      Alert(INDEX,"]]","Открыт только основной ордер, его уменьшаю и жду подхвата");
      Close_Lot(Ticket2[0][0],0);
      flag_check=0;
      return;
     }

   double V_sum = Mass_CountV(total);
   double V_cor = (-1)*Rol_koef*V_sum;
   V_cor=MathFloor(V_cor/Lotstep)*Lotstep;
   Alert(INDEX,"]]","Суммарный объем для корректировки = ",V_cor);
   if(V_cor<Minlot)
     {
      Alert(INDEX,"]]","Суммарный объем не корректирую. Меньше чем минимальный лот");
      return;
     }
//---------------------------------------------------------        
   if(V_cor>(V_sum-Ticket2[0][2])) //  Закрываю все неосновные и часть основного
     {
      double V_PF=V_cor -(V_sum-Ticket2[0][2]);

      Alert(INDEX,"]]","Закрываю все неосновные и часть основного= ",V_PF);

      for(i=1; i<total; i++) // закрытие неосновных
        {
         Close_Lot(Ticket2[i][0],-1);
        }
      Close_Lot(Ticket2[0][0],V_PF);     // закрытие части основного
      flag_check=0;
      return;
     }
//---------------------------------------------------------        
   for(i=1; i<total; i++) // поиск такого же лота или большего для закрытия
     {
      if(Ticket2[i][2]>=V_cor)
        {
         Alert(INDEX,"]]","Нашел подходящий ордер для уменьшения #",Ticket2[i][0]);
         Close_Lot(Ticket2[i][0],V_cor);
         return;
        }
     }
//---------------------------------------------------------        
   for(i=total-1; i>0; i--) // закрытие нескольких лотов, начиная с большего
     {
      if(V_cor>Ticket2[i][2])
        {
         Close_Lot(Ticket2[i][0],-1);
         Alert(INDEX,"]]","--Закрываю полностью №",Ticket2[i][0]);
         V_cor-=Ticket2[i][2];
         continue;
        }

      if(V_cor==Ticket2[i][2])
        {
         Alert(INDEX,"]]","---Закрываю полностью №",Ticket2[i][0]);
         Close_Lot(Ticket2[i][0],-1);
         return;
        }

      if(V_cor<Ticket2[i][2])
        {
         Alert(INDEX,"]]","----Закрываю часть №",Ticket2[i][0]);
         Close_Lot(Ticket2[i][0],V_cor);
         return;
        }
     }
*/
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//--------------------------------------------------------------------------------------------------------------------------------- 
void Increase() // Увеличение
  {
   Alert(INDEX,"]]","Запуск функции увеличения объема");
   double lot;
   int  res;

//   int total=Mass_Order_PF();

   double V_sum=Mass_CountV();
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(V_sum==0)
     {
      Alert(INDEX,"]]","Открытых рыночных ордеров/объема нет, корректировать нечего");
      return;
     }

   double Minlot   =  MarketInfo(Symbol(), MODE_MINLOT);
   double Lotstep  =  MarketInfo(Symbol(), MODE_LOTSTEP);

   lot = MathAbs (Rol_koef*V_sum);
   lot = MathFloor(lot/Lotstep)*Lotstep;
   Alert(INDEX,"]]","Открываемый лот для коррекции объема: ",lot);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(lot<Minlot)
     {
      Alert(INDEX,"]]","Планируемый лот меньше минимально-возможного. Отбой");
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      //      b=OrderSelect(Ticket2[0][0],SELECT_BY_TICKET);
      //     

      for(k=0; k<Numb_Orders[INDEX]; k++) // подбор параметров ближайшего открытого ордера
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
        {
         if(V_sum>0 && Ticket_b[INDEX][k][2]!=0 && Ticket_b[INDEX][k][2]!=5)
           {
            if(Ticket_b[INDEX][k][0]==0) continue;
            b=OrderSelect(Ticket_b[INDEX][k][0],SELECT_BY_TICKET);
            Alert(INDEX,"]]","Перенимаю параметры ордера БАЙ [",k);
            break;
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(V_sum<0 && Ticket_s[INDEX][k][2]!=0 && Ticket_s[INDEX][k][2]!=5)
           {
            if(Ticket_s[INDEX][k][0]==0) continue;
            b=OrderSelect(Ticket_s[INDEX][k][0],SELECT_BY_TICKET);
            Alert(INDEX,"]]","Перенимаю параметры ордера СЕЛЛ [",k);
            break;
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(k==Numb_Orders[INDEX]-1) // на последней итерации
           {
            Alert(INDEX,"]]","Чего то не удалось с поиском перенимаемого. Отбой ");
            return;
           }
        }

      //      string sym=Symbol();
      //      double SL = OrderStopLoss();
      //      double TP = OrderTakeProfit();
      string Coment="RC_"+OrderTicket();

      RefreshRates();

      if(V_sum>0)
         res=OrderSend(Symbol(),OP_BUY,lot,Ask,Slippage,OrderStopLoss(),OrderTakeProfit(),Coment,OrderMagicNumber()+10,0);
      else
         res=OrderSend(Symbol(),OP_SELL,lot,Bid,Slippage,OrderStopLoss(),OrderTakeProfit(),Coment,OrderMagicNumber()+10,0);

      if(res<0)
        {
         Alert(INDEX,"]]","Ошибка коррекции объема по ролловеру # ",GetLastError());
         return;
        }
      else
         Alert(INDEX,"]]","Открыл ордер увеличения по ролловеру № ",res);

      //------теперь его учет

      Numb_Orders[INDEX]++;
      int Range;

      if(V_sum>0)
        {
         Range=ArrayRange(Ticket_b,1);
         Alert(INDEX,"]]","Размер массива = ",Range);
         Alert(INDEX,"]]","Копирую характеристики БАЙ из = [",k);
         for(m=1; m<Range; m++) { Ticket_b[INDEX][Numb_Orders[INDEX]][m]=Ticket_b[INDEX][k][m]; } // копирую характеристики
         Ticket_b[INDEX][Numb_Orders[INDEX]][0]=res;
        }

      if(V_sum<0)
        {
         Range=ArrayRange(Ticket_s,1);
         Alert(INDEX,"]]","Размер массива = ",Range);
         Alert(INDEX,"]]","Копирую характеристики СЕЛЛ из = [",k);
         for(m=1; m<Range; m++) { Ticket_s[INDEX][Numb_Orders[INDEX]][m]=Ticket_s[INDEX][k][m]; } // копирую характеристики
         Ticket_s[INDEX][Numb_Orders[INDEX]][0]=res;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------------------------------------------------------------------------------------------------
int Mass_Order_PF() //заносит все открытые ордера  по данному символу в массив Ticket[]. Возвращает кол-во ордеров.
  {
   int c=0;
   double V=0.0;
//   string symbol=Symbol();

   for(k=0; k<Numb_Orders[INDEX]; k++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(Ticket_b[INDEX][k][2]!=0 && Ticket_b[INDEX][k][2]!=5) // проверка по бай
        {
         //         V+=Ticket_b[INDEX][k][7];
         //         Ticket[c][0] =  Ticket_b[INDEX][k][0];
         //         Ticket[c][7] =  Ticket_b[INDEX][k][7];
         c++;
        }
      if(Ticket_s[INDEX][k][2]!=0 && Ticket_s[INDEX][k][2]!=5) // проверка по селл
        {
         //         V-=Ticket_s[INDEX][k][7];
         //         Ticket[c][0] =  Ticket_s[INDEX][k][0];
         //         Ticket[c][7] =  Ticket_s[INDEX][k][7];
         c++;
        }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(c>0)
     {
      Alert(INDEX,"]]","Найдено всего открытых ордеров = ",c,",  Numb_Orders[INDEX] =",Numb_Orders[INDEX]);
      //      Alert(INDEX,"]]","Суммарный открытый их объем = ",V);
     }
   else  return(0);
/*
//--- Сортировка в Массив по объему --
   total= c;
   for(i=0; i<total; i++)
     {
      b=OrderSelect(Ticket[i],SELECT_BY_TICKET);
      Ticket2[i][0]=Ticket[i];
      //      Ticket2[i][1] = NormalizeDouble(OrderProfit() + OrderCommission() + OrderSwap(), 2);
      Ticket2[i][2]=OrderLots();
      //      Ticket2[i][3] = OrderOpenTime();
     }

   for(i=1; i<total; i++) // 0-это основной ордер, его не трогаем
      for(j=1; j<total-1; j++) // 0-это основной ордер, его не трогаем                       
        {                                                     //самый тяжёлый окажется справа <объём>
         if(Ticket2[j][2]-Ticket2[j+1][2]>0.0) //надо переставить местами
           {
            Ticket2[1000][0] = Ticket2[j][0];
            Ticket2[1000][2] = Ticket2[j][2];

            Ticket2[j][0] = Ticket2[j+1][0];
            Ticket2[j][2] = Ticket2[j+1][2];

            Ticket2[j+1][0] = Ticket2[1000][0];
            Ticket2[j+1][2] = Ticket2[1000][2];
           }
        }

   for(i=0; i<total; i++)
     {
      Alert(INDEX,"]]","---- ",i," ордер по объему №",Ticket2[i][0]);
     }
*/
   return (c);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------------------------------------------------------------------------------------------------
double Mass_CountV()
  {
   double V=0.0;
   int c=0;

   for(k=0; k<Numb_Orders[INDEX]; k++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(Ticket_b[INDEX][k][2]!=0 && Ticket_b[INDEX][k][2]!=5) // проверка по бай
        {
         V+=Ticket_b[INDEX][k][7];
         c++;
        }
      if(Ticket_s[INDEX][k][2]!=0 && Ticket_s[INDEX][k][2]!=5) // проверка по селл
        {
         V-=Ticket_s[INDEX][k][7];
         c++;
        }
     }

   Alert(INDEX,"]]","+- Найдено всего открытых ордеров = ",c,",  Numb_Orders[INDEX] =",Numb_Orders[INDEX]);
   Alert(INDEX,"]]","Суммарный учтённый объем = ",V);

   return(V);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

bool Nonfarm()
  {
   if(DayOfWeek()==5 && Day()<=7) // Nonfarm Payrolls
     {
      Alert(INDEX,"]]","!! Сегодня день Nonfarm Payrolls, торговать не будем");
      return (true);
     }

//-------------------     
   return (false);
  }
//+------------------------------------------------------------------+
