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
       
    Axis_Sel_Lookup : Array [$06..$14] of String = (
       {06} 'Axis_Sel_Off',
            '','','','','','','','','','',
       {11} 'Axis_Sel_X',
       {12} 'Axis_Sel_Y',
       {13} 'Axis_Sel_Z',
       {14} 'Axis_Sel_A');
       
    Wheel_Mode_Lookup : Array [$0D..$9B] of String = (
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

   lcd_data : Array [0..41] of Byte = (  //This is for HB04 not for WHB04B-4
        $FE, $FD, 1,
        1, 2, 3, 4,  // X WC
        0, 0, 0, 0,  // Y WC
        0, 0, 0, 0,  // Z WC
        0, 0, 0, 0,  // X MC
        0, 0, 0, 0,  // Y MC
        0, 0, 0, 0,  // Z MC
        0, 0,        // F ovr
        0, 0,        // S ovr
        0, 0,        // F
        0, 0,        // S
        $01,         // step mul
        0,           // inch/mm
        0, 0, 0, 0, 0   // padding
    );
Var
  Button_Raw,Button_1,Button_2,Axis_Sel,Wheel_Mode,xor_day:Byte;
  Wheel_Relative_Movement,Wheel_Absolute_Positon:Integer;
  X_Pos,Y_Pos,Z_Pos,A_Pos:Real;
  HB04_Packet:Boolean;

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

begin
  keyboard.InitKeyboard();

  if libusbhid_open_device(
        // $046D, $C216 {xbox gamepad }
        // $0000, $0001 {barcode scanner}
        // $24C0, $0003 {weather station}
        // $1784, $0001 {}
        // $056a, $00de {Wacom Bamboo}
        // $04e7, $0050  {elo touch screen}
        // $051d, $0002 {APC UPS}
        $10CE, $EB93  {WHB04B-4 CNC Handwheel}
         ,{instance=}1,device_context) then
    begin
      X_Pos:=0;
      Y_Pos:=0;
      Z_Pos:=0;
      A_Pos:=0;
      Wheel_Absolute_Positon:=0;
      Wheel_Relative_Movement:=0;
      Show_LibUSB_Messages:=False;
      reportIdx:=0; //devices often use one endpoint (commonly $81) to output data reports
      {read report until keypressed, then closes the device}
      repeat
        {interrupt reading   - for joystick or wiimote, or touchscreens, etc.
        NOTE: program execution is blocked until data is read from device!}
        hidReportData[reportIdx].dataLen:=libusbhid_interrupt_read(device_context,$81{endpoint},{out}hidReportData[reportIdx].hid_data,128{report length, varies by device}, {timeout=}3000);
        If hidReportData[reportIdx].dataLen > 0 Then
            Begin
               If
               //PrintAndCompareReport(reportIdx,0)   //- Show all data of all reports
               //PrintAndCompareReport(reportIdx,1)   //- Show Only Changed data of all reports
               PrintAndCompareReport(reportIdx,2)   //- Show all data only when report changed
               //PrintAndCompareReport(reportIdx,3)   //- Show Only Changed data only when report changed
                                                       Then
               Begin
                  If hidReportData[reportIdx].hid_data[0]<>$4 then  //Always $04 for an HB04 device
                     Begin
                        Writeln('HB04 Packet Not Detected');
                        HB04_Packet:=False;
                     end
                  Else
                     Begin
                        HB04_Packet:=True;
//                        Writeln('HB04 Packet Detected');
                     End;
                  //            hidReportData[reportIdx].hid_data[1];   // Always $00 on Wired version--- Wireless is doing something but I don't know what
                  Button_1   := hidReportData[reportIdx].hid_data[2];   // Buttons without Fn held down
                  Button_2   := hidReportData[reportIdx].hid_data[3];   // Buttons with Fn held down (byte 2 will be Fn still)
                  Wheel_Mode := hidReportData[reportIdx].hid_data[4];   // Wheel multiplier or Feedrate override
                  Axis_Sel   := hidReportData[reportIdx].hid_data[5];   // Axis Selection for Wheel or turn wheel off
                  Wheel_Relative_Movement := Twoscompliment(hidReportData[reportIdx].hid_data[6],8);  // Number of wheel ticks since last read
                  Wheel_Absolute_Positon+=Wheel_Relative_Movement;
                  // Button_Raw := hidReportData[reportIdx].hid_data[7];   //Only Wired version is this--- Wireless is something different
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
                  //Writeln('HB04 = ',HB04_Packet,'  Button_1 = $'+Inttohex(Button_1,2)+'  Button_2 = $'+Inttohex(Button_2,2)+'  Axis_Sel = $'+Inttohex(Axis_Sel,2)+'  Axis_Sel = $'+Inttohex(Axis_Sel,2)+
                  //                     '  Wheel_Mode = $'+Inttohex(Wheel_Mode,2)+'  Wheel = $'+Inttohex(Wheel,2)+'  xor_day = $'+Inttohex(xor_day,2) );
                  Writeln(Button_LookUp[Button_1],'    ',Fn_LookUp[Button_2],'    ',Button_Raw_LookUp[Button_Raw],'    ',Axis_Sel_LookUp[Axis_Sel],'    ',Wheel_Mode_LookUp[Wheel_Mode]
                  //        ,'    ',Wheel_Relative_Movement,'    ',Wheel_Absolute_Positon
                          ,'    X',X_Pos:0:5,'    Y',Y_Pos:0:5,'    Z',Z_Pos:0:5,'    A',A_Pos:0:5
                          );
               End;
            End;
      until KeyPressed;
      libusbhid_close_device(device_context);
    end
  else WriteLn('unable to open device');
  keyboard.DoneKeyboard();

end.
