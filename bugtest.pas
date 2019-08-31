program libusbhid_test;
{$mode objfpc}{$H+}
uses
  heaptrc,{to hunt for memory leaks}

  sysutils,

  libusbhid;
Var
  i : Integer;
begin
  For I:= 0 to 3 Do
     Begin
        LIBUSB_DEBUG_LEVEL:=I;
        Writeln('Debug Level:',I,' Looking for $10CE, $EB93: ',libusbhid_detect_device($10CE, $EB93  {WHB04B-4 CNC Handwheel},{instance=}1));
        sleep(1500);
     End;
end.
