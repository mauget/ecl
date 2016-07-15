unit UENGINE;

interface

{$A-}
{$D+}
{$R+}
{$S+}
{

 The MARC Engine is an interpreter for the MARC Language.  The engine
 resides within MARC.  This PS/2 version is used on a PS/2 for debugging
 and simulation.  This version is the source code that is ported to the
 AVPAS Pascal that MARC uses.

 A program written in MARC Language is downloaded into the MARC unit.
 When a MARC event occurs, the engine is called by the MARC supervisor
 to handle the event, passing indentifying parameters needed for the
 MARC Language program.  The MARC Language program communicates with the
 MARC unit through intrinsic functions called by SVC.

                           Lou Mauget 01/08/90


ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

        The tuple mnemonics and their meanings - alpabetized  by mnemonic
        ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

ADD     80              pop1 + pop0 -> push
AND     81              pop1 & pop0 -> push
DIV     82              pop1 / pop0 -> push
MOD     83              pop1 % pop0 -> push
MUL     84              pop1 * pop0 -> push
OR      85              pop1 | pop0 -> push
SUB     86              pop1 - pop0 -> push
XOR     87              pop1 ^ pop0 -> push
CMPEQ   88              pop1 == pop0 -> push
CMPGE   89              pop1 >= pop0 -> push
CMPGT   8A              pop1 >  pop0 -> push
CMPLE   8B              pop1 <= pop0 -> push
CMPLT   8C              pop1 <  pop0 -> push
CMPNE   8D              pop1 != pop0 -> push
DEC     A0              (level,rvalue)--
INC     A1              (level,rvalue)++
NEG     A2              -stk0
NOT     A3              ~stk0
CALL    B0  addr        push nsi, addr -> ic
SVC     B1  byte        ic -> push, svctab[value] -> ic
JMP     C0  addr        addr -> ic
JZ      C1  addr        pop0, if zero addr -> ic
CJE     C2  addr        pop1 - pop0, if 0: addr -> ic
CJZ     C2  addr        pop1 - pop0, if 0: addr -> ic
CJNE    C3  addr        pop1 - pop0, if !0: addr -> ic
CJNZ    C3  addr        pop1 - pop0, if !0: addr -> ic
RET     D0              pop0 -> ic
RETF    D1  lvl,rvalue  pop0 -> ic,  (level,rvalue) -> push
DUPE    E0              pop0 -> push, push
PURGE   E1              pop0
PUSHI   E2  value       value -> push
PUSHIB  E3  byte        byte  -> push
PUSHR   E4  lvl,rvalue  (level,rvalue) -> push
STORE   E5  lvl,rvalue  pop0 -> (level,rvalue)
PUSHS   E6  string      push(strrev(string)), push(strlen)
INIT    F0  byte        Push display of (byte) words onto stack
ENTER   F1  byte, byte, byte    argcount, level, autolen
LEAVE   F2              Purge current activation record

ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

        The tuple mnemonics and their meanings - grouped by action
        ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

ÄÄÄÄÄÄÄÄ Arithmetic - binary ÄÄÄÄÄÄÄÄ

ADD                     pop1 + pop0 -> push
AND                     pop1 & pop0 -> push
DIV                     pop1 / pop0 -> push
MOD                     pop1 % pop0 -> push
MUL                     pop1 * pop0 -> push
OR                      pop1 | pop0 -> push
SUB                     pop1 - pop0 -> push
XOR                     pop1 ^ pop0 -> push

ÄÄÄÄÄÄÄÄ Relational test - binary ÄÄÄÄÄÄÄÄ

CMPEQ                   pop1 == pop0 -> push
CMPGE                   pop1 >= pop0 -> push
CMPGT                   pop1 >  pop0 -> push
CMPLE                   pop1 <= pop0 -> push
CMPLT                   pop1 <  pop0 -> push
CMPNE                   pop1 != pop0 -> push

ÄÄÄÄÄÄÄÄ Arithmetic - unary ÄÄÄÄÄÄÄÄ

DEC                     (level,rvalue)--
INC                     (level,rvalue)++
NEG                     -stk0
NOT                     ~stk0

ÄÄÄÄÄÄÄÄ Subroutine calling ÄÄÄÄÄÄÄÄ

CALL    addr            push ic, addr -> ic
SVC     value           ic -> push, svctab[value] -> ic

ÄÄÄÄÄÄÄÄ Return operations ÄÄÄÄÄÄÄÄ

RET                     pop0 -> ic
RETF    level,rvalue    pop0 -> ic,  (level,rvalue) -> push

ÄÄÄÄÄÄÄÄ Jump operations ÄÄÄÄÄÄÄÄ

JMP     addr            addr -> ic
JZ      addr            pop0, if zero addr -> ic
CJE     addr            pop0, if 0: addr -> ic
CJZ     addr            pop0, if 0: addr -> ic
CJNE    addr            pop0, if !0: addr -> ic
CJNZ    addr            pop0, if !0: addr -> ic

ÄÄÄÄÄÄÄÄ Stack manipulation ÄÄÄÄÄÄÄÄ

DUPE                    pop0 -> push, push
PURGE                   pop0
PUSHI   value           value -> push
PUSHR   level,rvalue    (level,rvalue) -> push
STORE   level,rvalue    pop0 -> (level,rvalue)
PUSHS   E6  string      push(strrev(string)), push(strlen)


ÄÄÄÄÄÄÄÄ Activation housekeeping ÄÄÄÄÄÄÄÄ

ENTER   pc,level,len    Build AR with parms:pc, auto data:len
INIT    value           Set display. Simulate PROC(class, addr, val) call:
LEAVE                   Restore previous AR


ÄÄÄÄÄÄÄÄ Psuedo operations ÄÄÄÄÄÄÄÄ

EQU     value           Psuedo-op



ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

        The tuple mnemonics and their opcodes - grouped by action
        ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

ÄÄÄÄÄÄÄÄ Arithmetic - binary ÄÄÄÄÄÄÄÄ

ADD     80              pop1 + pop0 -> push
AND     81              pop1 & pop0 -> push
DIV     82              pop1 / pop0 -> push
MOD     83              pop1 % pop0 -> push
MUL     84              pop1 * pop0 -> push
OR      85              pop1 | pop0 -> push
SUB     86              pop1 - pop0 -> push
XOR     87              pop1 ^ pop0 -> push

ÄÄÄÄÄÄÄÄ Relational test - binary ÄÄÄÄÄÄÄÄ

CMPEQ   88              pop1 == pop0 -> push
CMPGE   89              pop1 >= pop0 -> push
CMPGT   8A              pop1 >  pop0 -> push
CMPLE   8B              pop1 <= pop0 -> push
CMPLT   8C              pop1 <  pop0 -> push
CMPNE   8D              pop1 != pop0 -> push

ÄÄÄÄÄÄÄÄ Arithmetic - unary ÄÄÄÄÄÄÄÄ

DEC     A0              (level,rvalue)--
INC     A1              (level,rvalue)++
NEG     A2              -stk0
NOT     A3              ~stk0

ÄÄÄÄÄÄÄÄ Subroutine calling ÄÄÄÄÄÄÄÄ

CALL    B0  addr        push nsi, addr -> ic
SVC     B1  byte        ic -> push, svctab[value] -> ic

ÄÄÄÄÄÄÄÄ Jump operations ÄÄÄÄÄÄÄÄ

JMP     C0  addr        addr -> ic
JZ      C1  addr        pop0, if zero addr -> ic
CJE     C2  addr        pop1 - pop0, if 0: addr -> ic
CJZ     C2  addr        pop1 - pop0, if 0: addr -> ic
CJNE    C3  addr        pop1 - pop0, if !0: addr -> ic
CJNZ    C3  addr        pop1 - pop0, if !0: addr -> ic

ÄÄÄÄÄÄÄÄ Return operations ÄÄÄÄÄÄÄÄ

RET     D0              pop0 -> ic
RETF    D1  lvl,rvalue  pop0 -> ic,  (level,rvalue) -> push

ÄÄÄÄÄÄÄÄ Stack manipulation ÄÄÄÄÄÄÄÄ

DUPE    E0              pop0 -> push, push
PURGE   E1              pop0
PUSHI   E2  value       value -> push
PUSHIB  E3  byte        byte  -> push
PUSHR   E4  lvl,rvalue  (level,rvalue) -> push
STORE   E5  lvl,rvalue  pop0 -> (level,rvalue)
PUSHS   E6  string      push(strrev(string)), push(strlen)


ÄÄÄÄÄÄÄÄ Activation housekeeping ÄÄÄÄÄÄÄÄ

INIT    F0  byte                Allocate (byte) display entries
ENTER   F1  byte, byte, byte    Build AR: Argcount, level, autolen
LEAVE   F2                      Pop current AR


ÄÄÄÄÄÄÄÄ Psuedo operations ÄÄÄÄÄÄÄÄ

EQU                     value           Psuedo-op



ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

        The tuple mnemonics and their opcodes - sorted by opcode
        ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

ADD     80              pop1 + pop0 -> push
AND     81              pop1 & pop0 -> push
DIV     82              pop1 / pop0 -> push
MOD     83              pop1 % pop0 -> push
MUL     84              pop1 * pop0 -> push
OR      85              pop1 | pop0 -> push
SUB     86              pop1 - pop0 -> push
XOR     87              pop1 ^ pop0 -> push
CMPEQ   88              pop1 == pop0 -> push
CMPGE   89              pop1 >= pop0 -> push
CMPGT   8A              pop1 >  pop0 -> push
CMPLE   8B              pop1 <= pop0 -> push
CMPLT   8C              pop1 <  pop0 -> push
CMPNE   8D              pop1 != pop0 -> push
DEC     A0              (level,rvalue)--
INC     A1              (level,rvalue)++
NEG     A2              -stk0
NOT     A3              ~stk0
CALL    B0  addr        push nsi, addr -> ic
SVC     B1  byte        ic -> push, svctab[value] -> ic
JMP     C0  addr        addr -> ic
JZ      C1  addr        pop0, if zero addr -> ic
CJE     C2  addr        pop1 - pop0, if 0: addr -> ic
CJZ     C2  addr        pop1 - pop0, if 0: addr -> ic
CJNE    C3  addr        pop1 - pop0, if !0: addr -> ic
CJNZ    C3  addr        pop1 - pop0, if !0: addr -> ic
RET     D0              pop0 -> ic
RETF    D1  lvl,rvalue  pop0 -> ic,  (level,rvalue) -> push
DUPE    E0              pop0 -> push, push
PURGE   E1              pop0
PUSHI   E2  value       value -> push
PUSHIB  E3  byte        byte  -> push
PUSHR   E4  lvl,rvalue  (level,rvalue) -> push
STORE   E5  lvl,rvalue  pop0 -> (level,rvalue)
PUSHS   E6  string      push(strrev(string)), push(strlen)
INIT    F0  byte        Push display of (byte) words onto stack
ENTER   F1  byte, byte, byte    argcount, level, autolen
LEAVE   F2              Purge current activation record


}

{***********************************************************}
{*                      Public stuff:                      *}
{***********************************************************}

const
  OK    = 0;
  ERROR = 12;

var
  HaltFlag : boolean;   { Halt engine when true. }

type                    { Catastrophic error codes }
  t_err = ( UNDERFLOW, OVERFLOW, SHOULDNOT, UNDEFINED, BADHEX );

type                    { Randy or Clayton: change t_addr if we go to 32 bits: }
  t_class = byte;       { Class of device : 'A'..'Z' }
  t_addr = word;        { Local MARC address of device (eventee) }
  t_value = byte;       { Value of address }

{***********************************************************}
{*      Externally callable functions and procedures:      *}
{***********************************************************}
        { Report and error and halt }
procedure report_error(Errcode : t_err);

        { Push an argument onto the stack }
procedure Push (Arg : word);

        { Pop an argument from the stack }
function Pop : word;

        { Pass an event through the engine: }
function Engine (Class : t_class; Addr : t_addr;  Value : t_value) : byte;

        { Disable the engine: clear load address }
function EngineDisable :  byte;

        { Load byte into config, increment load address }
function EngineLoadByte ( CodeByte : byte ) : byte;

        { Set load adress }
function EngineSetLoadAddr ( Address : word ) : byte;

        { Query the state of the enabled flag. Zero means disabled. }
function EngineQuery : byte;

        { Enable the engine: done loading config }
function EngineEnable  : byte;

{***********************************************************}
{*                     Private stuff:                      *}
{***********************************************************}

implementation

uses USVC;              { Unit for intrinics interface }

const
  STACKMAX = 4095;      { Developer: fiddle, but don't go over 32767 }
  CODEMAX  = 8191;      { Developer: fiddle, but don't go over 32767 }

  DUMMYRET = $FFFF;     { Dummy return pushed by INIT                }

{***********************************************************}
{*    Opcodes follow. They are in interpretation groups    *}
{***********************************************************}
const
  OC_ADD    = $80;      { Group 1: Binary operations }
  OC_AND    = $81;
  OC_DIV    = $82;
  OC_MOD    = $83;
  OC_MUL    = $84;
  OC_OR     = $85;
  OC_SUB    = $86;
  OC_XOR    = $87;
  OC_CMPEQ  = $88;
  OC_CMPGE  = $89;
  OC_CMPGT  = $8A;
  OC_CMPLE  = $8B;
  OC_CMPLT  = $8C;
  OC_CMPNE  = $8D;

  OC_DEC    = $A0;      { Group 2: Unary operations }
  OC_INC    = $A1;
  OC_NEG    = $A2;
  OC_NOT    = $A3;

  OC_CALL   = $B0;      { Group 3: Proc/func calls }
  OC_SVC    = $B1;

  OC_JMP    = $C0;      { Group 4: Jumps }
  OC_JZ     = $C1;
  OC_CJE    = $C2;
  OC_CJNE   = $C3;

  OC_RET    = $D0;      { Group 5: Returns }
  OC_RETF   = $D1;

  OC_DUPE   = $E0;      { Group 6: Stack operations }
  OC_PURGE  = $E1;
  OC_PUSHI  = $E2;
  OC_PUSHIB = $E3;
  OC_PUSHR  = $E4;
  OC_STORE  = $E5;
  OC_PUSHS  = $E6;

  OC_INIT   = $F0;      { Group 7: Activation record operations }
  OC_ENTER  = $F1;
  OC_LEAVE  = $F2;


type
  t_stype = word;       { Define stack element type }

{*******************************************************************}
{*      Adapt this as necessary in MARC. It is the data RAM.       *}
{*                       Lou Mauget 01/08/90                       *}
{*******************************************************************}
var
  StackRAM : array [0..STACKMAX] of t_stype;    { MARC Language stack }
  sp : word;                                    { MARC Language stack pointer }

  XClass : t_class;             { Values pushed by INIT: }
  XAddr : t_addr;
  XValue : t_value;

{*******************************************************************}
{*      Adapt this as necessary in MARC. It is the code RAM.       *}
{*                       Lou Mauget 01/08/90                       *}
{*******************************************************************}
var
  CodeRAM : array [0..CODEMAX] of byte;
  Ic : word;            { Instruction counter }
  Ar : word;            { Scope-lexical level-display: Register }

{*******************************************}
{*           Control information           *}
{*******************************************}
var
  Enabled : byte;       { Engine enabled, load disabled iff non-zero }
  LoadIndex : word;     { Index of next code byte to load }

{*************************************************************************}
{*        Disable the engine for all but loading of MARC Language        *}
{*        configuration program.                                         *}
{*                          Lou Mauget 01/08/90                          *}
{*************************************************************************}
function EngineDisable :  byte;
begin
  Enabled := 0;         { Turn off the interpreter engine }
  LoadIndex := 0;       { Set load address }
  EngineDisable := OK
end;

{*************************************************************************}
{*        Enable the engine for execution. Loading not allowed           *}
{*        afterward.                                                     *}
{*                          Lou Mauget 01/08/90                          *}
{*************************************************************************}
function EngineEnable :  byte;
begin
  Enabled := 1;
  EngineEnable := OK
end;

{**********************************************************************}
{*     Query the state of the enabled flag. Zero means disabled.      *}
{*                        Lou Mauget 01/08/90                         *}
{**********************************************************************}
function EngineQuery : byte;
begin
  EngineQuery := EngineEnable
end;

{*******************************************************************}
{*         Load byte into config, increment load address.          *}
{*                       Lou Mauget 01/08/90                       *}
{*******************************************************************}
function EngineLoadByte ( CodeByte : byte ) : byte;
begin
  if LoadIndex < CODEMAX then
    begin
      CodeRAM [ LoadIndex ] := CodeByte;        { Stuff byte }
      LoadIndex := LoadIndex + 1;               { Advance load point }
      EngineLoadByte := OK;                     { Say we did }
    end
  else
    EngineLoadByte := ERROR;                    { Say we didn't }
end;

{*******************************************************************}
{*                        Set load address.                        *}
{*                       Lou Mauget 01/09/90                       *}
{*******************************************************************}
function EngineSetLoadAddr ( Address : word ) : byte;
begin
  LoadIndex := Address
end;

{-------------------------- Here is the good stuff ---------------------------}

{***************************************************************}
{* Report an eval error. Rewrite this for the actual MARC box. *}
{*                     Lou Mauget 01/08/90                     *}
{***************************************************************}
procedure report_error(Errcode : t_err);
  var
    MsgText : string[40];
  begin
    case Errcode of
      UNDERFLOW: MsgText := 'stack underflow';
      OVERFLOW:  MsgText := 'stack overflow';
      SHOULDNOT: MsgText := 'should not occur (but did..tee hee)';
      UNDEFINED: MsgText := 'undefined';
      BADHEX:    MsgText := 'bad Intel Hex data';
      else       MsgText := 'unknown'
    end;
    Writeln('MARC engine: ', MsgText, ' error');
    halt
  end;

{*********************************************************************}
{* Given a lexical level (AR number) and a SIGNED offset, return the *}
{* index of the appropriate stack location.                          *}
{*                        Lou Mauget 01/09/90                        *}
{*********************************************************************}
function GetVariableIndex (Level, Offset : byte) : word;
  begin
    if (Offset AND $80) = 0 then   { Positive sign bit? }
      GetVariableIndex := StackRAM [ Level ] + Offset
    else                { Negative: simulate signed offset in unsigned arith }
      begin
        Offset :=  NOT Offset + 1;
        GetVariableIndex := StackRAM [ Level ] - Offset
      end;
  end;

{*********************************************************************}
{* Given a lexical level (AR number) and a signed offset, return the *}
{* word from the appropriate location.                               *}
{*                        Lou Mauget 01/09/90                        *}
{*********************************************************************}
function GetVariable (Level, Offset : byte) : word;
  begin
    GetVariable := StackRAM [GetVariableIndex(Level, Offset)]
  end;

{*********************************************************************}
{* Given a lexical level (AR number), a signed offset, and a word,   *}
{* store the word at the appropriate location.                       *}
{*                        Lou Mauget 01/09/90                        *}
{*********************************************************************}
procedure StoreVariable (Level, Offset : byte; Value : word);
  begin
    StackRAM [GetVariableIndex(Level, Offset)] := Value
  end;

{******************************************************************}
{*  Push the argument onto the MARC Language stack. If the stack  *}
{*  would overflow, call stack error.                             *}
{*                      Lou Mauget 01/08/90                       *}
{******************************************************************}
procedure Push (Arg : word);
  begin
    if sp >= STACKMAX then
      report_error(OVERFLOW)              { Report stack OVERFLOW  }
    else
      begin                               { Okay! }
        sp := sp + 1;                     { Allocate new location }
        StackRAM [sp] := Arg              { Stack the argument }
      end
  end;

{****************************************************************}
{*  Pop the argument from the stack unless the stack is empty.  *}
{*  If empty, return 0 and set the stack pointer to  0 (clear   *}
{*  stack: good value).                                         *}
{*                     Lou Mauget 01/08/90                      *}
{****************************************************************}
function Pop : word;
  begin
    if sp > 0 then                { Not empty stack:  }
      begin
        Pop := StackRAM [sp] ;    { Sp points to current busy location  }
        sp := sp - 1              { sp points to previous busy location }
      end
    else                          { Empty or bad stack pointer }
      report_error(UNDERFLOW)     { Report stack UNDERFLOW }
  end;

{*************************************************************************}
{*        Fetch an opcode. Report wild branch if ic out of range.        *}
{*        Does not change Ic.                                            *}
{*                Lou Mauget 01/08/90                                    *}
{*************************************************************************}
function Fetch : byte;
  begin
    Fetch := CodeRAM [Ic];
  end;

{*************************************************************************}
{*        Fetch operand word 1                                           *}
{*        Does not change Ic.                                            *}
{*                Lou Mauget 01/08/90                                    *}
{*************************************************************************}
function OpWord1 : word;
  begin
    OpWord1 := (Word(CodeRAM [Ic + 1]) SHL 8) OR Word(CodeRAM [Ic + 2])
  end;

{*************************************************************************}
{*        Fetch operand byte 1                                           *}
{*        Does not change Ic.                                            *}
{*                Lou Mauget 01/08/90                                    *}
{*************************************************************************}
function OpByte1 : word;
  begin
    OpByte1 := Word(CodeRAM [Ic + 1])
  end;

{*************************************************************************}
{*        Fetch operand byte 2                                           *}
{*        Does not change Ic.                                            *}
{*                Lou Mauget 01/08/90                                    *}
{*************************************************************************}
function OpByte2 : word;
  begin
    OpByte2 := Word(CodeRAM [Ic + 2])
  end;

{-------------------- Instruction interpretation groups -----------------}

{**************************************************************}
{*   Group 1: Binary operations                               *}
{*                                                            *}
{*       ADD    80  pop1 + pop0 -> push      1                *}
{*       AND    81  pop1 & pop0 -> push      1                *}
{*       DIV    82  pop1 / pop0 -> push      1                *}
{*       MOD    83  pop1 % pop0 -> push      1                *}
{*       MUL    84  pop1 * pop0 -> push      1                *}
{*       OR     85  pop1 | pop0 -> push      1                *}
{*       SUB    86  pop1 - pop0 -> push      1                *}
{*       XOR    87  pop1 ^ pop0 -> push      1                *}
{*       CMPEQ  88  pop1 == pop0 -> push     1                *}
{*       CMPGE  89  pop1 >= pop0 -> push     1                *}
{*       CMPGT  8A  pop1 >  pop0 -> push     1                *}
{*       CMPLE  8B  pop1 <= pop0 -> push     1                *}
{*       CMPLT  8C  pop1 <  pop0 -> push     1                *}
{*       CMPNE  8D  pop1 != pop0 -> push     1                *}
{*                                                            *}
{*                  Louis E. Mauget 01/08/90                  *}
{**************************************************************}
function DoGroup1 ( opcode : byte) : byte;
  var
    op0, op1, result : word;

  type
    t_cmpop = (GT, GE, LT, LE );    { Arugments to SignedCmp funct }

  {**********************************************************}
  {* Treat unsigned arguments as signed, perform comparison *}
  {**********************************************************}
  function SignedCmp(operator : t_cmpop) : word;
    const
      SIGN = $8000;            { Sign extraction mask }
    var
      work : word;
      sign0, sign1, N, V, Z : word;
    begin
      sign0 := op0 AND SIGN;
      sign1 := op1 AND SIGN;
      work := op1 - op0;                       { Base comparison }
      if work = 0 then Z := 1 else Z := 0;     { Z flag }
      N := work AND SIGN;                      { N flag }
      V := (sign1 AND NOT sign0 AND NOT N) OR  { V flag }
           (NOT sign1 AND sign0 AND N);

      case operator of
        GT: SignedCmp := word((Z OR (N XOR V)) = 0);
        GE: SignedCmp := word((N XOR V) = 0);
        LT: SignedCmp := word(N XOR V);
        LE: SignedCmp := word(Z OR (N XOR V));
      end;
    end;

  begin
    op0 := pop;         { Get operands from stack. op0 must be 1st pop. }
    op1 := pop;         { op1 must be second pop  }

    case opcode of      { Perform proper instruction }
      OC_ADD  : result := op1 +   op0;                   { +  }
      OC_SUB  : result := op1 -   op0;                   { -  }
      OC_CMPEQ: result := Word(op1 =  op0);  { =  }
      OC_CMPNE: result := Word(op1 <> op0);  { <> }
      OC_CMPGE: result := SignedCmp(GE);     { >= }
      OC_CMPGT: result := SignedCmp(GT);     { >  }
      OC_CMPLE: result := SignedCmp(LE);     { >= }
      OC_CMPLT: result := SignedCmp(LT);     { <  }
      OC_AND  : result := op1 AND op0;                   { &  }
      OC_DIV  : result := op1 DIV op0;                   { /  }
      OC_MOD  : result := op1 MOD op0;                   { %  }
      OC_MUL  : result := op1 *   op0;                   { *  }
      OC_OR   : result := op1 OR  op0;                   { |  }
      OC_XOR  : result := op1 XOR op0;                   { ^  }
      else
        report_error ( SHOULDNOT )
    end;
    push (result);              { Stack the result }
    Ic := Ic + 1;               { All are 1 byte instructions }
    DoGroup1 := OK
  end;

{***********************************************************}
{*                                                         *}
{*   Group 2: Unary operations                             *}
{*                                                         *}
{*       DEC    A0  (level,rvalue)--         3             *}
{*       INC    A1  (level,rvalue)++         3             *}
{*       NEG    A2  -stk0                    1             *}
{*       NOT    A3  ~stk0                    1             *}
{*                                                         *}
{*                  Louis E. Mauget 01/08/90               *}
{***********************************************************}
function DoGroup2 ( opcode : byte) : byte;
  var
    Index : word;
  begin
    case opcode of
      OC_DEC:
        begin
          Index := GetVariableIndex (OpByte1, OpByte2);
          StackRAM [Index] := StackRAM [Index] - 1;
          Ic := Ic + 3
        end;
      OC_INC:
        begin
          Index := GetVariableIndex (OpByte1, OpByte2);
          StackRAM [Index] := StackRAM [Index] + 1;
          Ic := Ic + 3
        end;
      OC_NEG:
        begin
          StackRAM [sp] := (NOT StackRAM [sp]) + 1;  { 2's complement }
          Ic := Ic + 1
        end;
      OC_NOT:
        begin
          StackRAM [sp] := NOT StackRAM [sp];
          Ic := Ic + 1
        end;
      else
        report_error( SHOULDNOT )
    end;
    DoGroup2 := OK
  end;

{***********************************************************}
{*                                                         *}
{*   Group 3: Proc/func calls                              *}
{*                                                         *}
{*       CALL   B0  push Ic, addr -> Ic               3    *}
{*       SVC    B1  Ic -> push, svctab[value] -> Ic   2    *}
{*                                                         *}
{*                  Louis E. Mauget 01/08/90               *}
{***********************************************************}
function DoGroup3 ( opcode : byte) : byte;
  begin
    case opcode of
      OC_CALL:
        begin
          Push (Ic + 3);        { Ret location  }
          Ic := OpWord1         { Jump location }
        end;
      OC_SVC :
        begin
          PerformSvc (OpByte1); { In unit USVC }
          Ic := Ic + 2
        end;
      else
        report_error( SHOULDNOT );
    end;
    DoGroup3 := OK
  end;

{***********************************************************}
{*                                                         *}
{*   Group 4: Jumps                                        *}
{*                                                         *}
{*       JMP    C0  addr -> Ic                        3    *}
{*       JZ     C1  pop0, if zero addr -> Ic          3    *}
{*       CJE    C2  pop1 - pop0, if 0: addr -> Ic     3    *}
{*       CJNE   C3  pop1 - pop0, if !0: addr -> Ic    3    *}
{*                                                         *}
{*                  Louis E. Mauget 01/08/90               *}
{***********************************************************}
function DoGroup4 ( opcode : byte) : byte;
  begin
    case opcode of
      OC_JMP : Ic := OpWord1;
      OC_JZ  : if pop = 0 then Ic := OpWord1 else Ic := Ic + 3;
      OC_CJE : if (pop - pop) =  0 then Ic := OpWord1 else Ic := Ic + 3;
      OC_CJNE: if (pop - pop) <> 0 then Ic := OpWord1 else Ic := Ic + 3;
      else
        report_error( SHOULDNOT );
    end;
    DoGroup4 := OK
  end;

{***********************************************************}
{*                                                         *}
{*   Group 5: Returns                                      *}
{*                                                         *}
{*       RET    D0  pop0 -> Ic                          1  *}
{*       RETF   D1  pop0 -> Ic,  (level,rvalue) -> push 3  *}
{*                                                         *}
{*                  Louis E. Mauget 01/08/90               *}
{***********************************************************}
function DoGroup5 ( opcode : byte) : byte;
  var
    NewIc : word;
  begin
    DoGroup5 := OK;
    case opcode of
      OC_RET : Ic := Pop;
      OC_RETF:
        begin
          NewIc := Pop;         { Get return address out of the way }
          Push( StackRAM [GetVariableIndex (OpByte1, OpByte2)] );
          Ic := NewIc
        end
      else
        report_error( SHOULDNOT )
    end;
   If Ic = DUMMYRET then      { Handle end-of-event }
     begin
       HaltFlag := TRUE ;
       DoGroup5 := 255  ;  { Make this a symbolic something }
     end
  end;


{***********************************************************}
{*                                                         *}
{*   Group 6: Stack operations                             *}
{*                                                         *}
{*       DUPE   E0  pop0 -> push, push           1         *}
{*       PURGE  E1  pop0                         1         *}
{*       PUSHI  E2  value -> push                3         *}
{*       PUSHIB E3  byte  -> push                2         *}
{*       PUSHR  E4  (level,rvalue) -> push       3         *}
{*       STORE  E5  pop0 -> (level,rvalue)       3         *}
{*                                                         *}
{*                  Louis E. Mauget 01/08/90               *}
{***********************************************************}
function DoGroup6 ( opcode : byte) : byte;
  var
    work, s : word;
    len, i , limit: byte;
  begin
    case opcode of
      OC_DUPE  : begin
                   work := Pop;
                   Push(work);
                   Push(work);
                   Ic := Ic + 1
                 end;
      OC_PURGE : begin work := Pop;   Ic := Ic + 1 end;
      OC_PUSHI : begin Push (OpWord1); Ic := Ic + 3 end;
      OC_PUSHIB: begin Push (OpByte1); Ic := Ic + 2 end;
      OC_PUSHR :
        begin
          Push( GetVariable (OpByte1, OpByte2) );
          Ic := Ic + 3
        end;
      OC_STORE :
        begin
          StoreVariable (OpByte1, OpByte2, Pop);
          Ic := Ic + 3
        end;
      OC_PUSHS :
        begin
          len := OpByte1;          { Get string length   }
          s := ic + len ;          { Address string      }
          limit := (len + 1) div 2;
          if (len AND 1) = 0 then  { Length odd?    }
            begin
              s := s + 1;
              limit := limit + 1
            end;

          for i := 1 to limit do
            begin
              Push( (word(CodeRAM [ s ]) SHL 8) OR word(CodeRAM [ s + 1 ]) );
              s := s - 2;
            end;
          ic := ic + len + 2;
        end
      else
        report_error( SHOULDNOT )
      end;
    DoGroup6 := OK
  end;

{***********************************************************}
{*                                                         *}
{*   Group 7: Activation record operations                 *}
{*                                                         *}
{*       INIT   F0  Allocate (byte) display entries     2  *}
{*       ENTER  F1  Build AR: Argcount, level, autolen  3  *}
{*       LEAVE  F2  Pop current AR                      1  *}
{*                                                         *}
{*                  Louis E. Mauget 01/08/90               *}
{***********************************************************}
function DoGroup7 ( opcode : byte) : byte;
  const
    DYNAR = 1; STATAR = 2; LEXLV = 3; PCOUNT = 4; { AR header offsets: }
  var
    OldAr , RetAddr : word;
    Level , ParmCount, i :byte;
  begin
    case opcode of
      OC_INIT :                    { Allocate lexical display            }
        begin
          Ar := Word(255);         { Ar is invalid: peg its value        }
          Level := OpByte1;        { Get maximum nesting level           }
          StackRAM [0] := Ar;      { Plug Ar into level 0 display        }
          while level <> 0  do     { For each additional level do:       }
            begin
              Push (255);          { ...allocate one scope display entry }
              level := level - 1;
            end;
          Push (XClass);           { Pass calling parms to MARC program  }
          Push (XAddr);
          Push (XValue);
          Push (DUMMYRET);         { Placeholder for return              }
          Ic := Ic + 2             { Instruction length is 2             }
        end;

      OC_ENTER:
        begin
                                { Unpack the operands:             }
          ParmCount := OpByte1;         { Packed count, level      }
          Level := ParmCount AND $F;    { Level is low nybble      }
          ParmCount := ParmCount SHR 4; { ParmCount is high nybble }
                                { Build activation record:         }
                                { Numbers are new AR offsets       }
          OldAr := Ar;
          Ar := Sp;                     { Assign new Activation Record  }
                                        { 0: Caller's return            }
          Push (OldAr);                 { 1: Dynamic AR link     DYNAR  }
          Push (StackRAM [Level]);      { 2: Static AR link      STATAR }
          Push (Level);                 { 3: AR level            LEXLV  }
          Push (Word(ParmCount));       { 4: Parm purge count    PCOUNT }
          Sp := Sp + OpByte2;           { 5: Allocated variables        }
          StackRAM [Level] := Ar;       { Set current display at level  }

          Ic := Ic + 3
        end;
      OC_LEAVE:
        begin
          Level := StackRAM [ Ar + LEXLV ];       { Get our level number     }
                                                  { Restore display level    }
          StackRAM [Level] := StackRAM [ Ar + STATAR]; { Caller's display    }
          ParmCount := StackRAM [ Ar + PCOUNT ];  { Save purge count         }
          Sp := Ar;                               { Purge the Ar             }
          Ar := StackRAM [ Ar + DYNAR ];          { Restore previous AR      }
          RetAddr := Pop;                         { Save return addr         }
          Sp := Sp - ParmCount;                   { Purge the parms          }
          Push (RetAddr);                         { Caller's link at tos     }
          Ic := Ic + 1;
        end;
      else
        report_error( SHOULDNOT )
    end;
    DoGroup7 := OK
  end;

{---------------- End instruction interpretation groups -----------------}

{*******************************************************************}
{*      This driver interprets one MARC Language instruction       *}
{*                       Lou Mauget 01/08/90                       *}
{*******************************************************************}
function ICycle : byte;
  var
    opcode : byte;      { Current opcode under Ic }
  begin
    {********************}
    {* Fetch the opcode *}
    {********************}
    opcode := Fetch;

    {*****************************************************************}
    {* Classify the opcode, dispatch proper opcode class interpreter *}
    {*****************************************************************}
    if (opcode >= OC_ADD) AND (opcode <= OC_CMPNE)  then
      ICycle := DoGroup1 ( opcode)
    else if (opcode >= OC_DEC) AND (opcode <= OC_NOT)    then
      ICycle := DoGroup2 ( opcode)
    else if (opcode >= OC_CALL) AND (opcode <= OC_SVC)   then
      ICycle := DoGroup3 ( opcode)
    else if (opcode >= OC_JMP) AND (opcode <= OC_CJNE)   then
      ICycle := DoGroup4 ( opcode)
    else if (opcode >= OC_RET) AND (opcode <= OC_RETF)   then
      ICycle := DoGroup5 ( opcode)
    else if (opcode >= OC_DUPE) AND (opcode <= OC_PUSHS) then
      ICycle := DoGroup6 ( opcode)
    else if (opcode >= OC_INIT) AND (opcode <= OC_LEAVE) then
      ICycle := DoGroup7 ( opcode)
    else if  opcode = 0 then         { Temp to stop us }
      ICycle := $AA
    else
        report_error( SHOULDNOT )
  end;

{*****************************************************************************}
{*        Pass the event parameters to the MARC configuration through        *}
{*        the engine.                                                        *}
{*                            Lou Mauget 01/08/90                            *}
{*****************************************************************************}
function Engine (Class : t_class; Addr : t_addr;  Value : t_value) : byte;
  begin
    Ic := 0;                    { Always enter at MARC Lang location 0 }
    writeln('Stack : ',sp);
    XClass := Class;            { Remember paramters for INIT instruction }
    XAddr  := Addr;
    XValue := Value;
    HaltFlag := FALSE;
    while ICycle = 0 do ;       { Execute }

    If HaltFlag then writeln('Normal end of event');

    Engine := OK                { Say we did the event }
  end;

{-------------------------- End of the good stuff ---------------------------}

{*******************************************************************}
{*        Initialize some stuff to make it look pretty to the      *}
{*        debugger person. Also initialize the variables           *}
{*                       Lou Mauget 01/08/90                       *}
{*******************************************************************}
var
  i : integer;
  rc : byte;

begin

  {*****************************************}
  {*       Initialize some variables       *}
  {*****************************************}
  rc := EngineDisable;  { Engine disabled for all but loading }
  sp := 0;              { One entry on the stack: display 0 }

  {*****************************************}
  {*               Clear RAM               *}
  {*****************************************}
  { Note: in real MARC box, DO NOT CLEAR THE STACK. The global }
  { variables should live across event calls.                  }
  for i := 0 to STACKMAX do StackRAM[i] := 0;  { 0 origin }
  for i := 0 to CODEMAX  do CodeRAM[i]  := 0;  { 0 origin }
end.

