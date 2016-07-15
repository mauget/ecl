{*---------------------------*}
{* External Declares         *}
{*---------------------------*}
FUNCTION  CrcCheck(area:byte; adr,len:word): BYTE          [STATIC XDATA]; EXTERNAL;
PROCEDURE Exit                                             [STATIC XDATA]; EXTERNAL;
FUNCTION  Len(VARX str: zstring;index:BYTE): BYTE          [STATIC ov0  ]; EXTERNAL;
PROCEDURE Newline                                          [STATIC XDATA]; EXTERNAL;
PROCEDURE PerformSvc (SvcNo : byte)                        [STATIC XDATA]; EXTERNAL;
PROCEDURE PrtHex(arg: BYTE)                                [STATIC ov2  ]; EXTERNAL;
PROCEDURE PrtMsg(VARC str:ARRAY[0] OF BYTE)                [STATIC ov2  ]; EXTERNAL;
PROCEDURE PrtMsgNL(VARC str:ARRAY[0] OF BYTE)              [STATIC ov2  ]; EXTERNAL;
FUNCTION  SignW(op1:word; operator:byte; op0:word) : word  [STATIC XDATA]; EXTERNAL;
