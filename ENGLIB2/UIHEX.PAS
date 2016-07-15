{***********************************************************}
{*        UIHEX: Provides buffered Intel Hex input.        *}
{*                   Lou Mauget 01/09/90                   *}
{***********************************************************}
unit UIHEX;

{***********************************************************}
{*                      Public stuff:                      *}
{***********************************************************}

interface

const
  DLEN      =  127;     { Maximum bytes per INTEL HEX record }
  DATA      =  0;       { Intel data type }
  ENDFILE   =  1;       { Intel eof type }

type                    { Definitions of string types:       }
  t_strilen = string[DLEN];             { Hex input data     }
  t_strolen = string[(DLEN+1) DIV 2];   { Binary output data }

{***********************************************************}
{*                Functions and procedures                 *}
{***********************************************************}
function hex2bin (var input: t_strilen; { Input Intel Hex record  }
                  var itype: byte;      { Type of hex record      }
                  var Location: word;   { Load location of record }
                  var output : t_strolen) : byte;

{***********************************************************}
{*                     Private stuff:                      *}
{***********************************************************}

{******************************************************************************}
{*    Definition of the Intel Hexadecimal Data Block Format                   *}
{*                     Lou Mauget 01/10/90                                    *}
{******************************************************************************}
{* t_intelhex = record                                                        *}
{*   header : byte;                 Always a colon (:)                        *}
{*   count : array[1..2] of byte;   Two-digit hexadecimal value specifying    *}
{*                                  the number of bytes in the data field     *}
{*                                  of the block. Maximum value = 0x10.       *}
{*                                  For a data block the minium count is      *}
{*                                  1.                                        *}
{*   location : array[1..4] of byte;Four hexadecimal digits representing      *}
{*                                  the starting memory location of the       *}
{*                                  block                                     *}
{*   itype: array[1..2] of byte;    Two hexadecimal digits. Value = 00 for    *}
{*                                  a data block                              *}
{*   data : array[1..len] of byte;  2 * N data bytes, each represented as     *}
{*                                  two hexadecimal digits. Each hex digit    *}
{*                                  is encoded as an ASCII character          *}
{*                                  0-9 or A-F.                               *}
{*   checksum: array[1..1] of byte; Two-digit hexadecimal number representing *}
{*                                  the two's complement of the sum of the    *}
{*                                  byte count, locations counters, record    *}
{*                                  type, and data fields (add without carry).*}
{*   eol : byte;                    End of line                               *}
{*                                                                            *}
{*   end ;                                                                    *}
{******************************************************************************}

implementation

uses UENGINE;           { For report_error }


const
  TYPE_DATA =  '0';     { INTEL HEX record type: data        }
  TYPE_END  =  '1';     { INTEL HEX record type: termination }
  HEADER    =  ':';     { INTEL HEX record header char       }

{------------------------ Procedures and Functions ---------------------}

{************************************************************************}
{*           Hex ASCII to integer conversion.  Use on byte.             *}
{*                         Lou Mauget 01/10/90                          *}
{************************************************************************}
function hatob  (c : byte) : byte;
 begin

   if  (c >= byte('0') ) AND (c <= Byte('9') ) then
     hatob := c AND $F

   else if ( (c >= byte('A')) AND (c <= byte('F')) ) then
     hatob := (c AND $F) + 9

   else if ( (c >= byte('a')) AND (c <= byte('f')) ) then
     hatob := (c AND $F) + 9

   else
     report_error (BADHEX);      { Bad input. quit }

 end;   { hatob }


{******************************************************************}
{*  Given an Intel Hex record in the buffer, put its binary data  *}
{*  into a holding string. Also hold onto it's address.           *}
{*                      Lou Mauget 01/10/90                       *}
{******************************************************************}
function hex2bin (var input: t_strilen; { Input Intel Hex record  }
                  var itype: byte;      { Type of hex record      }
                  var Location: word;   { Load location of record }
                  var output : t_strolen) : byte;
  var
    checksum : word;    { Computed checksum     }
    check    : word;    { Input checksum        }
    len      : byte;    { Length of binary data }
    wrk      : byte;    { Conversion work byte  }
    i, scan  : byte;    { Indices               }
  begin
    checksum := 0;
    {***************************************}
    {* Minimal validation of record format *}
    {***************************************}
    hex2bin := ERROR;
    scan := 1;
    if input[scan] = HEADER then
      begin
        scan := scan + 1;               { Step past field }

        {***********************************}
        {*         Convert length          *}
        {***********************************}
        len := 0;
        for i := 1 to 2 do
          begin
            wrk   := hatob(byte(input[scan]));
            scan := scan + 1;               { Step past field }
            len := (len SHL 4) OR wrk;
          end;
        checksum := checksum + len;


        {***********************************}
        {*         Convert location        *}
        {***********************************}
        location := 0;
        for i := 1 to 4 do
          begin
            wrk   := hatob(byte(input[scan]));
            scan := scan + 1;               { Step past field }
            location := (location SHL 4) OR wrk;
          end;
        checksum := checksum + Hi(location) + Lo(Location);

        {***********************************}
        {*         Convert type            *}
        {***********************************}
        itype := 0;
        for i := 1 to 2 do
          begin
            wrk   := hatob(byte(input[scan]));
            scan := scan + 1;               { Step past field }
            itype := (itype SHL 4) OR wrk;
          end;
        checksum := checksum + itype;

        {***********************************}
        {*         Convert data            *}
        {***********************************}
        for i := 1 to len do            { Do over OUTPUT length }
          begin
            wrk   := hatob(byte(input[scan]));
            scan := scan + 1;               { Step past field }
            output[i] := char(wrk SHL 4);   { Upper nybble }

            wrk   := hatob(byte(input[scan]));
            scan := scan + 1;                          { Step past field }
            output[i] := char(byte(output[i]) OR wrk); { Lower nybble }
            checksum := checksum + byte(output[i]);
          end;
        output[0] := char(len);         { Set string length );

        {***********************************}
        {*         Convert check           *}
        {***********************************}
        check := 0;
        for i := 1 to 2 do
          begin
            wrk   := hatob(byte(input[scan]));
            scan := scan + 1;               { Step past field }
            check := (check SHL 4) OR wrk;
          end;

        {***********************************}
        {*         Compute checksum        *}
        {***********************************}
        hex2bin := byte(-(checksum + check))

      end; { if valid record }

  end; { hex2bin }

end.
