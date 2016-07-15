{*******************************************************************}
{*             Place intrinsic functions in this unit.             *}
{*                       Lou Mauget 01/11/90                       *}
{*******************************************************************}

Module MIntrinsMod;

{***********************************************************}
{*                      Public stuff:                      *}
{***********************************************************}
{$I 'ASCIICON.INC'}
{$I 'CONST.INC'}
{$I 'OVEXT.INC'}
{$I 'MINTRINS.H'}
{$I 'ENGINE.INC'}

#define debug 3
#include <debug.inc>

VAR XDATA
    t_str  :  ARRAY[256+1] of byte;

{************************************************************}
{*  Pop a string from the engine stack and place it into a  *}
{*  pascal string. Return the string value.                 *}
{*                   Lou Mauget 01/15/90                    *}
{************************************************************}
PROCEDURE PopStr(varx str: zstring)                        [STATIC XDATA];
  var
    work : word;
    i   : byte;
    slen : byte;
  begin

    work := Pop;                   { pop length and 1st char }

    slen := Highbyte(work);        { set length  }
    str[0] := LowByte(work);       { init loop variable }
    i := 1;

    while i < slen do begin

      work := Pop;                 { pop 2 bytes of string              }
      str[i] := HighByte(work);
      i := i + 1;

      str[i] := LowByte(work);     { Garbage okay if len 0 }
      i := i + 1;

    end;                           { Length set by 1st iteration }

    str[slen] := 0;                { null terminate string }
  end;

{--------------- Intrinsic implementations -----------------}

{***********************************************************}
{* PROC           Print string to "stdout"                 *}
{***********************************************************}
PROCEDURE SVC_DebugS                                       [STATIC XDATA];
  begin
    PopStr(t_str);
    Prtstring(t_str);                    { display string }
  end;

{***********************************************************}
{* PROC            Print word to "stdout"                  *}
{***********************************************************}
PROCEDURE SVC_DebugW                                       [STATIC XDATA];
Var
  w : word;
  begin
    w := POP;
    PrtHexW(w)         { Display the word }
  end;

{***********************************************************}
{* PROC            Print cr to "stdout"                    *}
{***********************************************************}
PROCEDURE SVC_DebugCR                                      [STATIC XDATA];
  begin
   NewLine      { Carriage return }
  end;

{***********************************************************}
{* FUNC          Return value of Pi x 10000                *}
{***********************************************************}
PROCEDURE SVC_Pi                                           [STATIC XDATA];
  begin
    Push(31416)         { Pi x 10**4 }
  end;
{***********************************************************}
{* PROC          Call host                                 *}
{***********************************************************}
PROCEDURE CallHost                                         [STATIC XDATA];
VAR
  w : WORD;
  rc : BYTE;
  BEGIN

    prtmsgnl('call host intrins executed');

    {*-----------------------*}
    {* get parms from stack  *}
    {*-----------------------*}
    w := POP;
    PopStr(t_str);

    {*------------------------------------------------*}
    {* helpful debug stuff printed to diagnostic port *}
    {*------------------------------------------------*}
    prtmsg('retries = ');
    prthexw(w);
    newline;
    prtmsg('phone = ');
    prtxstr(t_str,0);
    newline;

    {*---------------------------------------------*}
    {* place phone call on outbound modem queue    *}
    {*---------------------------------------------*}
    rc := putmodq(t_str,w,5,TRUE);
  END;
{***********************************************************}
{* PROC          ReportXcept                               *}
{***********************************************************}
PROCEDURE ReportXcept                                      [STATIC XDATA];
VAR
  adr : WORD;
  class : WORD;
  value : WORD;
  rc : BYTE;
BEGIN
  value := POP;        {* get value *}
  class := POP;        {* get class *}
  adr   := POP;        {* get address *}

  rc := PutTransQ(adr,class,value);  {* put it on exception queue for host *}

END;
{***********************************************************}
{* PROC          ReportXcept                               *}
{***********************************************************}
PROCEDURE WriteDevice                                      [STATIC XDATA];
VAR
  adr   : WORD;
  value : WORD;
  savedev : BYTE;
  trc : BYTE;

BEGIN

  value := POP;             {* pop value from stack *}
  adr   := POP;             {* pop address from stack *}
  savedev := curdevice;     {* save current device *}
  device(IIC);              {* switch current device to IIC *}
  prtmsg('S D ');           {* ship command string out to LAN *}
  prthexw(adr);             {* ship address *}
  putchar(" ");             {* ship delimeter *}
  prthex(value);            {* ship boolean value *}
  putchar(CR);              {* ship CR to signify end of command *}

  device(savedev);
  DebugMsg3('write intrins executed ',CONBF);
  DebugWord3(adr,CONBF);
  DebugChar3(" ",CONBF);
  DebugHex3(value,CONBF);
  DebugChar3(CR,CONBF);
  DebugChar3(LF,CONBF);
  trc := waitresp(NULL,IIC);     {* wait for response from IIC *}

END;
{***********************************************************}
{* PROC          Call voice                                *}
{***********************************************************}
PROCEDURE CallVoice                                        [STATIC XDATA];
VAR
  w : WORD;
  rc : BYTE;
  x  : BYTE;
  BEGIN
    prtmsgnl('call voice intrins executed');   { debug stuff }

    {*-----------------------*}
    {* get parms from stack  *}
    {*-----------------------*}
    w := POP;
    PopStr(t_str);

    {*---------------------------------------------*}
    {* place semicolon at end of AT command string *}
    {*---------------------------------------------*}
    x := len(t_str,0);
    t_str[x] := ";";
    t_str[x+1] := 0;

    {*------------------------------------------------*}
    {* helpful debug stuff printed to diagnostic port *}
    {*------------------------------------------------*}
    prtmsg('retries = ');
    prthexw(w);
    newline;
    prtmsg('phone = ');
    prtxstr(t_str,0);
    newline;

    {*---------------------------------------------*}
    {* place phone call on outbound modem queue    *}
    {*---------------------------------------------*}
    rc := putmodq(t_str,w,5,FALSE);
  END;
{***********************************************************}
{* PROC          Speak Phrase                              *}
{***********************************************************}
PROCEDURE SpeakAudio                                       [STATIC XDATA];
VAR
 SpkLib    : WORD;
 phrase : WORD;
 savedev : BYTE;

BEGIN
  spklib :=  POP;       { get library parameter }
  phrase :=  POP;       { get phrase parameter }
  prtmsgnl('Speak audio intrinsic executed');
  savedev := curdevice; { save device }
  device(IIC);
  PrtMsg('T ');
  Prthex(spklib);
  Putchar(" ");
  Prthex(phrase);
  putchar(CR);
  device(savedev);

END;

{***********************************************************}
{* FUNC          Query device                              *}
{***********************************************************}
PROCEDURE QueryDevice                                      [STATIC XDATA];

VAR
 w   : WORD;                  { work variable }
 savedev : BYTE;
 buf : ARRAY[20] of BYTE;
 rc  : BYTE;

BEGIN
  w   := POP;                  { get address from stack }
  Prtmsgnl('Query intrinsic executed');

  savedev := curdevice;        { save current device }

  {*-------------------------------*}
  {* send command to IRM           *}
  {*-------------------------------*}
  device(IIC);                 { change current device to IIC }
  PrtMsg('Q D ');              { send first part of message }
  PrtHexw(w);                  { send address }
  Putchar(CR);                 { send tail }

  {*-------------------------------*}
  {* get response from IRM         *}
  {*-------------------------------*}
  rc := GetResp(buf,IIC);    { get response from iolan }
  w := valh(buf,1);            { convert response }

  {*-------------------------------*}
  {* timeout form lan ?            *}
  {*-------------------------------*}
  IF rc THEN
    PUSH($FFFF)      { time out, return - 1 }
  ELSE
    PUSH(w);         { return value from irm }

END;

end.
