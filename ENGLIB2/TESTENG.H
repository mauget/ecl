{*---------------------------*}
{* External Declares         *}
{*---------------------------*}
PROCEDURE Device(arg:BYTE)                                 [STATIC ov0  ]; EXTERNAL;
FUNCTION  Dload(target:Word; dev:BYTE; VARX len:WORD):BYTE [STATIC XDATA]; EXTERNAL;
PROCEDURE Dump(area:BYTE; adr:WORD; lines:BYTE)            [STATIC ov3  ]; EXTERNAL;
FUNCTION  Engine (Class : t_class; Adr : t_addr;  Value : t_value) : byte  [STATIC XDATA]; EXTERNAL;
PROCEDURE Exit                                             [STATIC XDATA]; EXTERNAL;
FUNCTION  GetChar:BYTE                                     [STATIC ov1  ]; EXTERNAL;
PROCEDURE InitEngine                                       [STATIC XDATA]; EXTERNAL;
PROCEDURE InitIIC                                          [STATIC XDATA]; EXTERNAL;
PROCEDURE InitSerialInt(baud : BYTE)                       [STATIC ov0  ]; EXTERNAL;
PROCEDURE Newline                                          [STATIC XDATA]; EXTERNAL;
PROCEDURE PrtHex(arg: BYTE)                                [STATIC ov2  ]; EXTERNAL;
PROCEDURE PrtHexW(arg: WORD)                               [STATIC ov3  ]; EXTERNAL;
PROCEDURE PrtMsg(VARC str:ARRAY[0] OF BYTE)                [STATIC ov2  ]; EXTERNAL;
PROCEDURE PrtMsgNL(VARC str:ARRAY[0] OF BYTE)              [STATIC ov2  ]; EXTERNAL;
PROCEDURE SwToM552                                         [STATIC XDATA]; EXTERNAL;
PROCEDURE XpntAllClr                                       [STATIC XDATA]; EXTERNAL;
