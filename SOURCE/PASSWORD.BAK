
;**+	Get Password if Selected!

.LETTERS	EQU	0	; start of letters 2x2 font
.BLANK	EQU	LETTERS+{4 MULT 27}	; Blank char
.UNDER_SCORE	EQU	LETTERS+{4 MULT 26}	; _ underscore
.NUMBERS	EQU	LETTERS+{4 MULT 28}	; 0 - 9
.SELECTOR	EQU	LETTERS+{4 MULT 38}	; Horse Shoe

CROSS_MOVEMENT	EQU	2

GET_PASSWORD	STZ	<XTEMP	; init position for name
	LDA	#1
	STA	<ATEMP	; use for selection speed

PASS_LOOP	;LongAI

	LDA	<JOY_PAD1
	BIT	#Joy_Right	; right
	BEQ	NORIGHT5
	PHA
	LDA	|OBJECT_DATA+0
	TAY
	AND	#$FF
	CMP	#256-32
	BCS	MAXR
	TYA
	CLC
	ADC	#CROSS_MOVEMENT
	STA	|OBJECT_DATA+0
MAXR	PLA

NORIGHT5	BIT	#Joy_Left
	BEQ	NOLEFT5
	PHA
	LDA	|OBJECT_DATA+0
	TAY
	AND	#$FF
	BEQ	MAXL
	TYA
	SEC
	SBC	#CROSS_MOVEMENT
	STA	|OBJECT_DATA+0
MAXL	PLA

NOLEFT5	BIT	#Joy_Down
	BEQ	NODOWN5
	PHA
	LDA	|OBJECT_DATA+0
	TAY
	AND	#$FF00
	CMP	#{224-32} MULT 256
	BEQ	MAXB
	TYA
	CLC
	ADC	#CROSS_MOVEMENT MULT 256
	STA	|OBJECT_DATA+0
MAXB	PLA
	
NODOWN5	BIT	#Joy_Up
	BEQ	NOUP5
	PHA
	LDA	|OBJECT_DATA+0
	TAY
	AND	#$FF00
	BEQ	MAXT
	TYA
	SEC
	SBC	#CROSS_MOVEMENT MULT 256
	STA	|OBJECT_DATA+0
MAXT	PLA

NOUP5	BIT	#Joy_Select
	BEQ	NOGET2
	RTS

NOGET2	BIT	#Joy_B	; now fire
	BNE	CHECK_WHAT
          	LDA	#1	; reinit speed when let go
	STA	<ATEMP
NO_CANDO	JSR	|DUCK_UPDATE
	JSR	|FIFTY
	JMP	|PASS_LOOP

	; Button B pressed ie want a letter
CHECK_WHAT	DEC	<ATEMP
	BNE	NO_CANDO	; only select @ certain speed
	LDA	#20
	STA	<ATEMP	; set back speed counter
	ShortAI
	LDA	|OBJECT_DATA+0	; get x cord
	CMP	#$0A+1	;30+4
	BCC	EAT_IT
	;CMP	#$D6	;200+4
	;BCS	EAT_IT
	SBC	#$0A	;$1A	;30+4	; - 20
	;TAY
	;AND	#$1F
	;CMP	#$1C	;9
	;BCS	EAT_IT
	;TYA
	LSR	A
	LSR	A
	LSR	A
	LSR	A
	LSR	A
	STA	<MIKE1
	LDA	|OBJECT_DATA+1	; have Y

	CMP	#$36	;$1A-4
	BCC	EAT_IT
	CMP	#$AE	;$A6-4	; not @ bottom
	BCS	EAT_IT
	SBC	#$36	;$1A-4	; - 8
	TAY
	AND	#$1F
	CMP	#$18-1	;0A+1	; small circle
	BCS	EAT_IT
	STA	<MIKE2	; amount save for latter
	TYA
	LSR	A
	LSR	A
	LSR	A
	LSR	A
	LSR	A
	TAY
	LDA	<MIKE1
	CLC
	ASSUME	DATABANK FIRST_BANK AND $FF0000
	ADC	|TIMES7T,Y	; time 6 table
	ASSUME	DATABANK COMMON_BANK AND $FF0000
	STA	<MIKE1
	TAY
	LDA	|DUCK_BUFFER	; hit already (DONT USE YET)
	BNE	EAT_IT
	;MONST
	JSR	|SET_HIT
	LDA	<MIKE1	
	ASL	A
	ASL	A
	LongA
	LDX	<XTEMP	; get position
	CMP	#26 MULT 4
	BCC	NO_BACK
	CMP	#27 MULT 4	; END ?
	BNE	MUST_BEDEL
	RTS
MUST_BEDEL	CPX	#0
	BEQ	EAT_IT
	LDA	#BLANK	; blank
	JSR	|PLOT_CHAR
	DEX
	DEX
	DEX
	DEX
	BRA	BACK_IT

NO_BACK	CPX	#{4 MULT 14}
	BEQ	EAT_IT	; only end and delete
	ADC	#LETTERS
	JSR	|PLOT_CHAR
	INX
	INX
	INX
	INX
BACK_IT	STX	<XTEMP	; save position
	CPX	#{4 MULT 14}
	BEQ	EAT_IT	; no cursor plotted
	JSR	|PUT_CURSOR

EAT_IT	LongAI
	JMP	|NO_CANDO	; back abit

st	EQU	4	; start 2 chars in

PASS_LINE	EQU	TEXT_SCREEN+{26 MULT 64}

PUT_CURSOR	LDA	#UNDER_SCORE
PLOT_CHAR	STA	|PASS_LINE+st,X
	INC	A
	STA	|PASS_LINE+st+2,X
	INC	A
	STA	|PASS_LINE+st+64,X
	INC	A
	STA	|PASS_LINE+st+64+2,X
	RTS

TIMES7T	BYTE	0,7,14,21,28	; max amount


	; set for hit a duck
	AssertM8X8
SET_HIT	LDA	#3
	STA	|BULLET_FRAME	; activate bullet
	LDA	|OBJECT_DATA+0
	;STA	|OBJECT_DATA+4
	LDA	|OBJECT_DATA+1
	;STA	|OBJECT_DATA+5
	STY	|DUCK_NUMBER	; hit number
	LDA	#11 ;0
	STA	|DUCK_BUFFER
	LDA	#0
	STA	|DUCK_DIR
	LDA	<MIKE2	; y position
	CMP	#$10
	BCC	NORWAY
	LDA	#11
	STA	|DUCK_DIR
NORWAY	RTS

	AssertM16X16
DUCK_UPDATE	PHP
	DEC	<DUCK_SPEED	; animation count for duck
	BNE	SLOW_THEM
	LDA	#4
	STA	<DUCK_SPEED
	ShortAI

	LDY	|BULLET_FRAME
	LDA	|HIT_FRAME AND $FFFF,Y
	;STA	|OBJECT_DATA+4+2	
	CPY	#0
	BEQ	BUL_FIN
	DEC	|BULLET_FRAME

BUL_FIN	LDX	|DUCK_NUMBER
	LDA	|DUCK_BUFFER
	BEQ	SLOW_THEM	; no update for now
	SEC
	SBC	#1
	STA	|DUCK_BUFFER	; -1
	CLC
	ADC	|DUCK_DIR	; direction 0 or 11 
	TAY
	LDA	|DUCK_FRAME_TAB AND $FFFF,Y
	PHA
	TXA
	ASL	A	; * 4 for object position
	ASL	A
	TAY
	PLA
	STA	|OBJECT_DATA+8+2,Y
	LongAI
	TXA
	ASL	A	; word positions
	TAY
	LDA	|CHAR_MEMORY AND $FFFF,Y ; get position for plot
	TAY
	LDA	|DUCK_BUFFER
	BNE	CLE	; zap to blank if not @ 0
	TXA
	CLC
	ADC	#156+2048+8192	; priority
	STA	|TEXT_SCREEN,Y
SLOW_THEM	PLP
	RTS

CLE	LDA	#156+30+2048+8192
	STA	|TEXT_SCREEN,Y
	PLP
	RTS

HIT_FRAME	BYTE	204,200,196,192	; hit object frame

DUCK_FRAME_TAB	BYTE	0,136,132,128,60,56,52,48,12,8,4
	BYTE	0,4,8,12,48,52,56,60,128,132,136

;**+	Setup Password Entry Screen Text

ST_PL	EQU	8+{10 MULT 64} ;128+8	; plot data start

DUCKMAC	MACRO	YP
	WORD	ST_PL+YP+0
	WORD	ST_PL+YP+8
	WORD	ST_PL+YP+16
	WORD	ST_PL+YP+24
	WORD	ST_PL+YP+32
	WORD	ST_PL+YP+40
	WORD	ST_PL+YP+48
	MEND

CHAR_MEMORY	DUCKMAC	0
	DUCKMAC	4 MULT 64
	DUCKMAC	8 MULT 64
	DUCKMAC	12 MULT 64
	;DUCKMAC	16 MULT 64

SETUP_PASSWORD	PHP
	ShortA
	LDA	#%10011	; BG1 + BG2 & OBJ enabled
	STA	|TM	; must reset as fadeout clears
	LongAI

	JSR	|CLS	; clear whats here

	LDA	#156+29+2048+8192
	LDY	#{30 MULT 2}-2
DIFF	LDX	|CHAR_MEMORY AND $FFFF,Y
	STA	|TEXT_SCREEN,X
	DEC	A
	DEY
	DEY
	BPL	DIFF

	LDX	#64-2	; lines worth
	LDA	#BLANK	; blank chars for entry line
	ASSUME	databank COMMON_BANK AND $FF0000
INIT_PAS	STA	|PASS_LINE,X
	STA	|PASS_LINE+64,X
	DEX
	DEX
	BPL	INIT_PAS
	LDX	#0
	JSR	|PUT_CURSOR
	JSR	|INIT_SPRITES

	LDA	#$8080	; cords in middle
	STA	|OBJECT_DATA+0	
	LDA	#%0011000000000000+140	; flip,obj col + name
	STA	|SPRITE_ATTRIBS+0	; test for sprite 0

	;LDA	#%0011000000000000+204	; blank sprite
	;STA	|SPRITE_ATTRIBS+4

	LDA	#4
	STA	<DUCK_SPEED	; animation speed for spin

	; Now Set All sprites as ducks
	; init cords of x @ 32 y@32

DUCK_X	EQU	16+3 ;4
DUCK_Y	EQU	40+28-1 ;2 ;4

	STZ	|DUCK_BUFFER	; use line buffer for
	STZ	|BULLET_FRAME	; hit hit graphic

	ShortAI
	LDX	#8 ;4	; start of duck sprites
	LDY	#DUCK_Y
	LDA	#4 ;5
	STA	<YTEMP
DY_LOOP	TYA
	XBA
	LDA	#7 ;6
	STA	<ATEMP
	LDA	#DUCK_X
DX_LOOP	LongAI
	STA	|OBJECT_DATA,X	; save x & y cord
	PHA
	LDA	#%0010000000000000
	STA	|SPRITE_ATTRIBS,X
	PLA
	INX
	INX
	INX
	INX
	ShortAI
	CLC
	ADC	#32	; advance x cord
	DEC	<ATEMP
	BNE	DX_LOOP
	TYA
	CLC
	ADC	#32
	TAY
	DEC	<YTEMP
	BNE	DY_LOOP
		
	PLP
	JMP	|FIFTY	; wait for VRAM to be written

	AssertM16X16
CLS	LDX	#2048-2
	LDA	#BLANK
CLEAR_IT	STA	|TEXT_SCREEN,X
	DEX
	DEX
	BPL	CLEAR_IT
	RTS
