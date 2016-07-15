
ect test4;

type
  mytype = array [10] of integer;

const
  sizeofmytype =  sizeof mytype + sizeof mytype - sizeof mytype / 1;

var
  a : array [2] of mytype;

procedure test(var arg : integer);
begin
  debugs("Size of arg is ");
  debugw(sizeof arg);
  debugcr;
end;

--class ab begin end;
--control  begin end;
--dtmf     begin end;
--error    begin end;
--init     begin end;
--timer    begin end;
class ab   begin end;
control    begin end;
dtmf       begin end;
error      begin end;
init
   var
     x : integer;
  begin
    debugcr;
    debugs("Size of mytype is ");
    debugw(sizeofmytype);
    debugcr;
    debugs("Size of A is ");
    debugw(-sizeof A*2+-4);
    debugcr;
    test(a[1][2]);
    test(x);
  end;
timer      begin end;


end.
