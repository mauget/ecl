{*****************************************************************}
{*                                                               *}
{* E V E N T   C O N T R O L   T A S K   ( E C T )   E N G I N E *}
{*                                                               *}
{* An interpreter of ECT instructions.  These instructions are   *}
{* compiled from source written in Event Control Language (ECL). *}
{* The output of the compiler is a load image.  The load image   *}
{* is loaded into the ESCON Monitor through one of its serial    *}
{* ASCII links.  The engine is passed event parameters from the  *}
{* microcode.  The engine interprets the ECT image and returns.  *}
{*                                                               *}
{*                   Louis E. Mauget 03/06/91                 !! *}
{*****************************************************************}


{  The ECT Engine is an interpreter for the ECT Language, ECL.  The engine       }
{  resides within the ESCON Monitor.  This PS/2 version is used on a PS/2        }
{  for debugging and simulation.  This version is the source code that is        }
{  ported to the AVPAS Pascal used in the ESCON Monitor microcode.               }
{                                                                                }
{                                                                                }
{  A program written in ECL is downloaded into the ESCON Monitor unit.           }
{  When an ECT event occurs, the engine is called by the monitor                 }
{  supervisor to handle the event.  Event-indentifying parameters are            }
{  passed to the ECT.  The ECT communicates with the ESCON Monitor through       }
{  intrinsic subroutines called by an ECT SVC instruction.                       }
{                                                                                }
{  The instructions are referred to as "tuples" in the following comments.       }
{                                                                                }
{                       Lou Mauget 01/08/90, 03/10/91  !!                        }
{                                                                                }
{                                                                                }
{ ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ }
{                                                                                }
{         The tuple mnemonics and their meanings - sorted by mnemonic            }
{         ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ            }
{                                                                                }
{ OC_ADD        ADD     20              pop1 + pop0 -> push                      }
{ OC_AND        AND     21              pop1 & pop0 -> push                      }
{ OC_CALL       CALL    12  addr        push nsi, addr -> ic                     }
{ OC_CJE        CJE     13  addr        pop1 - pop0, if 0: addr -> ic            }
{ OC_CJNE       CJNE    15  addr        pop1 - pop0, if !0: addr -> ic           }
{ OC_CMPEQ      CMPEQ   28              pop1 == pop0 -> push                     }
{ OC_CMPGE      CMPGE   29              pop1 >= pop0 -> push                     }
{ OC_CMPGT      CMPGT   2A              pop1 >  pop0 -> push                     }
{ OC_CMPLE      CMPLE   2B              pop1 <= pop0 -> push                     }
{ OC_CMPLT      CMPLT   2C              pop1 <  pop0 -> push                     }
{ OC_CMPNE      CMPNE   2D              pop1 != pop0 -> push                     }
{ OC_DEC        DEC     Ax  lvl,rvalue  (level,rvalue)--                         }
{ OC_DIV        DIV     22              pop1 / pop0 -> push                      }
{ OC_DUPE       DUPE    30              pop0 -> push, push                       }
{ OC_ENTER      ENTER   02  byte, byte, word    argcount, level, autolen         }
{ OC_ENTERB     ENTERB  03  byte, byte, byte    argcount, level, autolen         }
{ OC_INC        INC     Bx  lvl,rvalue  (level,rvalue)++                         }
{ OC_INIT       INIT    01  byte        Push display of (byte) words onto stack  }
{ OC_JMP        JMP     10  addr        addr -> ic                               }
{ OC_JZ         JZ      11  addr        pop0, if zero addr -> ic                 }
{ OC_LEAVE      LEAVE   04              Purge current activation record, return  }
{ OC_LEAVEF     LEAVEF  05              Purge current AR, push result, return    }
{ OC_MOD        MOD     23              pop1 % pop0 -> push                      }
{ OC_MUL        MUL     24              pop1 * pop0 -> push                      }
{ OC_NEG        NEG                     -stk0                                    }
{ OC_NOT        NOT     2F              ~stk0                                    }
{ OC_OR         OR      25              pop1 | pop0 -> push                      }
{ OC_PINCX      PINCX   18  lvl,rvalue  ((&(level,rvalue)+pop0)++) -> push       }
{ OC_PDECX      PDECX   19  lvl,rvalue  ((&(level,rvalue)+pop0)--) -> push       }
{ OC_PURGE      PURGE   31              pop0                                     }
{ OC_PUSHA      PUSHA   7x  lvl,rvalue  &(level,rvalue) -> push                  }
{ OC_PUSHAX     PUSHAX  Cx  lvl,rvalue  pop0 + &(level,rvalue) -> push           }
{ OC_PUSHI      PUSHI   32  value       value -> push                            }
{ OC_PUSHIB     PUSHIB  33  byte        byte  -> push  (byte extended)           }
{ OC_PUSHN      PUSHN   8x  lvl,rvalue  ((level,rvalue)) -> push                 }
{ OC_PUSHR      PUSHR   4x  lvl,rvalue  (level,rvalue) -> push                   }
{ OC_PUSHRB     PUSHR   5x  lvl,rvalue  (level,rvalue) -> push (byte extended)   }
{ OC_PUSHS      PUSHS   34  string      push(strrev(string)), push(strlen)       }
{ OC_PUSHX      PUSHX   Dx  lvl,rvalue  (pop0 + &(level,rvalue)) -> push         }
{ OC_RANGE      RANGE   06  value       No side-effect                           }
{ OC_STORE      STORE   6x  lvl,rvalue  pop0 -> (level,rvalue)                   }
{ OC_STOREN     STOREN  9x  lvl,rvalue  (pop0) -> ((level,rvalue))               }
{ OC_STOREX     STOREX  Ex  lvl,rvalue  pop0 -> (&(level,rvalue) + pop1)         }
{ OC_SUB        SUB     26              pop1 - pop0 -> push                      }
{ OC_SVC        SVC     17  byte        ic -> push, svctab[value] -> ic          }
{ OC_XOR        XOR     27              pop1 ^ pop0 -> push                      }
{                                                                                }
{ ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ           }
{                                                                                }
{         The tuple mnemonics and their meanings - grouped by action             }
{         ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ             }
{                                                                                }
{ ÄÄÄÄÄÄÄÄ Arithmetic - binary ÄÄÄÄÄÄÄÄ                                          }
{                                                                                }
{ ADD                     pop1 + pop0 -> push                                    }
{ AND                     pop1 & pop0 -> push                                    }
{ DIV                     pop1 / pop0 -> push                                    }
{ MOD                     pop1 % pop0 -> push                                    }
{ MUL                     pop1 * pop0 -> push                                    }
{ OR                      pop1 | pop0 -> push                                    }
{ SUB                     pop1 - pop0 -> push                                    }
{ XOR                     pop1 ^ pop0 -> push                                    }
{                                                                                }
{ ÄÄÄÄÄÄÄÄ Relational test - binary ÄÄÄÄÄÄÄÄ                                     }
{                                                                                }
{ CMPEQ                   pop1 == pop0 -> push                                   }
{ CMPGE                   pop1 >= pop0 -> push                                   }
{ CMPGT                   pop1 >  pop0 -> push                                   }
{ CMPLE                   pop1 <= pop0 -> push                                   }
{ CMPLT                   pop1 <  pop0 -> push                                   }
{ CMPNE                   pop1 != pop0 -> push                                   }
{                                                                                }
{ ÄÄÄÄÄÄÄÄ Arithmetic - unary ÄÄÄÄÄÄÄÄ                                           }
{                                                                                }
{ DEC                     (level,rvalue)--                                       }
{ INC                     (level,rvalue)++                                       }
{ NEG                     -stk0                                                  }
{ NOT                     ~stk0                                                  }
{                                                                                }
{ ÄÄÄÄÄÄÄÄ Subroutine calling ÄÄÄÄÄÄÄÄ                                           }
{                                                                                }
{ CALL    addr            push ic, addr -> ic                                    }
{ SVC     value           ic -> push, svctab[value] -> ic                        }
{                                                                                }
{                                                                                }
{ ÄÄÄÄÄÄÄÄ Jump operations ÄÄÄÄÄÄÄÄ                                              }
{                                                                                }
{ JMP     addr            addr -> ic                                             }
{ JZ      addr            pop0, if zero addr -> ic                               }
{ CJE     addr            pop0, if 0: addr -> ic                                 }
{ CJZ     addr            pop0, if 0: addr -> ic                                 }
{ CJNE    addr            pop0, if !0: addr -> ic                                }
{ CJNZ    addr            pop0, if !0: addr -> ic                                }
{                                                                                }
{ ÄÄÄÄÄÄÄÄ Stack manipulation ÄÄÄÄÄÄÄÄ                                           }
{                                                                                }
{ DUPE                    pop0 -> push, push                                     }
{ PURGE                   pop0                                                   }
{ PUSHI   value           value -> push                                          }
{ PUSHIB  byte            value -> push                                          }
{ PUSHR   level,rvalue    (level,rvalue) -> push                                 }
{ PUSHRB  level,rbyte     (level,rvalue) -> push                                 }
{ STORE   level,rvalue    pop0 -> (level,rvalue)                                 }
{ PUSHS   string          push(strrev(string)), push(strlen)                     }
{                                                                                }
{ ÄÄÄÄÄÄÄÄ Indexed Stack manipulation ÄÄÄÄÄÄÄÄ                                   }
{                                                                                }
{ PUSHAX  lvl,rvalue  pop0 + &(level,rvalue) -> push            !!               }
{                    -- Push data space address of variable     !!               }
{                                                                                }
{ PUSHX   lvl,rvalue  (pop0 + &(level,rvalue)) -> push          !!               }
{                    -- Push value of indexed variable          !!               }
{                                                                                }
{ STOREX  lvl,rvalue  pop0 -> (&(level,rvalue) + pop1)          !!               }
{                    -- Store value into indexed variable       !!               }
{                                                                                }
{ RANGE   value      No side-effect                             !!               }
{                    -- Signal error if peek0 outside of value  !!               }
{                                                                                }
{ PINCX   lvl,rvalue  ((&(level,rvalue)+pop0)++) -> push        !!               }
{                    -- Push indexed variable, post-increment   !!               }
{                                                                                }
{ PDECX   lvl,rvalue  ((&(level,rvalue)+pop0)--) -> push        !!               }
{                        -- Push indexed variable, post-decrement   !!           }
{                                                                                }
{                                                                                }
{ ÄÄÄÄÄÄÄÄ Activation housekeeping ÄÄÄÄÄÄÄÄ                                      }
{                                                                                }
{ ENTER   pc,level,len    Build AR with parms:pc, auto data:len                  }
{ ENTERB  pc,level,blen   Build AR with parms:pc, auto data:len                  }
{ INIT    value           Set display. Simulate PROC(class, addr, val) call:     }
{ LEAVE                   Restore previous AR, return                            }
{ LEAVEF                  Restore previous AR, push function result, return      }
{                                                                                }
{                                                                                }
{ ÄÄÄÄÄÄÄÄ Psuedo operations ÄÄÄÄÄÄÄÄ                                            }
{                                                                                }
{ EQU     value           Psuedo-op                                              }
{                                                                                }
{                                                                                }
{                                                                                }
{ ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ }
{                                                                                }
{         The tuple mnemonics and their opcodes - grouped by action              }
{         ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ              }
{                                                                                }
{ ÄÄÄÄÄÄÄÄ Arithmetic - binary ÄÄÄÄÄÄÄÄ                                          }
{                                                                                }
{ ADD                   pop1 + pop0 -> push                                      }
{ AND                   pop1 & pop0 -> push                                      }
{ DIV                   pop1 / pop0 -> push                                      }
{ MOD                   pop1 % pop0 -> push                                      }
{ MUL                   pop1 * pop0 -> push                                      }
{ OR                    pop1 | pop0 -> push                                      }
{ SUB                   pop1 - pop0 -> push                                      }
{ XOR                   pop1 ^ pop0 -> push                                      }
{                                                                                }
{ ÄÄÄÄÄÄÄÄ Relational test - binary ÄÄÄÄÄÄÄÄ                                     }
{                                                                                }
{ CMPEQ                 pop1 == pop0 -> push                                     }
{ CMPGE                 pop1 >= pop0 -> push                                     }
{ CMPGT                 pop1 >  pop0 -> push                                     }
{ CMPLE                 pop1 <= pop0 -> push                                     }
{ CMPLT                 pop1 <  pop0 -> push                                     }
{ CMPNE                 pop1 != pop0 -> push                                     }
{                                                                                }
{ ÄÄÄÄÄÄÄÄ Arithmetic - unary ÄÄÄÄÄÄÄÄ                                           }
{                                                                                }
{ DEC                   (level,rvalue)--                                         }
{ INC                   (level,rvalue)++                                         }
{ NEG                   -stk0                                                    }
{ NOT                   ~stk0                                                    }
{                                                                                }
{ ÄÄÄÄÄÄÄÄ Subroutine calling ÄÄÄÄÄÄÄÄ                                           }
{                                                                                }
{ CALL      addr        push nsi, addr -> ic                                     }
{ SVC       byte        ic -> push, svctab[value] -> ic                          }
{                                                                                }
{ ÄÄÄÄÄÄÄÄ Jump operations ÄÄÄÄÄÄÄÄ                                              }
{                                                                                }
{ JMP       addr        addr -> ic                                               }
{ JZ        addr        pop0, if zero addr -> ic                                 }
{ CJE       addr        pop1 - pop0, if 0: addr -> ic                            }
{ CJZ       addr        pop1 - pop0, if 0: addr -> ic                            }
{ CJNE      addr        pop1 - pop0, if !0: addr -> ic                           }
{ CJNZ      addr        pop1 - pop0, if !0: addr -> ic                           }
{                                                                                }
{                                                                                }
{ ÄÄÄÄÄÄÄÄ Stack manipulation ÄÄÄÄÄÄÄÄ                                           }
{                                                                                }
{ DUPE                  pop0 -> push, push                                       }
{ PURGE                 pop0                                                     }
{ PUSHI     value       value -> push                                            }
{ PUSHIB    byte        byte  -> push                                            }
{ PUSHR     lvl,rvalue  (level,rvalue) -> push                                   }
{ PUSHRB    lvl,rbyte   (level,rvalue) -> push                                   }
{ STORE     lvl,rvalue  pop0 -> (level,rvalue)                                   }
{ PUSHS     string      push(strrev(string)), push(strlen)                       }
{                                                                                }
{                                                                                }
{ PUSHA     lvl,rvalue  &(level,rvalue) -> push                   !!             }
{                      -- Push data space address of variable     !!             }
{                                                                                }
{ PUSHN     lvl,rvalue  ((level,rvalue)) -> push                  !!             }
{                      -- Push value of indirect variable         !!             }
{                                                                                }
{ STOREN    lvl,rvalue  (pop0) -> ((level,rvalue))                !!             }
{                      -- Store value into indirect variable      !!             }
{                                                                                }
{ ÄÄÄÄÄÄÄÄ Activation housekeeping ÄÄÄÄÄÄÄÄ                                      }
{                                                                                }
{ INIT      byte                Allocate (byte) display entries                  }
{ ENTER     byte, byte, word    Build AR: Argcount, level, autolen     !!        }
{ ENTERB    pc,level,blen       Build AR with parms:pc, auto data:len  !!        }
{ LEAVE                         Pop current AR, return                 !!        }
{ LEAVEF                        pop0 -> ic,  fvalue -> push, return    !!        }
{                                                                                }
{                                                                                }
{ ÄÄÄÄÄÄÄÄ Psuedo operations ÄÄÄÄÄÄÄÄ                                            }
{                                                                                }
{ EQU                     value           Psuedo-op                              }
{                                                                                }
{                                                                                }
{ ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ }
{                                                                                }
{         The tuple mnemonics and their opcodes - sorted by opcode               }
{         ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ              }
{                                                                                }
{ OC_INIT       INIT    01  byte        Push display of (byte) words onto stack  }
{ OC_ENTER      ENTER   02  byte, byte, word    argcount, level, autolen         }
{ OC_ENTERB     ENTERB  03  byte, byte, byte    argcount, level, autolen         }
{ OC_LEAVE      LEAVE   04              Purge current activation record, return  }
{ OC_LEAVEF     LEAVEF  05              Purge current AR, push result, return    }
{ OC_RANGE      RANGE   06  value       No side-effect                           }
{                                                                                }
{ OC_JMP        JMP     10  addr        addr -> ic                               }
{ OC_JZ         JZ      11  addr        pop0, if zero addr -> ic                 }
{ OC_CALL       CALL    12  addr        push nsi, addr -> ic                     }
{ OC_CJE        CJE     13  addr        pop1 - pop0, if 0: addr -> ic            }
{ OC_CJNE       CJNE    15  addr        pop1 - pop0, if !0: addr -> ic           }
{ OC_SVC        SVC     17  byte        ic -> push, svctab[value] -> ic          }
{                                                                                }
{ OC_PINCX      PINCX   18  lvl,rvalue  ((&(level,rvalue)+pop0)++) -> push       }
{ OC_PDECX      PDECX   19  lvl,rvalue  ((&(level,rvalue)+pop0)--) -> push       }
{                                                                                }
{ OC_ADD        ADD     20              pop1 + pop0 -> push                      }
{ OC_AND        AND     21              pop1 & pop0 -> push                      }
{ OC_DIV        DIV     22              pop1 / pop0 -> push                      }
{ OC_MOD        MOD     23              pop1 % pop0 -> push                      }
{ OC_MUL        MUL     24              pop1 * pop0 -> push                      }
{ OC_OR         OR      25              pop1 | pop0 -> push                      }
{ OC_SUB        SUB     26              pop1 - pop0 -> push                      }
{ OC_XOR        XOR     27              pop1 ^ pop0 -> push                      }
{ OC_CMPEQ      CMPEQ   28              pop1 == pop0 -> push                     }
{ OC_CMPGE      CMPGE   29              pop1 >= pop0 -> push                     }
{ OC_CMPGT      CMPGT   2A              pop1 >  pop0 -> push                     }
{ OC_CMPLE      CMPLE   2B              pop1 <= pop0 -> push                     }
{ OC_CMPLT      CMPLT   2C              pop1 <  pop0 -> push                     }
{ OC_CMPNE      CMPNE   2D              pop1 != pop0 -> push                     }
{ OC_NEG        NEG                     -stk0                                    }
{ OC_NOT        NOT     2F              ~stk0                                    }
{ OC_DUPE       DUPE    30              pop0 -> push, push                       }
{ OC_PURGE      PURGE   31              pop0                                     }
{ OC_PUSHI      PUSHI   32  value       value -> push                            }
{ OC_PUSHIB     PUSHIB  33  byte        byte  -> push  (byte extended)           }
{ OC_PUSHS      PUSHS   34  string      push(strrev(string)), push(strlen)       }
{                                                                                }
{ OC_PUSHR      PUSHR   4x  lvl,rvalue  (level,rvalue) -> push                   }
{ OC_PUSHRB     PUSHR   5x  lvl,rvalue  (level,rvalue) -> push (byte extended)   }
{ OC_STORE      STORE   6x  lvl,rvalue  pop0 -> (level,rvalue)                   }
{ OC_PUSHA      PUSHA   7x  lvl,rvalue  &(level,rvalue) -> push                  }
{ OC_PUSHN      PUSHN   8x  lvl,rvalue  ((level,rvalue)) -> push                 }
{ OC_STOREN     STOREN  9x  lvl,rvalue  (pop0) -> ((level,rvalue))               }
{ OC_DEC        DEC     Ax  lvl,rvalue  (level,rvalue)--                         }
{ OC_INC        INC     Bx  lvl,rvalue  (level,rvalue)++                         }
{ OC_PUSHAX     PUSHAX  Cx  lvl,rvalue  pop0 + &(level,rvalue) -> push           }
{ OC_PUSHX      PUSHX   Dx  lvl,rvalue  (pop0 + &(level,rvalue)) -> push         }
{ OC_STOREX     STOREX  Ex  lvl,rvalue  pop0 -> (&(level,rvalue) + pop1)         }


{***********************************************************}
{*                      Public stuff:                      *}
{***********************************************************}

Module MEngine;

{$I 'CONST.INC'}
{$I 'ASCIICON.INC'}
{$I 'OVEXT.INC'}
{$I 'ENGINE.INC'}
{$I 'MSGLOG.INC'}
{$I 'MENGINE.H'}

#define debug 3
#include <debug.inc>

VAR XDATA
  HaltFlag : byte;      { Halt engine when true. }

{***********************************************************}
{*    Opcodes follow. They are in interpretation groups    *}
{***********************************************************}
const
  OC_INIT   = $01;      { Group 7: Activation record operations }
  OC_ENTER  = $02;
  OC_ENTERB = $03;
  OC_LEAVE  = $04;
  OC_LEAVEF = $05;
  OC_RANGE  = $06;

  OC_JMP    = $10;      { Group 3: calls, jumps      }
  OC_JZ     = $11;
  OC_CALL   = $12;
  OC_CJE    = $13;
  OC_CJNE   = $15;
  OC_SVC    = $17;

  OC_PINCX  = $18;      { Group 4: Indexed inc/dec   }
  OC_PDECX  = $19;

  OC_ADD    = $20;      { Group 1: binary operations }
  OC_AND    = $21;
  OC_DIV    = $22;
  OC_MOD    = $23;
  OC_MUL    = $24;
  OC_OR     = $25;
  OC_SUB    = $26;
  OC_XOR    = $27;
  OC_CMPEQ  = $28;
  OC_CMPGE  = $29;
  OC_CMPGT  = $2A;
  OC_CMPLE  = $2B;
  OC_CMPLT  = $2C;
  OC_CMPNE  = $2D;

  OC_NEG    = $2E;      { Group 2: unary operations  }
  OC_NOT    = $2F;

  OC_DUPE   = $30;      { Group 6: Stack operations  }
  OC_PURGE  = $31;
  OC_PUSHI  = $32;
  OC_PUSHIB = $33;
  OC_PUSHS  = $34;

  OC_PUSHR  = $40;      { Group x:       operations  }
  OC_PUSHRB = $50;
  OC_STORE  = $60;
  OC_PUSHA  = $70;
  OC_PUSHN  = $80;
  OC_STOREN = $90;
  OC_DEC    = $A0;
  OC_INC    = $B0;
  OC_PUSHAX = $C0;
  OC_PUSHX  = $D0;
  OC_STOREX = $E0;

 {END_GROUPX = OC_STOREX OR $F;}  { Not an opcode. Used to select group X }
  END_GROUPX = $EF;               { Not an opcode. Used to select group X }

type
  t_stype = word;       { Define stack element type }

const                                                                 { !! }
  BinSig0 = OC_JMP;      { Binary signature byte }                    { !! }
  BinSig3 = $5A;         { Binary signature byte }                    { !! }

{*******************************************************************}
{*    Adapt this as necessary in microcode. It is the data RAM.    *}
{*                       Lou Mauget 01/08/90                       *}
{*******************************************************************}
VAR XDATA
  StackRAM : array [STACKMAX] of t_stype;       { MARC Language stack }
  sp : word;                                    { MARC Language stack pointer }

  EClass : t_class;             { Values pushed by INIT: }
  EAddr  : t_addr;
  EValue : t_value;
  DebugOpCode : byte;           { !! For debug display }
  EngineError : byte;           { !CBS global error flag }

{*******************************************************************}
{*    Adapt this as necessary in microcode. It is the code RAM.    *}
{*                       Lou Mauget 01/08/90                       *}
{*******************************************************************}
var XDATA
  CodeRAM : array [CODEMAX] of byte;
  Ic : word;            { Instruction counter }
  Ar : word;            { Scope-lexical level-display: Register }

{*******************************************}
{*           Control information           *}
{*******************************************}
var XDATA
  Enabled : byte;       { Engine enabled, load disabled iff non-zero }
  LoadIndex : word;     { Index of next code byte to load }

{*******************************************}
{*    Initialization Information    CBS    *}
{*******************************************}
var XDATA
  ConfigLoaded  : BYTE;
  ConfigSize    : WORD;
  ConfigAddr    : WORD;

{***************************************************}
{*               MakeWord ala AVPAS                *}
{*        Remove this when porting to AVPAS        *}
{*               Lou Mauget 03/08/91               *}
{***************************************************}
#if 0
function MakeWord (HighByte, LowByte : byte) : word;
begin
  MakeWord := (Word(HighByte) SHL 8) OR Word(LowByte)
end;
#endif

{*************************************************************************}
{*        Disable the engine for all but loading of MARC Language        *}
{*        configuration program.                                         *}
{*                          Lou Mauget 01/08/90                          *}
{*************************************************************************}
FUNCTION EngineDisable :  byte                             [STATIC XDATA];
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
FUNCTION EngineEnable :  byte                              [STATIC XDATA];
begin
  Enabled := 1;
  EngineEnable := OK
end;

{**********************************************************************}
{*     Query the state of the enabled flag. Zero means disabled.      *}
{*                        Lou Mauget 01/08/90                         *}
{**********************************************************************}
FUNCTION EngineQuery : byte                                [STATIC XDATA];
begin
  EngineQuery := EngineEnable
end;

{*******************************************************************}
{*         Load byte into config, increment load address.          *}
{*                       Lou Mauget 01/08/90                       *}
{*******************************************************************}
FUNCTION EngineLoadByte ( CodeByte : byte ) : byte         [STATIC XDATA];
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
FUNCTION EngineSetLoadAddr ( Address : word ) : byte       [STATIC XDATA];
begin
  EngineSetLoadAddr := 0;               { !! }
  LoadIndex := Address
end;

{-------------------------- Here is the good stuff ---------------------------}

{********************************************************************}
{*  Store value through reference. Used by intrinsics that require  *}
{*  reference parameters. Lou Mauget 03/05/91                       *}
{********************************************************************}
PROCEDURE StoreIndirect (Ref, Value : word)                [STATIC XDATA];
begin
  StackRAM [Ref] := Value;
end;

{********************************************************************}
{*  Load value through reference. Used by intrinsics that require   *}
{*  reference parameters. Lou Mauget 03/05/91                       *}
{********************************************************************}
FUNCTION LoadIndirect (Ref : word) : word                  [STATIC XDATA];
begin
  LoadIndirect := StackRAM [Ref]
end;

{***************************************************************}
{*   Report the value of the stack pointer. Only used for      *}
{*   debugging the engine or the compiler.                     *}
{*                     Lou Mauget 01/14/91                     *}
{***************************************************************}
#if 0
function Debug_Query_Sp : word      { Not needed in ROM version }
begin
  Debug_Query_Sp := Sp
end;
#endif

{***************************************************************}
{* Report an eval error. Rewrite this for the actual MARC box. *}
{*                     Lou Mauget 01/08/90                     *}
{***************************************************************}
PROCEDURE report_error(Errcode : byte)                     [STATIC XDATA];

  var
    MsgText : array[40] of BYTE;
  begin

    DebugMsg2('ESCON monitor engine: ',CONBF);
    case Errcode of
      UNDERFLOW: DebugMsg2('stack underflow',CONBF);
      OVERFLOW:  DebugMsg2('stack overflow',CONBF);
      SHOULDNOT: DebugMsg2('should not occur (but did  tee hee)',CONBF);
      UNDEFINED: DebugMsg2('undefined',CONBF);
      BADHEX:    DebugMsg2('bad Intel Hex data',CONBF);
      BOUNDS:    DebugMsg2('array range',CONBF);
      NOSVC:     DebugMsg2('no svc installed',CONBF);
      else       DebugMsg2('unknown',CONBF);
    end;
    DebugMsg2(' error.',CONBF);
    DebugMsg2('Opcode : $',CONBF);
    DebugHex2(DebugOpCode,CONBF);
    DebugMsg2(' Location $',CONBF);
    DebugWord2(ic,CONBF);
    DebugChar3(CR,CONBF);
    DebugChar3(LF,CONBF);

    EngineError := TRUE;        { !CBS set engine error flag }
    ConfigLoaded := FALSE;      { !CBS set engine loaded flag to false }
    CodeRam[0] := CodeRam[0]+1; { !Trash first byte to gen bad CRC }
    MsglogWBB(E_EngineError,IC,Errcode,DebugOpcode);

  end;


{*********************************************************************}
{* Given a lexical level (AR number) and a SIGNED offset, return the *}
{* index of the appropriate stack location.                          *}
{*                        Lou Mauget 01/09/90                        *}
{*********************************************************************}
FUNCTION GetVariableIndex (Level : byte; Offset : word) : word  [STATIC XDATA];
  begin
      GetVariableIndex := StackRAM [ Level ] + Offset
  end;

{*********************************************************************}
{* Given a lexical level (AR number) and a signed offset, return the *}
{* word from the appropriate location.                               *}
{*                        Lou Mauget 01/09/90                        *}
{*********************************************************************}
FUNCTION GetVariable (Level : byte; Offset : word) : word  [STATIC XDATA];
  begin
    GetVariable := StackRAM [GetVariableIndex(Level, Offset)]
  end;

{*********************************************************************}
{* Given a lexical level (AR number), a signed offset, and a word,   *}
{* store the word at the appropriate location.                       *}
{*                        Lou Mauget 01/09/90                        *}
{*********************************************************************}
PROCEDURE StoreVariable (Level : byte; Offset, Value : word) [STATIC XDATA];
  begin
    StackRAM [GetVariableIndex(Level, Offset)] := Value
  end;

{******************************************************************}
{*  Push the argument onto the MARC Language stack. If the stack  *}
{*  would overflow, call stack error.                             *}
{*                      Lou Mauget 01/08/90                       *}
{******************************************************************}
PROCEDURE Push (Arg : word)                                [STATIC XDATA];
  begin
    if sp >= STACKMAX then
      report_error(OVERFLOW)              { Report stack OVERFLOW  }
    else
      begin                               { Okay!                  }
        Sp := Sp + 1;                     { Allocate new location  }
        StackRAM [Sp] := Arg              { Stack the argument     }
      end
  end;

{****************************************************************}
{*  Pop the argument from the stack unless the stack is empty.  *}
{*  If empty, return 0 and set the stack pointer to  0 (clear   *}
{*  stack: good value).                                         *}
{*                     Lou Mauget 01/08/90                      *}
{****************************************************************}
FUNCTION Pop : word                                        [STATIC XDATA];
  begin
    if sp > 0 then                { Not empty stack:  }
      begin
        Pop := StackRAM [sp] ;    { Sp points to current busy location  }
        sp := sp - 1              { sp points to previous busy location }
      end
    else                          { Empty or bad stack pointer }
      begin                       { !! }
        Pop := ERROR;             { !! }
        report_error(UNDERFLOW)   { Report stack UNDERFLOW }
      end                         { !! }
  end;

{*************************************************************************}
{*        Fetch an opcode. Report wild branch if ic out of range.        *}
{*        Does not change Ic.                                            *}
{*                Lou Mauget 01/08/90                                    *}
{*************************************************************************}
FUNCTION Fetch : byte                                      [STATIC XDATA];
  begin
    Fetch := CodeRAM [Ic];
  end;

{*************************************************************************}
{*        Fetch operand word 1                                           *}
{*        Does not change Ic.                                            *}
{*                Lou Mauget 01/08/90                                    *}
{*************************************************************************}
FUNCTION OpWord1 : word                                    [STATIC XDATA];
  begin
    OpWord1 := MakeWord( CodeRAM [Ic + 1], CodeRAM [Ic + 2] )  { !! }
  end;

{*************************************************************************}
{*        Fetch operand word at instruction offset 2                     *}
{*        Does not change Ic.                                            *}
{*                Lou Mauget 03/07/91                              !!    *}
{*************************************************************************}
FUNCTION OpWord2 : word                                    [STATIC XDATA];
  begin
    OpWord2 := MakeWord ( CodeRAM [Ic + 2], CodeRAM [Ic + 3] )    { !! }
  end;                                                            { !! }

{*************************************************************************}
{*        Fetch operand byte 1                                           *}
{*        Does not change Ic.                                            *}
{*                Lou Mauget 01/08/90                                    *}
{*************************************************************************}
FUNCTION OpByte1 : word                                    [STATIC XDATA];
  begin
    OpByte1 := CodeRAM [Ic + 1];
  end;

{*************************************************************************}
{*        Fetch operand byte 2                                           *}
{*        Does not change Ic.                                            *}
{*                Lou Mauget 01/08/90                                    *}
{*************************************************************************}
FUNCTION OpByte2 : word                                    [STATIC XDATA];
  begin
    OpByte2 := CodeRAM [Ic + 2];
  end;

{-------------------- Instruction interpretation groups -----------------}

{**************************************************************}
{*   Group 1: Binary operations                               *}
{*                                                            *}
{*       ADD    20  pop1 + pop0 -> push      1                *}
{*       AND    21  pop1 & pop0 -> push      1                *}
{*       DIV    22  pop1 / pop0 -> push      1                *}
{*       MOD    23  pop1 % pop0 -> push      1                *}
{*       MUL    24  pop1 * pop0 -> push      1                *}
{*       OR     25  pop1 | pop0 -> push      1                *}
{*       SUB    26  pop1 - pop0 -> push      1                *}
{*       XOR    27  pop1 ^ pop0 -> push      1                *}
{*       CMPEQ  28  pop1 == pop0 -> push     1                *}
{*       CMPGE  29  pop1 >= pop0 -> push     1                *}
{*       CMPGT  2A  pop1 >  pop0 -> push     1                *}
{*       CMPLE  2B  pop1 <= pop0 -> push     1                *}
{*       CMPLT  2C  pop1 <  pop0 -> push     1                *}
{*       CMPNE  2D  pop1 != pop0 -> push     1                *}
{*                                                            *}
{*             Louis E. Mauget 01/08/90, 03/10/91             *}
{**************************************************************}
FUNCTION DoGroup1 ( opcode : byte) : byte                  [STATIC XDATA];
  var
    op0, op1, result : word;

  begin
    DoGroup1 := ERROR;  { !! }
    op0 := pop;         { Get operands from stack. op0 must be 1st pop. }
    op1 := pop;         { op1 must be second pop  }

    case opcode of      { Perform proper instruction }
      OC_ADD  : result := op1 +   op0;                   { +  }
      OC_SUB  : result := op1 -   op0;                   { -  }
      OC_CMPEQ: result := (op1 =  op0);      { =  }
      OC_CMPNE: result := (op1 <> op0);      { <> }
      OC_CMPGE: result := SignW(op1,GE,op0);     { >= }
      OC_CMPGT: result := SignW(op1,GT,op0);     { >  }
      OC_CMPLE: result := SignW(op1,LE,op0);     { >= }
      OC_CMPLT: result := SignW(op1,LT,op0);     { <  }
      OC_AND  : result := op1 AND op0;                   { &  }
      OC_DIV  : result := op1 DIV op0;                   { /  }
      OC_MOD  : result := op1 MOD op0;                   { %  }
      OC_MUL  : result := op1 *   op0;                   { *  }
      OC_OR   : result := op1 OR  op0;                   { |  }
      OC_XOR  : result := op1 XOR op0;                   { ^  }
      else
        report_error ( UNDEFINED )
    end;
    push (result);              { Stack the result }
    Ic := Ic + 1;               { All are 1 byte instructions }
    DoGroup1 := OK
  end;

{**************************************************************}
{*   Group X: Memory operations                               *}
{*                                                            *}
{*       PUSHR  40  (level,rvalue) -> push       3         !! *}
{*       PUSHRB 50  (level,rvalue) -> push       2  ++     !! *}
{*       STORE  60  pop0 -> (level,rvalue)       3            *}
{*       PUSHA  70  lvl,rvalue                   3         !! *}
{*       PUSHN  80  lvl,rvalue                   3         !! *}
{*       STOREN 90  lvl,rvalue                   3         !! *}
{*       DEC    A0  (level,rvalue)--             3         !! *}
{*       INC    B0  (level,rvalue)++             3         !! *}
{*       PUSHAX C0                               3            *}
{*       PUSHX  D0                               3            *}
{*       STOREX E0                               3            *}
{*                                                            *}
{*                                                            *}
{*             Louis E. Mauget 01/08/90, 03/10/91             *}
{**************************************************************}
FUNCTION DoGroupX ( opcode : byte) : byte                  [STATIC XDATA];
  var
    Work  : word;
    Index : word;
    Level : byte;
    Valueb: byte;
  begin

    DoGroupX := ERROR;  { !! }
    Level := opcode AND $0F;            { Extract lexical level }

    case opcode AND $F0 of

      OC_PUSHRB:        { A PUSHR with value byte to be extended to word }
        begin
          Valueb := OpByte1;
          if (Valueb AND $80) <> 0 then       { Considered negatory? }
            Work := MakeWord( $FF, Valueb )   { Sign-extend to word  }
          else
            Work := MakeWord( $00, Valueb );  { Sign-extend to word  }
          Push( GetVariable (Level, Work));   { As in PUSHR          }
          ic := ic - 1;                       { Shorten instruction  }
        end;

      OC_PUSHR :
          Push( GetVariable (Level, OpWord1) ); { !! }

      OC_STORE :
          StoreVariable (Level, OpWord1, Pop);  { !! }

      OC_DEC:
        begin
          Index := GetVariableIndex (Level, OpWord1);  { !! }
          StackRAM [Index] := StackRAM [Index] - 1;
        end;

      OC_INC:
        begin
          Index := GetVariableIndex (Level, OpWord1);  { !! }
          StackRAM [Index] := StackRAM [Index] + 1;
        end;

      {***********************************************************************}
      {* PUSHA   7/lvl  ,rvalue  &(level,rvalue) -> push                   !!*}
      {*                         -- Push data space address of variable    !!*}
      {***********************************************************************}
      OC_PUSHA  :  { !! }
          Push( GetVariableIndex (Level, OpWord1) );  { !! }

      {***********************************************************************}
      {* PUSHN   8/lvl   rvalue  ((level,rvalue)) -> push                  !!*}
      {*                         -- Push value of indirect variable        !!*}
      {***********************************************************************}
      OC_PUSHN  :  { !! }
          Push( StackRAM [GetVariable(Level, OpWord1)] );  { !! }

      {***********************************************************************}
      {* STOREN  9/lvl   rvalue  (pop0) -> ((level,rvalue))                !!*}
      {*                         -- Store value into indirect variable     !!*}
      {***********************************************************************}
      OC_STOREN :  { !! }
        begin
          work := Pop;  { Pop0 }
          StackRAM [GetVariable(Level, OpWord1)] := work;  { !! }
        end;

      {***********************************************************************}
      {* PUSHAX  C/lvl   rvalue  pop0 + &(level,rvalue) -> push            !!*}
      {*                        -- Push data space address of variable     !!*}
      {***********************************************************************}
      OC_PUSHAX :  { !! }
          Push ( Pop + GetVariableIndex (Level, OpWord1) );  { !! }

      {***********************************************************************}
      {* PUSHX   D/lvl   rvalue  (pop0 + &(level,rvalue)) -> push          !!*}
      {*                         -- Push value of indexed variable         !!*}
      {***********************************************************************}
      OC_PUSHX  :  { !! }
          Push ( StackRAM [Pop + GetVariableIndex (Level, OpWord1)] ); { !! }

      {***********************************************************************}
      {* STOREX  E/lvl   rvalue  pop0 -> (&(level,rvalue) + pop1)          !!*}
      {*                         -- Store value into indexed variable      !!*}
      {***********************************************************************}
      OC_STOREX :  { !! }
        begin
          work := Pop;  { Pop0 }
          StackRAM [Pop + GetVariableIndex (Level, OpWord1)] := work; { !! }
        end;

      else
        report_error( UNDEFINED )

    end;
    Ic := Ic + 3;
    DoGroupX := OK
  end;


{***********************************************************}
{*                                                         *}
{*   Group 2: Unary operations                             *}
{*                                                         *}
{*       NEG_       -stk0                    1             *}
{*       NOT    2F  ~stk0                    1             *}
{*                                                         *}
{*           Louis E. Mauget 01/08/90, 03/10/91            *}
{***********************************************************}
FUNCTION DoGroup2 ( opcode : byte) : byte                  [STATIC XDATA];
  var
    Index : word;
  begin

    DoGroup2 := ERROR;  { !! }

    case opcode of

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
        report_error( UNDEFINED )
    end;
    DoGroup2 := OK
  end;

{***********************************************************}
{*                                                         *}
{*   Group 3: Proc/func calls                              *}
{*                                                         *}
{*       CALL   12  push Ic, addr -> Ic               3    *}
{*       CJE    13  pop1 - pop0, if 0: addr -> Ic     3    *}
{*       CJNE   15  pop1 - pop0, if !0: addr -> Ic    3    *}
{*       JMP    10  addr -> Ic                        3    *}
{*       JZ     11  pop0, if zero addr -> Ic          3    *}
{*       SVC    17  Ic -> push, svctab[value] -> Ic   2    *}
{*                                                         *}
{*                  Louis E. Mauget 01/08/90               *}
{***********************************************************}
FUNCTION DoGroup3 ( opcode : byte) : byte                  [STATIC XDATA];
  begin
    DoGroup3 := ERROR;             { !! }

    case opcode of

      OC_JMP : Ic := OpWord1;

      OC_JZ  : if pop = 0 then Ic := OpWord1 else Ic := Ic + 3;

      OC_CJE : if (pop - pop) =  0 then Ic := OpWord1 else Ic := Ic + 3;

      OC_CJNE: if (pop - pop) <> 0 then Ic := OpWord1 else Ic := Ic + 3;

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

        report_error( UNDEFINED );

    end;

    DoGroup3 := OK
  end;

{***********************************************************}
{*                                                         *}
{*   Group 4: Indexed increment / decrement operations     *}
{*                                                         *}
{*    These are rare, so they trade length back to         *}
{*    other lvl,value opcodes.                             *}
{*                                                         *}
{*       PINCX  17  lvl, value                   4         *}
{*       PDECX  18  lvl, value                   4         *}
{*                                                         *}
{*                Louis E. Mauget 03/10/91                 *}
{***********************************************************}
FUNCTION DoGroup4 ( opcode : byte) : byte                  [STATIC XDATA];
  var
    work : word;
  begin

    DoGroup4 := ERROR;  { !! }

    { Common code }
    work := Pop + GetVariableIndex (OpByte1, OpWord2); { Index !! }
    Push ( StackRAM [work] );

    case opcode of

      {***********************************************************************}
      {* PINCX   17 lvl, rvalue  ((&(level,rvalue)+pop0)+1) -> push        !!*}
      {*                        -- Push indexed variable, post-increment   !!*}
      {***********************************************************************}
      OC_PINCX  :  { !! }
          StackRAM [work] := StackRAM [work] + 1;  { Post-inc }

      {***********************************************************************}
      {* PDECX   18 lvl, rvalue  ((&(level,rvalue)+pop0)-1) -> push        !!*}
      {*                        -- Push indexed variable, post-decrement   !!*}
      {***********************************************************************}
      OC_PDECX  :  { !! }
          StackRAM [work] := StackRAM [work] - 1; { Post-dec }

      else
        report_error( UNDEFINED )
    end;

    Ic := Ic + 4;
    DoGroup4 := OK
  end;


{***********************************************************}
{*                                                         *}
{*   Group 6: Stack operations                             *}
{*                                                         *}
{*       DUPE   30  pop0 -> push, push           1         *}
{*       PURGE  31  pop0                         1         *}
{*       PUSHI  32  value -> push                3         *}
{*       PUSHIB 33  byte  -> push                2         *}
{*       PUSHS  34  string                       strlen+2  *}
{*                                                         *}
{*           Louis E. Mauget 01/08/90, 03/10/91            *}
{***********************************************************}
FUNCTION DoGroup6 ( opcode : byte) : byte                  [STATIC XDATA];
  var
    work, s : word;
    len, i , limit: byte;
  begin
    DoGroup6 := ERROR;     { !! }

    case opcode of

      OC_DUPE  : begin
                   work := Pop;
                   Push(work);
                   Push(work);
                   Ic := Ic + 1
                 end;

      OC_PURGE : begin work := Pop;    Ic := Ic + 1 end;

      OC_PUSHI : begin Push (OpWord1); Ic := Ic + 3 end;

      OC_PUSHIB:
        begin
          i := OpByte1;
          if (i AND $80) <> 0 then            { Considered negatory?    }
            Push (makeword($ff, i))           { Push sign-extended word }
          else
            Push (makeword($00, i));          { Push sign-extended word }
          Ic := Ic + 2;
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
              Push( MakeWord( CodeRAM [ s ], CodeRAM [ s + 1 ] ));
              s := s - 2;
            end;
          ic := ic + len + 2;
        end;

      else
        report_error( UNDEFINED )
      end;

    DoGroup6 := OK
  end;

{***********************************************************}
{*                                                         *}
{*   Group 7: Activation record operations                 *}
{*                                                         *}
{*       INIT   01  Allocate (byte) display entries     2  *}
{*       ENTER  02  Build AR: Argcount, level, autolen  4  *}
{*       ENTERB 03  Build AR: Argcount, level, autolen  3  *}
{*       LEAVE  04  Pop current AR, return              1  *}
{*       LEAVEF 05  Pop current AR, push result, return 1  *}
{*       RANGE  06  value       No side-effect          3  *}
{*                                                         *}
{* Lexical scoping levels are kept in displays that are    *}  { !! }
{* allocated by the INIT operation.  The compiler tracks   *}  { !! }
{* the maximum lexical scope.  It compiles the INIT        *}  { !! }
{* operand to allocate the correct number of displays.     *}  { !! }
{* The INIT also pushes the event parameters as if it      *}  { !! }
{* were called.                                            *}  { !! }
{*                                                         *}  { !! }
{* The ENTER and LEAVE operations manage these scopes by   *}  { !! }
{* static (lexical nesting) and dynamic (call-sequence)    *}  { !! }
{* links of dynamically built scope activation records.    *}  { !! }
{*                                                         *}  { !! }
{* The LEAVE operations have been extended to perform the  *}  { !! }
{* return operation to save ECL code space and             *}  { !! }
{* interpretation.                                         *}  { !! }
{*                                                         *}
{* The activation record:                                  *}
{*   0: Caller's return                                    *}
{*   1: Dynamic AR link            DYNAR                   *}
{*   2: Static AR link             STATAR                  *}
{*   3: AR level                   LEXLV                   *}
{*   4: Parm purge count           PCOUNT                  *}
{*   5: FUNCTION return !!         FVALUE                  *}
{*   6: ... automatic variables                            *}
{*                                                         *}
{*           Louis E. Mauget 01/08/90, 03/05/91            *}
{***********************************************************}
FUNCTION DoGroup7 ( opcode : byte) : byte                  [STATIC XDATA];
  const                            { AR header offsets: }
    DYNAR = 1; STATAR = 2; LEXLV = 3; PCOUNT = 4; FVALUE = 5; { !! }
    INVALID_AR = $FFFF;            { !! }
  var
    OldAr , RetAddr : word;
    Level , ParmCount, i :byte;
    FuncRet : word;                { !! }
  begin
    DoGroup7 := ERROR;             { !! }
    case opcode of

      OC_INIT :                    { Allocate lexical display            }
        begin
          Ar := INVALID_AR;        { Ar is invalid: peg its value   !!   }
          Level := OpByte1;        { Get maximum nesting level           }
          StackRAM [0] := Ar;      { Plug Ar into level 0 display        }
          while level <> 0  do     { For each additional level do:       }
            begin
              Push (INVALID_AR);   { ...allocate one scope display entry !! }
              level := level - 1;
            end;
          Push (EClass);           { Pass calling parms to MARC program  }
          Push (EAddr);
          Push (EValue);
          Push (DUMMYRET);         { Placeholder for return              }
          Ic := Ic + 2             { Instruction length is 2             }
        end;

      OC_ENTERB,
      OC_ENTER:
        begin
                                { Unpack the operands:             }
          ParmCount := OpByte1;         { Packed count, level      }
          Level := ParmCount AND $F;    { Level is low nybble      }
          ParmCount := SHRV(ParmCount,4); { ParmCount is high nybble }
                                { Build activation record:         }
                                { Numbers are new AR offsets       }
          OldAr := Ar;
                                        { Assign new Activation Record  }
          Ar := Sp;                     { 0: Caller's return (here now) }
          Push (OldAr);                 { 1: Dynamic AR link     DYNAR  }
          Push (StackRAM [Level]);      { 2: Static AR link      STATAR }
          Push (Level);                 { 3: AR level            LEXLV  }
          Push (ParmCount);             { 4: Parm purge count    PCOUNT }
          Push ($FFFF);                 { 5: Function return !!  FVALUE }
          if opcode = OC_ENTER then
            begin
              Sp := Sp + OpWord2;       { 6: Allocate automatics   !!   }
              Ic := Ic + 4  { !! }
            end
          else                          { Must be ENTERB !! }
            begin
              Sp := Sp + OpByte2;       { 6: Allocated automatics  !!   }
              Ic := Ic + 3  { !! }
            end;
          StackRAM [Level] := Ar;       { Set current display at level  }

        end;

      OC_LEAVE,         { !! }
      OC_LEAVEF:        { !! }
        begin

          #if DUMP
            DumpStack( tstack(StackRAM), Sp);  { Dump Sp words of stack !!}
          #endif

          Level := StackRAM [ Ar + LEXLV ];       { Get our level number     }
                                                  { Restore display level    }
          StackRAM [Level] := StackRAM [ Ar + STATAR]; { Caller's display    }
          ParmCount := StackRAM [ Ar + PCOUNT ];  { Save purge count         }
          FuncRet := StackRAM [ Ar + FVALUE ];    { Save func return     !!  }
          Sp := Ar;                               { Purge the Ar             }
          Ar := StackRAM [ Ar + DYNAR ];          { Restore previous AR      }
          Ic := Pop;                              { Return addr becomes IC !!}
          Sp := Sp - ParmCount;                   { Purge the parms          }
          if opcode = OC_LEAVEF then              { Function return?      !! }
            Push(FuncRet);                        { Push return value     !! }
        end;

      {***********************************************************************}
      {* RANGE   06  value      No side-effect                             !!*}
      {*                        -- Signal error if peek0 outside of value  !!*}
      {***********************************************************************}
      OC_RANGE :   { !! }
        begin
          if  StackRAM [sp] >= OpWord1 then    { Bounds check }
            report_error( BOUNDS );
          Ic := Ic + 3
        end;

      else
        report_error( UNDEFINED )
    end;
    DoGroup7 := OK
  end;


{---------------- End instruction interpretation groups -----------------}

{*******************************************************************}
{*      This driver interprets one MARC Language instruction       *}
{*                       Lou Mauget 01/08/90                       *}
{*******************************************************************}
FUNCTION ICycle : byte                                     [STATIC XDATA];
  var
    opcode : byte;      { Current opcode under Ic }
  begin

    {**********************************}
    {*  Check for halt condition  !!  *}
    {**********************************}
    ICycle := 0;                                                 { !! }
    If Ic = DUMMYRET then      { Handle end-of-event }           { !! }
      begin                                                      { !! }
        HaltFlag := TRUE ;                                       { !! }
        ICycle := 255  ;  { Make this a symbolic something }     { !! }
      end                                                        { !! }
    else

      begin

        {********************}
        {* Fetch the opcode *}
        {********************}
        opcode := Fetch;
        DebugOpCode := opcode;  { !! for debugging tracks}

#if TRACE
        {***********************************}
        {*             Trace:              *}
        {***********************************}
        Writeln('Loc: ', Word2HexAscii(Ic),' Op: ',Byte2HexAscii(DebugOpCode) );
#endif

        {*****************************************************************}
        {* Classify the opcode, dispatch proper opcode class interpreter *}
        {*****************************************************************}

        if      (opcode >= OC_PUSHR) AND (opcode <= END_GROUPX )  then
          ICycle := DoGroupX ( opcode)
        else if (opcode >= OC_ADD  ) AND (opcode <= OC_CMPNE   )  then
          ICycle := DoGroup1 ( opcode)
        else if (opcode >= OC_JMP  ) AND (opcode <= OC_SVC     )  then
          ICycle := DoGroup3 ( opcode)
        else if (opcode >= OC_NEG  ) AND (opcode <= OC_NOT     )  then
          ICycle := DoGroup2 ( opcode)
        else if (opcode >= OC_INIT ) AND (opcode <= OC_RANGE   )  then
          ICycle := DoGroup7 ( opcode)
        else if (opcode >= OC_DUPE ) AND (opcode <= OC_PUSHS   )  then
          ICycle := DoGroup6 ( opcode)
        else if (opcode >= OC_PINCX) AND (opcode <= OC_PDECX   )  then
          ICycle := DoGroup4 ( opcode)
        else
            report_error( UNDEFINED )
      end
  end;

{***********************************************************}         { !! }
{*       Return the validity of code-space signature       *}         { !! }
{*                Louis E. Mauget 03/05/91             !!  *}         { !! }
{***********************************************************}         { !! }
FUNCTION GoodSignature : byte                              [STATIC XDATA];
begin                                                                 { !! }
  GoodSignature := (CodeRAM[0] = BinSig0) AND (CodeRAM[3] = BinSig3); { !! }
end;                                                                  { !! }

{*****************************************************************************}
{*        Pass the event parameters to the MARC configuration through        *}
{*        the engine.                                                        *}
{*                            Lou Mauget 01/08/90                            *}
{*****************************************************************************}
FUNCTION Engine (Class : t_class; Adr : t_addr;  Value : t_value) : byte [STATIC XDATA];
  begin

    Engine := ERROR ;               { Assume the worst. !! }

    if GoodSignature = 0 then                   { !! }
      DebugMsg3('Bad image - not executable.',CONBF)   { !! }
    else                                        { !! }

      begin                                     { !! }
                    { 01/14/91 Added LEM. Moved from init code }
        sp := 0;                    { One entry on the stack: display 0 }

        Ic := 0;                    { Always enter at MARC Lang location 0 }

        EClass := Class;            { Remember paramters for INIT instruction }
        EAddr  := Adr;
        EValue := Value;
        HaltFlag := FALSE;
        EngineError := FALSE;       { !CBS Set error flag to false }

        while (ICycle = 0) and (EngineError=FALSE) do ;  { !CBS Execute }

        If HaltFlag then
          begin
            DebugMsg3('Normal end of event.',CONBF);
          end;

        Engine := OK;               { Say we did the event }

#if DUMP
        DumpStack( tstack(StackRAM), Sp);  { Dump Sp words of stack !!}
#endif

      end                                       { !! }
  end;

{-------------------------- End of the good stuff ---------------------------}
PROCEDURE InitEngine                                       [STATIC XDATA];
var
  i : word;
  rc : byte;

begin

  {*****************************************}
  {*       Initialize some variables       *}
  {*****************************************}
  rc := EngineDisable;  { Engine disabled for all but loading }

  {*****************************************}
  {*               Clear RAM               *}
  {*****************************************}
  { Note: in real MARC box, DO NOT CLEAR THE STACK. The global }
  { variables should live across event calls.                  }
  for i := 0 to STACKMAX do StackRAM[i] := 0;  { 0 origin }
{ for i := 0 to CODEMAX  do CodeRAM[i]  := 0; }{ 0 origin }

  {***************************************************}
  {* Check to see if config program is loaded.  CBS  *}
  {***************************************************}
  ConfigAddr := addr(CodeRam);

  {***************************************************}
  {* Does Config size appear reasonable size ?  CBS  *}
  {***************************************************}
  IF ConfigSize < CODEMAX THEN

    BEGIN
      IF CrcCheck(EXT,ConfigAddr,ConfigSize+2) THEN
        ConfigLoaded := TRUE
      ELSE
        ConfigLoaded := FALSE;
    END

  ELSE

    ConfigLoaded := FALSE;  { config size too big, don't waste time crcing }

  EngineError := FALSE;     { !CBS set engine error flag to false }

  #if 0
  IF ConfigLoaded = TRUE THEN
    BEGIN
       rc := engine(InitClass,0,0);
    END;
  #endif
end;
end.

