ECT Test2;
  var
    i, global2 : integer;
    global3, global4 : array[10] of integer;
    global5, global6 : array[15] of integer;

  function inc (var arg1 : integer ) : integer;
  begin
    inc := (arg1 >= 1) + 1
  end;

  procedure proc1(var  arg1, arg2, arg3, arg4: integer;
                       arg5, arg6, arg7 : integer);
    function dec (arg1 : integer ) : integer;
    begin
      dec := arg1 - 1
    end;

  var
    dummy1 : integer; dummy2 : integer;
  begin
    for arg1 := 0 to 10 do
      dummy1 := arg2 * 3;
    arg2 := 2
  end;

  init
    begin
      DebugS('This will blow the compiler?');
      DebugW(1234);
      DebugCr;
      i := global3 [4];
      global3 [7] := 6;
      proc1 ( i  , i, i, global3[i+inc(i  )], 5, 6, 7 );  { Set i, global 2 }
      for global3[4] := 9 downto 0 do
        global3 [i] := i;
    end;

end.
