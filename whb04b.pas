Unit WHB04B;
{$mode objfpc}{$H+}
Interface

uses
//  heaptrc,{to hunt for memory leaks}
  serial,
  CRT,
  Classes,
  sysutils,
  libusbhid,
  hid_testing_utils;

Const
  Axis_Power_Off           = $00 ;
  Axis_Sel_Off             = $06 ;
  Axis_Sel_X               = $11 ;
  Axis_Sel_Y               = $12 ;
  Axis_Sel_Z               = $13 ;
  Axis_Sel_A               = $14 ;

  Wheel_Power_Off          = $00 ;
  Wheel_Mode_2             = $0D ;
  Wheel_Mode_5             = $0E ;
  Wheel_Mode_10            = $0F ;
  Wheel_Mode_30            = $10 ;
  Wheel_Mode_60            = $1A ;
  Wheel_Mode_100           = $1B ;
  Wheel_Mode_Lead          = $1C ;
  Wheel_Mode_Lead_Wireless = $9B ;

   Wheel_Distance_Multiplier : Array [$0D..$9B] of Real = (
      {0D} 0.001,
      {0E} 0.01,
      {0F} 0.1,
      {10} 1,
      0,0,0,0,0,0,0,0,0,
      {1A} 1,
      {1B} 1,
      {1C} 1,       //only for wired version
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,
      {9B} 1);       //only for wireless version

   Wheel_Feedrate_Percentage : Array [$0D..$9B] of Real = (
      {0D} 2,
      {0E} 5,
      {0F} 10,
      {10} 30,
      0,0,0,0,0,0,0,0,0,
      {1A} 60,
      {1B} 100,
      {1C} 100,       //only for wired version
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,
      {9B} 100);       //only for wireless version

  // Button definitions
  Button_None              = $00 ;
  Button_Reset             = $01;
  Button_Stop              = $02;
  Button_Start_Pause       = $03 ;
  Button_Macro1_FeedPos    = $04;
  Button_Macro2_FeedNeg    = $05;
  Button_Macro3_SpindlePos = $06 ;
  Button_Macro4_SpindleNeg = $07 ;
  Button_Macro5_MHome      = $08 ;
  Button_Macro6_SafeZ      = $09 ;
  Button_Macro7_WHome      = $0A ;
  Button_Macro8_SOnOff     = $0B ;
  Button_Fn                = $0C ;
  Button_Macro9_ProbeZ     = $0D ;
  Button_Continuous        = $0E ;
  Button_Step              = $0F ;
  Button_Macro10           = $10 ;



   // button look up table
    Button_Raw_LookUp : Array [$00..$FF] of String = (  // These only work on Wired version
       {00}'B00_None'              ,
       '','','','','','','','','','','','','','','','',
       '','','','','','','','','','','','','','','','',
       '','','','','','','','','','','','','','','','',
       '','','','','','','','','','','','','','','','',
       '','','','','','','','','','','','','','','','',
       '','','','','','','','','','','','','','','','',
       '','','','','','','','','','','','','','','','',
       '','','','','','','','','','','','','','','','',
       '','','','','','','','','','','','','','','','',
       '','','','','','','','','','','','','','','','',
       '','','','','','','','','','','','','','','','',
       '','','','','','','','','','','','','','','','',
       '','','','','','','','','','','','','','','','',
       '','','','','','','','','','','','','','','','',
       '','','','','','','','','','','','','','','',
       {FF}'B16_Macro10'           ,
       {FE}'B15_Step'              ,
       {FD}'B14_Continuous'        ,
       {FC}'B13_Macro9_ProbeZ'     ,
       {FB}'B12_Fn'                ,
       {FA}'B11_Macro8_SOnOff'     ,
       {F0}'B10_Macro7_WHome'      ,
       {F9}'B09_Macro6_SafeZ'      ,
       {F8}'B08_Macro5_MHome'      ,
       {F7}'B07_Macro4_SpindleNeg' ,
       {F6}'B06_Macro3_SpindlePos' ,
       {F5}'B05_Macro2_FeedNeg'    ,
       {F4}'B04_Macro1_FeedPos'    ,
       {F3}'B03_Start_Pause'       ,
       {F2}'B02_Stop'              ,
       {F1}'B01_Reset'             );

    Button_LookUp : Array [0..16] of String = (
       { 0}'None'             ,
       { 1}'Reset'            ,
       { 2}'Stop'             ,
       { 3}'Start_Pause'      ,
       { 4}'Macro1'           ,
       { 5}'Macro2'           ,
       { 6}'Macro3'           ,
       { 7}'Macro4'           ,
       { 8}'Macro5'           ,
       { 9}'Macro6'           ,
       {10}'Macro7'           ,
       {11}'Macro8'           ,
       {12}'Fn'               ,
       {13}'Macro9'           ,
       {14}'Continuous'       ,
       {15}'Step'             ,
       {16}'Macro10'          );

    Fn_LookUp : Array [0..16] of String = (
       { 0}'None'             ,
       { 1}'Reset'            ,
       { 2}'Stop'             ,
       { 3}'Start_Pause'      ,
       { 4}'FeedPos'          ,
       { 5}'FeedNeg'          ,
       { 6}'SpindlePos'       ,
       { 7}'SpindleNeg'       ,
       { 8}'MHome'            ,
       { 9}'SafeZ'            ,
       {10}'WHome'            ,
       {11}'SOnOff'           ,
       {12}'Fn'               ,
       {13}'ProbeZ'           ,
       {14}'Continuous'       ,
       {15}'Step'             ,
       {16}'Macro10'          );

    Axis_Sel_Lookup : Array [$00..$14] of String = (
       {00} 'Power Off',              //only for wireless version
       '','','','','',
       {06} 'Axis_Sel_Off',
            '','','','','','','','','','',
       {11} 'Axis_Sel_X',
       {12} 'Axis_Sel_Y',
       {13} 'Axis_Sel_Z',
       {14} 'Axis_Sel_A');

    Wheel_Mode_Lookup : Array [$00..$9B] of String = (
       {00} 'Power Off',              //only for wireless version
       '','','','','','','','','','','','',
       {0D} 'Wheel_Mode_2',
       {0E} 'Wheel_Mode_5',
       {0F} 'Wheel_Mode_10',
       {10} 'Wheel_Mode_30',
       '','','','','','','','','',
       {1A} 'Wheel_Mode_60',
       {1B} 'Wheel_Mode_100',
       {1C} 'Wheel_Mode_Lead',       //only for wired version
       '','','','','','','','','','','','','','','','',
       '','','','','','','','','','','','','','','','',
       '','','','','','','','','','','','','','','','',
       '','','','','','','','','','','','','','','','',
       '','','','','','','','','','','','','','','','',
       '','','','','','','','','','','','','','','','',
       '','','','','','','','','','','','','','','','',
       '','','','','','','','','','','','','','',
       {9B} 'Wheel_Mode_Lead');       //only for wireless version


Var
   X_WHB04B_Position,Y_WHB04B_Position,Z_WHB04B_Position,A_WHB04B_Position                  : Real;
   X_WHB04B_Position_Tmp,Y_WHB04B_Position_Tmp,Z_WHB04B_Position_Tmp,A_WHB04B_Position_Tmp  :Real;
   Thread_Running, Wireless_Device_PowerOff,Device_Is_Open,
   Pos_X_Changed,Pos_Y_Changed,Pos_Z_Changed,Pos_A_Changed                                  : Boolean;
   SpindleW,FeedW                                                                           : Word;
   Button_1,Button_2                                                                        : Byte;
   ReadThreadResult, Interrupt_read_Thread_Result                                           : Integer;
   criticalSection                                                                          : TRTLCriticalSection;

Type

  TInterruptReadThread=class(TThread)
  private
  protected
    procedure Execute; override;
  public
  end;
Var
  ReadThread                               : TInterruptReadThread;

 Function Process_USB_Data:Boolean;
Procedure Check_for_Device;
 Function Check_Wireless_Power:Boolean;
Procedure Check_And_End_Thread;
 Function WHB04B_Present:Boolean;

Implementation

Var
  X_IntW,Y_IntW,Z_IntW,A_IntW,
  X_DecW,Y_DecW,Z_DEcW,A_DEcW,
  LCD_Mode: byte;
  X_WHB04B_Position_Tmp_Save,Y_WHB04B_Position_Tmp_Save,Z_WHB04B_Position_Tmp_Save,A_WHB04B_Position_Tmp_Save:Real;

{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
procedure TInterruptReadThread.Execute;
Var
   New_Data,Saved_Data : Array [0..7] of Byte;
   Axis_Sel,
   Wheel_Mode,
   Wireless_Random,
   Wireless_Checksum,
   Button_Raw,
   xor_day : Byte;
   LoopCount,TimeoutCount:Dword;
   Wheel_Relative_Movement,Wheel_Absolute_WHB04B_Position,Interrupt_Read_ReturnCode : Integer;

Function ReadThreadTwosCompliment(InData,numberofbits:Byte):Integer;
   Var
      OutData:Integer;
   Begin
       OutData:=InData;
       if (OutData And (1 SHL (numberofbits - 1))) <> 0 Then  // if sign bit is set e.g., 8bit: 128-255
          OutData := OutData - (1 SHL numberofbits);          // compute negative value
       ReadThreadTwosCompliment:=OutData;                               //return positive value as is
       //Writeln('twos - in: '+Inttohex(InData,2)+'  Out: '+Inttohex(OutData,2));
   End;

Procedure Store_Device_Data;
   Begin
   //                        New_data[0];    // Report ID
   // Wireless_Random     := New_data[1];    // Always $00 on Wired version--- Wireless generates a random number used for the Checksum
      If New_data[2] <> 0 Then
         Begin
            EnterCriticalsection(criticalSection);
            Button_1   := New_data[2];
            LeaveCriticalsection(criticalSection);
         End;
      If New_data[3] <> 0 Then
         Begin
            EnterCriticalsection(criticalSection);
            Button_2   := New_data[3];
            LeaveCriticalsection(criticalSection);
         End;
      If New_data[4] <> Saved_Data[4] Then   // Wheel multiplier or Feedrate override
         Begin
            Wheel_Mode    := New_data[4];
            Saved_Data[4] := New_data[4];
         End;
      If New_data[5] <> Saved_Data[5] Then   // Axis Selection for Wheel or turn wheel off
         Begin
            Axis_Sel      := New_data[5];
            Saved_Data[5] := New_data[5];
         End;
   // Button_Raw          := New_data[7];    //Only Wired version
   // Wireless_Checksum   := New_data[7];    //Only Wireless version
   End;

begin
   Writeln('Thread Started');
   reportIdx:=0; //devices often use one endpoint (commonly $81) to output data reports
   Axis_Sel := $0F;
   Wheel_Mode := $F0;
   Repeat
      Interrupt_Read_ReturnCode:=libusbhid_interrupt_read(device_context,$81{endpoint},{out}hidReportData[reportIdx].hid_data,64{report length, varies by device}, hidReportData[reportIdx].dataLen, {timeout=}50);
      if (Interrupt_Read_ReturnCode = -7) Then
         Begin
            //Timeout happened Data not read from device yet... maybe do something with this information.
         End
      Else
      if (Interrupt_Read_ReturnCode < 0) then
         Begin
            EnterCriticalsection(criticalSection);
            Interrupt_Read_Thread_Result:=hidReportData[reportIdx].datalen;
            LeaveCriticalsection(criticalSection);
            //Writeln('Read Error: ',hidReportData[reportIdx].datalen);
            terminate;
         End
      Else
      if hidReportData[reportIdx].datalen <> 8 then
         Begin
            //Timeout probably
         End
      Else
         Begin
            //If PrintAndCompareReport(reportIdx,0) Then   //- Show all data of all reports
            //If PrintAndCompareReport(reportIdx,1) Then   //- Show Only Changed data of all reports
            //If PrintAndCompareReport(reportIdx,2) Then   //- Show all data only when report changed
            //If PrintAndCompareReport(reportIdx,3) Then   //- Show Only Changed data only when report changed
            Begin
               Move(hidReportData[REPORTIDX].hid_data[0],New_Data[0],8);
               If New_Data[0]<>$4 then  //Always $04 for an HB04 device
                  Begin
                     Write('HB04 Packet Not Detected: ');
                     PrintAndCompareReport(reportIdx,0);
                     readln;
                  end
               Else
                  Begin
                     // Writeln('HB04 Packet Detected');
                     If New_Data[6]<>0 Then
                        Begin
                           Wheel_Relative_Movement := ReadThreadTwoscompliment(New_Data[6],8);  // Number of wheel ticks since last read
                           If Wheel_Relative_Movement<>0 Then
                              Begin
                                 If Axis_Sel < Axis_Sel_X Then
                                    Store_Device_Data;
                                 If Axis_Sel = Axis_Sel_X Then
                                    Begin
                                       EnterCriticalsection(criticalSection);
                                       X_WHB04B_Position += Wheel_Relative_Movement*Wheel_Distance_Multiplier[Wheel_Mode];
                                       LeaveCriticalsection(criticalSection);
                                    End;
                                 If Axis_Sel = Axis_Sel_Y Then
                                    Begin
                                       EnterCriticalsection(criticalSection);
                                       Y_WHB04B_Position += Wheel_Relative_Movement*Wheel_Distance_Multiplier[Wheel_Mode];
                                       LeaveCriticalsection(criticalSection);
                                    End;
                                 If Axis_Sel = Axis_Sel_Z Then
                                    Begin
                                       EnterCriticalsection(criticalSection);
                                       Z_WHB04B_Position += Wheel_Relative_Movement*Wheel_Distance_Multiplier[Wheel_Mode];
                                       LeaveCriticalsection(criticalSection);
                                    End;
                                 If Axis_Sel = Axis_Sel_A Then
                                    Begin
                                       EnterCriticalsection(criticalSection);
                                       A_WHB04B_Position += Wheel_Relative_Movement*Wheel_Distance_Multiplier[Wheel_Mode];
                                       LeaveCriticalsection(criticalSection);
                                    End;
                              End;
                        End
                     Else
                        Begin
                           Store_Device_Data;
                           //Writeln(Axis_Sel,' ',Wheel_Mode);
                           If (Axis_Sel = Axis_Power_Off) AND (Wheel_Mode = Wheel_Power_Off) then
                              Begin
                                 Writeln('Wireless Device - Power Off');
                                 Wireless_Device_PowerOff:=True;
                                 Terminate;
                              End;
                        End;
                  End;
            End;
         End;
   Until Terminated;
   Writeln('Thread Stopped');
   Thread_Running:=False;
end;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function Process_USB_Data:Boolean;
Var
   WHB04_Packet1,
   WHB04_Packet2,
   WHB04_Packet3:Array [0..7] of byte;

   X_WHB04B_Position_Abs,Y_WHB04B_Position_Abs,Z_WHB04B_Position_Abs,A_WHB04B_Position_Abs:Real;

   Position_Changed:Boolean;

Begin
   X_WHB04B_Position_Tmp:=X_WHB04B_Position;  //Copy data so it can't change in the middle of processing
   Y_WHB04B_Position_Tmp:=Y_WHB04B_Position;  //Copy data so it can't change in the middle of processing
   Z_WHB04B_Position_Tmp:=Z_WHB04B_Position;  //Copy data so it can't change in the middle of processing
   A_WHB04B_Position_Tmp:=A_WHB04B_Position;  //Copy data so it can't change in the middle of processing

   Position_Changed:=False;
   If X_WHB04B_Position_Tmp<>X_WHB04B_Position_Tmp_Save Then
      Begin;
         Position_Changed:=True;
         Pos_X_Changed:=True;
         X_WHB04B_Position_Abs:=Abs(Round(X_WHB04B_Position_Tmp*10000)/10000);  //Get absolute value with floating point weirdness cut off
         X_IntW:=Trunc(X_WHB04B_Position_Abs);  //Get integer part
         X_DecW :=Round((X_WHB04B_Position_Abs-X_IntW)*10000);  //Get 4 decimal digits as an integer
         If Round(X_WHB04B_Position_Tmp*10000)<0 Then X_DecW := X_DecW Or $8000;  //Set sign bit if negative
         X_WHB04B_Position_Tmp_Save:=X_WHB04B_Position_Tmp;
      End;

   If Y_WHB04B_Position_Tmp<>Y_WHB04B_Position_Tmp_Save Then
      Begin;
         Position_Changed:=True;
         Pos_Y_Changed:=True;
         Y_WHB04B_Position_Abs:=Abs(Round(Y_WHB04B_Position_Tmp*10000)/10000);  //Get absolute value with floating point weirdness cut off
         Y_IntW:=Trunc(Y_WHB04B_Position_Abs);  //Get integer part
         Y_DecW :=Round((Y_WHB04B_Position_Abs-Y_IntW)*10000);  //Get 4 decimal digits as an integer
         If Round(Y_WHB04B_Position_Tmp*10000)<0 Then Y_DecW := Y_DecW Or $8000;  //Set sign bit if negative
         Y_WHB04B_Position_Tmp_Save:=Y_WHB04B_Position_Tmp;
      End;

   If Z_WHB04B_Position_Tmp<>Z_WHB04B_Position_Tmp_Save Then
      Begin;
         Position_Changed:=True;
         Pos_Z_Changed:=True;
         Z_WHB04B_Position_Abs:=Abs(Round(Z_WHB04B_Position_Tmp*10000)/10000);  //Get absolute value with floating point weirdness cut off
         Z_IntW:=Trunc(Z_WHB04B_Position_Abs);  //Get integer part
         Z_DecW :=Round((Z_WHB04B_Position_Abs-Z_IntW)*10000);  //Get 4 decimal digits as an integer
         If Round(Z_WHB04B_Position_Tmp*10000)<0 Then Z_DecW := Z_DecW Or $8000;  //Set sign bit if negative
         Z_WHB04B_Position_Tmp_Save:=Z_WHB04B_Position_Tmp;
      End;

   If A_WHB04B_Position_Tmp<>A_WHB04B_Position_Tmp_Save Then
      Begin;
         Position_Changed:=True;
         Pos_A_Changed:=True;
         A_WHB04B_Position_Abs:=Abs(Round(A_WHB04B_Position_Tmp*10000)/10000);  //Get absolute value with floating point weirdness cut off
         A_IntW:=Trunc(A_WHB04B_Position_Abs);  //Get integer part
         A_DecW :=Round((A_WHB04B_Position_Abs-A_IntW)*10000);  //Get 4 decimal digits as an integer
         If Round(A_WHB04B_Position_Tmp*10000)<0 Then A_DecW := A_DecW Or $8000;  //Set sign bit if negative
         A_WHB04B_Position_Tmp_Save:=A_WHB04B_Position_Tmp;
      End;

   If Position_Changed Then
      Begin
         WHB04_Packet1[0]    := $06;                        //Packet Always starts with $06
         WHB04_Packet1[1]    := $FE;                        //The beginning of the first packet is always $FEFD
         WHB04_Packet1[2]    := $FD;
         WHB04_Packet1[3]    := $FF;                        // Seed used for checksum
         WHB04_Packet1[4]    := LCD_Mode;                   // $0 "CONT xx%", $1 "STEP: xx", $2 "MPG xx%", $3 "xxx%", $40 RESET , $80 Work Coordinates
         WHB04_Packet1[5]    := X_IntW AND $00FF;           //Low  Byte of Interger part of X number
         WHB04_Packet1[6]    := (X_IntW AND $FF00) SHR 8;   //High Byte of Interger part of X number
         WHB04_Packet1[7]    := X_DecW AND $00FF;           //Low  Byte of Decimal part of X number
         WHB04_Packet2[0]    := $06;
         WHB04_Packet2[1]    := (X_DecW AND $FF00) SHR 8;   //High Byte of Decimal part of X number
         WHB04_Packet2[2]    := Y_IntW AND $00FF;           //Low  Byte of Interger part of Y number
         WHB04_Packet2[3]    := (Y_IntW AND $FF00) SHR 8;   //High Byte of Interger part of Y number
         WHB04_Packet2[4]    := Y_DecW AND $00FF;           //Low  Byte of Decimal part of Y number
         WHB04_Packet2[5]    := (Y_DecW AND $FF00) SHR 8;   //High Byte of Decimal part of Y number
         WHB04_Packet2[6]    := Z_IntW AND $00FF;           //Low  Byte of Interger part of Z number
         WHB04_Packet2[7]    := (Z_IntW AND $FF00) SHR 8;   //High Byte of Interger part of Z number
         WHB04_Packet3[0]    := $06;
         WHB04_Packet3[1]    := Z_DecW AND $00FF;           //Low  Byte of Decimal part of Z number
         WHB04_Packet3[2]    := (Z_DecW AND $FF00) SHR 8;   //High Byte of Decimal part of Z number
         WHB04_Packet3[3]    := FeedW AND $00FF;            //Low  Byte of Decimal part of FeedRate
         WHB04_Packet3[4]    := (FeedW AND $FF00) SHR 8;    //High Byte of Decimal part of FeedRate
         WHB04_Packet3[5]    := SpindleW AND $00FF;         //Low  Byte of Decimal part of Spindle Speed
         WHB04_Packet3[6]    := (SpindleW AND $FF00) SHR 8; //High Byte of Decimal part of Spindle Speed
         WHB04_Packet3[7]    := $0;

         libusbhid_set_report(device_context, HID_REPORT_TYPE_FEATURE, $6 , 8 , WhB04_Packet1 );
         libusbhid_set_report(device_context, HID_REPORT_TYPE_FEATURE, $6 , 8 , WhB04_Packet2 );
         libusbhid_set_report(device_context, HID_REPORT_TYPE_FEATURE, $6 , 8 , WhB04_Packet3 );
      End;
   Process_USB_Data:=Position_Changed;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Procedure Start_Read_Thread;
Begin
   X_WHB04B_Position_Tmp_Save:= -999;
   Y_WHB04B_Position_Tmp_Save:= -999;
   Z_WHB04B_Position_Tmp_Save:= -999;
   A_WHB04B_Position_Tmp_Save:= -999;
   Interrupt_Read_Thread_Result:=0;
   Thread_Running:=True;
   Wireless_Device_PowerOff:=False;
   readThread:=TInterruptReadThread.Create(false);
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Procedure Check_for_Device;
Begin
   If Not(Thread_Running) And Not(Device_is_Open) Then
      Begin
         If WHB04B_Present Then
            Begin
               If libusbhid_open_device($10CE, $EB93  {WHB04B-4 CNC Handwheel},{instance=}1,device_context,False) then
                  begin
                     WriteLn('Device open');
                     Device_Is_Open:=True;
                  End
               else
                  WriteLn('unable to open device');
            End;
      End;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function Check_Wireless_Power:Boolean;
Var
   Interrupt_Read_Code:Integer;
Begin
   Result:=False;
   If Not(Thread_Running) and Device_is_Open Then
      Begin
         Interrupt_Read_Code:=libusbhid_interrupt_read(device_context,$81{endpoint},{out}hidReportData[reportIdx].hid_data,64{report length, varies by device},hidReportData[reportIdx].dataLen, {timeout=}50);
         Writeln(Interrupt_Read_Code,'  ',hidReportData[reportIdx].dataLen,'  ',hidReportData[reportIdx].hid_data[5],Axis_Power_Off,'  ',hidReportData[reportIdx].hid_data[4],Wheel_Power_Off);
         If (Interrupt_Read_Code>=0) and ({Axis_Sel}hidReportData[reportIdx].hid_data[5]  <> Axis_Power_Off) AND ({Wheel Mode}hidReportData[reportIdx].hid_data[4] <> Wheel_Power_Off)   then
            Begin
               Start_Read_Thread;
               Result:=True
            End
         Else
            Begin
               If (Interrupt_Read_Code<>-7) Then  //Trasnsiever Unplugged for Wireless version
                  Begin
                     libusbhid_close_device(device_context);
                     Device_Is_Open:=False;
                  End
            End;
      End;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Procedure Check_And_End_Thread;
Begin
   If Thread_Running Then
      Begin
         ReadThreadResult:=Interrupt_Read_Thread_Result;
         If (ReadThreadResult <0) And (ReadThreadResult < -7)  Then
            Begin
               Thread_Running:=False;
               readThread.Terminate;
               readThread.Free();
               If Not(Wireless_Device_PowerOff) Then
                  Begin
                     libusbhid_close_device(device_context);
                     Device_Is_Open:=False;
                  End;
            End;
      End;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function WHB04B_Present:Boolean;
Begin
   WHB04B_Present:=libusbhid_detect_device($10CE, $EB93  {WHB04B-4 CNC Handwheel},{instance=}1);
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}

Initialization
Begin
   Wireless_Device_PowerOff:=False;
   FeedW:=0;
   SpindleW:=0;
   X_WHB04B_Position:=0;
   Y_WHB04B_Position:=0;
   Z_WHB04B_Position:=0;
   A_WHB04B_Position:=0;
   Thread_Running:=False;
   InitCriticalsection(criticalSection);
End;

Finalization
Begin
   If Thread_Running Then
      readThread.Terminate;
   readThread.Free();
   If Device_Is_Open Then
      libusbhid_close_device(device_context);
   DoneCriticalsection(criticalSection);
End;

End.
