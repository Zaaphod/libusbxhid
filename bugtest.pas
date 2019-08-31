program libusbhid_test;
{$mode objfpc}{$H+}
uses
  heaptrc,{to hunt for memory leaks}

  sysutils,

  libusbhid;
Var
  i : Integer;
begin
        LIBUSB_DEBUG_LEVEL:=3;
  For I:= 0 to 3 Do
     Begin

        Writeln('Debug Level:',3,' Looking for $10CE, $EB93: ',libusbhid_detect_device($10CE, $EB93  {WHB04B-4 CNC Handwheel},{instance=}1));
        sleep(1500);
     End;
end.
