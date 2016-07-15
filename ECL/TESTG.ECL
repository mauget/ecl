-- Test program

  ECT Test_Repeat_and_Global;

        const msg = 'To be or not to be, that is the question. Whether tis';
        var Result : integer;                    -- Lex level 0
            Global : integer;   { Test persistent global values }

        FUNCTION Echo(x : integer) : INTEGER;    -- Lex level 1

          Procedure Massage(arg : integer);
            begin
              DebugW(arg + 2);
              DebugW(arg - 2);
              DebugW(NOT arg);
              DebugW(-arg);
              DebugW(arg AND $0F);
              DebugW(arg / 2    );
              DebugW(arg MOD 10 );
              DebugW(arg OR  $3 );
              DebugW(arg XOR $3);
            end;

          begin
            Massage(x);
            Echo := x ;  { Echos its own parameter }
            for x := 10 downto 1 do
              begin
                if x = 5 then
                  debugw(5)
                else
                  begin debugw(x); debugcr end
              end;
            x := 1;
            repeat
              debugw(x);
              x := x + 1;
            until x > 10;
          end;


        DEFAULT                                 -- Lex level 1
          begin
            Result := Echo(66);
            DebugW(Result); DebugCR;
            DebugS (Msg); DebugCr;

            DebugS ('Global before increment: '); DebugW(Global); DebugCR;
            Global := Global + 1;
            DebugS ('Global after increment:  '); DebugW(Global); DebugCR;
          end;

    END .

