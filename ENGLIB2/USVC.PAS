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

unit USVC;

{***********************************************************}
{*                      Public stuff:                      *}
{***********************************************************}

interface
{$A-}
{$D+}
{$R+}
{$S+}

procedure PerformSvc (SvcNo : byte);

{***********************************************************}
{*                     Private stuff:                      *}
{***********************************************************}

implementation

uses UENGINE, UINTRINS;           { Uses push and pop }


procedure PerformSvc (SvcNo : byte);
  var
    RetValue : word;    { Functional return value }
    Func : byte;        { Function flag: we push value at return if true }
  begin
    Func := 0;          { Default to procedure }
    RetValue := 0;      { Initialize }
    case SvcNo of
      0:  Writeln('DisplayInteger: ', Integer(Pop));  { SVC 0 }
      1:  DebugW;                                     { SVC 1 }
      2:  DebugS;                                     { SVC 2 }
      3:  DebugCR;                                    { SVC 3 }
      4:  Pi;                                         { SVC 4 }
      else
      {************************************}
      {* Report an error if undefined SVC *}
      {************************************}
        report_error(UNDEFINED);        { Halts }
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