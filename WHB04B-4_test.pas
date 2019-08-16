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


   // button look up table
    Button_Raw_LookUp : Array [$00..$FF] of String = (
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
       {06} 'Axis_Sel_Off ',
            '','','','','','','','','','',
       {11} 'Axis_Sel_X   ',
       {12} 'Axis_Sel_Y   ',
       {13} 'Axis_Sel_Z   ',
       {14} 'Axis_Sel_A   ');
    Wheel_Mode_Lookup : Array [$0D..$1C] of String = (
       {0D} 'Wheel_Mode_2   ',
       {0E} 'Wheel_Mode_5   ',
       {0F} 'Wheel_Mode_10  ',
       {10} 'Wheel_Mode_30  ',
       '','','','','','','','','',
       {1A} 'Wheel_Mode_60  ',
       {1B} 'Wheel_Mode_100 ',
       {1C} 'Wheel_Mode_Lead');

   lcd_data : Array [0..41] of Byte = (
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
  Wheel:Integer;
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
      Show_LibUSB_Messages:=False;
      reportIdx:=0; //devices often use one endpoint (commonly $81) to output data reports
      {read report until keypressed, then closes the device}
      repeat
        {interrupt reading   - for joystick or wiimote, or touchscreens, etc.
        NOTE: program execution is blocked until data is read from device!}
        hidReportData[reportIdx].dataLen:=libusbhid_interrupt_read(device_context,$81{endpoint},{out}hidReportData[reportIdx].hid_data,128{report length, varies by device}, {timeout=}1000);
        If hidReportData[reportIdx].dataLen > 0 Then
            Begin
               If
               //PrintAndCompareReport(reportIdx,0)   //- Show all data of all reports
               //PrintAndCompareReport(reportIdx,1)   //- Show Only Changed data of all reports
               PrintAndCompareReport(reportIdx,2)   //- Show all data only when report changed
               //PrintAndCompareReport(reportIdx,3)   //- Show Only Changed data only when report changed
                                                       Then
               Begin
                  If hidReportData[reportIdx].hid_data[0]<>$4 then
                     Begin
                        Writeln('HB04 Packet Not Detected');
                        HB04_Packet:=False;
                     end
                  Else
                     Begin
                        HB04_Packet:=True;
//                        Writeln('HB04 Packet Detected');
                     End;
                  Button_1   := hidReportData[reportIdx].hid_data[2];
                  Button_2   := hidReportData[reportIdx].hid_data[3];
                  Wheel_Mode := hidReportData[reportIdx].hid_data[4];
                  Axis_Sel   := hidReportData[reportIdx].hid_data[5];
                  Wheel      := Twoscompliment(hidReportData[reportIdx].hid_data[6],8);
                  Button_Raw := hidReportData[reportIdx].hid_data[7];
                  //Writeln('HB04 = ',HB04_Packet,'  Button_1 = $'+Inttohex(Button_1,2)+'  Button_2 = $'+Inttohex(Button_2,2)+'  Axis_Sel = $'+Inttohex(Axis_Sel,2)+'  Axis_Sel = $'+Inttohex(Axis_Sel,2)+
                  //                     '  Wheel_Mode = $'+Inttohex(Wheel_Mode,2)+'  Wheel = $'+Inttohex(Wheel,2)+'  xor_day = $'+Inttohex(xor_day,2) );
                  Writeln(Button_LookUp[Button_1],'    ',Fn_LookUp[Button_2],'    ',Button_Raw_LookUp[Button_Raw],'    ',Axis_Sel_LookUp[Axis_Sel],'    ',Wheel_Mode_LookUp[Wheel_Mode]);
               End;
            End;
      until KeyPressed;
      libusbhid_close_device(device_context);
    end
  else WriteLn('unable to open device');
  keyboard.DoneKeyboard();

end.
