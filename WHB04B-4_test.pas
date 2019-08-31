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

  Classes,

  sysutils,

  libusbhid,

  hid_testing_utils,

  WHB04B;

Var
   SerPortBaud                              : LongInt;
   SerPort                                  : String;
   SerialHandle                             : TSerialHandle;


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
Function OutString(OS:Real):String;
Var
   Stringtemp      : String;
   Strngposition   : Integer;
Begin
   STR(OS:0:4,Stringtemp);
   For Strngposition := Length(Stringtemp) DownTo 1 Do
      Begin
         If Stringtemp[Strngposition]='0' Then
            Stringtemp:=copy(Stringtemp,1,Strngposition-1)
         Else
            break;
      End;
   If Stringtemp[Strngposition]='.' Then
      Stringtemp:=copy(Stringtemp,1,Strngposition-1);
   OutString:= Stringtemp;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Procedure SimpleTerminal;
const
  NullLetter = #0;
var
  Inputchar, OutputLetter: Char;
  InputString            : String;
  newlinestarted         : Boolean;
  OutputString           : String;
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
      Check_for_Device;
      Check_Wireless_Power;
      Check_And_End_Thread;
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
         If Thread_Running and Process_USB_Data then
            Begin
               OutputString:='G0';
               If Pos_X_Changed Then OutputString+=' X'+OutString(X_WHB04B_Position_Tmp);
               If Pos_Y_Changed Then OutputString+=' Y'+OutString(Y_WHB04B_Position_Tmp);
               If Pos_Z_Changed Then OutputString+=' Z'+OutString(Z_WHB04B_Position_Tmp);
               Writeln(OutputString);
               SendSerial(Outputstring);
               Pos_X_Changed:=False;
               Pos_Y_Changed:=False;
               Pos_Z_Changed:=False;
            End;
   Until (inputchar=#24) OR (inputchar=#27);
   Textcolor(12);
   Writeln('Terminal Exit');
End;

begin
   
 LIBUSB_DEBUG_LEVEL=3;//
   SerPort:='COM5';
   SerPortbaud:=250000;
   If OpenSerialPort>0 Then
   Begin
      Writeln(SerPort,' Open @ ',SerPortbaud,'bps');
   End;
   SimpleTerminal;  //Process_USB_Data in this procedure
   CloseSerialPort;

end.
