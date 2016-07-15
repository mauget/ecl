
PROGRAM TestEngMod;


{$I 'asciicon.INC'}
{$I 'CONST.INC'}
{$I 'VAR.INC'}
{$I 'OVERLAY.INC'}
{$I 'SERIAL.INC'}
{$I 'TESTENG.H'}
   var xdata
       rc :  byte;
       i  :  byte;
       l : WORD;
       configaddr : EXTERNAL WORD;
{--------------------------------------------------------------------------}
{ Main Program                                                             }
{--------------------------------------------------------------------------}
Begin

  InitSerialInt(B9600);
  device(CONBF);
  InitIIC;
  XpntAllClr;
  SwToM552;
  prtmsgnl('start test engine');
  InitEngine;
  prtmsgnl('down load a file');
  rc := dload(configaddr);
  prtmsg('rc = ');
  prthex(rc);
  newline;
  prtmsg('len = ');
  prthexw(l);
  newline;

  dump(EXT,configaddr,10);
  device(CONBF);

  prtmsgnl('start');
  prtmsgnl('press key');
  i := getchar;

  for i := 1 to 1    do begin
    rc := engine("A",1234,56);
  end; {endfor}

  device(CONBF);
  prtmsgnl('stop!');


{ prtmsg('engine rc = ');    }
{ prthex(rc);                }
{ newline;                   }
  exit;


END.
