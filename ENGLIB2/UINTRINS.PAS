{*******************************************************************}
{*             Place intrinsic functions in this unit.             *}
{*                       Lou Mauget 01/11/90                       *}
{*******************************************************************}
unit uintrins;

interface

{*********************************************************}
{*    Exported functions and procedures - intrinsics     *}
{*********************************************************}
procedure DebugW;
procedure DebugS;
procedure DebugCR;
procedure Pi;

implementation

uses UENGINE;

{************************************************************}
{*  Pop a string from the engine stack and place it into a  *}
{*  pascal string. Return the string value.                 *}
{*                   Lou Mauget 01/15/90                    *}
{************************************************************}
function PopStr : string;
  var
    work : word;
    str : string;
    i   : byte;
  begin
    i := 0;
    repeat
      work := Pop;                { 1st loop: pops length and 1st char }
      str[i] := char(Hi(work));
      i := i + 1;
      str[i] := char(Lo(work));   { Garbage okay if len 0 }
      i := i + 1;
    until i > Length(str);      { Length set by 1st iteration }
    PopStr := str               { Return value }
  end;

{--------------- Intrinsic implementations -----------------}

{***********************************************************}
{* PROC           Print string to "stdout"                 *}
{***********************************************************}
procedure DebugS;
  begin
    Write(PopStr)                { Display the string     }
  end;

{***********************************************************}
{* PROC            Print word to "stdout"                  *}
{***********************************************************}
procedure DebugW;
  begin
    Write(Integer(Pop))         { Display the word }
  end;

{***********************************************************}
{* PROC            Print cr to "stdout"                    *}
{***********************************************************}
procedure DebugCR;
  begin
    Writeln      { Carriage return }
  end;

{***********************************************************}
{* FUNC          Return value of Pi x 10000                *}
{***********************************************************}
procedure Pi;
  begin
    Push(31416)         { Pi x 10**4 }
  end;
end.
