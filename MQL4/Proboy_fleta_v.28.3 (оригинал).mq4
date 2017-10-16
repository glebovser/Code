//+------------------------------------------------------------------+
//|                                        Pol_282_v1.mq4 |
//|                                                              GSS |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "GSS"
#property link      ""

//+------------------------------------------------------------------+
//|  ������ ����� / ������� �����
//+------------------------------------------------------------------+
/*      

27,0 - ������ �� ���� ������� ������ (�� 9,15 � 11,30)
28,0- ������ ������ � �������� �� ������� ����
28.3 - ���������� � ������ OLD-�������

*/

int MAGICMA=19102015;

extern int Number_Orders=2;  // ���������� ������� � ����� �����������  //v20,0
int Numb_Orders[3];   // ���������� �������� ��� ECN.PRO
int Number_Point=6;

extern uchar Mode_Flat=3;  // 1-������ ������ ����, 2-������ ������ ����, 3- ������ � ������ ����

extern double     Flat1_op_1=6.0; //  8.25;      // ������ ��������� �����, � �����
extern double     Flat1_cl_1=9.25; // 11.00;      // ����� ��������� �����, � ����� 

extern double     Flat1_op_2=9.0; //  8.25;      // ������ ��������� �����, � �����
extern double     Flat1_cl_2=11.5; // 11.00;      // ����� ��������� �����, � ����� 

extern double     Time_work_max_1=20.25; //  18.75  // 20/25   //  ������������ ���, �� �������� �������� � ������� ���
extern double     Time_work_max_2=20.25;
double     Time_work_max[2];

extern int     Flat_max=450;  // ��������� - 284; //340      //  ������������ �������� ����� ��� ������
extern  int    Flat_min=190;       //  ����������� �������� ����� ��� ������ 16.2
                                   ///*extern*/ int     Flat_Delta[INDEX]     = 0;  //-20;       //  ������ � �����  
double Lots=0;    // ���������� �����,���� ����, �� ���������� ��������� 
double Percent=0;   // ������� ���������� ������� 
extern double Loss_Percent=12;  // ������ ���� �� ��������� �������
double Loss_Percent_max=10;

double Lots_New[2];       // ��������� ���������� ����� ��� ����� ������� (�����������)
                          //double Ticket__ [Index][7];        // ��� �������� ������ � ���������� �����

int        Slippage=5;

int    Proskalz_delta=10;   // �������� ��������������� ��� ��������, ��� ������� �������� �� v14
int    Proskalz_bar=145;  // ������� ��� ��� �������� ������, ����� �������� ����������� �������� �� �����

extern int TakeProfit_close_min=270;   // ��� v 17.0 
extern int TakeProfit_close=450; //350;   // ��� v 11.0
extern int TakeProfit_close_max=750;   // ��� v 17.0 

extern int TakeProfit=800;

extern int        Proskalz_SL=320; //274;   // �������� ������� ������������ �������������� SL ��� ������� �������������� 14.0
extern int        Proskalz_TP=2000;   // �������� ������������� TP ��� ������� �������������� 14.0
extern int        Proskalz_Level_2=600; //500;  // 18.2  ������� ����, ��� ������� ������ ������ ������������

double Lot_koof_cl=0.5;  // ����������� ��������� ���� ������ ������������ ������
double Lot_koof_cl_big = 0.5; //   17.4  ����������� ��������� ���� ������ ������������ ������
double Lot_koof_1part = 0.5;  // 18,6  �������� ����� ��� ��������������� ������ �����


extern double Bezubytok_point=180;  //  ������ � ��������� ��� ���������� ������ �������
int Bezubytok_profit_0 = -20; // ������ ��� �������� � ���������
int Bezubytok_profit_1 =  24; // ������ ��� �������� � ���������

extern double  Spred=14;  // �������� �������� ������ � �������(��� EUR/USD = 14)

extern bool Agressiv=false; //24.3 ��� ������������ �����
extern bool Test=true;  // ���� ������� � ����������� ����� � ������ ���������� ����� 1-���, 0-����
extern bool check_orders= true;  // �������� �� ������� �������� ������� ������� 1-���, 0-����
extern bool DoubleClose = true;  // �������� ����� �������  v 17/0
extern bool DoubleClose_big=true;  // �������� ����� ����� �� ������� ������� ���� v 17.4
extern bool One_part_long_cl=false;
extern bool Two_part_long_cl=true;

bool Fast_flat_open=false;  // 18,7,1 ��� �������� �������� ������� ����� �� ������� �����

extern int Zig_number=0;//20;  // ���-�� ������� ��� ����
datetime Zig_time_old;  // ��� ���������� �������� �������

double Price_SL[2];  //16.0.2
int  flag_Limit[2];         // ���� �����������  ������ ����� (����������� �� ��� � ����)
                            // int  flag_s, flag_b, 
int flag_no_flat[2],flag_order_op[2];   // �����: ���������� ����� � �������� ������ ������� ���
                                        // int flag_order_back;  // ���� ��������� ������ � �������� ����������� � ������� �� �������� (�� v8.0)
int flag_no_open[2];   // ���� �� �������� ������� � ����

double Flat_Hich[2],Flat_Low[2],Flat_Delta[2],Flat_Medium[2],Flat_1_3_L[2],Flat_1_3_H[2];

double spred;

bool Lost_s[2]={0,0};  // ���� ���������� ������� PRO.ECN
bool Lost_b[2]={0,0};

int GLE;  // ��� ��������� ������

int n_op[2]={1,1};   // ������� ������� ���������� ��������

datetime   Time_Bar_old_i[2];               // ��� ����������� ������������ ������ ���� 

                                            //datetime Start_t[INDEX],Stop_t[INDEX];   // ��� ���������������� ������ ������   26,0
//int Flag_i_Limit[INDEX];    // // 26.0  0-��� �� �����������, 1 - ������ ��� ��� ���� �� ���� ���, 
extern int Delta_lim=20;
extern int Flat_1_3=250;
double flat_1_3;

//double Sell_NoOpen,Buy_NoOpen,Sell_NoOpen_Lim,Buy_NoOpen_Lim;    //   ���� ��� ������������ ���������� �� ����� /v13

double Rol_koef;   // ����������� ��������� ������� � ��������
int Ticket_rol;   // ����� ���������� ���������
int Check_cl_ROL;
string Rollover_name="Ticket_ROL";   // ��� ���������� ���������� ��� ���������

extern int Balance=0;

int k,m;
bool b;
int INDEX,INDEX_min,INDEX_max,INDEX_Old;

bool Flag_Old;

//#��������� �������
double Ticket_b[3][10][15]; //  0 - �����, 1 - ���� ���������, 2 -��������� �� ������������, 3 - TakeProfit_close, 4-TakeProfit_close_min, 5-TakeProfit_close_max, 6-Proskalz_Level_2, 7-��� ��� ��������, 8-���� ���������������.
double Ticket_s[3][10][15]; //  9 - ���� ��� ���������� ����� Buy_NoOpen_Lim/Sell_NoOpen_Lim, 10 - ���� ��� ���������� ����� Sell_NoOpen/Buy_NoOpen, 11 - ���,��������������� � ��������, 12 - ������� ����� �� �����������

datetime Time_b[3][10][4]; // 0 -����������� ����� ��� �������� ������ �����, 1-����� �������� ������ ��� VeryNevs, 2 -����� ����� ��� ����
datetime Time_s[3][10][4];

string Text_b[3][10][4];   // 0 - ����������� ������
string Text_s[3][10][4];
//-----------------------------------------------------------
uchar Flag_i_Limit[2];
int Test_flag[2];
datetime Start_t[2],Stop_t[2];

double Flat1_op[2];
double Flat1_cl[2];
//�������������������������������������������������������������������+
void  init()
  {
   Alert(Symbol()," v.27.  _**********�������� ����� ������**** ",AccountCompany(),"  ������� � ",AccountCurrency());
   Alert(Symbol(),"������� ������ ",AccountServer()); // Alpari-Pro.ECN
//--------------------------
   Numb_Orders[0]=Number_Orders; Numb_Orders[1]=Number_Orders;
   Time_work_max[0]=Time_work_max_1; Time_work_max[1]=Time_work_max_2;
   Flat1_op[0]=Flat1_op_1;Flat1_op[1]=Flat1_op_2;
   Flat1_cl[0]=Flat1_cl_1;Flat1_cl[1]=Flat1_cl_2;

   switch(Mode_Flat)
     {
      case 1: INDEX_min = 0; INDEX_max = 1; INDEX_Old =2; Alert("! ������   ������   ����");break;
      case 2: INDEX_min = 1; INDEX_max = 2; INDEX_Old =2; Alert("! ������   ������   ����");break;
      case 3: INDEX_min = 0; INDEX_max = 2; INDEX_Old =2; Alert("! ������ � ������   ����");break;

      default:INDEX_min=0; INDEX_max=2; INDEX_Old=2; Alert("! ������, ��� �����");break;
     }
//--------------------------   
   spred=Spred*Point;
   flat_1_3=Flat_1_3*Point;
   if(TakeProfit_close_min==0 || TakeProfit_close_min==TakeProfit_close) DoubleClose=false;
   if(IsTradeAllowed()==false) Alert(Symbol(),"   !! !! �������� ��������� !! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
   if(Hour()+Minute()/60.0<Time_work_max[INDEX] && Hour()+Minute()/60.0>=Flat1_cl_1)
     {
      if(check_orders==true) Order_open_analiz();  // �������� ����� �������� � ������������ �������
     }

   Ticket_rol=GlobalVariableGet(Rollover_name);
   Alert("��������� ��� �� ������� ���������� = ",Ticket_rol);
   Rol_Check();
  }
//�������������������������������������������������������������������+
void  deinit()
  {
/*   if(Hour()+Minute()/60.0>=Time_work_max[INDEX] || Hour()+Minute()/60.0<Flat1_cl[INDEX])
     {
      // !!!!      if(Ticket!=0) Check_for_Close_5(); // ����������� �������������� ������ � ��������� ����� ��� �������� �����
     }
*/
  }
//�������������������������������������������������������������������+   START ----

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

      if(flag_Limit[INDEX]!=DayOfYear()) // ������ � ���� ����������� ������ �����
        {
         //        Alert(INDEX,"]]",Symbol(),"_","flag_Limit ��� ������� � =",flag_Limit[INDEX]);

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
            Alert(INDEX,"]]",Symbol(),"   !! !! �������� ��������� !! !!");
            flag_no_flat[INDEX]=1; Test_flag[INDEX]=0;Flag_i_Limit[INDEX]=6;
            return;
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
/*      if((flag_no_flat[INDEX]==0 || Test_flag[INDEX]==1) && Ticket!=0) // 17.5 - ������ ������������ �������� ���������� ������, ���� ������� �� ����� ��������
        {
!!!         Check_for_Close_5();                       // ���� ������� ��������, �� ������ ����� ����������� � �������
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
      if(flag_no_flat[INDEX]==0 || Test_flag[INDEX]==1) // ���� ���� � �������� �������������, �� �������� � ������� ���
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

               Alert(INDEX,"]]",Symbol(),"_","������ ����= ",Lots_New[INDEX]);

               if( Send_Orders(4 , 0)== -1) flag_no_open[INDEX] = 1;
               if( Send_Orders(5 , 0)== -1) flag_no_open[INDEX] = 1;

               if(Number_Orders>1)
                 {
                  if( Send_Orders(4 , 1)== -1) flag_no_open[INDEX] = 1;
                  if( Send_Orders(5 , 1)== -1) flag_no_open[INDEX] = 1;
                 }

               if(flag_no_open[INDEX]==1) { Alert(INDEX,"]]","!! !! !!!!!!!!  �� ��� ������ ���������  !!!!!");}
               if(flag_no_open[INDEX]==1) { No_open();}   // ������� ���������� �������� ������� v10

               Bezubyt_price();
               if(INDEX==INDEX_min) Zigzag(Zig_number);
              }
            else
              {
               Alert(INDEX,"]]",Symbol(),"_","����� ���, ���� ��������");
               flag_no_flat[INDEX]=1;
              }

            flag_order_op[INDEX]=1;
           }

         Check_for_Close();                           // V 11.0 - ������������ ���� �������� 

         Proskalz ();                                  // �������� �� ���������������         
         VeryNews ();                                  // v 9.0 - ������ �� ������� �������� � ��������
         Bezubyt_check();

         if(Lost_b[INDEX]==1 || Lost_s[INDEX]==1) LostLot();

         if(flag_no_open[INDEX]==1) { No_open();  if(flag_no_open[INDEX]==0) Bezubyt_price(); }

        }
/*       
      else  // ��� ������, ���� ���� ������ ���
        {
        
         for(k=0; k<Numb_Orders[INDEX]; k++)
            //+------------------------------------------------------------------+
            //|                                                                  |
            //+------------------------------------------------------------------+
           {
            if((Ticket_b[INDEX][k][2]!=0 && Ticket_b[INDEX][k][2]!=5) || (Ticket_s[INDEX][k][2]!=0 && Ticket_s[INDEX][k][2]!=5)) // ������ ������������ �������� ������ 17.5
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
//���������������� ����� ������� void start()�����������������������+  

//--------------------------------------------------------------------------------------------------------------------------------------
void Old_Copy() // ����������� ������� � ������ ������������ ����� ����� �������� ���  28,0
  {
   int num;
   for(INDEX=INDEX_min; INDEX<INDEX_max; INDEX++) // 27.0
     {
      for(k=0; k<Numb_Orders[INDEX]; k++)
        {
         //------------ ���--        
         if(Ticket_b[INDEX][k][2]!=0 && Ticket_b[INDEX][k][2]!=5)
           {
            num=Numb_Orders[INDEX_Old];
            Alert("������� ������� ��� [",k,"], ����� �",Ticket_b[INDEX][k][0],"� OLD ������ �� � [",num,"]");
            for(m=0; m<ArrayRange(Ticket_b,2); m++)
              {
               Ticket_b[INDEX_Old][num][m]=Ticket_b[INDEX][k][m];
               Time_b[INDEX_Old][num][m]=Time_b[INDEX][k][m];
               Text_b[INDEX_Old][num][m]=Text_b[INDEX][k][m];
              }
            Numb_Orders[INDEX_Old]++;
           }

         //------------ ����� --        
         if(Ticket_s[INDEX][k][2]!=0 && Ticket_s[INDEX][k][2]!=5)
           {
            num=Numb_Orders[INDEX_Old];
            Alert("������� ������� ���� [",k,"], ����� �",Ticket_s[INDEX][k][0],"� OLD ������ �� � [",num,"]");
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
void Old_Check() // 28.0 ������������ ������� �� ������� ����
  {
   INDEX=INDEX_Old;   // 28.0 ������������ ������� �� ������� ����

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
         Alert("_____��������� ������ ������ ������������!!!");

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//--------------------------------------------------------------------------------------------------------------------------------------
void i_Limit_Search() // ���������������� ����������� ������ ����� � ��������� ��� �������  v26.0
  {
   int Start_bar;
//-------------------------------------------------------------------------------------
   if(Flag_i_Limit[INDEX]==0) // ������ ������ ����������
     {
      Alert(INDEX,"]]","������ ������ ���������");
      datetime BeginDay=MathFloor(TimeCurrent()/86400)*86400;
      Start_t[INDEX]= BeginDay+Flat1_op[INDEX] *3600;
      Stop_t[INDEX] =  BeginDay+Flat1_cl[INDEX] *3600;
      Limit_Time(clrYellow);

      double zz;
      int ExtDepth=12,ExtDeviation=5,ExtBackstep=3;   //   ����� ������� ������ - ������
      Start_bar=iBarShift(Symbol(),0,Start_t[INDEX],true);

      for(m=Start_bar+1; m<=Start_bar+2; m++) // ����� ����� ����� ��������� ������������� ��������
        {
         zz=iCustom(NULL,0,"ZigZag",ExtDepth,ExtDeviation,ExtBackstep,0,m);
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(zz!=0)
           {
            Alert(INDEX,"]]","������� ��������� ����� �����, ��� =",m);
            Start_t[INDEX]=iTime(NULL,0,m);        // --- ��������� ������� ������
           }
        }
      Flag_i_Limit[INDEX]=1;
      flag_no_flat[INDEX]=1;
      flag_Limit[INDEX]=DayOfYear();
     }
//-------------------------------------------------------------------------------------
   if(Flag_i_Limit[INDEX]==5) // ��������� ������ ����������
     {
      Limit_Search();
      Flag_i_Limit[INDEX]=6;
      return;
     }

//-------------------------------------------------------------------------------------
   if(Time_Bar_old_i[INDEX]!=iTime(NULL,0,0)) // ����� ����� ���������� �� ������ ����
     {
      //     Alert(INDEX,"]]","������� �������� ����� ����� �� ������ ����");
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
            //           Alert(INDEX,"]]","��������� ������� - ������/������. ���� ������ ��???? ��� �",k);
            break;
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(High[k]==Flat_Hich[INDEX])
           {
            Flag_i_Limit[INDEX]=2;
            Alert(INDEX,"]]","��������� ������� - �������, ��� �",k);
            break;
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(Low[k]==Flat_Low[INDEX])
           {
            Flag_i_Limit[INDEX]=3;
            //      Alert(INDEX,"]]","��������� ������� - ������, ��� �",k);
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
      if((Flag_i_Limit[INDEX]==2 && Low[0]<Flat_1_3_H[INDEX]) || (Flag_i_Limit[INDEX]==3 && High[0]>Flat_1_3_L[INDEX])) //��� ��������� �� ���� �����
        {
         Stop_t[INDEX]=TimeCurrent();
         Limit_Time(clrGreen);
         Flag_i_Limit[INDEX]=5;
         return;
        }
     }
   else
     {
      if((Flag_i_Limit[INDEX]==2 && Low[0]<Flat_Medium[INDEX]) || (Flag_i_Limit[INDEX]==3 && High[0]>Flat_Medium[INDEX])) //��� ��������� � �������� �����
        {
         Stop_t[INDEX]=TimeCurrent();
         Limit_Time(clrGreen);
         Flag_i_Limit[INDEX]=5;
         return;
        }
     }

//  Flag_i_Limit[INDEX]=1;    // 0-��� �� �����������, 1 - ������ ��� ��� ���� �� ���� ���, 2 - ��������� ������� �������, 3 - ��������� ������� ������, 5 - ��������� ������� ����������, 6 - ������ Limit_Search ���������

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
//--------- ��������� �������---------------------------------------------------   
   int fl_delta=Flat_Delta[INDEX]/Point;

   datetime time_1 = Start_t[INDEX];
   datetime time_2 =(MathFloor(TimeCurrent()/86400)*86400)+(Time_work_max[INDEX]*3600);

   string Name[6];

   Name[0]=INDEX+"_flet "+DayOfYear();  // ��� �����
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
void Limit_Search() // ����������� ������ ����� � ��������� ��� �������
  {
   int fl_delta=Flat_Delta[INDEX]/Point;

   if(fl_delta>Flat_max) // ���� ������ ������� �������
     {
      //      flag_Limit[INDEX]=DayOfYear();
      //      Flag_i_Limit[INDEX]=6;
      flag_no_flat[INDEX]=1;
      Alert(INDEX,"]]",Symbol(),"_","������ ����� ������� �������");
      Limit_Paint(clrMagenta);
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      // --------- ������ � �������� ������ ---------------

      if(Test==true)
        {
         if(fl_delta<Flat_max*2.0)
           {
            Alert(INDEX,"]]",Symbol(),"_�������� � �������� ������");
            Test_flag[INDEX]=1;
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         else
           {
            Alert(INDEX,"]]",Symbol(),"_������ ������� ���� ��� �����");
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
//���������������� �������� ������� �����������������������+  

int Send_Orders(int Type,int Index) // ���� �������: 0-BUY, 1-SELL, 2-BUY-lim, 3-SELL-lim,  4 - BUY-st,  5 - SELL-st
  {

   datetime BeginDay=MathFloor(TimeCurrent()/86400)*86400;     // ������ ������� ������ ������� �����
   int      Start_time=iBarShift(Symbol(),0,BeginDay+Flat1_op[INDEX]*3600,true);     // ���, �������������� ������ ������ 
   datetime end_work=BeginDay+Time_work_max[INDEX]*3600;
   double Points_n;
   int    Point_n;

   double Price,SL,TP;
   int    MG;
//   int    MG=MAGICMA;
   int    Tick_b,Tick_s;
//   int GLE;  // ��� ������

//------------------------  ����� BUY (0)  ---------------------

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
         Alert(INDEX,"]]","������ �� buy =",GetLastError()," ���� Ask=",DoubleToStr(Ask,Digits)," ���� Bid=",DoubleToStr(Bid,Digits)," ���� ����=",DoubleToStr(Price,Digits));
        }
      else   Ticket_b[INDEX][Index][0]=Tick_b;
      return (Tick_b);
     }
//------------------------  ����� SELL (1)  ---------------------

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
         Alert(INDEX,"]]","������ �� sell =",GetLastError()," ���� Bid=",DoubleToStr(Bid,Digits)," ���� Ask=",DoubleToStr(Ask,Digits)," ���� ����=",DoubleToStr(Price,Digits));
        }
      else   Ticket_s[INDEX][Index][0]=Tick_s;
      return (Tick_s);
     }
//------------------------  ����� BUY STOP (4)  ---------------------

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
         Alert(INDEX,"]]","������ �� buy stop =",GetLastError()," ���� Ask=",DoubleToStr(Ask,Digits)," ���� Bid=",DoubleToStr(Bid,Digits)," ���� ����=",DoubleToStr(Price,Digits));
         Ticket_b[INDEX][Index][10]=Ask;
         if(Ticket_b[INDEX][Index][9]==0) Ticket_b[INDEX][Index][9]=Price-spred;
        }
      else   Ticket_b[INDEX][Index][0]=Tick_b;
      return (Tick_b);
     }
//------------------------  ����� SELL STOP (5)  ---------------------

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
         Alert(INDEX,"]]","������ �� sell stop =",GetLastError()," ���� Bid=",DoubleToStr(Bid,Digits)," ���� Ask=",DoubleToStr(Ask,Digits)," ���� ����=",DoubleToStr(Price,Digits));
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
// ----------------------------  ������� ���������� �������� ������������� ������ ������� -----------------------------------------------------------------------

void No_open()
  {
   double Price;

   for(k=0; k<Numb_Orders[INDEX]; k++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      // -----------------------  ���������� BUY ---
      if(Ticket_b[INDEX][k][0]==0)
        {
         Price=Flat_Hich[INDEX]+spred;
         RefreshRates();
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(Ask>=Price && Ask<=Price+Slippage && Fast_flat_open)
           {
/*         Alert(INDEX,"]]",Symbol(),"������� ������������ �� ������� ���� Ask (+ slippage) = ",DoubleToStr(Ask,Digits));
         if(Send_Orders(0)!=-1)
           {flag_no_open[INDEX]=0; Alert(INDEX,"]]",Symbol(),"����� BUY �������� - ����"); return;}*/

           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(Bid>Ticket_b[INDEX][k][9])
           {
            Alert(INDEX,"]]",Symbol(),"������� ������������ ��� ����� ������� ���� Ask = ",DoubleToStr(Ask,Digits));
            if(Send_Orders(2,k)!=-1)
              { Alert(INDEX,"]]",Symbol(),"����� BUY �������� - ���� [",k); Alert(INDEX,"]]",Symbol(),"����� �� Bid =",((Bid-Ticket_b[INDEX][k][9])/Point)); return;}
            else
              {
               n_op[INDEX]++;
               Ticket_b[INDEX][k][9]=Bid;
               if(n_op[INDEX]>60)
                 {
                  Alert(INDEX,"]]",Symbol(),"��������� ������������ ����� ������� ��������, STOP");
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
            Alert(INDEX,"]]",Symbol(),"������� ������������ �� ����� ������ ���� Ask = ",DoubleToStr(Ask,Digits));
            if(Send_Orders(4,k)!=-1)
              { Alert(INDEX,"]]",Symbol(),"����� BUY �������� - ���� [",k); Alert(INDEX,"]]",Symbol(),"����� �� Ask =",((Ticket_b[INDEX][k][10]-Ask)/Point));  return;}
            else
              {
               n_op[INDEX]++;
               Ticket_b[INDEX][k][10]=Ask;
               if(n_op[INDEX]>60)
                 {
                  Alert(INDEX,"]]",Symbol(),"��������� ������������ ����� ������� ��������, STOP");
                  flag_no_open[INDEX]=0;
                  Ticket_b[INDEX][k][0]=1000;
                 }
              }
           }
        }
      // -----------------------  ���������� SELL ---

      if(Ticket_s[INDEX][k][0]==0)
        {
         Price=Flat_Low[INDEX];
         RefreshRates();
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(Bid<=Price && Bid>=Price-Slippage && Fast_flat_open)
           {
/*         Alert(INDEX,"]]",Symbol(),"������� ������������ �� ������� ���� Bid (- slippage) = ",DoubleToStr(Bid,Digits));
         if(Send_Orders(1)!=-1)
           {flag_no_open[INDEX]=0; Alert(INDEX,"]]",Symbol(),"����� SELL �������� - ����"); return;}  */

           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(Ask<Ticket_s[INDEX][k][9])
           {
            Alert(INDEX,"]]",Symbol(),"������� ������������ ��� ����� ������ ���� Bid = ",DoubleToStr(Bid,Digits));
            if(Send_Orders(3,k)!=-1)
              { Alert(INDEX,"]]",Symbol(),"����� SELL �������� - ���� [",k); Alert(INDEX,"]]",Symbol(),"����� �� Ask =",(Ticket_s[INDEX][k][9]-Ask)/Point); return;}
            else
              {
               n_op[INDEX]++;
               Ticket_s[INDEX][k][9]=Ask;
               if(n_op[INDEX]>60)
                 {
                  Alert(INDEX,"]]",Symbol(),"��������� ������������ ����� ������� ��������, STOP");
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
            Alert(INDEX,"]]",Symbol(),"������� ������������ �� ����� ������� ���� Bid = ",DoubleToStr(Bid,Digits));
            if(Send_Orders(5,k)!=-1)
              { Alert(INDEX,"]]",Symbol(),"����� SELL �������� - ���� [",k); Alert(INDEX,"]]",Symbol(),"����� �� Bid =",(Bid-Ticket_s[INDEX][k][10])/Point); return;}
            else
              {
               n_op[INDEX]++;
               Ticket_s[INDEX][k][10]=Bid;
               if(n_op[INDEX]>60)
                 {
                  Alert(INDEX,"]]",Symbol(),"��������� ������������ ����� ������� ��������, STOP");
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
bool Lot() // ������� ���������� ���������� �����.
  {
// double Lots_New[INDEX] - ���������� ����� ��� ����� ������� (�����������)
// double Lots     - �������� ���������� �����, �������� �����������.
// int Percent     - ������� �������, �������� �������������
// ������������ ��������:
// true  - ���� ������� ������� �� ����������� ���
// false - ���� ������� �� ������� �� ����������� ���
//--------------------------------------------------------------- 2 --
   string Symb=Symbol();                    // ���������� �������.
   double Leverage=AccountLeverage();
   double One_Lot=MarketInfo(Symb,MODE_MARGINREQUIRED);//�����. 1 ����
                                                       //Alert ("��������� ������ ����= ",One_Lot );   
   double Min_Lot=MarketInfo(Symb,MODE_MINLOT);// ���. ������. �����
                                               //Alert ("��������� ������������ ����= ",Min_Lot );      
   double Step=MarketInfo(Symb,MODE_LOTSTEP);//��� ������� �������
   double Free=AccountFreeMargin()/Number_Orders/(INDEX_max-INDEX_min);         // ��������� ��������  // v20.0
   Alert("��������� �������� �� ����� =",Free);
   double Percent_test=0.15;  // �������� ��� � ���������,  v18.5 // 20.0

//-----------------------------------------+
// �� ������� ������

   double Price_minLot=0.01; //  ������� $ / 1 ����� ������������ ����,    ������� ����� ��� �� ��������� 0,01 - ��� EUR/USD
                             //   double Percent_t=Loss_Percent*Min_Lot*One_Lot/Price_minLot/(Flat_Delta[INDEX]/Point+Spred);
   double Percent_t=Loss_Percent*Min_Lot*One_Lot/Price_minLot/(Flat_Delta[INDEX]/Point+Spred)*Leverage/500;   // v 21.7 ��������� ��������������� �����
   Alert(INDEX,"]]","������ ����� = ",Flat_Delta[INDEX]/Point);
//--------������----------------------   
   double Kurs;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(AccountCurrency()=="RUR")
     {
      Kurs=(MarketInfo("USDRUB",MODE_BID)+MarketInfo("USDRUB",MODE_ASK))/2;
      Percent=Percent_t/Kurs;
      Alert(INDEX,"]]","!!!! ������ ���� - �����, ��������� ���� = ",Kurs);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(AccountCurrency()=="EUR")
     {
      Kurs=(MarketInfo("EURUSD",MODE_BID)+MarketInfo("EURUSD",MODE_ASK))/2;
      Percent=Percent_t*Kurs;
      Alert(INDEX,"]]","!!!! ������ ���� - ����, ��������� ���� = ",Kurs);
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
      Alert(INDEX,"]]","��������� ������� �������, � = ",Percent,". ����������� �� �������������");
      Percent=Loss_Percent_max_2;
     }

   Alert(INDEX,"]]","��������� ������� ������ = ",Loss_Percent,", ������� ����� �� ������� = ",Percent);
//-----------------------------------------+

   if(Test_flag[INDEX]==1) // v14.1   � ������ ����� ��������� �� �����
     {
      Lots_New[INDEX]=MathFloor(Free*Percent_test *(500/Leverage)/100/One_Lot/Step)*Step;//����     21,8 
                                                                                         //   Lots_New[INDEX] = Min_Lot;
      if(Lots_New[INDEX]<Min_Lot) // ���� ������ ������..
         Lots_New[INDEX]=Min_Lot;                        // .. �� ������������
      if(Lots_New[INDEX]*One_Lot>Free) // �� ������� ����..
        {                                         // ..�� ���������. ���:(
         Alert(INDEX,"]]",Symbol(),"_","�� ������� �����");                    // ���������..
         Test_flag[INDEX]=0;
         return(false);                           // ..� ����� 
        }
      return(true);
     }
//--------------------------------------------------------------- 3 --
   if(Lots>0) // ���� ������ ����..
     {                                         // ..�������� ���
      double Money=Lots*One_Lot;               // ��������� ������
      if(Money<=Free) // ������� �������..
         Lots_New[INDEX]=Lots;                        // ..��������� ��������
      else                                     // ���� �� �������..
      Lots_New[INDEX]=MathFloor(Free *(500/Leverage)/One_Lot/Step)*Step;// ������ �����  21,8
     }
//--------------------------------------------------------------- 4 --
   else                                        // ���� ���� �� ������
     {                                         // ..�� ���� �������
      if(Percent>100) // ������ �������� ..
         //         Percent=100;                          // .. �� �� ����� 100
         return(false);
      if(Percent==0) // ���� ���������� 0 ..
         Lots_New[INDEX]=Min_Lot;                     // ..�� ����������� ���
      else                                     // ������. �����.�����:
      Lots_New[INDEX]=MathFloor(Free*Percent *(500/Leverage)/100/One_Lot/Step)*Step;//���� 21,8
     }
//--------------------------------------------------------------- 5 --
   if(Lots_New[INDEX]<Min_Lot) // ���� ������ ������..
      Lots_New[INDEX]=Min_Lot;                        // .. �� ������������
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(Lots_New[INDEX]*One_Lot>Free) // �� ������� ����..
     {                                         // ..�� ���������. ���:(
      Alert(INDEX,"]]",Symbol(),"_","�� ������� �����");                    // ���������..
      return(false);                           // ..� ����� 
     }
   return(true);                               // ����� �� �����. �-��
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// -----------------------------  ��������� -------------------------------------------------------------------------------------

void Bezubyt_price() //  ������� ����������� ��� �������� � ��������� 
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

      //---- ���  --------     
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
      Alert(INDEX,"]]",Symbol(),"_","�����: BUY_",k," =",Ticket_b[INDEX][k][0],", ��������� =",DoubleToStr(Ticket_b[INDEX][k][1],Digits));
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //---- �����  --------

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
      Alert(INDEX,"]]",Symbol(),"_","�����: SELL_",k," =",Ticket_s[INDEX][k][0],", ��������� =",DoubleToStr(Ticket_s[INDEX][k][1],Digits));

     }

   Bezubyt_line();         // ������ ������ ���������

  }
//-----------------------------------------------------------------------------------------------------

void Bezubyt_price_OLD() //  ������� ����������� ��� �������� � ��������� ��� OLD
  {
   double Price_bez;
   double Bezubytok=Bezubytok_point*Point;

   for(k=0; k<Numb_Orders[INDEX_Old]; k++)
     {

      //---- ���  --------     
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
      Alert(INDEX_Old,"]]",Symbol(),"_","�����: BUY_",k," =",Ticket_b[INDEX_Old][k][0],", ��������� =",DoubleToStr(Ticket_b[INDEX_Old][k][1],Digits));
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //---- �����  --------

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
      Alert(INDEX_Old,"]]",Symbol(),"_","�����: SELL_",k," =",Ticket_s[INDEX_Old][k][0],", ��������� =",DoubleToStr(Ticket_s[INDEX_Old][k][1],Digits));

     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+----------------------------------------------------------------------------------
void Bezubyt_check() // �������� ��� �������� � ���������
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
      //----------���------------------   
      //      if(Ticket_b[INDEX][k][1]!=0 && Ticket_b[INDEX][k][1]<=Bid)
      if(Ticket_b[INDEX][k][1]!=0 && Ticket_b[INDEX][k][1]<=High[0])
        {
         if(!OrderSelect(Ticket_b[INDEX][k][0],SELECT_BY_TICKET))
           {
            Alert(INDEX,"]]",Ticket_b[INDEX][k][0]," ������ ������ ������ ��� ����������� � ",GetLastError());
            Ticket_b[INDEX][k][1]=0;
            continue;
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(OrderCloseTime()==0)
           {
            Alert(INDEX,"]]",Symbol(),"_","������� ����������� ������ BUY � ��������� _",k,"] ",Ticket_b[INDEX][k][0]);
            Alert(INDEX,"]]","������ ������� ������� � ������� = ",(Bid-OrderOpenPrice())/Point);

            double Bezub_b=OrderOpenPrice()+Order_form(k,"Bezub")*Point;
            double TP_b=OrderOpenPrice()+Proskalz_TP*Point;

            if(Low[0]<Flat_Hich[INDEX] && Bezub_b>Low[0])
              {
               Bezub_b=Low[0];  // ���������� � �������� �������� ����
               Alert(INDEX,"]]","!_!_���������� � �/� � �������� �������� ����, ������� = ",Bezub_b);
               Time_b[INDEX][k][2]=iTime(NULL,0,0);
              }
            //           else
            //              Bezub_b=OrderOpenPrice()+Order_form(k,"Bezub")*Point;

            if(Bezub_b<OrderStopLoss())
              {
               Alert(INDEX,"]]"," ����� �� ������������, � ��� SL �����");
               Ticket_b[INDEX][k][1]=0;
               continue;
              }

            if(OrderModify(Ticket_b[INDEX][k][0],OrderOpenPrice(),Bezub_b,TP_b,0,Magenta)==false)
              {
               Alert(INDEX,"]]",Symbol(),"_","������ ����������� � ",GetLastError());
               continue;
              }
           }
         else Alert(INDEX,"]]",Ticket_b[INDEX][k][0]," ����� ��� ����������� ��� ������ ");

         Ticket_b[INDEX][k][1]=0;
         continue;
        }
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //-----------����-----------------   
      //      if(/*Ticket_s[INDEX][k][1]!=0 &&*/ Ticket_s[INDEX][k][1]>=Ask)
      if(/*Ticket_s[INDEX][k][1]!=0 &&*/ Ticket_s[INDEX][k][1]>=Low[0])

        {
         if(!OrderSelect(Ticket_s[INDEX][k][0],SELECT_BY_TICKET))
           {
            Alert(INDEX,"]]",Ticket_s[INDEX][k][0]," ������ ������ ������ ���� ����������� � ",GetLastError());
            Ticket_s[INDEX][k][1]=0;
            continue;
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(OrderCloseTime()==0)
           {
            Alert(INDEX,"]]",Symbol(),"_","������� ����������� ������ SELL � ��������� _",k,"] ",Ticket_s[INDEX][k][0]);
            Alert(INDEX,"]]","������ ������� ������� � ������� = ",(OrderOpenPrice()-Ask)/Point);

            double Bezub_s=OrderOpenPrice()-Order_form(k,"Bezub")*Point;
            double TP_s=OrderOpenPrice()-Proskalz_TP*Point;

            if(High[0]+spred>Flat_Low[INDEX] && Bezub_b<High[0]+spred)
              {
               Bezub_s=High[0]+spred;  // ���������� � ��������� �������� ����
               Alert(INDEX,"]]","!_!_���������� � �/� � ��������� �������� ����, ������� = ",Bezub_s);
               Time_s[INDEX][k][2]=iTime(NULL,0,0);
              }
            //           else
            //              Bezub_s=OrderOpenPrice()-Order_form(k,"Bezub")*Point;

            if(Bezub_s>OrderStopLoss())
              {
               Alert(INDEX,"]]"," ����� �� ������������, � ��� SL �����");
               Ticket_s[INDEX][k][1]=0;
               continue;
              }

            if(OrderModify(Ticket_s[INDEX][k][0],OrderOpenPrice(),Bezub_s,TP_s,0,Magenta)==false)
              {
               Alert(INDEX,"]]",Symbol(),"_","������ ����������� � ",GetLastError());
               continue;
              }
           }
         else Alert(INDEX,"]]",Ticket_s[INDEX][k][0]," ����� ��� ����������� ��� ������");

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
            Alert(INDEX,"]]",Ticket_b[INDEX][k][0]," ������ ������ ������ ��� �����������_2 � ",GetLastError());
            Time_b[INDEX][k][2]=0;
            continue;
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(OrderCloseTime()==0)
           {
            Alert(INDEX,"]]",Symbol(),"_","�����������_2 ������ BUY � ���������� ��������� _",k,"] ",Ticket_b[INDEX][k][0]);
            Bezub_b=OrderOpenPrice()+Order_form(k,"Bezub")*Point;

            if(Bezub_b<OrderStopLoss())
              {
               Alert(INDEX,"]]"," ����� �� ������������_2, � ��� SL �����");
               Time_b[INDEX][k][2]=0;
               continue;
              }

            if(OrderModify(Ticket_b[INDEX][k][0],OrderOpenPrice(),Bezub_b,OrderTakeProfit(),0,Magenta)==false)
              {
               Alert(INDEX,"]]",Symbol(),"_","������ ����������� � ",GetLastError());
               continue;
              }
           }
         else Alert(INDEX,"]]",Ticket_b[INDEX][k][0]," ����� ��� �����������_2 ��� ������ ");

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
            Alert(INDEX,"]]",Ticket_s[INDEX][k][0]," ������ ������ ������ ���� �����������_2 � ",GetLastError());
            Time_s[INDEX][k][2]=0;
            continue;
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(OrderCloseTime()==0)
           {
            Alert(INDEX,"]]",Symbol(),"_","�����������_2 ������ SELL � ���������� ��������� _",k,"] ",Ticket_s[INDEX][k][0]);
            Bezub_s=OrderOpenPrice()-Order_form(k,"Bezub")*Point;

            if(Bezub_s>OrderStopLoss())
              {
               Alert(INDEX,"]]"," ����� �� ������������_2, � ��� SL �����");
               Time_s[INDEX][k][2]=0;
               continue;
              }

            if(OrderModify(Ticket_s[INDEX][k][0],OrderOpenPrice(),Bezub_s,OrderTakeProfit(),0,Magenta)==false)
              {
               Alert(INDEX,"]]",Symbol(),"_","������ ����������� � ",GetLastError());
               continue;
              }
           }
         else Alert(INDEX,"]]",Ticket_s[INDEX][k][0]," ����� ��� �����������_2 ��� ������");

         Time_s[INDEX][k][2]=0;
         continue;
        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// ----------------- ��������� ������� ��������� -------------------------

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
// ----------  �������� �������� � ����������� �������� ������� --------
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
            //          Alert(INDEX,"]]","������ � ������� ",i);
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA+Point_n+INDEX)
              {
               if(TimeDayOfYear(OrderOpenTime())==DayOfYear())
                 {
                  Alert(INDEX,"]]","����� ����� ��� ������� � ������� � ",OrderTicket());
                  if(OrderType() == OP_BUY || OrderType() == OP_BUYSTOP || OrderType() == OP_BUYLIMIT ) Ticket_b[INDEX][0][0] = OrderTicket ();
                  if(OrderType() == OP_SELL || OrderType() == OP_SELLSTOP || OrderType() == OP_SELLLIMIT ) Ticket_s[INDEX][1][0] = OrderTicket ();
                 }
               else
                 {
                  Alert(INDEX,"]]","����� !!!  OLD - ����� ��� ������� � ������� � ",OrderTicket());
                  if(OrderType() == OP_BUY  )    {Ticket_b[INDEX_Old][b_old][0] = OrderTicket (); b_old++; }
                  if(OrderType() == OP_SELL )    {Ticket_s[INDEX_Old][s_old][0] = OrderTicket (); s_old++; }
                 }
              }

            if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA-Point_n+INDEX)
              {
               if(TimeDayOfYear(OrderOpenTime())==DayOfYear())
                 {
                  Alert(INDEX,"]]","����� ����� ��� ������� � ������� � ",OrderTicket());
                  if(OrderType() == OP_BUY || OrderType() == OP_BUYSTOP || OrderType() == OP_BUYLIMIT ) Ticket_b[INDEX][1][0] = OrderTicket ();
                  if(OrderType() == OP_SELL || OrderType() == OP_SELLSTOP || OrderType() == OP_SELLLIMIT ) Ticket_s[INDEX][0][0] = OrderTicket ();
                 }
               else
                 {
                  Alert(INDEX,"]]","����� !!!  OLD - ����� ��� ������� � ������� � ",OrderTicket());
                  if(OrderType() == OP_BUY  )    {Ticket_b[INDEX_Old][b_old][0] = OrderTicket (); b_old++; }
                  if(OrderType() == OP_SELL )    {Ticket_s[INDEX_Old][s_old][0] = OrderTicket (); s_old++; }
                 }
              }
           }
        }
      // ----------  �������� �������� �������� ������� � ������� --------     

      for(k=0; k<Numb_Orders[INDEX]; k++) // 
        {
         Point_n=Order_form(k,"Pips");

         for(int j=OrdersHistoryTotal()-1;j>=0;j--)
            //+------------------------------------------------------------------+
            //|                                                                  |
            //+------------------------------------------------------------------+
           {

            b=OrderSelect(j,SELECT_BY_POS,MODE_HISTORY);
            //      Alert(INDEX,"]]","������ � �������� ",j);
            if(TimeDayOfYear(OrderOpenTime())<DayOfYear()) break;

            if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA+Point_n+INDEX && TimeDayOfYear(OrderOpenTime())==DayOfYear() && (OrderType()==0 || OrderType()==1))
              {
               Alert(INDEX,"]]","����� ����� ��� ������� � �������� � ",OrderTicket());
               if(OrderType() == OP_BUY)  {Ticket_b[INDEX][0][0] = OrderTicket (); Ticket_b[INDEX][0][8]=1;}
               if(OrderType() == OP_SELL) {Ticket_s[INDEX][1][0] = OrderTicket (); Ticket_s[INDEX][1][8]=1;}
              }

            if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA-Point_n+INDEX && TimeDayOfYear(OrderOpenTime())==DayOfYear() && (OrderType()==0 || OrderType()==1))
              {
               Alert(INDEX,"]]","����� ����� ��� ������� � �������� � ",OrderTicket());
               if(OrderType() == OP_BUY)  {Ticket_b[INDEX][1][0] = OrderTicket ();Ticket_b[INDEX][1][8]=1;}
               if(OrderType() == OP_SELL) {Ticket_s[INDEX][0][0] = OrderTicket ();Ticket_s[INDEX][0][8]=1;}
              }
           }
        }
      Alert(INDEX,"]]",Symbol(),"_","�������� ������� Ticket_b[0]=",Ticket_b[INDEX][0][0],", Ticket_b[1]=",Ticket_b[INDEX][1][0]);
      Alert(INDEX,"]]",Symbol(),"_","�������� ������� Ticket_s[0]=",Ticket_s[INDEX][0][0],", Ticket_s[1]=",Ticket_s[INDEX][1][0]);

      Alert(INDEX_Old,"]]",Symbol(),"_","��������  OLD Ticket_b[0]=",Ticket_b[INDEX_Old][0][0],", Ticket_b[1]=",Ticket_b[INDEX_Old][1][0],", Ticket_b[2]=",Ticket_b[INDEX_Old][2][0]);
      Alert(INDEX_Old,"]]",Symbol(),"_","��������  OLD Ticket_s[0]=",Ticket_s[INDEX_Old][0][0],", Ticket_s[1]=",Ticket_s[INDEX_Old][1][0],", Ticket_s[2]=",Ticket_s[INDEX_Old][2][0]);
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
         Lot(); Alert(INDEX,"]]",Symbol(),"_","��������� �������� ���� = ",Lots_New[INDEX]);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// ----------------------------  ������� ����������� ��������������� ---------------------------
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
            if(OrderType()==OP_SELL) //  �������� ����� SELL
              {
               if(OrderCloseTime()!=0)
                 {
                  Ticket_s[INDEX][k][8]=1;
                  continue;
                 }
               int pr_s=(Flat_Low[INDEX]-OrderOpenPrice())/Point+(OrderMagicNumber()-MAGICMA-INDEX);
               Alert(INDEX,"]]",Symbol(),"_�������� ����� SELL [",k,"] , ��� ��������������� = ",pr_s);
               //               Alert ("Flat_Low[INDEX]-OrderOpenPrice = ", (Flat_Low[INDEX]-OrderOpenPrice())/Point, ", OrderMagicNumber-MAGICMA = ", (OrderMagicNumber()-MAGICMA) );
               Ticket_s[INDEX][k][8]=1;
               Time_s[INDEX][k][1]=OrderOpenTime();

               if(pr_s>Slippage)
                 {
                  Alert(INDEX,"]]","��������������� ������� �������, ������������ SL � TP ������");
/*
                  int Point_ns= Order_form(k,"Pips");
                  double SL_s = Flat_Hich[k]+spred+Point_ns *Point;
                  if(OrderStopLoss()!=SL_s)
                    {
                     Alert(INDEX,"]]"," ����� ������ ��� ���������������, �����");
                  continue;
                  }
*/
                  if(OrderModify(Ticket_s[INDEX][k][0],OrderOpenPrice(),OrderStopLoss()-pr_s*Point,OrderTakeProfit()-pr_s*Point,0,Blue)==false)
                    {
                     GLE=GetLastError();
                     Alert(INDEX,"]]","������ �����������=",GLE);
                     if(Errors(GLE)==true)
                       {
                        if(OrderModify(Ticket_s[INDEX][k][0],OrderOpenPrice(),OrderStopLoss()-pr_s*Point,OrderTakeProfit()-pr_s*Point,0,Blue)==false)
                           Alert(INDEX,"]]","����� ������ �����������=",GetLastError());
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
            if(OrderType()==OP_BUY) //  �������� ����� BUY
              {
               if(OrderCloseTime()!=0)
                 {
                  Ticket_b[INDEX][k][8]=1;
                  continue;
                 }
               int pr_b=(OrderOpenPrice()-Flat_Hich[INDEX]-spred)/Point-OrderMagicNumber()+MAGICMA+INDEX;
               Alert(INDEX,"]]",Symbol(),"_�������� ����� BUY[",k,"],��� ���������������=",pr_b);
               //               Alert ("OrderOpenPrice()-Flat_Hich[INDEX]-spred=", (OrderOpenPrice()-Flat_Hich[INDEX]-spred)/Point, ",OrderMagicNumber-MAGICMA=", (OrderMagicNumber()-MAGICMA) );
               Ticket_b[INDEX][k][8]=1;
               Time_b[INDEX][k][1]=OrderOpenTime();

               if(pr_b>Slippage)
                 {
                  Alert(INDEX,"]]","��������������� ������� �������,������������ SL � TP ������");
/*                  
                  int Point_nb = Order_form(k, "Pips");
                  double SL_b = Flat_Low[k] + Point_nb *Point;
                  if (OrderStopLoss() != SL_b)
                  {
                  Alert(INDEX,"]]"," ����� ������ ��� ���������������,�����");
                     continue;
                    }
*/
                  if(OrderModify(Ticket_b[INDEX][k][0],OrderOpenPrice(),OrderStopLoss()+pr_b*Point,OrderTakeProfit()+pr_b*Point,0,Blue)==false)
                    {
                     GLE=GetLastError();
                     Alert(INDEX,"]]","������ ����������� = ",GLE);
                     if(Errors(GLE)==true)
                       {
                        if(OrderModify(Ticket_b[INDEX][k][0],OrderOpenPrice(),OrderStopLoss()+pr_b*Point,OrderTakeProfit()+pr_b*Point,0,Blue)==false)
                           Alert(INDEX,"]]","����� ������ ����������� = ",GetLastError());
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
// ----------------------------  ������� ������ �� ������ �������� � ����� ���� ---------------------------
void VeryNews()
  {
   int Bar_now=iBarShift(Symbol(),0,TimeCurrent(),true);
   int Tick_end=Number_Orders-1;
//-------------���� �������� SELL, � BUY ��� ���-----
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
                  //           Alert(INDEX,"]]","������ ����� ������� �� ������ ���������� ���� [",k);
                 }
               else
                 {
                  Ticket_b[INDEX][k][0]=0;
                  Alert(INDEX,"]]","����� ������� ��� ��� �� ������ [",k);
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
                  Alert(INDEX,"]]",k,"] ���� ��� ���� �����, ������ ��� �� �������� ������ [",k);
                  Ticket_b[INDEX][k][2]=5;
                  Ticket_b[INDEX][k][1]=0;
                 }
               else
                 {
                  if(Ticket_b[INDEX][k][0]==0) Ticket_b[INDEX][k][0]=Send_Orders(4,k);
                  //            Alert(INDEX,"]]","������ ����� ��� [",k,"__",Ticket_b[INDEX][k][0]);
                 }
              }
           }
        }
     }
//-------------���� �������� BUY , � SELL ��� ���-----
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
                  //          Alert(INDEX,"]]","������ ����� ������� �� ������ ���������� ���� [",k);
                 }
               else
                 {
                  Ticket_s[INDEX][k][0]=0;
                  Alert(INDEX,"]]","����� ������� ��� ��� �� ������ [",k);
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
                  Alert(INDEX,"]]",k,"] ���� ��� ���� ����, ������ ���� �� �������� ������ [",k);
                  Ticket_s[INDEX][k][2]=5;
                  Ticket_s[INDEX][k][1]=0;
                 }
               else
                 {
                  if(Ticket_s[INDEX][k][0]==0) Ticket_s[INDEX][k][0]=Send_Orders(5,k);
                  //          Alert(INDEX,"]]","������ ����� ���� [",k,"__",Ticket_s[INDEX][k][0]);

                 }
              }
           }
        }
     }
//---------------------------- 24,3  Agressiv ---------------------------------- �������� ������� ������� �� ����     

   if(Agressiv==true) // �� ������� ������ ��� (Number_Orders==1||
     {
      //-------------���� �������� SELL 1, BUY 1 ��� ��������,  � BUY 2 � SELL 2 ��� ���-----
      if(Ticket_s[INDEX][0][2]>0 && Ticket_s[INDEX][Tick_end][2]>0 && Ticket_b[INDEX][0][2]==5 && Ticket_b[INDEX][Number_Orders][0]==0 && Ticket_s[INDEX][Number_Orders][0]==0)
        {
         if(iBarShift(Symbol(),0,Time_s[INDEX][Tick_end][1],true)!=Bar_now)
           {
            for(k=Number_Orders; k<Number_Orders*2; k++)
              {
               if(Bid>=Flat_Hich[INDEX])
                 {
                  Alert(INDEX,"]]",k,"] ��� ���� ��� ���� �����, ������ ���_2 �� �������� ������");
                  Ticket_b[INDEX][k][2]=5;
                  Ticket_b[INDEX][k][1]=0;
                  Ticket_b[INDEX][k][0]=1000;
                 }
               else
                 {
                  if(Ticket_b[INDEX][k][0]==0)
                    {
                     Ticket_b[INDEX][k][0]=Send_Orders(4,k);
                     Alert(INDEX,"]]","��� ������ ����� ��� [",k,"__",Ticket_b[INDEX][k][0]);
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
      //-------------���� �������� BUY 1, SELL 1 ��� ��������, � BUY 2 � SELL 2 ��� ���-----
      if(Ticket_b[INDEX][0][2]>0 && Ticket_b[INDEX][Tick_end][2]>0 && Ticket_s[INDEX][0][2]==5 && Ticket_s[INDEX][Number_Orders][0]==0 && Ticket_b[INDEX][Number_Orders][0]==0)
        {
         if(iBarShift(Symbol(),0,Time_b[INDEX][Tick_end][1],true)!=Bar_now)
           {
            for(k=Number_Orders; k<Number_Orders*2; k++)
              {
               if(Ask<=Flat_Low[INDEX])
                 {
                  Alert(INDEX,"]]",k,"] ��� ���� ��� ���� ����, ������ ����_2 �� �������� ������");
                  Ticket_s[INDEX][k][2]=5;
                  Ticket_s[INDEX][k][1]=0;
                  Ticket_s[INDEX][k][0]=1000;
                 }
               else
                 {
                  if(Ticket_s[INDEX][k][0]==0)
                    {
                     Ticket_s[INDEX][k][0]=Send_Orders(5,k);
                     Alert(INDEX,"]]","��� ������ ����� ���� [",k,"__",Ticket_s[INDEX][k][0]);
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
//------------------------------  v24 ����� ������������ ������ ��� ECN PRO -----------------------------------------------

void LostLot()
  {
   bool Tick;
   for(k=0; k<Numb_Orders[INDEX]; k++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //-------���---------  
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

            if(OrderType()==OP_BUY && OrderMagicNumber()==MG_b && OrderLots()<=Ticket_b[INDEX][k][12]) // ����� ������� � ������������, ���� ���� ��� �������� ������ ����
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
               if(Tick==1) // ����� ����� ��� ������
                 {
                  Alert(INDEX,"]]","����� ����� ���.������ � ",OrderTicket(),". ��� ����� =",OrderLots(),". ��� �������: ",OrderComment());

                  double Lot_b=Ticket_b[INDEX][k][12]-OrderLots();
                  Ticket_b[INDEX][k][12]=Lot_b;

                  if(Lot_b==0)
                    {
                     Alert(INDEX,"]]",k,"] ����� ��� ������ ������ ���������");

                     double LL_b=0;
                     for(int bb=0; bb<Numb_Orders[INDEX]; bb++)
                       {
                        LL_b+=Ticket_b[INDEX][bb][12];
                       }
                     if(LL_b==0)
                       {Lost_b[INDEX]=0; Alert(INDEX,"]]","����� ������� ��� ��������� ��������");}
                    }
                  else
                    {
                     Alert(INDEX,"]]",k,"] ����� ��� ��� ������ �����������, �� ������� ",Lot_b);
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
//-------�����---------  
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

            if(OrderType()==OP_SELL && OrderMagicNumber()==MG_s && OrderLots()<=Ticket_s[INDEX][k][12]) // ����� ������� � ������������, ���� ���� ��� �������� ������ ����
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
               if(Tick==1) // ����� ����� ��� ������
                 {
                  Alert(INDEX,"]]","����� ����� ���.������ � ",OrderTicket(),". ��� ����� =",OrderLots(),". ��� �������: ",OrderComment());

                  double Lot_s=Ticket_s[INDEX][k][12]-OrderLots();
                  if(Lot_s==0)
                    {
                     Alert(INDEX,"]]",k,"] ����� ���� ������ ������ ���������");

                     double LL_s=0;
                     for(int ss=0; ss<Numb_Orders[INDEX]; ss++)
                       {
                        LL_s+=Ticket_s[INDEX][ss][12];
                       }
                     if(LL_s==0)
                       {Lost_s[INDEX]=0; Alert(INDEX,"]]","����� ������� ���� ��������� ��������");}
                    }
                  else
                    {
                     Alert(INDEX,"]]",k,"] ����� ���� ��� ������ �����������, �� ������� ",Lot_s);
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
// ----------------------------  ������� ������������ �������� ������� ����������(v11) --------------------------- !!!!!  

void Check_for_Close()
  {
/*[2] 0-�� ������
      1-������, ����������
      2-��������� ������ �����
      3-������ ����� ������������� �� �����
      4-
      5-����� ������
*/

//--------------------------        
   for(k=0; k<Numb_Orders[INDEX]; k++) // �������� ������������� ������� � ������ �������
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(Ticket_b[INDEX][k][2]==1 || Ticket_b[INDEX][k][2]==2) Check_for_Close_2(Ticket_b[INDEX][k][0],k);   //�������� ������ ����� \\ ������ ����� ��� �������
      if(Ticket_s[INDEX][k][2]== 1 || Ticket_s[INDEX] [k][2] == 2)  Check_for_Close_2(Ticket_s[INDEX] [k][0] , k);

      if(Ticket_b[INDEX][k][2]==3) Check_for_Close_3(Ticket_b[INDEX][k][0],k);  // ������ ����� ����������� �� �����
      if(Ticket_s[INDEX][k][2]== 3)  Check_for_Close_3(Ticket_s[INDEX] [k][0] , k);
     }

//--------------------------        
   for(k=0; k<Numb_Orders[INDEX]; k++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(Ticket_b[INDEX][k][2]==0) Check_for_Close_1(Ticket_b[INDEX][k][0],k);  // ����� ����������� �������
      if(Ticket_s[INDEX][k][2]== 0)  Check_for_Close_1(Ticket_s[INDEX] [k][0] , k);

      if(Ticket_b[INDEX][k][2]!=0 && Ticket_b[INDEX][k][2]!=5) Check_for_Close_0(Ticket_b[INDEX][k][0],k);      // ����� ����������� �������    
      if(Ticket_s[INDEX][k][2]!= 0 && Ticket_s[INDEX] [k][2] != 5) Check_for_Close_0(Ticket_s[INDEX] [k][0] , k);
     }

//-------------------------- 

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+--------------------------------------------------------------------------------------------------------------------------------+

void Check_for_Close_0(int Ticket,int Index) // ����������� �������� ������
  {
   b=OrderSelect(Ticket,SELECT_BY_TICKET);         // ���� ����� ��� ��� ��������, ������ �� �����������
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(OrderCloseTime()!=0)
     {
      int Check_cl_new;
      Alert(INDEX,"]]",Ticket," ����� ��������, ��� ����������: ",OrderComment());

      //-----------����--------------------------------            
      if(OrderType()==OP_SELL)
        {
         if(OrderProfit()>0)
            Alert(INDEX,"]]",Symbol(),Index,"]_������� ��� �������� =",((OrderOpenPrice()-OrderClosePrice())/Point)," �������");
         else
            Alert(INDEX,"]]",Symbol(),Index,"]_������ ��� �������� ",((-OrderOpenPrice()+OrderClosePrice())/Point),". ��������������� �� SL =",((OrderClosePrice()-OrderStopLoss())/Point)," �������");
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if("to #"==StringSubstr(OrderComment(),0,4)) //  ������� ����������� ������� ����� �������
           {
            Check_cl_new=StringSubstr(OrderComment(),4,StrToInteger(StringLen(OrderComment())-4));
            Alert(INDEX,"]]","������� ������ �� ���������� - ",StringSubstr(OrderComment(),4,StringLen(OrderComment())-4));
            Alert(INDEX,"]]","��������� ����� SELL � ",Check_cl_new);
            Ticket_s[INDEX][Index][0]=Check_cl_new;
            //            Alert(INDEX,"]]","����� ����� � ������� ",Ticket_s[INDEX][Index][0]);
            Ticket_s[INDEX][Index][7]=Ticket_s[INDEX][Index][7]-OrderLots();
            Alert(INDEX,"]]","����� ��� ��� �������� = ",Ticket_s[INDEX][Index][7]);
            return;
           }
         Ticket_s[INDEX][Index][2]=5; Ticket_s[INDEX][Index][1]=0;
         //                Alert ("�������� 5 ��� ", Ticket_s[INDEX] [Index][0]);
         return;
        }

      //-----------���--------------------------------            
      if(OrderType()==OP_BUY)
        {
         if(OrderProfit()>0)
            Alert(INDEX,"]]",Symbol(),Index,"]_������� ��� �������� =",(( OrderClosePrice()-OrderOpenPrice())/Point)," �������");
         else
            Alert(INDEX,"]]",Symbol(),Index,"]_������ ��� �������� ",(( -OrderClosePrice()+OrderOpenPrice())/Point),". ��������������� �� SL =",((OrderStopLoss()-OrderClosePrice())/Point)," �������");
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if("to #"==StringSubstr(OrderComment(),0,4)) //  ������� ����������� ������� ����� �������
           {
            Check_cl_new=StringSubstr(OrderComment(),4,StrToInteger(StringLen(OrderComment())-4));
            Alert(INDEX,"]]","������� ������ �� ���������� - ",StringSubstr(OrderComment(),4,StringLen(OrderComment())-4));
            Alert(INDEX,"]]","��������� ����� BUY ",Check_cl_new);
            Ticket_b[INDEX][Index][0]=Check_cl_new;
            //            Alert(INDEX,"]]","����� ����� � ������� ",Ticket_b[INDEX][Index][0]);
            Ticket_b[INDEX][Index][7]=Ticket_b[INDEX][Index][7]-OrderLots();
            Alert(INDEX,"]]","����� ��� ��� �������� = ",Ticket_b[INDEX][Index][7]);
            return;
           }
         Ticket_b[INDEX][Index][2]=5; Ticket_b[INDEX][Index][1]=0;
         //              Alert ("�������� 5 ��� ", Ticket_b[INDEX] [Index][0]);                 
         return;
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+--------------------------------------------------------------------------------------------------------------------------------+
void Check_for_Close_1(int Ticket,int Index) // �������� ������������� �����
  {
   if(OrderSelect(Ticket,SELECT_BY_TICKET))
     {
      //----------------     
      if(OrderType()==OP_SELL) // ����� ���� SELL
        {
         if(OrderCloseTime()!=0) // ����� ��� �������� ���-��
           {
            Ticket_s[INDEX][Index][2]=5; Ticket_s[INDEX][Index][1]=0;
            return;
           }
         Ticket_s[INDEX][Index][2]=1;  // �����������

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
         //         Alert(INDEX,"]]","!-!-!-!-!-!-!������ ����� �������� ����� s_",Index,"]  ",Ticket);

         if(OrderLots()!=Ticket_s[INDEX][Index][11])
           {
            Alert(INDEX,"]]",Index,"] ������ ����� ���� �� ��������, ����� � ",OrderTicket(),". �� ������� ����� = ",Ticket_s[INDEX][Index][11]-OrderLots());
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
         if(OrderCloseTime()!=0) // ����� ��� �������� ���-��
           {
            Ticket_b[INDEX][Index][2]=5; Ticket_b[INDEX][Index][1]=0;
            return;
           }
         Ticket_b[INDEX][Index][2]=1;  // �����������

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
         //         Alert(INDEX,"]]","!-!-!-!-!-!-!������ ����� �������� ����� b_",Index,"]  ",Ticket);

         if(OrderLots()!=Ticket_b[INDEX][Index][11])
           {
            Alert(INDEX,"]]",Index,"] ������ ����� ��� �� ��������, ����� � ",OrderTicket(),". �� ������� ����� = ",Ticket_b[INDEX][Index][11]-OrderLots());
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
void Check_for_Close_2(int Ticket,int Index) //  ������������ ��� ���������� �������� ����
  {
   double Lot_clos_s,Lot_clos_b;

   b=OrderSelect(Ticket,SELECT_BY_TICKET);
//--����--
   if(OrderType()==OP_SELL)
     {
      //-----�������� ������ �����---
      if(Ticket_s[INDEX][Index][2]==1 && Ask<=Ticket_s[INDEX][Index][4] && DoubleClose) //   v17 �������� ������ �����
        {
         if(One_part_long_cl==true)
           {
            if(Ticket_s[INDEX][Index][4]-Ask>Proskalz_delta*Point || High[0]-Ticket_s[INDEX][Index][4]>Proskalz_bar*Point)
              {
               Alert(INDEX,"]]",Symbol(),Index,"] ��������������� �� �������� 1� ��������� =",(Ticket_s[INDEX][Index][4]-Ask)/Point);
               Alert(INDEX,"]]",Symbol(),Index,"] ������� ��� �� �������� 1� �������� =",(High[0]-Ticket_s[INDEX][Index][4])/Point);

               Lot_clos_s=NormalizeDouble(Ticket_s[INDEX][Index][7]*Lot_koof_cl*Lot_koof_1part,2);   //  !!!!������������ ���� �� 2� ������ ����� ������� - ����� �� ����� ��������           
               if(Close_Ord(Ticket,Lot_clos_s)==true) {Ticket_s[INDEX][Index][2]=2;}

               return;
              }
           }
         Alert(INDEX,"]]",Symbol(),Index,"] �������� ������ ����� ������. Ask =",DoubleToStr(Ask,Digits));

         Lot_clos_s=NormalizeDouble(Ticket_s[INDEX][Index][7]*Lot_koof_cl,2);   //  !!!!������������ ���� �� 2� ������ ����� ������� - ����� �� ����� ��������

         RefreshRates();
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(Ask<=Ticket_s[INDEX][Index][4]) // ������ �� ������� ������� ����
           {

            if(OrderClose(Ticket,Lot_clos_s,Ask,Slippage,clrRed))
              {
               Ray(INDEX+"_Close_s2"+Index+DayOfYear(),TimeCurrent()+6000,Ask,clrAqua,2);
               b=OrderSelect(Ticket,SELECT_BY_TICKET);     //  ������������ �������� �� v11 
               Alert(INDEX,"]]","������� ���� =",DoubleToStr(Ask,Digits),", ��������� �� = ",DoubleToStr(OrderClosePrice(),Digits));
               Alert(INDEX,"]]",Symbol(),Index,"]_������� �� �������� ������ ����� = ",(Ticket_s[INDEX][Index][4]-OrderClosePrice())/Point," ������� + ",(OrderOpenPrice()-Ticket_s[INDEX][Index][4])/Point);

               if(Ticket_s[INDEX][Index][7]>MarketInfo(Symbol(),MODE_MINLOT)) // ���. ������. �����)
                 {
                  for(int pos=0;pos<=OrdersTotal();pos++) // ����� ������ ������
                    {
                     if(OrderSelect(pos,SELECT_BY_POS,MODE_TRADES)==false) continue;
                     if(OrderComment()=="from #"+Ticket) { int Tikt_s=OrderTicket(); break; }  // ����� �������� ������� ������ �� ����������, ��� / ����, ������, ������
                    }

                  Ticket_s[INDEX][Index][0]=Tikt_s;
                  Ticket=Tikt_s;
                  Ticket_s[INDEX][Index][7]=Ticket_s[INDEX][Index][7]-Lot_clos_s;

                  Alert(INDEX,"]]",Symbol(),Index,"] ����� ����� ������������ = ",Ticket);
                  b=OrderSelect(Ticket,SELECT_BY_TICKET);
                  Alert(INDEX,"]]","��� ���������� �����= ",OrderMagicNumber(),", � ���������� = ",OrderComment());
                  Alert(INDEX,"]]",Symbol(),Index,"] ����� ��� ��� �������� = ",Ticket_s[INDEX][Index][7]);
                  Ticket_s[INDEX][Index][2]=2;
                 }
               return;
              }
            else
              {
               Alert(INDEX,"]]","������ �������� sell = ",GetLastError());
               Alert(INDEX,"]]",Ticket,", ",Lot_clos_s,", ",DoubleToStr(Ask,Digits));
              }
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         else
           {
            Alert(INDEX,"]]","���� ����� ���������, �������� �� �����. Ask = ",DoubleToStr(Ask,Digits));
            return;
           }

        }
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //-----�������� ������ �����---
      if(Ask<=Ticket_s[INDEX][Index][3])
        {
         if(Two_part_long_cl)
           {
            if(Ticket_s[INDEX][Index][3]-Ask>Proskalz_delta*Point)
              {
               Alert(INDEX,"]]",Symbol(),Index,"] ��������������� �� 2 �������� ������� � ��������� =",(Ticket_s[INDEX][Index][3]-Ask)/Point);
               Alert(INDEX,"]]",Symbol(),Index,"] ������� ��� �� �������� ��� ���� �������� =",(High[0]-Ticket_s[INDEX][Index][3])/Point);
               Check_for_Close_3(Ticket,Index);
               return;
              }

            if(High[0]-Ticket_s[INDEX][Index][3]>Proskalz_bar*Point)
              {
               Alert(INDEX,"]]",Symbol(),Index,"] ������� ��� �� 2 �������� �������� =",(High[0]-Ticket_s[INDEX][Index][3])/Point);
               Alert(INDEX,"]]",Symbol(),Index,"] ��������������� �� �������� ��� ���� ��������� =",(Ticket_s[INDEX][Index][3]-Ask)/Point);
               Check_for_Close_3(Ticket,Index);
               return;
              }
           }

         RefreshRates();
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(Ask<=Ticket_s[INDEX][Index][3]) // ������ �� ������� ������� ����
           {
            if(OrderClose(Ticket,Ticket_s[INDEX][Index][7],Ask,Slippage,clrRed))
              {
               Ray(INDEX+"_Close_s"+Index+DayOfYear(),TimeCurrent()+6000,Ask,clrAqua,2);
               b=OrderSelect(Ticket,SELECT_BY_TICKET);     //  ������������ �������� �� v11 
               Alert(INDEX,"]]","������� ���� =",DoubleToStr(Ask,Digits),", ��������� �� = ",DoubleToStr(OrderClosePrice(),Digits));
               Alert(INDEX,"]]",Symbol(),Index,"]_������� �� �������� = ",(Ticket_s[INDEX][Index][3]-OrderClosePrice())/Point," ������� + ",(OrderOpenPrice()-Ticket_s[INDEX][Index][3])/Point);
               Ticket_s[INDEX][Index][2]=5; Ticket_s[INDEX][Index][1]=0;
               return;
              }
            else
              {
               Alert(INDEX,"]]","������ �������� sell = ",GetLastError());
               Alert(INDEX,"]]",Ticket,", ",Ticket_s[INDEX][Index][7],", ",DoubleToStr(Ask,Digits));
              }
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         else
           {
            Alert(INDEX,"]]","���� 2�� �������� ����� ���������, �������� �� �����. Ask = ",DoubleToStr(Ask,Digits));
            return;
           }
        }
     }
//--���--
   if(OrderType()==OP_BUY)
     {
      //-----�������� ������ �����---
      if(Ticket_b[INDEX][Index][2]==1 && Bid>=Ticket_b[INDEX][Index][4] && DoubleClose) //   v17 �������� ������ �����
        {
         if(One_part_long_cl==true)
           {
            if(Bid-Ticket_b[INDEX][Index][4]>Proskalz_delta*Point || Ticket_b[INDEX][Index][4]-Low[0]>Proskalz_bar*Point)
              {
               Alert(INDEX,"]]",Symbol(),Index,"] ��������������� �� �������� 1� ��������� =",(Bid-Ticket_b[INDEX][Index][4])/Point);
               Alert(INDEX,"]]",Symbol(),Index,"] ������� ��� �� �������� 1� �������� =",(Ticket_b[INDEX][Index][4]-Low[0])/Point);

               Lot_clos_b=NormalizeDouble(Ticket_b[INDEX][Index][7]*Lot_koof_cl*Lot_koof_1part,2);   //  !!!!������������ ���� �� 2� ������ ����� ������� - ����� �� ����� ��������           
               if(Close_Ord(Ticket,Lot_clos_b)) Ticket_b[INDEX][Index][2]=2;

               return;
              }
           }

         Alert(INDEX,"]]",Symbol(),Index,"] �������� ������ ����� ������. Bid =",DoubleToStr(Bid,Digits));

         Lot_clos_b=NormalizeDouble(Ticket_b[INDEX][Index][7]*Lot_koof_cl,2);   //  !!!!������������ ���� �� 2� ������ ����� ������� - ����� �� ����� ��������

         RefreshRates();
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(Bid>=Ticket_b[INDEX][Index][4]) // ������ �� ������� ������� ����
           {

            if(OrderClose(Ticket,Lot_clos_b,Bid,Slippage,clrRed))
              {
               Ray(INDEX+"_Close_b2"+Index+DayOfYear(),TimeCurrent()+6000,Bid,clrAqua,2);
               b=OrderSelect(Ticket,SELECT_BY_TICKET);     //  ������������ �������� �� v11 
               Alert(INDEX,"]]","������� ���� =",DoubleToStr(Bid,Digits),", ��������� �� = ",DoubleToStr(OrderClosePrice(),Digits));
               Alert(INDEX,"]]",Symbol(),Index,"]_������� �� �������� ������ ����� = ",(OrderClosePrice()-Ticket_b[INDEX][Index][4])/Point," ������� + ",(Ticket_b[INDEX][Index][4]-OrderOpenPrice())/Point);

               if(Ticket_b[INDEX][Index][7]>MarketInfo(Symbol(),MODE_MINLOT)) // ���. ������. �����)
                 {

                  for(int poss=0;poss<=OrdersTotal();poss++) // ����� ������ ������
                    {
                     if(OrderSelect(poss,SELECT_BY_POS,MODE_TRADES)==false) continue;
                     if(OrderComment()=="from #"+Ticket) { int Tikt_b=OrderTicket(); break; }  // ����� �������� ������� ������ �� ����������, ��� / ����, ������, ������
                    }

                  Ticket_b[INDEX][Index][0]=Tikt_b;
                  Ticket=Tikt_b;
                  Ticket_b[INDEX][Index][7]=Ticket_b[INDEX][Index][7]-Lot_clos_b;

                  Alert(INDEX,"]]",Symbol(),Index,"] ����� ����� ������������ = ",Ticket);
                  b=OrderSelect(Ticket,SELECT_BY_TICKET);
                  Alert(INDEX,"]]","��� ���������� �����= ",OrderMagicNumber(),", � ���������� = ",OrderComment());
                  Alert(INDEX,"]]",Symbol()," ����� ��� ��� �������� = ",Ticket_b[INDEX][Index][7]);
                  Ticket_b[INDEX][Index][2]=2;
                 }
               return;
              }
            else
              {
               Alert(INDEX,"]]","������ �������� buy = ",GetLastError());
               Alert(INDEX,"]]",Ticket,", ",Lot_clos_b,", ",DoubleToStr(Bid,Digits));
              }
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         else
           {
            Alert(INDEX,"]]","���� ����� ���������, �������� �� �����. Bid = ",DoubleToStr(Bid,Digits));
            return;
           }

        }
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //-----�������� ������ �����---
      if(Bid>=Ticket_b[INDEX][Index][3])
        {
         if(Two_part_long_cl)
           {
            if(Bid-Ticket_b[INDEX][Index][3]>Proskalz_delta*Point)
              {
               Alert(INDEX,"]]",Symbol(),Index,"] ��������������� �� 2 �������� ������� � ��������� =",(Bid-Ticket_b[INDEX][Index][3])/Point);
               Alert(INDEX,"]]",Symbol(),Index,"] ������� ��� �� �������� ��� ���� �������� =",(Ticket_b[INDEX][Index][3]-Low[0])/Point);
               Check_for_Close_3(Ticket,Index);
               return;
              }

            if(Ticket_b[INDEX][Index][3]-Low[0]>Proskalz_bar*Point)
              {
               Alert(INDEX,"]]",Symbol(),Index,"] ������� ��� �� 2 �������� �������� =",(Ticket_b[INDEX][Index][3]-Low[0])/Point);
               Alert(INDEX,"]]",Symbol(),Index,"] ��������������� �� �������� ��� ���� ��������� =",(Bid-Ticket_b[INDEX][Index][3])/Point);
               Check_for_Close_3(Ticket,Index);
               return;
              }
           }

         RefreshRates();
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(Bid>=Ticket_b[INDEX][Index][3]) // ������ �� ������� ������� ����
           {
            if(OrderClose(Ticket,Ticket_b[INDEX][Index][7],Bid,Slippage,clrRed))
              {
               Ray(INDEX+"_Close_b"+Index+DayOfYear(),TimeCurrent()+6000,Bid,clrAqua,2);
               b=OrderSelect(Ticket,SELECT_BY_TICKET);     //  ������������ �������� �� v11 
               Alert(INDEX,"]]","������� ���� =",DoubleToStr(Bid,Digits),", ��������� �� = ",DoubleToStr(OrderClosePrice(),Digits));
               Alert(INDEX,"]]",Symbol(),Index,"]_������� �� �������� = ",(OrderClosePrice()-Ticket_b[INDEX][Index][3])/Point," ������� + ",(Ticket_b[INDEX][Index][3]-OrderOpenPrice())/Point);
               Ticket_b[INDEX][Index][2]=5; Ticket_b[INDEX][Index][1]=0;
               return;
              }
            else
              {
               Alert(INDEX,"]]","������ �������� buy = ",GetLastError());
               Alert(INDEX,"]]",Ticket,", ",Ticket_b[INDEX][Index][7],", ",DoubleToStr(Bid,Digits));
              }
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         else
           {
            Alert(INDEX,"]]","���� 2�� �������� ����� ���������, �������� �� �����. Bid = ",DoubleToStr(Bid,Digits));
            return;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void Check_for_Close_3(int Ticket,int Index) // ���� ��������������� ��� �������� �������, �� ���� ������� �� ��������� ����� ��� ������ ������ (������)
  {
   double SL,TP;

   b=OrderSelect(Ticket,SELECT_BY_TICKET);
   if(OrderCloseTime()!=0) return;
//--����--
   if(OrderType()==OP_SELL)
     {
      if(Ticket_s[INDEX][Index][2]!=3)
        {
         if(High[0]+spred>Flat_Low[INDEX])
           {
            Alert(INDEX,"]]",Index,"]_����� ��������� � ������ ",Proskalz_SL,", �� ������� ��� ������� �������.");
            Ticket_s[INDEX][Index][2]=3;
            Time_s[INDEX][Index][0]=iTime(NULL,0,0);

            TP=OrderOpenPrice()-Proskalz_TP*Point;
            if(OrderTakeProfit()!=TP)
              {
               Alert(INDEX,"]] ��������� ��� TP ��� �� ������������, ���������� ");
               if(OrderModify(Ticket,OrderOpenPrice(),OrderStopLoss(),TP,0,clrDodgerBlue)==false)
                 {
                  Alert(INDEX,"]]",Symbol()," ������ ������������ ������ = ",GetLastError(),"___",Ticket,"_",OrderOpenPrice(),"_",OrderStopLoss(),"_",TP," ������ �� ������");
                 }
              }
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         else
           {
            Alert(INDEX,"]]",Symbol(),Index,"] ����������� SL �� �������� ��������������� ��� ���� �� = ",Proskalz_SL);
            SL = OrderOpenPrice()- Proskalz_SL * Point;
            TP = OrderOpenPrice()- Proskalz_TP * Point;

            if(OrderModify(Ticket,OrderOpenPrice(),SL,TP,0,clrDodgerBlue)==false)
              {
               Alert(INDEX,"]]",Symbol()," ������ ������������ ������ �� �������� ��������������� = ",GetLastError(),"___",Ticket,"_",OrderOpenPrice(),"_",SL,"_",TP);
               return;
              }
            Ticket_s[INDEX][Index][2]=3;
            Time_s[INDEX][Index][0]=iTime(NULL,0,0);
           }
        }
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      if(Ticket_s[INDEX][Index][6]!=0 && Ask<=Ticket_s[INDEX][Index][6]) //   v18.2 ������������ �� ������� ������
        {

         if(High[0]+spred>Flat_Low[INDEX])
           {
            Alert(INDEX,"]]",Index,"]_����� ��������� �� ������� ������ ",TakeProfit_close,", �� ������� ��� ��� ������� �������");
            Ticket_s[INDEX][Index][6]=0;
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         else
           {
            Alert(INDEX,"]]",Symbol(),Index,"] ���������� SL ������ �� ������� ������ �� = ",TakeProfit_close);

            b=OrderSelect(Ticket,SELECT_BY_TICKET);
            SL = OrderOpenPrice()- TakeProfit_close * Point;
            TP = OrderOpenPrice()- Proskalz_TP * Point;

            if(OrderStopLoss()<=SL)
              {
               Alert(INDEX,"]]","����� ��������� SL �� ������� ������, �� SL ��� �����. ");
               Ticket_s[INDEX][Index][6]=0;

               if(OrderTakeProfit()!=TP)
                 {
                  Alert(INDEX,"]] ��������� ��� TP ��� �� ������������, ���������� ");
                  if(OrderModify(Ticket,OrderOpenPrice(),OrderStopLoss(),TP,0,clrDodgerBlue)==false)
                    {
                     Alert(INDEX,"]]",Symbol()," ������ ������������ ������ = ",GetLastError(),"___",Ticket,"_",OrderOpenPrice(),"_",OrderStopLoss(),"_",TP," ������ �� ������");
                    }
                 }

               return;
              }

            if(OrderModify(Ticket,OrderOpenPrice(),SL,TP,0,clrDodgerBlue)==false)
              {
               Alert(INDEX,"]]",Symbol()," ������ ������������ ������ �� ������� ������ = ",GetLastError(),"___",Ticket,"_",OrderOpenPrice(),"_",SL,"_",TP," ������ �� ������");
               return;
              }
            Ticket_s[INDEX][Index][6]=0;
           }
        }

      if(Ticket_s[INDEX][Index][5]!=0 && Ask<=Ticket_s[INDEX][Index][5] && DoubleClose_big) //   v17.4 �������� ������ ����� �� ������� ����
        {
         Alert(INDEX,"]]",Symbol(),Index,"] �������� ����� ������ �� ������� ����");
         double Lot_clos_s=NormalizeDouble(Ticket_s[INDEX][Index][7]*Lot_koof_cl_big,2);   //  !!!!������������ ���� �� 2� ������ ����� ������� - ����� �� ����� ��������            
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(OrderClose(Ticket,Lot_clos_s,Ask,Slippage,clrRed))
           {
            Ray(INDEX+"_Close_big_s2"+Index+DayOfYear(),TimeCurrent()+6000,Bid,clrAqua,2);
            b=OrderSelect(Ticket,SELECT_BY_TICKET);     //  ������������ �������� �� v11 
            Alert(INDEX,"]]","������� ���� =",DoubleToStr(Ask,Digits),", ��������� �� = ",DoubleToStr(OrderClosePrice(),Digits));
            Alert(INDEX,"]]",Symbol(),Index,"]_������� �� �������� ����� = ",(Ticket_s[INDEX][Index][5]-OrderClosePrice())/Point," ������� + ",TakeProfit_close_max);

            for(int pos=0;pos<=OrdersTotal();pos++) // ����� ������ ������
              {
               if(OrderSelect(pos,SELECT_BY_POS,MODE_TRADES)==false) continue;
               if(OrderComment()=="from #"+Ticket) { int Tikt_s=OrderTicket(); break; }  // ����� �������� ������� ������ �� ����������, ��� / ����, ������, ������
              }
            Ticket_s[INDEX][Index][0]=Tikt_s;
            Ticket=Tikt_s;
            Ticket_s[INDEX][Index][7]=Ticket_s[INDEX][Index][7]-Lot_clos_s;

            Alert(INDEX,"]]",Symbol(),Index,"] ����� ����� ������������ = ",Ticket);
            b=OrderSelect(Ticket,SELECT_BY_TICKET);
            Alert(INDEX,"]]","��� ���������� �����= ",OrderMagicNumber(),", � ���������� = ",OrderComment());
            Alert(INDEX,"]]",Symbol()," ����� ��� ��� �������� = ",Ticket_s[INDEX][Index][7]);
            Ticket_s[INDEX][Index][5]=0;
            return;
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         else
           {
            Alert(INDEX,"]]","������ �������� SELL = ",GetLastError());
            Alert(INDEX,"]]",Ticket,", ",Lot_clos_s,", ",DoubleToStr(Ask,Digits));
           }
        }

      if(Time_s[INDEX][Index][0]!=iTime(NULL,0,0)) //  ������� ������ � �������� ������ ����
        {
         SL=iHigh(NULL,0,1)+spred;
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(OrderSelect(Ticket,SELECT_BY_TICKET))
           {
            if(SL>=OrderStopLoss()) // ���� ����� SL ���� �������, �� �� ���������� 
              {
               Time_s[INDEX][Index][0]=iTime(NULL,0,0);
               return;
              }

            if(Price_SL[INDEX]==0 || Price_SL[INDEX]>Ask)
              {

               Alert(INDEX,"]]",Symbol(),Index,"] ����������� SL �� ��������� ����������� ����");
               if(OrderModify(Ticket,OrderOpenPrice(),SL,OrderTakeProfit(),0,clrDodgerBlue)==false)
                 {
                  Alert(INDEX,"]]",Symbol()," ������ ������������ ������ �� ������������ SL = ",GetLastError(),"_",Ticket,"_",OrderOpenPrice(),"_",SL,"_",OrderTakeProfit());
                  Alert(INDEX,"]]","����� ����� SL � Ask ",(SL-Ask)/Point," �������");
                  Price_SL[INDEX]=Ask;
                  return;
                 }
               else
                 {
                  Alert(INDEX,"]]",Symbol(),Index,"] ����� ��� ��������� ",((OrderOpenPrice()-SL)/Point)," �������");
                  Time_s[INDEX][Index][0]=iTime(NULL,0,0);
                  Price_SL[INDEX]=0;
                 }
              }
           }
        }
     }
//------------------------------------------------------------------------------

//--���--
   if(OrderType()==OP_BUY)
     {
      if(Ticket_b[INDEX][Index][2]!=3)
        {

         if(Low[0]<Flat_Hich[INDEX])
           {
            Alert(INDEX,"]]",Index,"]_����� ��������� � ������ ",Proskalz_SL,", �� ������� ��� ������� �������.");
            Ticket_b[INDEX][Index][2]=3;
            Time_b[INDEX][Index][0]=iTime(NULL,0,0);

            TP=OrderOpenPrice()+Proskalz_TP*Point;
            if(OrderTakeProfit()!=TP)
              {
               Alert(INDEX,"]] ��������� ��� TP ��� �� ������������, ���������� ");
               if(OrderModify(Ticket,OrderOpenPrice(),OrderStopLoss(),TP,0,clrDodgerBlue)==false)
                 {
                  Alert(INDEX,"]]",Symbol()," ������ ������������ ������ = ",GetLastError(),"___",Ticket,"_",OrderOpenPrice(),"_",OrderStopLoss(),"_",TP," ������ �� ������");
                 }
              }

           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         else
           {

            Alert(INDEX,"]]",Symbol(),Index,"] ����������� SL �� �������� ��������������� ��� ���� �� =",Proskalz_SL);
            SL = OrderOpenPrice()+ Proskalz_SL * Point;
            TP = OrderOpenPrice()+ Proskalz_TP * Point;
            if(OrderModify(Ticket,OrderOpenPrice(),SL,TP,0,clrDodgerBlue)==false)
              {
               Alert(INDEX,"]]",Symbol()," ������ ������������ ������ �� �������� ��������������� = ",GetLastError(),"___",Ticket,"_",OrderOpenPrice(),"_",SL,"_",TP);
               return;
              }
            Ticket_b[INDEX][Index][2]=3;
            Time_b[INDEX][Index][0]=iTime(NULL,0,0);
           }
        }
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      if(Ticket_b[INDEX][Index][6]!=0 && Bid>=Ticket_b[INDEX][Index][6]) //   v18.2 ������������ �� ������� ������
        {
         if(Low[0]<Flat_Hich[INDEX])
           {
            Alert(INDEX,"]]",Index,"]_����� ��������� �� ������� ������ ",TakeProfit_close,", �� ������� ��� ��� ������� �������");
            Ticket_b[INDEX][Index][6]=0;
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         else
           {

            Alert(INDEX,"]]",Symbol(),Index,"] ���������� SL ������ �� ������� ������ �� = ",TakeProfit_close);

            b=OrderSelect(Ticket,SELECT_BY_TICKET);
            SL = OrderOpenPrice()+ TakeProfit_close * Point;
            TP = OrderOpenPrice()+ Proskalz_TP * Point;

            if(OrderStopLoss()>=SL)
              {
               Alert(INDEX,"]]","����� ��������� SL �� ������� ������, �� SL ��� �����. ");
               Ticket_b[INDEX][Index][6]=0;

               if(OrderTakeProfit()!=TP)
                 {
                  Alert(INDEX,"]] ��������� ��� TP ��� �� ������������, ���������� ");
                  if(OrderModify(Ticket,OrderOpenPrice(),OrderStopLoss(),TP,0,clrDodgerBlue)==false)
                    {
                     Alert(INDEX,"]]",Symbol()," ������ ������������ ������ = ",GetLastError(),"___",Ticket,"_",OrderOpenPrice(),"_",OrderStopLoss(),"_",TP," ������ �� ������");
                    }
                 }

               return;
              }

            if(OrderModify(Ticket,OrderOpenPrice(),SL,TP,0,clrDodgerBlue)==false)
              {
               Alert(INDEX,"]]",Symbol()," ������ ������������ ������ �� ������� ������ = ",GetLastError(),"___",Ticket,"_",OrderOpenPrice(),"_",SL,"_",TP);
               return;
              }
            Ticket_b[INDEX][Index][6]=0;
           }
        }

      if(Ticket_b[INDEX][Index][5]!=0 && Bid>=Ticket_b[INDEX][Index][5] && DoubleClose_big) //   v17.4 �������� ������ ����� �� ������� ����
        {
         Alert(INDEX,"]]",Symbol(),Index,"] �������� ����� ������ �� ������� ����");
         double Lot_clos_b=NormalizeDouble(Ticket_b[INDEX][Index][7]*Lot_koof_cl_big,2);   //  !!!!������������ ���� �� 2� ������ ����� ������� - ����� �� ����� ��������            
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(OrderClose(Ticket,Lot_clos_b,Bid,Slippage,clrRed))
           {
            Ray(INDEX+"_Close_big_b2"+Index+DayOfYear(),TimeCurrent()+6000,Bid,clrAqua,2);
            b=OrderSelect(Ticket,SELECT_BY_TICKET);     //  ������������ �������� �� v11 
            Alert(INDEX,"]]","������� ���� =",DoubleToStr(Bid,Digits),", ��������� �� = ",DoubleToStr(OrderClosePrice(),Digits));
            Alert(INDEX,"]]",Symbol(),Index,"]_������� �� �������� ����� = ",(OrderClosePrice()-Ticket_b[INDEX][Index][5])/Point," ������� + ",TakeProfit_close_max);

            for(int poss=0;poss<=OrdersTotal();poss++) // ����� ������ ������
              {
               if(OrderSelect(poss,SELECT_BY_POS,MODE_TRADES)==false) continue;
               if(OrderComment()=="from #"+Ticket) { int Tikt_b=OrderTicket(); break; }  // ����� �������� ������� ������ �� ����������, ��� / ����, ������, ������
              }
            Ticket_b[INDEX][Index][0]=Tikt_b;
            Ticket=Tikt_b;
            Ticket_b[INDEX][Index][7]=Ticket_b[INDEX][Index][7]-Lot_clos_b;

            Alert(INDEX,"]]",Symbol(),Index,"] ����� ����� ������������ = ",Ticket);
            b=OrderSelect(Ticket,SELECT_BY_TICKET);
            Alert(INDEX,"]]","��� ���������� �����= ",OrderMagicNumber(),", � ���������� = ",OrderComment());
            Alert(INDEX,"]]",Symbol()," ����� ��� ��� �������� = ",Ticket_b[INDEX][Index][7]);
            Ticket_b[INDEX][Index][5]=0;
            return;
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         else
           {
            Alert(INDEX,"]]","������ �������� BUY = ",GetLastError());
            Alert(INDEX,"]]",Ticket,", ",Lot_clos_b,", ",DoubleToStr(Bid,Digits));
           }
        }

      if(Time_b[INDEX][Index][0]!=iTime(NULL,0,0)) //  ������� ������ � �������� ������ ����
        {
         SL=iLow(NULL,0,1);
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(OrderSelect(Ticket,SELECT_BY_TICKET))
           {
            if(SL<=OrderStopLoss()) // ���� ����� SL ���� �������, �� �� ���������� 
              {
               Time_b[INDEX][Index][0]=iTime(NULL,0,0);
               return;
              }

            if(Price_SL[INDEX]==0 || Price_SL[INDEX]<Bid)
              {
               Alert(INDEX,"]]",Symbol(),Index,"] ����������� SL �� �������� ����������� ����");
               if(OrderModify(Ticket,OrderOpenPrice(),SL,OrderTakeProfit(),0,clrDodgerBlue)==false)
                 {
                  Alert(INDEX,"]]",Symbol()," ������ ������������ ������ �� ������������ SL = ",GetLastError(),"___",Ticket,"_",OrderOpenPrice(),"_",SL,"_",OrderTakeProfit());
                  Alert(INDEX,"]]","����� ����� Bid � SL ",(Bid-SL)/Point," �������");
                  Price_SL[INDEX]=Bid;
                  return;
                 }
               else
                 {
                  Alert(INDEX,"]]",Symbol(),Index,"] ����� ��� ��������� ",((SL-OrderOpenPrice())/Point)," �������");
                  Time_b[INDEX][Index][0]=iTime(NULL,0,0);
                  Price_SL[INDEX]=0;
                 }
              }
           }
        }
     }
  }

//+------------------------------------------------------------------------------------------------------------------------------------------------------+
void Check_for_Close_5() // ��������� ����� �� ����������� �������, ����� ����� �������� ���
  {/*
         double TP;

         if(Ticket == Ticket_s[INDEX] || Ticket == Ticket_s2 ) TP = Ticket_s[INDEX] [Index][3];
         if(Ticket == Ticket_b[INDEX] || Ticket == Ticket_b2 ) TP = Ticket_b[INDEX] [Index][3];
         Alert(INDEX,"]]",Symbol(),"_����������� TP �������, �� �������� ��� ������ ���. ������� = ",TP);
         if(OrderSelect(Ticket,SELECT_BY_TICKET))
           {
            if(OrderModify(Ticket,OrderOpenPrice(),OrderStopLoss(),TP,0,clrMagenta)==false)
               Alert(INDEX,"]]",Symbol(),"_ ������ ����������� �������� = ",GetLastError());
            Alert(INDEX,"]]",Symbol(),"_ ���� Bid = ",Bid," ���� Ask = ",Ask);
            Ticket = 0; return;
           }
   */     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Check_for_Close_6() //  ������������ ��� ���������� �������� ���� ��� ������ ���������
  {/*
         if(Ticket==Ticket_s[INDEX] || Ticket==Ticket_s2) // ????  ����� � ����� �������
           {

            if(Ask<=Ticket_s[INDEX] [Index][3])
              {

               if(OrderClose(Ticket,Ticket__ [Index][7],Ask,Slippage,clrRed))
                 {
                  Ray(INDEX+"_Close_s",TimeCurrent()+6000,Ask,clrAqua,2);
                  OrderSelect(Ticket,SELECT_BY_TICKET);     //  ������������ �������� �� v11 
                  Alert(INDEX,"]]",Symbol(),"_������� �� �������� = ",(Ticket_s[INDEX] [Index][3]-OrderClosePrice())/Point," �������");
                  Ticket=0;
                  return;
                 }
               else
                 {
                  Alert(INDEX,"]]","������ �������� sell = ",GetLastError());
                  Alert(INDEX,"]]",Ticket,", ",Ticket__ [Index][7],", ",Ask);
                 }
              }
           }

         if(Ticket==Ticket_b[INDEX] || Ticket==Ticket_b2) // ????  ����� � ����� �������
           {

            if(Bid>=Ticket_b[INDEX] [Index][3])
              {
               if(OrderClose(Ticket,Ticket__ [Index][7],Bid,Slippage,clrRed))
                 {
                  Ray(INDEX+"_Close_b",TimeCurrent()+6000,Bid,clrAqua,2);
                  OrderSelect(Ticket,SELECT_BY_TICKET);     //  ������������ �������� �� v11 
                  Alert(INDEX,"]]",Symbol(),"_������� �� �������� = ",(OrderClosePrice()-Ticket_b[INDEX] [Index][3])/Point," �������");
                  Ticket=0;
                  return;
                 }
               else
                 {
                  Alert(INDEX,"]]","������ �������� buy = ",GetLastError());
                  Alert(INDEX,"]]",Ticket,", ",Ticket__ [Index][7],", ",Bid);
                 }
              }
           }
    */    }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//--- ��������� ������� ���� �� ����� ------------------------------------------------------------------------------------------------------------------------

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
// ������������ ��� ������������� � �������� ������� � �������� MQL4.
//--------------------------------------------------------------- 1 --
// ������� ��������� ������.
// ������������ ��������:
// true  - ���� ������ ����������� (�.�. ����� ���������� ������)
// false - ���� ������ ����������� (�.�. ��������� ������)
//--------------------------------------------------------------- 2 --
bool Errors(int Error) // ���������������� �������
  {
// Error             // ����� ������   
//   if(Error==0)
//      return(false);                      // ��� ������
//--------------------------------------------------------------- 3 --
   switch(Error)
     {   // ����������� ������:
      case 129:         // ������������ ����
      case 135:         // ���� ����������
         RefreshRates();                  // ������� ������
         return(true);                    // ������ �����������
      case 136:         // ��� ���. ��� ����� ���.
         while(RefreshRates()==false) // �� ������ ����
         Sleep(1);                     // �������� � �����
         return(true);                    // ������ �����������
      case 146:         // ���������� �������� ������
         Sleep(500);                      // ������� �������
         RefreshRates();                  // ������� ������
         return(true);                    // ������ �����������

                                          // ����������� ������:
      case 2 :          // ����� ������
      case 5 :          // ������ ������ ����������� ���������
      case 64:          // ���� ������������
      case 133:         // �������� ���������
         return(false);                   // ����������� ������

      default:          // ������ ��������      
         return(true);                   // ���� ������ �� �������, �� ������
     }
//--------------------------------------------------------------- 4 --
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//--- ���������� �� �������  ------------------------------------------------------------------------------------------------------------------------

void Zigzag(int Chikl)
  {
   int i,j;
//  int k;
//  int m=0;  // ��� ���������� ��������, ���� ������ ������� ���
   m=0;  // ��� ���������� ��������, ���� ������ ������� ���
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
         //Alert ("�������� ���� =", zz); 
         datetime ZZ_time=iTime(NULL,0,i);
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(m==0) // ��� ���������� ��������, ���� ������ ������� ��� ��� ��������� ������� �������
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

   for(k=j;k<100;k++) // ������� ������ ������  ��� ��������� ������� �������
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(ObjectDelete("Zig_"+k+"_"+DayOfYear()));
      else break;  // ���� �����������, �� �������
     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//------------------------------------------------------------------------------------------------------------------------------------------------
// �������� ������ �� ����

bool Close_Ord(int Ticket,double Lot) //  �������� ������ 
  {
   Alert(INDEX,"]]","�������� ����� ������ � ",Ticket," ����� = ",Lot);
   if(OrderSelect(Ticket,SELECT_BY_TICKET)==false)
     { Alert(INDEX,"]]",Symbol(),"������ ������ ������ � ",GetLastError()); return(true); }

   double Price;
   if(OrderType()!=OP_BUY && OrderType()!=OP_SELL)
     { Alert(INDEX,"]]",Symbol(),"����� # ",Ticket," �� ��������"); return(true); }

   if(Lot>OrderLots() || Lot==0) Lot=OrderLots();

   RefreshRates();
   if(OrderType() == OP_BUY ) Price = Bid;
   if(OrderType() == OP_SELL ) Price = Ask;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(OrderClose(Ticket,Lot,Price,Slippage,clrRed))
     {
      Alert(INDEX,"]]","������� ���� = ",DoubleToStr(Price,Digits),", ��������� �� = ",DoubleToStr(OrderClosePrice(),Digits));
      return (true);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      Alert(INDEX,"]]",Symbol()," ������ �������� ������ # ",Ticket,", ������ # ",GetLastError());
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
///-----����� ���� ����� � ������� (������ �����)--------------------------------------------------  

   if(Number_Orders==1)
     {
      if(Form=="Bezub") return(1);
      if(Form=="Pips") return(0);
      if(Form=="Take_min") return (TakeProfit_close_min);
      if(Form=="Take_midl") return (TakeProfit_close);

      Alert(INDEX,"]]","������ � ������� Order_form  ",Index," , ",Form);
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

   Alert(INDEX,"]]","������ � ������� Order_form  ",Index," , ",Form);
   return (1000000000);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//------------------------------------------------------------ ��������� --------------------------------------------------------------------- 

void Rollover()
  {
   Rol_Check();
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(Rol_koef<0) // ����������
     {
      Decrease();
      //     Delayed_cor();
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(Rol_koef>0) // ����������  
     {
      Increase();
      //    Delayed_cor();
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+ �������� ����������
void Rol_Check() // �������� ����������
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
      if(OrderType()==6) // ���������� ��������   
        {
         Rol_ti=OrderTicket();
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(Rol_ti>Ticket_rol)
           {
            Alert(INDEX,"]]","=-=-=-=- �������� �������� ��������� � ",OrderTicket());
            Balance_Change+=OrderProfit();   // ����� ��������� ������� �� ����������
            if(Rol_ti>Rol_pr) Rol_pr=Rol_ti;
           }
         else break;  //   ���� ����������� ������ ��� ������ ��� ����� Ticket_rol 
        }
     }

   if(Balance!=0) Alert(INDEX,"]]","������� ������ = ",Balance);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(Rol_pr!=0 || Balance!=0)
     {
      if(Rol_pr!=0) Ticket_rol=Rol_pr;
      GlobalVariableSet(Rollover_name,Ticket_rol);   // ���������� ���������� ���������

      if(OrdersTotal()==0)
        {
         Rol_koef=0;
         Alert(INDEX,"]]","�������� ������� ��� ������������� ���");
         return;
        }

      Equity=AccountEquity();
      if(Equity!=Balance_Change)// ������ �� ������ ������� �� 0  
         //         Rol_koef=Balance_Change/(Equity-Balance_Change);
         Rol_koef=(Balance_Change+Balance)/(Equity-Balance_Change-Balance);
      else Rol_koef=0.0000001;

      Balance=0;

      Alert(INDEX,"]]","��������� ������� �� ���������� ����� =                                          ",Balance_Change);
      Alert(INDEX,"]]","������ �� ��������� �� �������� = ",Equity-Balance_Change);
      Alert(INDEX,"]]","����� ��������� �������� � ",Ticket_rol);
      Alert(INDEX,"]]","����������� ��������� = ",Rol_koef);
      double Lotstep=MarketInfo(Symbol(),MODE_LOTSTEP);
      Alert(INDEX,"]]","���������� ��������/������� ����� = ",MathFloor((Equity-Balance_Change)*Rol_koef/Lotstep)*Lotstep);

      if(Rol_koef<-1)
        {
         Alert(INDEX,"]]","������ � ��������, ��������� 0");
         Rol_koef=0;
        }
     }
   else Rol_koef=0;    // ���� �� ���� ���������� ��������
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+ ���������� � ��������
void Decrease() // ����������
  {
   Alert(INDEX,"]]","������ ������� ���������� ������");
//   string sym;

   int total=Mass_Order_PF();
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(total==0)
     {
      Alert(INDEX,"]]","�������� �������� ������� ���, �������������� ������");
      return;
     }
/*
   if(total==1)
     {
      Alert(INDEX,"]]","������ ������ �������� �����, ��� �������� � ��� ��������");
      Close_Lot(Ticket2[0][0],0);
      flag_check=0;
      return;
     }

   double V_sum = Mass_CountV(total);
   double V_cor = (-1)*Rol_koef*V_sum;
   V_cor=MathFloor(V_cor/Lotstep)*Lotstep;
   Alert(INDEX,"]]","��������� ����� ��� ������������� = ",V_cor);
   if(V_cor<Minlot)
     {
      Alert(INDEX,"]]","��������� ����� �� �����������. ������ ��� ����������� ���");
      return;
     }
//---------------------------------------------------------        
   if(V_cor>(V_sum-Ticket2[0][2])) //  �������� ��� ���������� � ����� ���������
     {
      double V_PF=V_cor -(V_sum-Ticket2[0][2]);

      Alert(INDEX,"]]","�������� ��� ���������� � ����� ���������= ",V_PF);

      for(i=1; i<total; i++) // �������� ����������
        {
         Close_Lot(Ticket2[i][0],-1);
        }
      Close_Lot(Ticket2[0][0],V_PF);     // �������� ����� ���������
      flag_check=0;
      return;
     }
//---------------------------------------------------------        
   for(i=1; i<total; i++) // ����� ������ �� ���� ��� �������� ��� ��������
     {
      if(Ticket2[i][2]>=V_cor)
        {
         Alert(INDEX,"]]","����� ���������� ����� ��� ���������� #",Ticket2[i][0]);
         Close_Lot(Ticket2[i][0],V_cor);
         return;
        }
     }
//---------------------------------------------------------        
   for(i=total-1; i>0; i--) // �������� ���������� �����, ������� � ��������
     {
      if(V_cor>Ticket2[i][2])
        {
         Close_Lot(Ticket2[i][0],-1);
         Alert(INDEX,"]]","--�������� ��������� �",Ticket2[i][0]);
         V_cor-=Ticket2[i][2];
         continue;
        }

      if(V_cor==Ticket2[i][2])
        {
         Alert(INDEX,"]]","---�������� ��������� �",Ticket2[i][0]);
         Close_Lot(Ticket2[i][0],-1);
         return;
        }

      if(V_cor<Ticket2[i][2])
        {
         Alert(INDEX,"]]","----�������� ����� �",Ticket2[i][0]);
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
void Increase() // ����������
  {
   Alert(INDEX,"]]","������ ������� ���������� ������");
   double lot;
   int  res;

//   int total=Mass_Order_PF();

   double V_sum=Mass_CountV();
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(V_sum==0)
     {
      Alert(INDEX,"]]","�������� �������� �������/������ ���, �������������� ������");
      return;
     }

   double Minlot   =  MarketInfo(Symbol(), MODE_MINLOT);
   double Lotstep  =  MarketInfo(Symbol(), MODE_LOTSTEP);

   lot = MathAbs (Rol_koef*V_sum);
   lot = MathFloor(lot/Lotstep)*Lotstep;
   Alert(INDEX,"]]","����������� ��� ��� ��������� ������: ",lot);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(lot<Minlot)
     {
      Alert(INDEX,"]]","����������� ��� ������ ����������-����������. �����");
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      //      b=OrderSelect(Ticket2[0][0],SELECT_BY_TICKET);
      //     

      for(k=0; k<Numb_Orders[INDEX]; k++) // ������ ���������� ���������� ��������� ������
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
        {
         if(V_sum>0 && Ticket_b[INDEX][k][2]!=0 && Ticket_b[INDEX][k][2]!=5)
           {
            if(Ticket_b[INDEX][k][0]==0) continue;
            b=OrderSelect(Ticket_b[INDEX][k][0],SELECT_BY_TICKET);
            Alert(INDEX,"]]","��������� ��������� ������ ��� [",k);
            break;
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(V_sum<0 && Ticket_s[INDEX][k][2]!=0 && Ticket_s[INDEX][k][2]!=5)
           {
            if(Ticket_s[INDEX][k][0]==0) continue;
            b=OrderSelect(Ticket_s[INDEX][k][0],SELECT_BY_TICKET);
            Alert(INDEX,"]]","��������� ��������� ������ ���� [",k);
            break;
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(k==Numb_Orders[INDEX]-1) // �� ��������� ��������
           {
            Alert(INDEX,"]]","���� �� �� ������� � ������� �������������. ����� ");
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
         Alert(INDEX,"]]","������ ��������� ������ �� ��������� # ",GetLastError());
         return;
        }
      else
         Alert(INDEX,"]]","������ ����� ���������� �� ��������� � ",res);

      //------������ ��� ����

      Numb_Orders[INDEX]++;
      int Range;

      if(V_sum>0)
        {
         Range=ArrayRange(Ticket_b,1);
         Alert(INDEX,"]]","������ ������� = ",Range);
         Alert(INDEX,"]]","������� �������������� ��� �� = [",k);
         for(m=1; m<Range; m++) { Ticket_b[INDEX][Numb_Orders[INDEX]][m]=Ticket_b[INDEX][k][m]; } // ������� ��������������
         Ticket_b[INDEX][Numb_Orders[INDEX]][0]=res;
        }

      if(V_sum<0)
        {
         Range=ArrayRange(Ticket_s,1);
         Alert(INDEX,"]]","������ ������� = ",Range);
         Alert(INDEX,"]]","������� �������������� ���� �� = [",k);
         for(m=1; m<Range; m++) { Ticket_s[INDEX][Numb_Orders[INDEX]][m]=Ticket_s[INDEX][k][m]; } // ������� ��������������
         Ticket_s[INDEX][Numb_Orders[INDEX]][0]=res;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------------------------------------------------------------------------------------------------
int Mass_Order_PF() //������� ��� �������� ������  �� ������� ������� � ������ Ticket[]. ���������� ���-�� �������.
  {
   int c=0;
   double V=0.0;
//   string symbol=Symbol();

   for(k=0; k<Numb_Orders[INDEX]; k++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(Ticket_b[INDEX][k][2]!=0 && Ticket_b[INDEX][k][2]!=5) // �������� �� ���
        {
         //         V+=Ticket_b[INDEX][k][7];
         //         Ticket[c][0] =  Ticket_b[INDEX][k][0];
         //         Ticket[c][7] =  Ticket_b[INDEX][k][7];
         c++;
        }
      if(Ticket_s[INDEX][k][2]!=0 && Ticket_s[INDEX][k][2]!=5) // �������� �� ����
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
      Alert(INDEX,"]]","������� ����� �������� ������� = ",c,",  Numb_Orders[INDEX] =",Numb_Orders[INDEX]);
      //      Alert(INDEX,"]]","��������� �������� �� ����� = ",V);
     }
   else  return(0);
/*
//--- ���������� � ������ �� ������ --
   total= c;
   for(i=0; i<total; i++)
     {
      b=OrderSelect(Ticket[i],SELECT_BY_TICKET);
      Ticket2[i][0]=Ticket[i];
      //      Ticket2[i][1] = NormalizeDouble(OrderProfit() + OrderCommission() + OrderSwap(), 2);
      Ticket2[i][2]=OrderLots();
      //      Ticket2[i][3] = OrderOpenTime();
     }

   for(i=1; i<total; i++) // 0-��� �������� �����, ��� �� �������
      for(j=1; j<total-1; j++) // 0-��� �������� �����, ��� �� �������                       
        {                                                     //����� ������ �������� ������ <�����>
         if(Ticket2[j][2]-Ticket2[j+1][2]>0.0) //���� ����������� �������
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
      Alert(INDEX,"]]","---- ",i," ����� �� ������ �",Ticket2[i][0]);
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
      if(Ticket_b[INDEX][k][2]!=0 && Ticket_b[INDEX][k][2]!=5) // �������� �� ���
        {
         V+=Ticket_b[INDEX][k][7];
         c++;
        }
      if(Ticket_s[INDEX][k][2]!=0 && Ticket_s[INDEX][k][2]!=5) // �������� �� ����
        {
         V-=Ticket_s[INDEX][k][7];
         c++;
        }
     }

   Alert(INDEX,"]]","+- ������� ����� �������� ������� = ",c,",  Numb_Orders[INDEX] =",Numb_Orders[INDEX]);
   Alert(INDEX,"]]","��������� ������� ����� = ",V);

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
      Alert(INDEX,"]]","!! ������� ���� Nonfarm Payrolls, ��������� �� �����");
      return (true);
     }

//-------------------     
   return (false);
  }
//+------------------------------------------------------------------+
