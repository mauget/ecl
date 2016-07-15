
.mod.obj:
        cl -P $*.mod
        genh $*.i
        avpas51 $< -se
        avm51 $*.asm nome noli
        erase $*.asm
        erase $*.prn
        erase $*.lst

.pas.obj:
        cl -P $*.pas
        genh $*.i
        avpas51 $< -se
        avm51 $*.asm nome noli
        erase $*.asm
        erase $*.prn
        erase $*.lst

engine.hex: mengine.obj mintrins.obj msvc.obj testeng.obj
        avlink @testeng.lnk
        re u1 t27512 ltesteng.hex
