program libusbhid_test;
{
S. V. Pantazi (svpantazi@gmail.com), 2013

updated
   08/13/2019
  08/16/2019
}

{$mode objfpc}{$H+}

uses
  heaptrc,{to hunt for memory leaks}

  {$IFDEF UNIX}
  {$DEFINE UseCThreads}
  {$IFDEF UseCThreads}

  cthreads,
  {$ENDIF}{$ENDIF}

  keyboard,

  sysutils,

  libusbhid,

  hid_testing_utils;
Const
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

  Axis_Sel_Off             = $06 ;
  Axis_Sel_X               = $11 ;
  Axis_Sel_Y               = $12 ;
  Axis_Sel_Z               = $13 ;
  Axis_Sel_A               = $14 ;

  Wheel_Mode_2             = $0D ;
  Wheel_Mode_5             = $0E ;
  Wheel_Mode_10            = $0F ;
  Wheel_Mode_30            = $10 ;
  Wheel_Mode_60            = $1A ;
  Wheel_Mode_100           = $1B ;
  Wheel_Mode_Lead          = $1C ;
  Wheel_Mode_Lead_Wireless = $9B ;


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

Var
  WHB04_Packet1,
  WHB04_Packet2,
  WHB04_Packet3:Array [0..7] of byte;

  Writing_LCD_Data,
  LCD_Data_Ready,
  LCD_Ready1,
  LCD_Ready2,
  LCD_Ready3:Boolean;

  LCD_Mode,
  Button_Raw,
  Button_1,
  Button_2,
  Axis_Sel,
  Wheel_Mode,
  Wireless_Random,
  Wireless_Checksum,
  xor_day : Byte;

  Wheel_Relative_Movement,Wheel_Absolute_Positon : Integer;

  X_Pos,Y_Pos,Z_Pos,A_Pos:Real;

  X_IntW,Y_IntW,Z_IntW,A_IntW,
  X_DecW,Y_DecW,Z_DEcW,A_DEcW,
  SpindleW,FeedW                :Word;

  HB04_Packet:Boolean;
  LoopCount,Thread_Id,TimeoutCount:Dword;
  i:Longint;

Function TwosCompliment(InData,numberofbits:Byte):Integer;
   Var
      OutData:Integer;
   Begin
       OutData:=InData;
       if (OutData And (1 SHL (numberofbits - 1))) <> 0 Then  // if sign bit is set e.g., 8bit: 128-255
          OutData := OutData - (1 SHL numberofbits);          // compute negative value
       TwosCompliment:=OutData;                               //return positive value as is
       //Writeln('twos - in: '+Inttohex(InData,2)+'  Out: '+Inttohex(OutData,2));
   End;

Function ReadUSBPort(p : pointer) : ptrint;
Var
   Saved_Data : Array [0..7] of Byte;
Begin
   Loopcount:=0;
   TimeoutCount:=0;
   Axis_Sel := $0F;
   Wheel_Mode := $F0;
   Repeat
      hidReportData[reportIdx].dataLen:=libusbhid_interrupt_read(device_context,$81{endpoint},{out}hidReportData[reportIdx].hid_data,64{report length, varies by device}, {timeout=}50);
      if hidReportData[reportIdx].datalen <= 0 then
         Begin
            Loopcount:=0;
            Inc(TimeoutCount);
         End
      Else
         Begin
            Timeoutcount:=0;
            Inc(Loopcount);
            //If PrintAndCompareReport(reportIdx,0) Then   //- Show all data of all reports
            //If PrintAndCompareReport(reportIdx,1) Then   //- Show Only Changed data of all reports
            //If PrintAndCompareReport(reportIdx,2) Then   //- Show all data only when report changed
            //If PrintAndCompareReport(reportIdx,3) Then   //- Show Only Changed data only when report changed
            Begin
               If hidReportData[reportIdx].hid_data[0]<>$4 then  //Always $04 for an HB04 device
                  Begin
                     Write('HB04 Packet Not Detected: ');
                     PrintAndCompareReport(reportIdx,0);
                     HB04_Packet:=False;
                     readln;
                  end
               Else
                  Begin
                     HB04_Packet:=True;
                     // Writeln('HB04 Packet Detected');
                     If hidReportData[reportIdx].hid_data[6]<>0 Then
                        Begin
                           Wheel_Relative_Movement := Twoscompliment(hidReportData[reportIdx].hid_data[6],8);  // Number of wheel ticks since last read
                           Wheel_Absolute_Positon+=Wheel_Relative_Movement;
                           If Wheel_Relative_Movement<>0 Then
                              Begin
                                 If Axis_Sel = Axis_Sel_X Then
                                    X_Pos += Wheel_Relative_Movement*Wheel_Distance_Multiplier[Wheel_Mode];
                                 If Axis_Sel = Axis_Sel_Y Then
                                    Y_Pos += Wheel_Relative_Movement*Wheel_Distance_Multiplier[Wheel_Mode];
                                 If Axis_Sel = Axis_Sel_Z Then
                                    Z_Pos += Wheel_Relative_Movement*Wheel_Distance_Multiplier[Wheel_Mode];
                                 If Axis_Sel = Axis_Sel_A Then
                                    A_Pos += Wheel_Relative_Movement*Wheel_Distance_Multiplier[Wheel_Mode];
                              End;
                        End
                     Else
                        Begin
                        //                        hidReportData[reportIdx].hid_data[0];    // Report ID
                        // Wireless_Random     := hidReportData[reportIdx].hid_data[1];    // Always $00 on Wired version--- Wireless generates a random number used for the Checksum
                           If hidReportData[reportIdx].hid_data[2] <> Saved_Data[2] Then   // Buttons without Fn held down
                              Begin
                                 If hidReportData[reportIdx].hid_data[2] <> 0 Then
                                    Button_1   := hidReportData[reportIdx].hid_data[2];
                                 Saved_Data[2] := hidReportData[reportIdx].hid_data[2];
                              End;
                           If hidReportData[reportIdx].hid_data[3] <> Saved_Data[3] Then   // Buttons with Fn held down (byte 2 will be Fn still)
                              Begin
                                 If hidReportData[reportIdx].hid_data[3] <> 0 Then
                                    Button_2   := hidReportData[reportIdx].hid_data[3];
                                 Saved_Data[3] := hidReportData[reportIdx].hid_data[3];
                              End;
                           If hidReportData[reportIdx].hid_data[4] <> Saved_Data[4] Then   // Wheel multiplier or Feedrate override
                              Begin
                                 Wheel_Mode    := hidReportData[reportIdx].hid_data[4];
                                 Saved_Data[4] := hidReportData[reportIdx].hid_data[4];
                              End;
                           If hidReportData[reportIdx].hid_data[5] <> Saved_Data[5] Then   // Axis Selection for Wheel or turn wheel off
                              Begin
                                 Axis_Sel      := hidReportData[reportIdx].hid_data[5];
                                 Saved_Data[5] := hidReportData[reportIdx].hid_data[5];
                              End;
                        // Button_Raw          := hidReportData[reportIdx].hid_data[7];    //Only Wired version
                        // Wireless_Checksum   := hidReportData[reportIdx].hid_data[7];    //Only Wireless version
                        End;
                  End;
            End;
         End;
         If Timeoutcount>10 then
            Timeoutcount:=0;
         If LCD_Data_Ready Then
            Begin
               Writing_LCD_Data:=True;
               If (TimeoutCount=4) {OR LCD_Ready1} Then
                  Begin
                     LCD_Ready1:=False;
                     libusbhid_set_report(device_context, HID_REPORT_TYPE_FEATURE, $6 , 8 , WhB04_Packet1 );
                  End;
               If (TimeoutCount=6) {Or LCD_Ready2} Then
                  Begin
                     LCD_Ready2:=False;
                     libusbhid_set_report(device_context, HID_REPORT_TYPE_FEATURE, $6 , 8 , WhB04_Packet2 );
                  End;
               If (TimeoutCount=8) {OR LCD_Ready3} Then
                  Begin
                     Timeoutcount:=0;
                     LCD_Ready3:=False;
                     libusbhid_set_report(device_context, HID_REPORT_TYPE_FEATURE, $6 , 8 , WhB04_Packet3 );
                     LCD_Data_Ready:=False;
                     Writing_LCD_Data:=False;
                  End;
            End;
   Until Axis_Sel = Wheel_Mode; //Power Off
   Writeln('Power Off');
End;

begin
   keyboard.InitKeyboard();
   LCD_Data_Ready:=False;
   Writing_LCD_Data:=False;
   If libusbhid_open_device($10CE, $EB93  {WHB04B-4 CNC Handwheel},{instance=}1,device_context) then
      begin
         X_Pos:=0;
         Y_Pos:=0;
         Z_Pos:=0;
         A_Pos:=0;
         i:=0;
         Wheel_Absolute_Positon:=0;
         Wheel_Relative_Movement:=0;
         reportIdx:=0; //devices often use one endpoint (commonly $81) to output data reports
         thread_id:=BeginThread(@ReadUSBPort,pointer(i));
         repeat
            If Not(Writing_LCD_Data) then
               Begin
                  X_IntW:=Trunc(Abs(X_Pos));
                  If X_Pos<0 Then
                     X_IntW := X_IntW Or $80;
                  X_DecW :=Trunc((X_Pos-X_IntW)*10000);
                  Y_IntW :=Trunc(Abs(Y_Pos));
                  If Y_Pos<0 Then
                     Y_IntW := Y_IntW Or $80;
                  Y_DecW :=Trunc((Y_Pos-Y_IntW)*10000);
                  Z_IntW :=Trunc(Abs(Z_Pos));
                  If X_Pos<0 Then
                     Z_IntW := Z_IntW Or $80;
                  Z_DecW :=Trunc((Z_Pos-Z_IntW)*10000);
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
                  WHB04_Packet3[3]    := FeedW AND $00FF;            //Low  Byte of Decimal part of FeedRate (not working yet, don't know how to turn on Feedrate display)
                  WHB04_Packet3[4]    := (FeedW AND $FF00) SHR 8;    //High Byte of Decimal part of FeedRate (not working yet, don't know how to turn on Feedrate display)
                  WHB04_Packet3[5]    := SpindleW AND $00FF;         //Low  Byte of Decimal part of Spindle Speed (not working yet, don't know how to turn on Spindle Speed display)
                  WHB04_Packet3[6]    := (SpindleW AND $FF00) SHR 8; //High Byte of Decimal part of Spindle Speed (not working yet, don't know how to turn on Spindle Speed display)
                  WHB04_Packet3[7]    := $0;
                  Sleep(250);
                  LCD_Data_Ready:=True;
               End;
            //Sleep(300);
            //   libusbhid_set_report(device_context, HID_REPORT_TYPE_FEATURE, $6 , 8 , WhB04_Packet1 );
            //Sleep(300);
            //   libusbhid_set_report(device_context, HID_REPORT_TYPE_FEATURE, $6 , 8 , WhB04_Packet2 );
            //Sleep(300);
            //   libusbhid_set_report(device_context, HID_REPORT_TYPE_FEATURE, $6 , 8 , WhB04_Packet3 );
         until KeyPressed;
         libusbhid_close_device(device_context);
      end
   else
      WriteLn('unable to open device');
   keyboard.DoneKeyboard();
end.
