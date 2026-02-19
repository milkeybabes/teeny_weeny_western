65C816

	#INCLUDE "816CONST.ASM"
	#INCLUDE "MACROS.ASM"
	#INCLUDE "SNES_IO.ASM"
	LONGS
	

	SEGMENT	'banklowRAM'	; for zero page


.JOY_PAD1	DS.W
.CHANGE1_DELAY	DS.W
.SPRITE_START	DS.W
.CHANGE2_DELAY	DS.W
.PALETTE_NUMBER	DS.W

.OBJ_TEST1	DS.W
.OBJ_SIZE	DS.W
.SYNC	DS.W
.YPOSITION	DS.W		; sprite position 0-32


	SEGMENT 'bankcommon'
.COMMON_BANK
.OBJECT_DATA	DS.W	128 mult 2	; Object data
.OBJECT_SIZES	DS.W	128/8	; as words. 2bits / sprite
.SPRITE_ATTRIBS	EQU	OBJECT_DATA+2	; attributes + NAME

; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; Vector entry points - must be in bank 0
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	SEGMENT	'bank0ROM'
.FIRST_BANK

	#INCLUDE "backchan.asm"
	#INCLUDE "bchcomms.asm"


;**+	NMI Handler

NMIentry	GROUP	nmi
	PHP
	LongAI
	PHB
	PHA
	PHX
	PHY
	ShortAI
	LDA	#0	; bank 0
	PHA
	PLB
	LDA	|RDNMI	; Clear NMI
	INC	<SYNC

	LDA	#%10100000
	ORA	<SPRITE_START
	ORA	<OBJ_TEST1
	STA	|OBJSEL

	LongA_ShortI
	STZ	|OAMADDL	; object OAM data address
	LDA	#OBJECT_DATA	; Object_data
	STA	|DMA_A1ADDR+DMA5	; data start low/hi
	LDX	#SEG OBJECT_DATA
	STX	|DMA_A1ADDRB+DMA5
	LDA     #544	; bytes to transfer
	STA     |DMA_COUNT+DMA5
	LDX	#BIT5	; DMA 5
	STX	|MDMAEN	; Trigger Channel5 DMA


	LDA	|JOY1L
	STA	<JOY_PAD1
	;LDA	|JOY2L
	;STA	|TEST2

	LongAI

	PLY
	PLX
	PLA
	PLB
	PLP
	GROUP	main
	RTI


RESETentry	CLI
	CLC
	XCE
	LongI
	LDX	#$1ff
	TXS
	ShortAI
	;Initial_Settings
	STZ	|HDMAEN


	LongAI
	LDA	#0	; init Direct Page
	TCD
	ASSUME	DATABANK FIRST_BANK AND $FF0000
	LDA	#SEG FIRST_BANK
	PHA
	PLB		; select data bank $00

	LongA

	LDA	#$0400	; $2104 OAM, byte store
	STA	|DMA_SETUP+DMA5	; use DMA 5

	LDA	#%10000	; BG1 only & OBJ
	STA	|TM
	STZ	|TMW	; make sure no windows effects 

	ASSUME	databank COMMON_BANK AND $FF0000

	LongA
	LDX	#$0000
CLEAR_SPRITES1	LDA	#$E000	; x=0 y=224
	STA	|OBJECT_DATA,X
	STZ	|OBJECT_DATA+2,X	; name & bits
	INX
	INX
	CPX	#128 MULT 4
	BNE	CLEAR_SPRITES1
	LDX	#{128/4}-2
CLEAR_OTHER1	STZ	|OBJECT_SIZES,X
	DEX
	DEX
	BPL	CLEAR_OTHER1


	ShortA

	LDA	#64
	STA	|OBJECT_DATA+0
	STA	|OBJECT_DATA+8
	STA	|OBJECT_DATA+16
	STA	|OBJECT_DATA+24
	LDA	#128
	STA	|OBJECT_DATA+4
	STA	|OBJECT_DATA+12
	STA	|OBJECT_DATA+20
	STA	|OBJECT_DATA+28


	LDA	#0
	JSR	|SET_YCORD


	LDA	#%10101010
	STA	|OBJECT_SIZES+0
	STA	|OBJECT_SIZES+1

	LDA	#%10000001
	STA	|NMITIMEN

	LongA
	LDA	#1
	STA	<CHANGE1_DELAY
	STA	<CHANGE2_DELAY
	STZ	<SPRITE_START
	STZ	<PALETTE_NUMBER

	STZ	<YPOSITION

FOREVER	LDA	<JOY_PAD1
	PHA
	XBA
	AND	#%00110000
	STA	<OBJ_TEST1

	PLA

	DEC	<CHANGE1_DELAY
	BNE	NOCHANGE
	PHA
	LDA	#20
	STA	<CHANGE1_DELAY
	PLA
	BIT	#Joy_X
	BEQ	no_speedi
	PHA
	LDA	<SPRITE_START
	BEQ	RIGHA1
	DEC	<SPRITE_START
RIGHA1	PLA
no_speedi	BIT	#Joy_Y
	BEQ	NOCHANGE
	PHA
	LDA	<SPRITE_START
	CMP	#3
	BEQ	RIGHA
	INC	<SPRITE_START
RIGHA	PLA

NOCHANGE

	DEC	<CHANGE2_DELAY
	BNE	PNOCHANGE
	PHA
	LDA	#20
	STA	<CHANGE2_DELAY
	PLA
	BIT	#Joy_A
	BEQ	Pno_speedi
	PHA
	LDA	<PALETTE_NUMBER
	BEQ	PRIGHA1
	DEC	<PALETTE_NUMBER
PRIGHA1	PLA
Pno_speedi	BIT	#Joy_B
	BEQ	PNOCHANGE
	PHA
	LDA	<PALETTE_NUMBER
	CMP	#7
	BEQ	PRIGHA
	INC	<PALETTE_NUMBER
PRIGHA	PLA

PNOCHANGE	BIT	#Joy_Down
	BEQ	noc1
	LDA	<YPOSITION
	CLC
	ADC	#8
	CMP	#32+8
	BCS	noc1
	STA	<YPOSITION
noc1	BIT	#Joy_Up
	BEQ	canc
	LDA	<YPOSITION
	SEC
	SBC	#8
	BCC	canc
	STA	<YPOSITION


canc	ShortA
	LDA	<YPOSITION
	JSR	|SET_YCORD	; sprites cords
	LongA

	LDA	<PALETTE_NUMBER
	XBA
	ASL	A
	TAX		; x now palet

	STA	|OBJECT_DATA+2
	TXA
	ORA	#8
	STA	|OBJECT_DATA+6
	TXA
	ORA	#256	;128
	STA	|OBJECT_DATA+10
	TXA
	ORA	#264	;136
	STA	|OBJECT_DATA+14

	TXA
	ORA	#128	;256
	STA	|OBJECT_DATA+18
	TXA
	ORA	#136	;264
	STA	|OBJECT_DATA+22
	TXA
	ORA	#384
	STA	|OBJECT_DATA+26
	TXA
	ORA	#392
	STA	|OBJECT_DATA+30

	JSR	|FIFTY
	JMP	|FOREVER


	AssertM8X8
SET_YCORD	EOR	#255
	INC	A

	STA	|OBJECT_DATA+1	; Y
	STA	|OBJECT_DATA+5
	CLC
	ADC	#64
	STA	|OBJECT_DATA+9
	STA	|OBJECT_DATA+13
	ADC	#64
	STA	|OBJECT_DATA+17
	STA	|OBJECT_DATA+21
	ADC	#64
	STA	|OBJECT_DATA+25
	STA	|OBJECT_DATA+29
	RTS

FIFTY	PHP
	LongA
WAIT_S	LDA	<SYNC
	BEQ	WAIT_S
	STZ	<SYNC
	PLP
	RTS	



	SEGMENT 'bank0ROM'

; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; Vector jumps mapped into bank 0
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	SEGMENT	'vecjmps>vjdata'

RESETjmp	JMP	>RESETentry
NMIjmp	JMP	>NMIentry
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; BRKs used for (soft) breakpointing
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
BRKentry	JMP	|unusedvec
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; unused vectors: whip into monitor
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
COPentry
ABORTentry
IRQentry
unusedvec
	CLC		; in case got in to emulation mode somehow
	XCE
	;MONST		; break point
	JMP	|unusedvec

; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; 65816 Vectors
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	SEGMENT 'vectors>vecdata'

COPvec	WORD	COPentry
BRKvec	WORD	BRKentry
ABRTvec	WORD	ABORTentry
NMIvec	WORD	NMIjmp
	WORD	unusedvec
IRQvec	WORD	IRQentry

	WORD	0
	WORD	0

; Now aligned to FFF4: emulation vectors
; Vectors called while E bit is set; we're only interested in RESET

	WORD	unusedvec	; COP
	WORD	unusedvec	; BRK
	WORD	unusedvec	; ABORT
	WORD	unusedvec	; NMI
RSTvec	WORD	RESETjmp
	WORD	unusedvec	; IRQ


	END

