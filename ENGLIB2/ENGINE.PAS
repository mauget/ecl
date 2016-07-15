{***********************************************************}
{*          Test driver for MARC Language engine.          *}
{*                   Lou Mauget 01/09/90                   *}
{***********************************************************}

program Driver;

Uses UENGINE, UIHEX;

Const
  DefaultFile = 'TEST';

var
  f : text;                     { Input file }
  Fname : string;               { Input file name }
  buffer : t_strilen;           { Input buffer }
  rc : byte;                    { Return code }
  itype : byte;                 { Intel hex record type }
  Location : word;              { Intel hex record load location }
  output : t_strolen;           { Intel hex record binary load for Location }
  i : byte;

begin
    {*************************}
    {*   Load the program    *}
    {*************************}
    if ParamCount > 0 then              { If any command line parms: }
      Fname := ParamStr(1)              { Take passed parameter as name }
    else
      Fname := DefaultFile;             { Otherwise, take default name }

    if Pos('.', Fname) = 0 then         { Add default extension, if needed }
      Fname := Fname + '.HEX';

    for i := 1 to Length(Fname) do      { Upper case the file name }
      Fname[i] := UpCase(Fname[i]);

    writeln ('Loading ',Fname);

    Assign(f, Fname);
    reset(f);

    repeat                      { Load the file into engine code ram }
      if  Eof(f) then
        begin writeln('End of file'); rc := 255; halt end
      else
        begin
          readln (f, buffer);
          rc := hex2bin (buffer,
                         itype,
                         Location,
                         output);
          if rc <> 0 then
            writeln('rc = ', rc)
          else
            begin

              {**************************************************}
              {* Load one Intel Hex record into engine code ram *}
              {**************************************************}
    {         writeln('Address ', Location:5);   }
              rc := rc + EngineSetLoadAddr ( Location);
              for i := 1 to byte(output[0]) do
                rc := rc + EngineLoadByte ( byte(output[i]) );

            end
        end
    until itype <> DATA;
    Close(f);

    {*************************}
    {*  Execute the program  *}
    {*************************}
    rc := Engine (t_class('A'), 1234,  56);  { Pass: Class, addr, value }
    rc := Engine (t_class('A'), 1234,  56);  { Pass: Class, addr, value }
    rc := Engine (t_class('A'), 1234,  56);  { Pass: Class, addr, value }
    rc := Engine (t_class('A'), 1234,  56);  { Pass: Class, addr, value }

end.
