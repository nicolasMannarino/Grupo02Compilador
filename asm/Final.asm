include macros2.asm
include number.asm

.MODEL SMALL
.386
.STACK 200h

.DATA
NEW_LINE DB 0AH,0DH,'$'
CWprevio DW ?
_0 dd ?
var1 dd ?
var2 dd ?
var3 dd ?
a1 dd ?
a2 dd ?
a3 dd ?
_5 dd 5
_2 dd 2
 dd ?

.CODE

MOV AX, @DATA
MOV DS, AX
FINIT

FLD _5
FSTP var1
FLD _5
FSTP var2
FLD _5
FSTP var3
FLD a1
FLD a2
FXCH
FCOMP
FSTSW AX
SAHF
JBE SALTO1015
FLD _2
FSTP a1
FLD _2
FSTP a2
SALTO1015:
END_IF:

MOV AH, 1
INT 21h
MOV AX, 4C00h
INT 21h

END
