include macros2.asm
include number.asm

.MODEL SMALL
.386
.STACK 200h

.DATA
NEW_LINE DB 0AH,0DH,'$'
CWprevio DW ?
_0 dd ?
a1 dd ?
a2 dd ?
a3 dd ?
l1 dd ?
l2 dd ?
l3 dd ?
r1 dd ?
p1 dd ?
J3 dd ?
k4 dd ?
var1 dd ?
var2 dd ?
var3 dd ?
str1 dd ?
str2 dd ?
_5 dd ?
_"hola" dd ?
_1 dd ?
_4 dd ?
_8 dd ?
_3 dd ?
_2 dd ?
 dd ?

.CODE

MOV AX, @DATA
MOV DS, AX
FINIT






FXCH
FCOMP
FSTSW AX
SAHF
JNE 