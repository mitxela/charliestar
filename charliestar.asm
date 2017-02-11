.include "tn9def.inc"


lds r16, 0x0040
inc r16
andi r16,0b0000_0011
sts 0x0040, r16
cpi r16, 0
brne dontsleep

clr r16
sts 0x0040, r16

out DDRB,r16
ldi r16, 1<<SM1 | 1<< SE
out SMCR, r16
ldi r16, 1<<PRTIM0
out PRR,r16
ldi r16, 1<<ACD
out ACSR,r16

sleep




dontsleep:
cpi r16, 1
breq glowring

sbrs r16, 0
rjmp morse

rjmp sparkle




glowring:
  ldi ZL,  low(0x4000+data*2)
  ldi ZH, high(0x4000+data*2)

gmain:

  ldi r16, 0b0000_0101
  ldi r17, 0b0000_0001
  rcall pwm

  ldi r16, 0b0000_0101
  ldi r17, 0b0000_0100
  rcall pwm


  ldi r16, 0b0000_0011
  ldi r17, 0b0000_0010
  rcall pwm

  ldi r16, 0b0000_0011
  ldi r17, 0b0000_0001
  rcall pwm



  ldi r16, 0b0000_0110
  ldi r17, 0b0000_0100
  rcall pwm

  ldi r16, 0b0000_0110
  ldi r17, 0b0000_0010
  rcall pwm



  inc ZL


rjmp gmain







pwm:
  out DDRB, r16
  out PORTB, r17

  subi ZL, 43
  ld r18, Z
  clr r19
pwm_1:
  inc r19
  cpse r18,r19
  rjmp pwm_1

  clr r18
  out PORTB,r18
pwm_2:
  inc r19
  cpse r18,r19
  rjmp pwm_2

  ret



morse:
  clr r25

readmessage:
  ldi ZL,  low(0x4000+message*2)
  ldi ZH, high(0x4000+message*2)
  add ZL, r25
  ld r19, Z
  cpi r19,0
  breq morse
  
  inc r25
  cpi r19, ' '
  brne loadChar
  rcall wordSpace
  rjmp readmessage

loadChar:

  mov ZL, r19
  subi ZL, 'a' 
  lsl ZL
  lsl ZL
  subi ZL, - low(0x4000+charset*2)
flashLoop:
  ld r19, Z+
  sbrs r19, 0 ;skip if dot
  rcall dash
  
  rcall dot

  sbrs r19, 7 ;end of character
  rjmp flashLoop
  
  rcall charSpace
  rjmp readmessage  
  





dash:
  rcall allon
  rcall allon
  ret

dot:
  rcall allon
  rcall alloff
  ret


charSpace:
  rcall alloff
  rcall alloff
  ret

wordSpace:
  rcall charSpace
  rcall charSpace
  ret

alloff:
  ldi r18,25 *6
alloff1:
  clr r16
  clr r17
  rcall wait2
  dec r18
  brne alloff1
  ret

allon:
  ldi r18,25
allon1:
  ldi r16, 0b0000_0110
  ldi r17, 0b0000_0010
  rcall wait2

  ldi r16, 0b0000_0101
  ldi r17, 0b0000_0100
  rcall wait2

  ldi r16, 0b0000_0011
  ldi r17, 0b0000_0010
  rcall wait2

  ldi r16, 0b0000_0110
  ldi r17, 0b0000_0100
  rcall wait2

  ldi r16, 0b0000_0101
  ldi r17, 0b0000_0001
  rcall wait2

  ldi r16, 0b0000_0011
  ldi r17, 0b0000_0001
  rcall wait2

  dec r18
  brne allon1
  ret


wait2:
  out DDRB, r16
  out PORTB, r17
  clr r16
wait_1:
  dec r16
  brne wait_1
  ret






lfsr:
    ror r24 
    mov r24, r23
    mov r23, r22
    mov r22, r21
 
    mov r20,r24
    rol r20

    rol r21
    eor r20, r21

    ror r24
    ror r23
    ror r22
    rol r20
    mov r21,r20
    ret


sparkle:

ldi r20, 55
ldi r21, 11
ldi r22, 22
ldi r23, 33
ldi r24, 44


sparklemain:
  rcall lfsr
  mov r19,r20
  rcall lfsr
  mov r25,r20
  rcall lfsr

  ;ldi r25,250
hold:

  ldi r16, 0b0000_0110
  ldi r17, 0b0000_0010

  sbrc r19,7
  clr r17
  rcall wait3

  ldi r16, 0b0000_0101
  ldi r17, 0b0000_0100
  sbrc r19,1
  clr r17
  rcall wait3

  ldi r16, 0b0000_0011
  ldi r17, 0b0000_0010
  sbrc r20,7
  clr r17
  rcall wait3

  ldi r16, 0b0000_0110
  ldi r17, 0b0000_0100
  sbrc r20,3
  clr r17
  rcall wait3

  ldi r16, 0b0000_0101
  ldi r17, 0b0000_0001
  sbrc r20,1
  clr r17
  rcall wait3

  ldi r16, 0b0000_0011
  ldi r17, 0b0000_0001
  sbrs r20,5
  clr r17
  rcall wait3

  subi r25, 3
  brcc hold


rjmp sparklemain


wait3:
  out DDRB, r16
  out PORTB, r17
  clr r16
wait3_1:

  inc r16
  cpse r16,r25 
  rjmp wait3_1

  clr r17
  out PORTB, r17
wait3_2:
  inc r16
  brne wait3_2

  ret













.org 256
message:
;.db "the quick brown fox jumps over the lazy dog ",0
.db "pn junctions are a girls best friend ",0


.org 320
charset:

#define DOT 1
#define DASH 2
#define EOC 128

;A
.db DOT, DASH | EOC, 0, 0
;B
.db DASH, DOT, DOT, DOT |EOC
;C
.db DASH,DOT,DASH,DOT|EOC
;D
.db DASH,DOT,DOT|EOC, 0
;E
.db DOT|EOC, 0, 0, 0
;F
.db DOT, DOT, DASH, DOT |EOC
;G
.db DASH,DASH,DOT|EOC, 0
;H
.db DOT, DOT, DOT, DOT |EOC
;I
.db DOT, DOT |EOC, 0,0
;J
.db DOT,DASH,DASH,DASH|EOC
;K
.db DASH,DOT,DASH|EOC, 0
;L
.db DOT,DASH,DOT,DOT|EOC
;M
.db DASH, DASH | EOC, 0, 0
;N
.db DASH, DOT | EOC, 0, 0
;O
.db DASH,DASH,DASH|EOC, 0
;P
.db DOT,DASH,DASH,DOT|EOC
;Q
.db DASH,DASH,DOT,DASH|EOC
;R
.db DOT,DASH,DOT|EOC, 0
;S
.db DOT,DOT,DOT|EOC, 0
;T
.db DASH|EOC, 0, 0, 0
;U
.db DOT,DOT,DASH|EOC, 0
;V
.db DOT,DOT,DOT,DASH|EOC
;W
.db DOT,DASH,DASH|EOC, 0
;X
.db DASH,DOT,DOT,DASH|EOC
;Y
.db DASH,DOT,DASH,DASH|EOC
;Z
.db DASH,DASH,DOT,DOT|EOC

.org 384
data:
; a="";for (i=0;i<256;i++) a+=","+Math.round(2+60*Math.pow((1+Math.sin(2*3.1415926535897*i/255)),2)); a
.db 62,65,68,71,74,78,81,84,88,91,95,98,102,106,109,113,117,121,125,128,132,136,140,144,148,151,155,159,163,166,170,174,177,181,184,188,191,194,198,201,204,207,210,212,215,217,220,222,224,227,229,230,232,234,235,236,238,239,240,240,241,241,242,242,242,242,242,241,241,240,239,238,237,236,234,233,231,229,228,226,223,221,219,216,214,211,208,205,202,199,196,193,189,186,183,179,176,172,168,165,161,157,153,149,146,142,138,134,130,126,123,119,115,111,108,104,100,97,93,90,86,83,79,76,73,70,67,63,61,58,55,52,49,47,44,42,40,37,35,33,31,29,27,26,24,22,21,19,18,17,15,14,13,12,11,10,10,9,8,7,7,6,6,5,5,4,4,4,4,3,3,3,3,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,4,4,4,5,5,5,6,6,7,8,8,9,10,11,12,13,14,15,16,17,19,20,22,23,25,26,28,30,32,34,36,39,41,43,46,48,51,53,56,59,62