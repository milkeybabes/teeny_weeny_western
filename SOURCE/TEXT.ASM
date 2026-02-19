;**+	Set For Text Screen's Options/Passsword/Music.
SETUP_TEXT	PHP
	ShortA_LongI
	STZ	<NMI_JUMP	; now action in NMI
	STZ	|HDMAEN	; kill HDMA's
	LDA	#%00000001	; mode 1
	STA	|BGMODE
	LDA	#%10100010	; sprites @ $4000 (big sprites)
	STA	|OBJSEL
	STZ	|BG1SC	; normal screen @ 0
	LDA	#$400/$100
	STA	|BG2SC
	LDA	#%00100001	; BG1 @ $1000 ,BG2 @ $2000
	STA	|BG12NBA

	LDA	#%0001	; BG1 for now
	STA	|TM	; Password have BG2 & OBJ
	STZ	|TS
	STZ	|TMW
	STZ	|TSW	; no windows or such

	STZ	|BG1HOFS	; makesure
	STZ	|BG1HOFS	; BG1 @ 0 
	STZ	|BG2HOFS	; makesure
	STZ	|BG2HOFS	; BG1 @ 0 
	LDA	#255
	STA	|BG1VOFS
	STA	|BG1VOFS
	STA	|BG2VOFS
	STA	|BG2VOFS

	LDX	#OFFSET DUCKMAP	; packed map start
	LDA	#SEG DUCKMAP
	JSR	|UNPACK_DATA	; to RAM
	LDY	#$0400	; BG 2 map
	JSR	|DMA_TO_VRAM

	LDX	#OFFSET PASS_CHARS	; packed map start
	LDA	#SEG PASS_CHARS
	JSR	|UNPACK_DATA	; to RAM
	LDY	#$1000	; BG 1 chars
	JSR	|DMA_TO_VRAM

	LDX	#OFFSET DUCKCHR	; packed map start
	LDA	#SEG DUCKCHR
	JSR	|UNPACK_DATA	; to RAM
	LDY	#$2000	; BG 2 chars
	JSR	|DMA_TO_VRAM

	LDX	#OFFSET DUCK_SPRITES	; cross hair
	LDA	#SEG DUCK_SPRITES
	JSR	|UNPACK_DATA
	LDY	#$4000	; sprites area
	JSR	|DMA_TO_VRAM

	LDA	#0
	STA	|CGADD	; start of pallete colours
	LDX	#32+32+32+32+32
	STX	|DMA_COUNT+DMA6
	LDX	#OFFSET PASS_PAL	; character set first
	STX	|DMA_A1ADDR+DMA6
	LDA	#SEG PASS_PAL
	STA	|DMA_A1ADDRB+DMA6
	LDA	#BIT6
	STA	|MDMAEN
	LDA	#$80	; for sprites
	STA	|CGADD
	LDX	#32
	STX	|DMA_COUNT+DMA6
	LDA	#BIT6
	STA	|MDMAEN


	LongA
	JSR	|CLS	; clear text screen buffer

	; Clear VRAM screen area (no map for NOW)
	LDA	#%0000110000000000	; clear byte
	LDX	#0	; start @ 0
	LDY	#$400	; 1 screens worth
	JSR	|CLEAR_VRAM

	ShortA
	LDA	#TEXT_NMI
	STA	<NMI_JUMP	; jump in NMI
	PLP
	RTS

;**+	Text Plot For Text Screen's

	AssertM16X16
PLOT_TEXT	PLA		; get return address
	STA	<MIKE1	; low byte
	LDY	#1	; index to first byte
	LDA	(MIKE1),Y	; word (only want high byte)
	PHA
	INY
	INY
	LDA	(MIKE1),Y	; memory
	TAX
	INY
	PLA
POKE_SCREEN
	LDA	#0
	ShortA
	INY
	LDA	(MIKE1),Y	; get text to convert
	CMP	#32
	BEQ	SPACE
	CMP	#255
	BNE	ONSCREEN
	LongA
	TYA
	SEC
	ADC	<MIKE1	; advance to end of
	STA	<MIKE1	; data to set return
	JMP	(MIKE1)	; return back
	AssertM8X16
SPACE	LDA	#27+65
ONSCREEN	LongA
	SEC
	SBC	#65
	ASL	A	; * 4
	ASL	A
	CLC
	ADC	#LETTERS
	STA	|TEXT_SCREEN,X	; screen memory
	INC	A
	STA	|TEXT_SCREEN+2,X	; next line
	INC	A
	STA	|TEXT_SCREEN+64,X
	INC	A
	STA	|TEXT_SCREEN+64+2,X
	INX		; along screen
	INX
	INX
	INX
	BRA	POKE_SCREEN

;**+	Selection Screens stuff

RE_SPEED	LDX	#1
	JSR	|SM_DELAY
MUSIC_LOOP	JSR	|MUSIC_VALUES
	JSR	|SELECT_MOVE	; get position and fire
	LDY	<YTEMP	; get current position
	LDA	<JOY_PAD1
	BEQ	RE_SPEED	; nothing pressed no delay
	LDA	#Joy_B+Joy_Start	; select 
	BIT	<JOY_PAD1
	BNE	MADE_SEL1

	CPY	#2	; only change value for tune
	BCS	IN_RANGE	; and sound fx
	CPY	#1
	BEQ	CHANGE_EFX

	LDA	#Joy_Right	; change number
	BIT	<JOY_PAD1
	BEQ	ADV2
	LDA	<TEMP1
	INC	A
	CMP	#9	; max tune number
	BCS	IN_RANGE
	STA	<TEMP1	; save new number
	BRA	IN_RANGE

ADV2	LDA	#Joy_Left
	BIT	<JOY_PAD1
	BEQ	IN_RANGE	; no change
	LDA	<TEMP1
	BEQ	IN_RANGE	; 0 already
	DEC	A
	STA	<TEMP1
	BRA	IN_RANGE


CHANGE_EFX	LDA	#Joy_Right	; change number
	BIT	<JOY_PAD1
	BEQ	ADV1
	LDA	<TEMP2
	INC	A
	CMP	#9	; max tune number
	BCS	IN_RANGE
	STA	<TEMP2	; save new number
	BRA	IN_RANGE

ADV1	LDA	#Joy_Left
	BIT	<JOY_PAD1
	BEQ	IN_RANGE	; no change
	LDA	<TEMP2
	BEQ	IN_RANGE	; 0 already
	DEC	A
	STA	<TEMP2
	BRA	IN_RANGE

	
MADE_SEL1	CPY	#0
	BEQ	MUSIC_TEST
	CPY	#2	; sound mode
	BEQ	NEW_MODE
	CPY	#1
	BEQ	SFX_TEST
	RTS		; else must be 3 exit

MUSIC_TEST	; else play music tune
	BRA	IN_RANGE
SFX_TEST	; play sound fx 
	BRA	IN_RANGE

NEW_MODE	INC	<MUSIC_MODE
	LDA	<MUSIC_MODE
	CMP	#6
	BNE	IN_RANGE
	STZ	<MUSIC_MODE	; reset back

IN_RANGE	LDX	#10
	JSR	|SM_DELAY
	JMP	|MUSIC_LOOP

ST_X	EQU	10
ST_Y	EQU	9

OPTIONS_TEXT	ShortA
	LDA	#%00001	; BG1 only
	STA	|TM	; must reset as fadeout clears
	LongA

	JSR	|CLS	; needed as re called

	JSR	|PLOT_TEXT
	WORD	358,8+{2 MULT 64}
	BYTE	"GAME OPTIONS",255

	JSR	|PLOT_TEXT
	WORD	358,6+ST_X+{ST_Y MULT 64}
	BYTE	"PASSWORD",255

	JSR	|PLOT_TEXT
	WORD	358,ST_X+{{ST_Y+4} MULT 64}
	BYTE	"MUSIC SETUP",255

	JSR	|PLOT_TEXT
	WORD	358,2+ST_X+{{ST_Y+8} MULT 64}
	BYTE	"START GAME",255
 	LDY	#2 ;0	; init positions
	STY	<YTEMP
	STY	<XTEMP	; copy of last position
	LDA	#2	; max down
	STA	<ATEMP
	JMP	|SELECT_BAR	; plot selection indicator

MUSIC_OPTIONS	ShortA
	LDA	#%00001	; BG1 only
	STA	|TM	; must reset as fadeout clears
	LongA
	JSR	|CLS	; zap 

	JSR	|PLOT_TEXT
	WORD	358,6+{2 MULT 64}
	BYTE	"MUSIC OPTIONS",255
	JSR	|PLOT_TEXT
	WORD	358,ST_X+{ST_Y MULT 64}
	BYTE	"PLAY TUNE",255

	JSR	|PLOT_TEXT
	WORD	358,2+ST_X+{{ST_Y+4} MULT 64}
	BYTE	"TEST SFX",255

	JSR	|PLOT_TEXT
	WORD	358,ST_X+{{ST_Y+8} MULT 64}
	BYTE	"MODE",255

	JSR	|PLOT_TEXT
	WORD	358,ST_X+{{ST_Y+12} MULT 64}
	BYTE	"RETURN BACK",255

	LDY	#0	; init positions
	STY	<YTEMP
	STY	<XTEMP	; copy of last position
	STZ	<TEMP1	; tune number
	STZ	<TEMP2	; effect number
	LDA	#3	; max down
	STA	<ATEMP
	JMP	|SELECT_BAR	; plot selection indicator


MUSIC_VALUES	LDY	#40+ST_X+{ST_Y MULT 64}
	LDA	<TEMP1	; tune number
	ASL	A
	ASL	A
	CLC
	ADC	#NUMBERS
	JSR	|PLOT_IT
	LDY	#2+36+ST_X+{{ST_Y+4} MULT 64}
	LDA	<TEMP2	; effect number
	ASL	A
	ASL	A
	CLC
	ADC	#NUMBERS
	JSR	|PLOT_IT
	LDA	<MUSIC_MODE	; stereo etc
	CMP	#1
	BEQ	STEREO
	CMP	#2
	BEQ	PROLOGIC
	CMP	#3
	BEQ	STUDIO
	CMP	#4
	BEQ	STADIUM
	CMP	#5
	BEQ	THX

MONO	JSR	|PLOT_TEXT
	WORD	358,20+ST_X+{{ST_Y+8} MULT 64}
	BYTE	"MONO    ",255
	RTS
STEREO	JSR	|PLOT_TEXT
	WORD	358,20+ST_X+{{ST_Y+8} MULT 64}
	BYTE	"STEREO  ",255
	RTS
PROLOGIC	JSR	|PLOT_TEXT
	WORD	358,20+ST_X+{{ST_Y+8} MULT 64}
	BYTE	"PROLOGIC",255
	RTS
STUDIO	JSR	|PLOT_TEXT
	WORD	358,20+ST_X+{{ST_Y+8} MULT 64}
	BYTE	"STUDIO  ",255
	RTS
STADIUM	JSR	|PLOT_TEXT
	WORD	358,20+ST_X+{{ST_Y+8} MULT 64}
	BYTE	"STADIUM ",255
	RTS
THX	JSR	|PLOT_TEXT
	WORD	358,20+ST_X+{{ST_Y+8} MULT 64}
	BYTE	"OFF     ",255
	RTS

SELECT_MOVE	LDA	#Joy_Up
	BIT	<JOY_PAD1
	BEQ	FORGET
	LDA	<YTEMP	; top one anyway no move
	BEQ	FORGET
	DEC	<YTEMP	; up one		
FORGET	LDA	#Joy_Down
	BIT	<JOY_PAD1
	BEQ	ICECREAM
	LDA	<YTEMP
	CMP	<ATEMP	; max down	
	BEQ	ICECREAM
	INC	<YTEMP
ICECREAM	LDA	<YTEMP	; any changes in position
	CMP	<XTEMP
	BEQ	NO_UP	; both same
	LDY	<XTEMP
	JSR	|DELETE_BAR
	LDY	<YTEMP
	STY	<XTEMP
SELECT_BAR	LDA	#1000	; reinit used
	STA	<TEMP3
	LDA	#SELECTOR	; A for now
	BRA	PLOT_BAR

DELETE_BAR	LDA	#BLANK	; blank I think
PLOT_BAR	PHA
	TYA
	ASL	A
	TAY
	LDA	|SELECT_POST AND $FFFF,Y
	TAY
	PLA
PLOT_IT	STA	|TEXT_SCREEN,Y
	INC	A
	STA	|TEXT_SCREEN+2,Y
	INC	A
	STA	|TEXT_SCREEN+64,Y
	INC	A
	STA	|TEXT_SCREEN+66,Y
NO_UP	RTS

SELECT_POST	WORD	ST_X-6+{ST_Y MULT 64}
	WORD	ST_X-6+{{ST_Y+4} MULT 64}
	WORD	ST_X-6+{{ST_Y+8} MULT 64}
	WORD	ST_X-6+{{ST_Y+12} MULT 64}

;**+	Pull Down Window Stuff

	AssertM16X16
GAME_OPTIONS	LDA	#Joy_Up
	BIT	<JOY_PAD1
	BEQ	TOP_ALREADY
	LDA	<YTEMP	; top one anyway no move
	BEQ	TOP_ALREADY
	DEC	<YTEMP	; up one		
TOP_ALREADY	LDA	#Joy_Down
	BIT	<JOY_PAD1
	BEQ	MAX_ALREADY
	LDA	<YTEMP
	CMP	<ATEMP	; max down	
	BEQ	MAX_ALREADY
	INC	<YTEMP
MAX_ALREADY	LDA	<YTEMP	; any changes in position
	CMP	<XTEMP
	BEQ	BOTH_SAME	; both same
	STA	<XTEMP	; now as last
	JMP	|REPLOT_SELECT

OPTIONS_INIT	STZ	<XTEMP	; last position compare
	STZ	<YTEMP	; selection position
	LDA	#1
	STA	<ATEMP
REPLOT_SELECT	STZ	<MIKE2	; compare for invent print
	LDY	#-1	; start of text
	LDX	#{OPT_Y MULT 64}+{OPT_X MULT 2}
	STX	<TEMP1	; screen dest start

PLOT_SELECTED	LDA	<MIKE2
	CMP	<YTEMP	; select position
	BNE	PLOT_UNSELECT
	LDA	#37	; set high byte
	BRA	DO_PLOT_NOW
PLOT_UNSELECT	LDA	#0	; set high byte
DO_PLOT_NOW	STA	<MIKE1
	LDA	#%0011000000000000
PLOT_LINE	ShortA
	INY
	LDA	|GOPTIONS_TEXT AND $FFFF,Y
	BPL	NOTED
	CMP	#255	; 255 marks end of line
	BNE	TNEXT_LINE
	LongA
BOTH_SAME	RTS

	AssertM8X16
NOTED	CMP	#32
	BNE	NOT_ASPACE
	LDA	#0
	BRA	NOWP
	
NOT_ASPACE	CMP	#'9'+1	; less then 9
	BCS	LETTRS
	SBC	#'1'
	BRA	NOWP

LETTRS	SBC	#'A'-11	; start of letters @ 10
NOWP	CLC
	ADC	<MIKE1
	LongA
	STA	|TEXT_SCREEN,X
	INX
	INX
	BRA	PLOT_LINE

TNEXT_LINE	LongA
	LDA	<TEMP1
	CLC
	ADC	#64	; next line
	TAX
	STX	<TEMP1
	INC	<MIKE2	; next option
	BRA	PLOT_SELECTED

CLEAR_OPTIONS	LDX	#18	; max length
ZAP_OPT	STZ	|TEXT_SCREEN+{OPT_Y MULT 64}+{OPT_X MULT 2},X
	STZ	|TEXT_SCREEN+{OPT_Y MULT 64}+{OPT_X MULT 2}+64,X
	DEX
	BPL	ZAP_OPT
	RTS


GOPTIONS_TEXT	BYTE	"RETURN",128
	BYTE	"QUIT GAME",255


PASSWORD_CODE	JSR	|CLS	; needed as re called

	JSR	|PLOT_TEXT
	WORD	358,6+{2 MULT 64}
	BYTE	"GAME PASSWORD",255

	JSR	|PLOT_TEXT
	WORD	358,10+{22 MULT 64}
	BYTE	"PRESS START",255
	JSR	|PLOT_TEXT
	WORD	358,6+{25 MULT 64}
	BYTE	"WHEN FINISHED",255

	JSR	|PLOT_TEXT
	WORD	358,st+{13 MULT 64}	; password start
	BYTE	"WERIGDCJKLIOPQ",255
	RTS



