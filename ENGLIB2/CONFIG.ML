-- Executable test program

  config DebugInstructions;

        CONST Two = 2;
        VAR x : integer;


        PROCEDURE proc1;
          PROCEDURE proc2;
            begin
              x := x + 1
            end;
          begin
            x := 99;
            proc2
          end;


        DEFAULT
          begin
            proc1;
          end

    END .           { End program }
    -- really end

