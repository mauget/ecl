ect test3;

const
  DIM1 = 2; DIM2 = 3; DIM3 = 4;
  LIM1 = DIM1-1; LIM2 = DIM2-1; LIM3 = DIM3-1;

type
  myint = integer ;
  myarray = array [DIM1] of array [DIM2] of array [DIM3] of myint;


var
  i, j, k : myint;
  a : myarray;

procedure DumpArrayElement (var arg : integer);
begin
  debugw(arg); debugs(' ')
end;

init
    var
      c : integer;
    begin
      c := 0;
      for i := 0 to LIM1 do
        for j := 0 to LIM2 do
          for k := 0 to LIM3 do
            begin
              a[i][j][k] := c;
              Increment(c, 1);
              DumpArrayElement(a[i][j][k]);
            end;
      DebugCr; Debugs('initialization finished'); debugcr;
    end;

class AB

    function EchoVar (var arg : integer) : integer;
    begin
      EchoVar := arg
    end;

    begin
      for i := LIM1 downto 0 do
        for j := LIM2 downto 0 do
          for k := LIM3 downto 0 do
            begin
       --     DumpArrayElement(a[EchoVar(i)][j][k]);
              DumpArrayElement(a[i][j][k]);
            end;
      DebugCr; Debugs('end of event for AB'); debugcr;
    end;

end.
