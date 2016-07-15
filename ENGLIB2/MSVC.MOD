{*************************************************************}
{* USVC:  this unit contains code and data used to implement *}
{* MARC Language intrinic functions and procedures.  An      *}
{* intrinic is invoked by the MARC Language interpreter      *}
{* (engine) when an SVC instruction is decoded.              *}
{*                                                           *}
{* The single byte operand of the SVC is the index of the    *}
{* SVC routine to be executed. The number must correspond    *}
{* 1:1 with the intrinsic entry order intialized in the MARC *}
{* Language compiler.                                        *}
{*                                                           *}
{*                                                           *}
{* Each intrinsic must take the number and types of          *}
{* parameters that was given to the MARC Language compiler.  *}
{* The intrinsic type (function vs procedure) must match     *}
{* also.                                                     *}
{*                                                           *}
{* Thus, the compiler code and this module must be in        *}
{* agreement.  Changes to either component must be reflected *}
{* in the other component.                                   *}
{*                                                           *}
{*                Lou Mauget 01/09/90                        *}
{*************************************************************}

Module MSVCmod;

{***********************************************************}
{*                      Public stuff:                      *}
{***********************************************************}
{$I 'CONST.INC'}
{$I 'OVEXT.INC'}
{$I 'MSVC.H'}
{$I 'ENGINE.INC'}


{***********************************************************}
{*                     Private stuff:                      *}
{***********************************************************}


PROCEDURE PerformSvc (SvcNo : byte)                        [STATIC XDATA];
  var
    RetValue : word;    { Functional return value }
    Func : byte;        { Function flag: we push value at return if true }
    w : word;
  begin
{   prtmsg('perform SVC ');      }
{   prthex(svcno);               }
{   newline;                     }

    Func := 0;          { Default to procedure }
    RetValue := 0;      { Initialize }
    case SvcNo of
      0:  BEGIN                                       { SVC 0 }
            prtmsg('DisplayInteger: ');
            w := Pop;
            prthexw(w);
          END;
      1:  SVC_DebugW;                                 { SVC 1 }
      2:  SVC_DebugS;                                 { SVC 2 }
      3:  SVC_DebugCR;                                { SVC 3 }
      4:  SVC_Pi;                                     { SVC 4 }
      5:  CallHost;                                   { SVC 5 }
      6:  ReportXcept;                                { SVC 6 }
      7:  WriteDevice;                                { SVC 7 }
      8:  CallVoice;                                  { SVC 8 }
      9:  SpeakAudio;                                 { SVC 9 }
     10:  E_QueryYear;                                { SVC 10}
     11:  E_QueryMon;                                 { SVC 11}
     12:  E_QueryDay;                                 { SVC 12}
     13:  E_QueryDow;                                 { SVC 13}
     14:  E_QueryHour;                                { SVC 14}
     15:  E_QueryMin;                                 { SVC 15}
     16:  E_QuerySec;                                 { SVC 16}
     17:  E_SetTmZone;                                { SVC 17}
     18:  E_Storenow1;                                { SVC 18}
     19:  E_Storenow2;                                { SVC 19}
     20:  E_StoreRaw1;                                { SVC 20}
     21:  E_StoreRaw2;                                { SVC 21}
     22:  E_DeltaDay;                                 { SVC 22}
     23:  E_DeltaHour;                                { SVC 23}
     24:  E_DeltaMin;                                 { SVC 24}
     25:  E_DeltaSec;                                 { SVC 25}
     26:  E_PrtTime;                                  { SVC 26}
     27:  E_SetSTmr  ;                                { SVC 27}
     28:  E_ClearStmr                                 { SVC 28}

      else
      {************************************}
      {* Report an error if undefined SVC *}
      {************************************}
        report_error(NOSVC);            { Halts }
    end;

   {**********************************}
   {* Push return value if function  *}
   {**********************************}
   if Func <> 0 then
     Push(RetValue);


 end;

{***********************************}
{*      Initialize stuff here      *}
{***********************************}
end.
