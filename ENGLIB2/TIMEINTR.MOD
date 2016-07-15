{*******************************************************************}
{*                    Time and Date intrinsics                     *}
{*******************************************************************}

Module TimeIntrMod;

{***********************************************************}
{*                      Public stuff:                      *}
{***********************************************************}
{$I 'ASCIICON.INC'}
{$I 'CONST.INC'}
{$I 'OVEXT.INC'}
{$I 'ENGINE.INC'}
{$I 'TIME.INC'}
{$I 'TIMEINTR.H'}
#define debug 3
#include <debug.inc>

VAR XDATA
    Eyear,Emon,Eday,Eweek,Ehour,Emin,Esec  :  WORD;
    TimeZone : EXTERNAL WORD;
    DayLight : EXTERNAL BYTE;
    ETimeRec : tm;
    ECLTmrs  : Array[MaxECLtmrs] of ECLTmrRec;


{***********************************************************}
{* Read Clock - used for time and date intrinsics          *}
{***********************************************************}
PROCEDURE ReadClock                                        [STATIC XDATA];
BEGIN
  rd72423(ETimeRec.tm_year,
          ETimeRec.tm_mon,
          ETimeRec.tm_mday,
          ETimeRec.tm_wday,
          ETimeRec.tm_hour,
          ETimeRec.tm_min,
          ETimeRec.tm_sec);

END;
{***********************************************************}
{* DeltaRawTime   Calculate detla given two rawtimes       *}
{***********************************************************}
FUNCTION  DeltaRawTime(high1,high2,low1,low2:WORD;VARX result:DWORD):BYTE [STATIC XDATA];
VAR
  dw1 : DWORD;
  dw2 : DWORD;
BEGIN
   MakeDwordx(high1,high2,dw1);
   MakeDwordx(low1,low2,dw2);
   IF SignDWX(dw1,GE,dw2) THEN
     BEGIN
       SubDWx(dw1,dw2,result);
       DeltaRawTime := 0;
     END
   ELSE
     DeltaRawTime := $FF;

END;
{***********************************************************}
{* E_QUERYYEAR   Query Year                                *}
{***********************************************************}
PROCEDURE E_QueryYear                                      [STATIC XDATA];

BEGIN
  ReadClock;
  Push(ETimeRec.tm_year);
END;
{***********************************************************}
{* E_QUERYMONTH  Query Month                               *}
{***********************************************************}
PROCEDURE E_QueryMon                                       [STATIC XDATA];

BEGIN
  ReadClock;
  Push(ETimeRec.tm_mon);
END;

{***********************************************************}
{* E_QUERYDAY    Query Day                                 *}
{***********************************************************}
PROCEDURE E_QueryDay                                       [STATIC XDATA];

BEGIN
  ReadClock;
  Push(EtimeRec.tm_mday);
END;

{***********************************************************}
{* E_QUERYDOW    Query Day of Week                         *}
{***********************************************************}
PROCEDURE E_QueryDOW                                       [STATIC XDATA];

BEGIN
  ReadClock;
  Push(EtimeRec.tm_wday);
END;

{***********************************************************}
{* E_QUERYHOUR   Query Hour                                *}
{***********************************************************}
PROCEDURE E_QueryHour                                      [STATIC XDATA];

BEGIN
  ReadClock;
  Push(EtimeRec.tm_hour);
END;
{***********************************************************}
{* E_QUERYMIN    Query Min                                 *}
{***********************************************************}
PROCEDURE E_QueryMin                                       [STATIC XDATA];

BEGIN
  ReadClock;
  Push(ETimeRec.tm_min);
END;

{***********************************************************}
{* E_QUERYSEC    Query Sec                                 *}
{***********************************************************}
PROCEDURE E_QuerySec                                       [STATIC XDATA];

BEGIN
  ReadClock;
  Push(ETimeRec.tm_sec);
END;


{***********************************************************}
{* E_SETTMZONE(GmtDiff,DST)                                *}
{* GmtDiff - signed number of timezones form the prime     *}
{*           meridian                                      *}
{* DST     - non-zero causes use of US daylight saving time*}
{* Examples:                                               *}
{*   E_SetTmZone( 5,1) Raleigh,Boca,Kingston               *}
{*   E_SetTmZone( 6,1) Chicago,Arkansas                    *}
{*   E_SetTmZone( 7,0) Arizona                             *}
{*   E_SetTmZone( 8,1) California                          *}
{***********************************************************}
PROCEDURE E_SetTmZone                                      [STATIC XDATA];
VAR
   i : WORD;
BEGIN
  i := POP;
  DayLight := i;
  i := POP;
  TimeZone := i;
END;

{***********************************************************}
{* E_StoreNow1 -  Return first half of rawtime             *}
{***********************************************************}
PROCEDURE E_StoreNow1                                      [STATIC XDATA];
VAR
  RawTime : Time_t;
  w       : WORD;
BEGIN
   ReadClock;                       { read rtc into time rec (will be gmt)}
   MkTIme (ETimeRec, RawTime);      { convert gmt time rec to raw secs }
   LocalTime(RawTime,EtimeRec);     { convert raw seconds to local time rec }
   MkTIme(EtimeRec,RawTime);        { convert local time rec back to rawtime}
   w := Makeword(RawTime[0],RawTime[1]);
   PUSH(w);
END;

{***********************************************************}
{* E_StoreNow2 -  Return second half of rawtime            *}
{***********************************************************}
PROCEDURE E_StoreNow2                                      [STATIC XDATA];
VAR
  RawTime : Time_t;
  w       : WORD;
BEGIN
   ReadClock;                       { read rtc into time rec (will be gmt)}
   MkTIme (ETimeRec, RawTime);      { convert gmt time rec to raw secs }
   LocalTime(RawTime,EtimeRec);     { convert raw seconds to local time rec }
   MkTIme(EtimeRec,RawTime);        { convert local time rec back to rawtime}
   w := Makeword(RawTime[2],RawTime[3]);
   PUSH(w);
END;

{***********************************************************}
{* E_StoreRaw1 -  Store first half of rawtime              *}
{***********************************************************}
PROCEDURE E_StoreRaw1                                      [STATIC XDATA];
VAR
  RawTime : Time_t;
  w       : WORD;
BEGIN
   ETimeRec.tm_sec  := POP;
   ETimeRec.tm_min  := POP;
   ETimeRec.tm_hour := POP;
   ETimeRec.tm_mday := POP;
   ETimeRec.tm_mon  := POP - 1;   { change to zero origin }
   ETimeRec.tm_year := POP;
   MkTIme (ETimeRec, RawTime);
   w := Makeword(RawTime[0],RawTime[1]);
   push(w);
END;

{***********************************************************}
{* E_StoreRaw2 -  Store second half of rawtime             *}
{***********************************************************}
PROCEDURE E_StoreRaw2                                      [STATIC XDATA];
VAR
  RawTime : Time_t;
  w       : WORD;
BEGIN
   ETimeRec.tm_sec  := POP;
   ETimeRec.tm_min  := POP;
   ETimeRec.tm_hour := POP;
   ETimeRec.tm_mday := POP;
   ETimeRec.tm_mon  := POP-1;
   ETimeRec.tm_year := POP;
   MkTIme (ETimeRec, RawTime);
   w := Makeword(RawTime[2],RawTime[3]);
   push(w);
END;

{***********************************************************}
{* E_DeltaDay  -  Store second half of rawtime             *}
{***********************************************************}
PROCEDURE E_DeltaDay                                       [STATIC XDATA];
VAR
  Result        : DWORD;
  SecondsPerDay : DWORD;
  DeltaDay      : DWORD;
  remain        : DWORD;
  rc            : WORD;
  low1          : WORD;
  low2          : WORD;
  high1         : WORD;
  high2         : WORD;

BEGIN
   low2 := POP;
   low1 := POP;
   high2:= POP;
   high1:= POP;

   {*-----------------------------------*}
   {* subtract times                    *}
   {*-----------------------------------*}
   rc := DeltaRawTime(high1,high2,low1,low2,result);

   {*-----------------------------------*}
   {* high greater than low ?           *}
   {*-----------------------------------*}
   IF rc THEN

     PUSH($FFFF)        { oops, high less than low value }

   ELSE
     BEGIN
        MakeDwordX($0001,$5180,SecondsPerDay);          { 60 * 60 * 24 }
        DivDwx(result,SecondsPerDay,DeltaDay,remain);

        {* number of days will fit into word ? *}
        IF HighWordx(DeltaDay) THEN
          push($FFFF)
        ELSE
          Push(LowWordx(DeltaDay));
     END;

END;

{***********************************************************}
{* E_DeltaHour -  Find Delta hour                          *}
{***********************************************************}
PROCEDURE E_DeltaHour                                      [STATIC XDATA];
VAR
  Result        : DWORD;
  DeltaHour     : DWORD;
  remain        : WORD;
  rc            : WORD;
  low1          : WORD;
  low2          : WORD;
  high1         : WORD;
  high2         : WORD;

BEGIN
   low2 := POP;
   low1 := POP;
   high2:= POP;
   high1:= POP;

   {*-----------------------------------*}
   {* subtract times                    *}
   {*-----------------------------------*}
   rc := DeltaRawTime(high1,high2,low1,low2,result);

   {*-----------------------------------*}
   {* high greater than low ?           *}
   {*-----------------------------------*}
   IF rc THEN

     PUSH($FFFF)        { oops, high less than low value }

   ELSE

     BEGIN

        DivWx(result,3600,DeltaHour,remain);    { 60 * 60 }

        {* number of days will fit into word ? *}
        IF HighWordx(DeltaHour) THEN
          push($FFFF)
        ELSE
          Push(LowWordx(DeltaHour));
     END;

END;

{***********************************************************}
{* E_DeltaMin  -  Find delta minute                        *}
{***********************************************************}
PROCEDURE E_DeltaMin                                       [STATIC XDATA];
VAR
  Result        : DWORD;
  remain        : WORD;
  DeltaMin      : DWORD;
  rc            : WORD;
  low1          : WORD;
  low2          : WORD;
  high1         : WORD;
  high2         : WORD;

BEGIN
   low2 := POP;
   low1 := POP;
   high2:= POP;
   high1:= POP;

   {*-----------------------------------*}
   {* subtract times                    *}
   {*-----------------------------------*}
   rc := DeltaRawTime(high1,high2,low1,low2,result);

   {*-----------------------------------*}
   {* check parms?                      *}
   {*-----------------------------------*}
   IF rc THEN

     PUSH($FFFF)        { oops, high less than low value }

   ELSE
     BEGIN

        DivWx(result,60,DeltaMin,remain);    { 60 }

        {* number of days will fit into word ? *}
        IF HighWordx(DeltaMin) THEN
          push($FFFF)
        ELSE
          Push(LowWordx(DeltaMin));
     END;

END;

{***********************************************************}
{* E_DeltaSec  -  Find delta sec                           *}
{***********************************************************}
PROCEDURE E_DeltaSec                                       [STATIC XDATA];
VAR
  Result        : DWORD;
  rc            : WORD;
  low1          : WORD;
  low2          : WORD;
  high1         : WORD;
  high2         : WORD;

BEGIN
   low2 := POP;
   low1 := POP;
   high2:= POP;
   high1:= POP;

   {*-----------------------------------*}
   {* subtract times                    *}
   {*-----------------------------------*}
   rc := DeltaRawTime(high1,high2,low1,low2,result);

   {*-----------------------------------*}
   {* bad parms or to big for integer?  *}
   {*-----------------------------------*}
   IF rc or (highwordx(result) <> 0 ) THEN

     PUSH($FFFF)        { oops, high less than low value }

   ELSE

     PUSH(LowWordx(result));

END;
{***********************************************************}
{* E_PrtTime   -  Print Time                               *}
{***********************************************************}
PROCEDURE E_PrtTime                                        [STATIC XDATA];
VAR
   high : WORD;
   low  : WORD;
   dw   : DWORD;
BEGIN
   low  := POP;
   high := POP;
   MakedWordx(high,low,dw);    { place in double word }

   {*-------------------------------------------*}
   {* convert to time record.  No local time    *}
   {* adjustments are needed because they were  *}
   {* store in local times                      *}
   {*-------------------------------------------*}
   GmTime(dw,ETimeRec);        { convert to time rec }
   PrtAscTime(EtimeRec);
END;
{***********************************************************}
{* S_SetTmr    -  Set Timer(tmr,secs,class,adr,value)      *}
{***********************************************************}
PROCEDURE E_SetSTmr                                        [STATIC XDATA];
VAR
  secs : WORD;
  tmr  : BYTE;
  class : WORD;
  adr   : WORD;
  value : WORD;
BEGIN


  value := POP;
  adr   := POP;
  class := POP;
  secs  := POP;
  tmr   := POP;

  ECLTmrs[tmr].value     := value;
  ECLTmrs[tmr].address   := adr;
  ECLTmrs[tmr].class     := class;

  IF (tmr > 0) and (tmr <= MaxECLtmrs) THEN
    SetStmr(tmr,secs)
  ELSE
    DebugMsg3('Invalid timer number in ECL E_SetTmr.',CONBF);

END;
{***********************************************************}
{* E_ClrTmr    -  Set Timer(tmr,secs,class,adr,value)      *}
{***********************************************************}
PROCEDURE E_ClearSTmr                                      [STATIC XDATA];
VAR
 tmr : BYTE;
BEGIN

  tmr := POP;

  IF (tmr > 0) and (tmr < MaxECLtmrs) THEN
    SetStmr(tmr,$FFFF)
  ELSE
    DebugMsg3('Invalid timer number in ECL E_ClrTmr.',CONBF);

END;
end.
