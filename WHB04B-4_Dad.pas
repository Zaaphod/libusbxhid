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
       Outputstring:String;
       
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
begin
   LIBUSB_DEBUG_LEVEL:=3;
   repeat
      Check_for_Device;
      Check_Wireless_Power;
      Check_And_End_Thread;
        If Thread_Running and Process_USB_Data then
            Begin
               OutputString:='G0';
               If Pos_X_Changed Then OutputString+=' X'+OutString(X_WHB04B_Position_Tmp);
               If Pos_Y_Changed Then OutputString+=' Y'+OutString(Y_WHB04B_Position_Tmp);
               If Pos_Z_Changed Then OutputString+=' Z'+OutString(Z_WHB04B_Position_Tmp);
               Writeln(OutputString);
               //SendSerial(Outputstring);
               Pos_X_Changed:=False;
               Pos_Y_Changed:=False;
               Pos_Z_Changed:=False;
            End;
      Sleep(100);
   until keypressed
end.
