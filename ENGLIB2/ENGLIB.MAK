.mod.obj:
        cl -P $*.mod
        genh $*.i
        avpas51 $*.i -se
        avm51 $*.asm nome noli
        erase $*.i
        erase $*.h
        erase $*.asm
        erase $*.prn
        erase $*.lst



OBJECTS1 =MENGINE.OBJ      \
          MINTRINS.OBJ     \
          TIMEINTR.OBJ     \
          MSVC.OBJ


$(MARCPATH)\englib.lib: $(OBJECTS1)
            erase $(MARCPATH)\englib.lib
            avlib @englib.fil

