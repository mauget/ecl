
{**************************************************************}
{*   Call with these parameters and you should get a display  *}
{*   of the first 7 factorials and the value of PI:           *}
{*     EClass : AB                                            *}
{*     EAddr  : 1234                                          *}
{*     EValue : 7         (the number of factorials)          *}
{*          Louis E. Mauget 09/03/90                          *}
{**************************************************************}
 ECT     FactorialProgram;

   type
     myarray = array[3] of integer;
   var
     global : integer;
     gla : myarray;

   procedure PrintPi;
     begin
       DebugS('PI x 10**4 = ');
       DebugW(Pi) ;
       DebugCR
     end;

   function factorial   (x : integer ) : integer;
     begin
       if x <= 1 then
         factorial := 1
       else
         factorial := factorial(x - 1) * x
     end ;

   INIT
     begin
       DebugCR; DebugS('Init section called'); DebugCR
     end;

   TIMER
     begin
       DebugCR; DebugS('Timer section called'); DebugCR
     end;

   CONTROL
     begin
       DebugCR; DebugS('Control section called'); DebugCR
     end;

   CLASS AB

     const
       sep = '---------------------';
       START = 1;
     var x , Limit: integer;

     var                                { Added for array test }
       testarr : array[10] of integer;
       arindx  : array[2] of integer;

     procedure level2 (var arg:integer);
     begin
       debugs('level2: '); debugw(arg); debugcr;
       arg := arg * 2;
       debugs('level2: '); debugw(arg); debugcr;
     end;
 --  procedure testvar (var arg : integer; setting : integer);
 --  procedure testvar (arg , setting : integer);
 --  procedure testvar (arg : integer; setting : integer);
     procedure testvar (var arg : integer                   );
     begin
   --  debugw(arg); debugs('   '); debugw(setting); debugcr; { temp }
   --  arg := setting
   --  arg := arg * 2
       level2(arg)
     end;

     begin

       DebugW(EClass); DebugS(' is EClass value'); DebugCR;
       DebugW(EAddr ); DebugS(' is EAddr value' ); DebugCR;
       DebugW(EValue); DebugS(' is EValue value'); DebugCR;

       if EAddr = 1234 then begin
         Limit := EVALUE;  { EVALUE is the device (eg sensor) value }
         DebugS('Let''s test recursion and looping'); DebugCR;
         DebugS(sep); DebugCR;
         for x := START to Limit do
           begin
             DebugW(x);
             DebugS(' Factorial = ');
             DebugW(factorial(x));
             DebugCR; DebugS(sep); DebugCR
           end;
         DebugS('Now let''s test an intrinsic function: pi'); DebugCR;
         PrintPi;

 --      for x := 0   to   9 do begin     { Added for array test }
 --        testarr[x] := x;
 --        DebugS('x is '); DebugW(x); DebugCR
 --      end
         for arindx[1] := 9 downto 0 do begin     { Added for array test }
      -- for arindx[1] := 0   to   9 do begin     { Added for array test }
           testarr[arindx[1]] := arindx[1];
           DebugS('testarr[arindx[1]] is '); DebugW(testarr[arindx[1]]); DebugCR
         end;

         { Test var parameter }
         x := 333;
         testvar (x);
         testarr[10-1] := 333;  -- Change this to test range check
         testvar(testarr[9]); -- This one needs pushax to work
   --    testvar (1234, 5678);
   --    testvar (x, 12345);
         DebugS('testarr[10-1] = '); DebugW(testarr[10-1]); DebugCr;

         DebugS ('Global before increment: '); DebugW(Global); DebugCR;
         Increment(Global, 50);
         DebugS ('Global after increment:  '); DebugW(Global);;DebugCR;

         DebugS ('Global array before increment: '); DebugW(Gla[2]); DebugCR;
         Increment(Gla[2], 6);
         DebugS ('Global array after increment:  '); DebugW(Gla[2]); DebugCR;

       end
     end;

 end.

