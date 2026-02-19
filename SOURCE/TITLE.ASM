;**+	Spin Effect Intro in MODE7
SPIN_EFFECT	ShortA
	LDA	#%00001111
	STA	<FADE
	JSR	|FIFTY
	LongAI
	LDY	#128	; size looP
SPIN_LOOP	JSR	|FIFTY	; wait a frame
	LDA	<ROTATION
	CLC
	ADC	#2
	STA	<ROTATION
	LDA	<X_SCALE
	CLC
	ADC	#4
	STA	<X_SCALE
	DEY
	BNE	SPIN_LOOP


	LDX	#50
	JSR	|SM_DELAY
	LDY	#240
SHRINK_LOOP	JSR	|FIFTY
	TYA
	LSR	A
	LSR	A
	LSR	A
	LSR	A
	STA	<FADE
	LDA	<X_SCALE
	CLC
	ADC	#32
	STA	<X_SCALE
	DEY
	BNE	SHRINK_LOOP
	LDA	#%10001111
	STA	<FADE
	JMP	|FIFTY

;**+	Set Logo Page Stuff
SET_LOGO	PHP
	ShortA
	STZ	<NMI_JUMP
	STZ	|HDMAEN

	LDA	#7	; fancy effects mode
	STA	|BGMODE
	STZ	|BG1SC	; screen start @ 0
	LDA	#%11000000
	STA	|M7SEL
	;LDA	#%01000010	; sprites @ $4000 (big sprites)
	;STA	|OBJSEL
	LDA	#%00001	; BG1 only & OBJ
	STA	|TM
	STZ	|TMW	; make sure no windows effects 

	STZ	|BG1HOFS	; makesure
	STZ	|BG1HOFS	; BG1 @ 0 
	STZ	|BG2HOFS	; makesure
	STZ	|BG2HOFS	; BG1 @ 0 
	LDA	#255
	STA	|BG1VOFS
	STA	|BG1VOFS
	STA	|BG2VOFS
	STA	|BG2VOFS

	LongAI
	LDX	#$8000
	LDA	#$0000
ZAP	STA	>MODE7_MAKEUP-2,X	; clear ram where want to go
	DEX
	DEX
	BNE	ZAP
	JSR	|MAKE_MODE7	; make mode7 screen
	LongA_ShortI
	STZ	|VMADDL	; vram start write
	LDA	#$8000	; whole mode 7 data
	STA	|DMA_COUNT+DMA7
	LDA	#OFFSET MODE7_MAKEUP
	STA	|DMA_A1ADDR+DMA7	; start address for read
	LDX	#SEG MODE7_MAKEUP	; bank 1 for character set
	STX	|DMA_A1ADDRB+DMA7
	LDX	#BIT7
	STX	|MDMAEN	; set channel 7 going?
	LDX	#0
	STX	|CGADD	; start of pallete colours
	LDA	#512	; 16 palettes for 256 BG mode
	STA	|DMA_COUNT+DMA6
	LDA	#OFFSET LOGO_PALETTE
	STA	|DMA_A1ADDR+DMA6
	LDX	#SEG LOGO_PALETTE
	STX	|DMA_A1ADDRB+DMA6
	LDX	#BIT6
	STX	|MDMAEN

	LDA	#18;518	; normal size factor
	STA	<X_SCALE
	STZ	<ROTATION	; no rotation angle
	ShortA
	LDA	#LOGO_NMI
	STA	<NMI_JUMP	; jump in NMI
	PLP
	RTS


TEST_HDMA	BYTE	127,%01000010	; sprites @ $4000 (big sprites)
 	BYTE	1,  %01000010
	BYTE	63, %01000011	; sprites @ $6000 (big sprites)
	BYTE	0

;**+	Set Title Page Screen

SETUP_TITLE	PHP
	ShortA_LongI
	STZ	<NMI_JUMP
	STZ	|HDMAEN

	LDA	#%01110000	; BG2 @ $7000 BG1 @ 0
	STA	|BG12NBA
	LDA	#3
	STA	|BGMODE
	LDA	#{$6800/$100}	; screen after chars
	STA	|BG1SC
	LDA	#{$6c00/$100}	; other screen after last
	STA	|BG2SC
	LDA	#2+1	; ENABLE ONLY BG1
	;LDA	#2
	STA	|TM
	STA	|TMW
	STZ	|TS
	STZ	|TSW
	LDA	#%11001100
	STA	|W12SEL


	STZ	|BG1HOFS	; makesure
	STZ	|BG1HOFS	; BG1 @ 0 
	STZ	|BG2HOFS	; makesure
	STZ	|BG2HOFS	; BG1 @ 0 
	LDA	#255
	STA	|BG1VOFS
	STA	|BG1VOFS
	STA	|BG2VOFS
	STA	|BG2VOFS

	LongAI
	LDA	#$6800+32	; screen @ $7800
	STA	|VMADDL	; BG1 screen @ 0
	LDA	#0
	TAX
INIT_MAP	STA	|VMDATAL	; clearn it out
	INX
	INX		; advance stor position
	INC	A
	CMP	#32 MULT 26	; NOT whole screen
	BNE	INIT_MAP

	ShortA_LongI

	STZ	|CGADD	; start of pallete colours
	LDX	#512	; 16 palettes for 256 BG mode
	STX	|DMA_COUNT+DMA6
	LDX	#OFFSET TITLE_PALETTE
	STX	|DMA_A1ADDR+DMA6
	LDA	#SEG TITLE_PALETTE
	STA	|DMA_A1ADDRB+DMA6
	LDA	#BIT6
	STA	|MDMAEN

	LDX	#OFFSET TITLE_CHARSET	; packed map start
	LDA	#SEG TITLE_CHARSET
	JSR	|UNPACK_DATA	; to RAM
	LDY	#$0000	; BG 1 chars
	JSR	|DMA_TO_VRAM

	LDX	#OFFSET START_H	; packed map start
	LDA	#SEG START_H
	JSR	|UNPACK_DATA	; to RAM
	LDY	#$7000	; BG 1 chars
	JSR	|DMA_TO_VRAM

	LDX	#OFFSET START_HS	; packed map start
	LDA	#SEG START_HS
	JSR	|UNPACK_DATA	; to RAM
	LDY	#$6c00	; BG 1 SCREEN
	JSR	|DMA_TO_VRAM

	LDX	#$7000+$8D0	; temp poke for char update
	STX	<XTEMP
	LDX	#2
	STX	<YTEMP

	LDX	#OFFSET TITLE_HDMA
	STX	|DMA_A1ADDR+DMA4
	LDA	#SEG TEST_HDMA
	STA	|DMA_A1ADDRB+DMA4
	LDA	#BIT1
	STA	|HDMAEN

	LDA	#1
	STA	|HDMA_DATA
	STZ	|HDMA_DATA+1
	LDA	#BIT4	; enable HDMA for Windows
	STA	|HDMAEN

	LDX	#ANIM_NMI
	STX	<NMI_JUMP
	PLP
	RTS

TITLE_HDMA	BYTE	8
	BYTE	0,0
	BYTE	127
	BYTE	0,255
	BYTE	81
	BYTE	0,255
	BYTE	8
	BYTE	0,0
	BYTE	0
