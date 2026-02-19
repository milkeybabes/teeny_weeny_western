;**+    Replot whole screen from current world pointers

	AssertM8X16
ALL_SCREEN	PHP
	LDA	#SEG USER_RAM2	; pointer to user ram setting
	STA	<MIKE1_BANK
	LongAI

	LDA	#-1
	STA	<LAST_XPLOT
	STA	<LAST_YPLOT

	LDA	<WORLD_X	; DIV 8 * 2
	AND	#%1111111111111000
	LSR	A
	LSR	A
	TAY
	LDA	<WORLD_Y
	AND	#%1111111111111000	
	LSR	A
	LSR	A
	TAX		; y offset in data
	TYA
	CLC
	ASSUME	DATABANK FIRST_BANK AND $FF0000
	ADC	|GMAP_L,X	; source pointer
	STA	<MIKE1	; start offset down map

	;MONST
	LDA	#32
	STA	<MIKE2

	LDA	<WORLD_Y	; Y / 8
	AND	#%11111000	; * 2
	LSR	A
	LSR	A
	TAX		; start offset into screen mem

	LDA	<WORLD_X	; Y / 8
	AND	#%11111000
	LSR	A
	LSR	A
	LSR	A
	STA	<ATEMP
YLOOP1	LDY	#0
XLOOP1	LDA	|SCREEN_MAP,X
	CLC
	ADC	<ATEMP
	STA	|VMADDL
	LDA	[MIKE1],Y
	STA	|VMDATAL
	LDA	<ATEMP
	INC	A
	AND	#31
	STA	<ATEMP
	INY
	INY
	CPY	#64
	BNE	XLOOP1
	LDA	<MIKE1
	CLC
	ADC	#MAPX MULT 2	; next line in map
	STA	<MIKE1
	INX
	INX
	TXA
	AND	#64-1
	TAX
	DEC	<MIKE2
	BNE	YLOOP1
	PLP
	RTS

	; start of screen mem @ char boundarys
SCREEN_MAP	TABLE	0,31,32,0	; A=0 TO 31 V=A*64 + 0

GMAP_L	;TABLE	0,126,128,0
	TABLE	0,MAPY,MAPX MULT 2,MADEUP_MAP	; 0 TO 160-2

	; slow macros
	;MACRO	FOR,NEXT,TIM,ADD
	; FOR A= @2 TO @3 ; VALUE = A*@4+@5
;value	EQU	FOR
;	REPEAT		; Define Lable
;	WORD	{{value MULT TIM}+ADD}	; Low Byte
;value	CEQU	value + 1
;	UNTIL	value GT NEXT


;**+	Scroll Processing
SCROLL_UPDATE	ShortA
	LDA	#SEG USER_RAM2	; pointer to user ram setting
	STA	<MIKE1_BANK
	LongA
	LDA	<WORLD_Y
	LSR	A	; /8 for character position
	LSR	A
	LSR	A
	TAX		; save for now
	ASL	A	; * 2 for word pointer
	STA	<XTEMP
	AND	#31 MULT 2	; dest pointer for
	STA	<TEMP1	; cir buffer

	LDA	<WORLD_X
	LSR	A	; /8 for character position
	LSR	A
	LSR	A
	TAY
	ASL	A
	STA	<YTEMP	; * 2 for word pointer
	AND	#31 MULT 2	; dest pointer for
	STA	<TEMP2	; cir buffer

	CPY	<LAST_XPLOT
	BEQ	NO_CHANGE
	STY	<LAST_XPLOT
	TYA
	BCS	RIGHT_SIDE
	AND	#$1F	; left side
	STA	<YPLOT_MEM
	TYA
	BRA	SET_REST
RIGHT_SIDE	CLC
	ADC	#31	; test at middof of screen
	AND	#$1F	; VRAM start address
	STA	<YPLOT_MEM
	TYA
	CLC
	ADC	#31	; right side of data
SET_REST	ASL	A
	TAY		; start of read data
	ASSUME	DATABANK FIRST_BANK AND $FF0000
	PHX		; save x
	LDX	<XTEMP
	LDA	|GMAP_L,X	; source pointer (C=0?)
	STA	<MIKE1	; start offset down map
	LDX	<TEMP1	; buffer store start
	LDA	#32	; amount to save
	STA	<ATEMP
COPY_STRIP	LDA	[MIKE1],Y
	STA	>SCROLL_YBUFFER,X
	LDA	<MIKE1
	CLC
	ADC	#MAPX MULT 2	; next line in map
	STA	<MIKE1
	INX
	INX
	TXA
	AND	#$1F MULT 2	; make a circular buffer
	TAX
	DEC	<ATEMP
	BNE	COPY_STRIP
	LDA	#1	; set NMI to do DMA of strip
	STA	<YPLOT_ACT
	PLX		; get back x

NO_CHANGE	CPX	<LAST_YPLOT	; same place as last
	BEQ	NO_CHANGE1
	STX	<LAST_YPLOT	; now new is last
	TXA
	BCC	SET_REST1	; TOP_SIDE @ 0
	ADC	#30	; very bottom plot (c=1)
SET_REST1	TAX
	ASL	A	; *2 word for source data
	TAY
	TXA
	AND	#$1F	; 0 TO 31
	XBA		; * 256
	LSR	A	; / 2    128
	LSR	A	; / 4    64
	LSR	A	; / 8    32
	STA	<XPLOT_MEM	; for screen position 
	LDA	|GMAP_L,Y	; source pointer (C=0?)
	STA	<MIKE1	; start offset down map
	LDY	<YTEMP	; read source
	LDX	<TEMP2	; dest buffer start
	LDA	#32	; amount to save
	STA	<ATEMP
COPY_STRIP1	LDA	[MIKE1],Y
	STA	>SCROLL_XBUFFER,X
	INY
	INY		; next line in map
	INX
	INX
	TXA
	AND	#$1F MULT 2	; make a circular buffer
	TAX
	DEC	<ATEMP
	BNE	COPY_STRIP1
	LDA	#1	; set NMI to do DMA of strip
	STA	<XPLOT_ACT
NO_CHANGE1	RTS

;**-	DEBUG Status Plot
STATUS_PANNEL	PHP
	ASSUME	databank COMMON_BANK AND $FF0000
	LDX	#4
	LDA	<DEBUG0	; High first
	JSR	|HEXW
	LDA	<DEBUG1
	JSR	|HEXW
	LDA	<DEBUG2
	JSR	|HEXW
	LDA	<DEBUG3
	JSR	|HEXW
	LDA	<DEBUG4
	JSR	|HEXW
	LDA	<DEBUG5
	JSR	|HEXW
	PLP
	RTS

HEXW	XBA		; plot high first
	JSR	|TOPB
	XBA		; low next
	JSR	|TOPB
	INX
	INX
	RTS

TOPB	ShortA
	PHA
	LSR	A
	LSR	A
	LSR	A
	LSR	A
	INC	A
	STA	|LINE_BUFFER,X
	INX
	INX
	PLA
BOTB	AND	#15
	INC	A
	STA	|LINE_BUFFER,X
	LongA
	INX			; next along
	INX
	RTS

SING_DEC	STA	<MIKE1
	JSR	|DIVID		; divide by 10
	PHA
	LDA	<MIKE1
	JSR	|BOTB		; remainder first
	PLA
	JMP	|BOTB

	; div by 10
DIVID	LDA	#0
	ASL	<MIKE1	
	LDY	#8
LOOP	ROL	A
	CMP	#10
	BCC	SKIP
	SBC	#10
SKIP	ROL	<MIKE1
	DEY
	BNE	LOOP
	RTS

