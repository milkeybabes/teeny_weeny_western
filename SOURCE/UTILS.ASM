
;**-	Init For SPRITE OAM data Area
	AssertM16X16
INIT_SPRITES	ASSUME	databank COMMON_BANK AND $FF0000
	LDX	#$0000
CLEAR_SPRITES	LDA	#$E000	; x=0 y=224
	STA	|OBJECT_DATA,X
	STZ	|OBJECT_DATA+2,X	; name & bits
	TXA
	LSR	A
	LSR	A
	LSR	A
	LSR	A
	STA	|SPRITE_OFFSET,X
	TXA
	AND	#%0000000000001100
	LSR	A
	TAY
	ASSUME	databank FIRST_BANK AND $FF0000
	LDA	|MASK_TABLE,Y
	ASSUME	databank COMMON_BANK AND $FF0000
	STA	|SPRITE_SET,X
	INX
	INX
	INX
	INX
	CPX	#128 MULT 4
	BNE	CLEAR_SPRITES
	LDX	#{128/4}-2
CLEAR_OTHER	STZ	|OBJECT_SIZES,X
	DEX
	DEX
	BPL	CLEAR_OTHER
	RTS

MASK_TABLE	WORD	%1111111000000001
	WORD	%1111101100000100
	WORD	%1110111100010000
	WORD	%1011111101000000

;**-	Wait for X refreshes
SM_DELAY	PHP
	ShortAI
WAIT_V	LDA	<SYNC
	BEQ	WAIT_V
	STZ	<SYNC
	DEX
	BNE	WAIT_V
	PLP
	RTS

;**-	Fade in all Planes
FADE_SPEED	EQU	3;4
FADE_IN	PHP
	ShortAI
	LDY	#0
FADELOOP	STY	<FADE	; fade in screen
	LDX	#FADE_SPEED
FADE_WAIT1	JSR	|FIFTY	;WAI		; wait for irq
	DEX
	BNE	FADE_WAIT1
	INY
	CPY	#$10
	BNE	FADELOOP
	PLP
	RTS


;**-	Fade Out all Planes
FADE_OUT	PHP
	ShortAI
	LDY	#%00001111	; full colour
FADE_OUT_LOOP	STY	<FADE	; fade in screen
	LDX	#FADE_SPEED
FADE_WAIT2	JSR	|FIFTY	;WAI		; wait for irq
	DEX
	BNE	FADE_WAIT2
	DEY
	BPL	FADE_OUT_LOOP
	LDA	#%10000000
	STA	<FADE
	;STA	|INIDISP	; force blank now
	STZ	|TM	; turn off all planes
	PLP		; do a refresh as well

;**-	Wait for refresh
FIFTY	PHP
	ShortA
WAIT_S	LDA	<SYNC
	BEQ	WAIT_S
	STZ	<SYNC
	PLP
	RTS	


;**-	Unpack Routine. source X,A dest UNPACK_BUFFER
UNPACK_DATA	PHP
	PHB
	ShortA_LongI
	STX	<MIKE1
	STA	<MIKE1_BANK
	LDA	#SEG USER_RAM1	; dest for data
	PHA
	PLB		; get ram to bank
	ASSUME	databank USER_RAM1 AND $FF0000
	LDA	#$FF	; top for neg add
	STA	<TEMP1+1
	LDX	#$0000
	TXY
UNPACK_ALL	LDA	[MIKE1],Y	; get control
	BMI	SPECIAL	; -ive then special
	INC	A
	STA	<XTEMP	; else amount + 1
LITERAL	INY
	LDA	[MIKE1],Y	; copy litrally
	STA	|UNPACK_BUFFER,X
	INX
	DEC	<XTEMP
	BNE	LITERAL	; do all copy
	INY
	BRA	UNPACK_ALL	; keep going

SPECIAL	INY		; to next value
	STA	<TEMP1	; save sub value
	PHY
	LDA	[MIKE1],Y	; get amount repeat
	BEQ	END_PACKED	; end of data list
	STA	<XTEMP	; save amount
	LongA		; Long A
	TXA
	CLC
	ADC	<TEMP1	; get to repeat pointer
	TAY
	ShortA		; Short A
REPEAT	LDA	|UNPACK_BUFFER,Y	; copy from prev store
	STA	|UNPACK_BUFFER,X	; to store
	INY
	INX
	DEC	<XTEMP	; amount to do
	BNE	REPEAT
	PLY		; get back source
	INY
	BRA	UNPACK_ALL	; keep going

END_PACKED	PLY		; back source
	PLB		; back bank
	PLP
	RTS

;**-	General DMA unpacked to VRAM area in Y
DMA_TO_VRAM	STY	|VMADDL	; vram start write
	STX	|DMA_COUNT+DMA7	; amount unpacked
	LDY	#OFFSET UNPACK_BUFFER
	STY	|DMA_A1ADDR+DMA7	; start address for read
	LDA	#SEG UNPACK_BUFFER	; bank 1 for character set
	STA	|DMA_A1ADDRB+DMA7
	LDA	#BIT7
	STA	|MDMAEN	; set channel 7 going?
	RTS

;**+	Clear VRAM word A @ X size Y ShortA Return
CLEAR_VRAM	STA	<ZAP_OUT	; POKE WITH A
	STX	|VMADDL	; VRAM start @ x
	STY	|DMA_COUNT+DMA3	; size to clear
	LDX	#OFFSET ZAP_OUT
	STX	|DMA_A1ADDR+DMA3	; start address for read
	ShortA
	LDA	#SEG ZAP_OUT	; bank 1 for zap
	STA	|DMA_A1ADDRB+DMA3
	LDA	#BIT3
	STA	|MDMAEN	; set CLEAR going
	RTS
