program libusbhid_test;
{
S. V. Pantazi (svpantazi@gmail.com), 2013

updated
   08/13/2019
  08/16/2019
}

{$mode objfpc}{$H+}

uses
//  heaptrc,{to hunt for memory leaks}

  {$IFDEF UNIX}
  {$DEFINE UseCThreads}
  {$IFDEF UseCThreads}

  cthreads,
  {$ENDIF}{$ENDIF}

  serial,

  CRT,

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
  X_Pos_Tmp,Y_Pos_Tmp,Z_Pos_Tmp,A_Pos_Tmp:Real;
  X_Pos_Abs,Y_Pos_Abs,Z_Pos_Abs,A_Pos_Abs:Real;

  X_IntW,Y_IntW,Z_IntW,A_IntW,
  X_DecW,Y_DecW,Z_DEcW,A_DEcW,
  SpindleW,FeedW                :Word;

  HB04_Packet:Boolean;
  LoopCount,Thread_Id,TimeoutCount:Dword;
  i:Longint;

   SerPortBaud                              : LongInt;
   SerPort                                  : String;
   SerialHandle                             : TSerialHandle;
   ByteTime                                 : Double;

{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function OpenSerialPort:TSerialHandle;
Var
   Flags        : TSerialFlags; { TSerialFlags = set Of (RtsCtsFlowControl); }
Begin
   SerialHandle := SerOpen(SerPort);
   If SerialHandle>0 Then
      Begin
         Flags:= [ ]; // None
         SerSetParams(SerialHandle,SerPortBaud,8,NoneParity,1,Flags);
         SerSetDTR(SerialHandle,True); {Set DTR To a low}
         {each Byte takes 10 bits,  Start, 8 Bits, 1 sTop}
         ByteTime:=10/SerPortBaud;
         {WriteLn(BytETIMe[SerPortNum]*1000000:1:3,'bps');}
      End;
   OpenSerialPort:=SerialHandle;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Procedure CloseSerialPort;
Begin
   If SerialHandle>0 Then
      Begin
         SerSync(SerialHandle); { flush out any remaining beFore closure }
         SerFlushOutput(SerialHandle); { discard any remaining output }
         SerClose(SerialHandle);
      End;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function smserread:char;
var
 inchar:char;
Begin
   inchar:=#0;
   SerRead(SerialHandle, Inchar, 1);
   smserread:=inchar;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function SendSerial(SerialString:String):LongInt;
Var
   resendattempt,reopenattempt:Byte;
   reopen:Tserialhandle;
   Status:Longint;
Begin
   Status:=0;
   If (SerialString<>'') Then
      Begin
         If (SerialString<>'?') AND
            (SerialString<>'!') AND
            (SerialString<>'~') AND
            (SerialString<>#24 {Ctrl_X}) Then
               SerialString:=SerialString+#10; {Linefeed}
         If (Length(serialstring)>0) then
            Begin
               Repeat
                  Resendattempt:=0;
                  Repeat
                     Begin
                        Status := SerWrite(SerialHandle,SerialString[1],Length(SerialString));
                        If Status <> Length(SerialString) Then
                           Begin
                              Sleep (10);
                              Inc(Resendattempt);
                           End;
                     End;
                  Until (Resendattempt>=25) or (Status = Length(SerialString));
                  If Status <> Length(serialstring) Then
                     Begin
                     End;
               until Status = Length(serialstring);
            end;
         {writeln ('status ',status);}
         SendSerial:=Status;
         End;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Procedure SimpleTerminal;
const
  NullLetter = #0;
var
  Inputchar, OutputLetter: Char;
  InputString            : String;
  newlinestarted         : Boolean;
Begin
   NewLineStarted:=False;
   Textcolor(10);
   Write('Termnal Port: '+SerPort+'     ');
   Textcolor(14);
   Write('X');
   Textcolor(10);
   Write(' to ');
   Textcolor(11);
   Write('e');
   Textcolor(14);
   Write('X');
   Textcolor(11);
   Writeln('it');
   repeat
      OutputLetter := NullLetter;
      Outputletter:=smSerRead;
      If Outputletter<>#0 then
         Begin
          If (Outputletter=#10) Or (Outputletter=#13) then
             Begin
               If Not(Newlinestarted) then
                 Writeln;
               newlinestarted:=True;
             End
          Else
             Begin
              newlinestarted:=false;
              Textcolor(11);
              Write(Outputletter);
              //Textcolor(13);
              //Write('#',Ord(Outputletter));
             End;
         End;
      if Keypressed then
         begin
            inputstring:='';
            repeat
               if Keypressed then
                  begin
                      inputchar:=readkey;
                      If inputchar=#8 then
                        Begin
                           If Length(inputstring)>1 then
                              Inputstring:=copy(inputstring,1,length(inputstring)-1)
                           else
                              inputstring:='';
                           Write(#13+inputstring+#32#13+Inputstring);
                        End
                  else
                        Begin
                           If (inputchar<>#24) and (inputchar<>#27) and (inputstring<>#13) and (inputstring<>#63) then
                              Begin
                                 inputstring:=inputstring+inputchar;
                                 Textcolor(13);
                                 Write(inputchar);
                              End;
                        End;
                  End;
            until (inputchar=#24) OR (inputchar=#27) OR (inputchar=#13) OR (inputchar=#63);
            {Readln(Inputstring);  }
            If inputchar=#13 Then
               Begin
                  Writeln;
                  SendSerial(Inputstring);
               End;
            If inputchar=#63 Then
               Begin
                  Writeln;
                  SendSerial('?');
               End;
         end;
   Until (inputchar=#24) OR (inputchar=#27);
   Textcolor(12);
   Writeln('Terminal Exit');
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
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

Begin
   Loopcount:=0;
   TimeoutCount:=0;
   Axis_Sel := $0F;
   Wheel_Mode := $F0;
   Repeat
      hidReportData[reportIdx].dataLen:=libusbhid_interrupt_read(device_context,$81{endpoint},{out}hidReportData[reportIdx].hid_data,64{report length, varies by device}, {timeout=}0);
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
                           Wheel_Relative_Movement := ReadThreadTwoscompliment(hidReportData[reportIdx].hid_data[6],8);  // Number of wheel ticks since last read
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
   Until Axis_Sel = Wheel_Mode; //Power Off
   Writeln('Power Off');
End;

Procedure Use_MPG_Device;
Begin
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
            X_Pos_Tmp:=X_Pos;  //Copy data so it can't change in the middle of processing
            Y_Pos_Tmp:=Y_Pos;  //Copy data so it can't change in the middle of processing
            Z_Pos_Tmp:=Z_Pos;  //Copy data so it can't change in the middle of processing
            A_Pos_Tmp:=A_Pos;  //Copy data so it can't change in the middle of processing

            X_Pos_Abs:=Abs(Round(X_Pos_Tmp*10000)/10000);  //Get absolute value with floating point weirdness cut off
            Y_Pos_Abs:=Abs(Round(Y_Pos_Tmp*10000)/10000);  //Get absolute value with floating point weirdness cut off
            Z_Pos_Abs:=Abs(Round(Z_Pos_Tmp*10000)/10000);  //Get absolute value with floating point weirdness cut off
            A_Pos_Abs:=Abs(Round(A_Pos_Tmp*10000)/10000);  //Get absolute value with floating point weirdness cut off

            X_IntW:=Trunc(X_Pos_Abs);  //Get integer part
            Y_IntW:=Trunc(Y_Pos_Abs);  //Get integer part
            Z_IntW:=Trunc(Z_Pos_Abs);  //Get integer part
            A_IntW:=Trunc(A_Pos_Abs);  //Get integer part

            X_DecW :=Round((X_Pos_Abs-X_IntW)*10000);  //Get 4 decimal digits as an integer
            Y_DecW :=Round((Y_Pos_Abs-Y_IntW)*10000);  //Get 4 decimal digits as an integer
            Z_DecW :=Round((Z_Pos_Abs-Z_IntW)*10000);  //Get 4 decimal digits as an integer
            A_DecW :=Round((A_Pos_Abs-A_IntW)*10000);  //Get 4 decimal digits as an integer

            If Round(X_Pos_Tmp*10000)<0 Then X_DecW := X_DecW Or $8000;  //Set sign bit if negative
            If Round(Y_Pos_Tmp*10000)<0 Then Y_DecW := Y_DecW Or $8000;  //Set sign bit if negative
            If Round(Z_Pos_Tmp*10000)<0 Then Z_DecW := Z_DecW Or $8000;  //Set sign bit if negative
            If Round(A_Pos_Tmp*10000)<0 Then A_DecW := A_DecW Or $8000;  //Set sign bit if negative

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

            Sleep(1000);
         until KeyPressed;
         libusbhid_close_device(device_context);
      end
   else
      WriteLn('unable to open device');
End;

begin
   LCD_Data_Ready:=False;
   Writing_LCD_Data:=False;
   FeedW:=800;
   SpindleW:=24000;
   SerPort:='COM5';
   SerPortbaud:=250000;
   If OpenSerialPort>0 Then
   Begin
      Writeln(SerPort,' Open @ ',SerPortbaud,'bps');
      SimpleTerminal;
   End;

   Writeln('Looking for WHB04B-4');
   Repeat
      Sleep(500);
      Write('.');
      If libusbhid_detect_device($10CE, $EB93  {WHB04B-4 CNC Handwheel},{instance=}1) then
         Begin
            Writeln;
            Writeln('Found @ $10CE, $EB93');
            Use_MPG_Device;
         End;
   Until Keypressed;

   CloseSerialPort;
end.
