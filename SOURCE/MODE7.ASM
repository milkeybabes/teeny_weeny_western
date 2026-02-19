;**+	Makeup MODE7 routine, generate MAP & Chrset
MAKE_MODE7	ShortA_LongI
	; Unpack Map to User Ram Store	
	LDX	#OFFSET LOGO_MAP	; packed map start
	LDA	#SEG LOGO_MAP
	JSR	|UNPACK_DATA
	PHB		; save current bank
	LDA	#SEG USER_RAM1
	PHA
	PLB		; get ram to bank
	ASSUME	databank USER_RAM1 AND $FF0000
	LongA
	LDX	#$0000
	TXY
	LDA	#32
	STA	<MIKE1
save_all	LDA	|UNPACK_BUFFER,X	; get map data (WORDs
	AND	#$00FF	; only need first 256 values
	STA	|MODE7_MAKEUP,Y	; save to RAM store
	INY
	INY
	DEC	<MIKE1
	BNE	all_line
	LDA	#32
	STA	<MIKE1
	TYA
	CLC
	ADC	#256-64
	TAY
all_line	INX
	INX
	CPX	#2048	; whole of map to do
	BNE	save_all
	ShortA
	LDX	#OFFSET LOGO_CHARS	; packed map start
	LDA	#SEG LOGO_CHARS
	JSR	|UNPACK_DATA

	ShortA_LongI
	LDY	#0
	TYX
QUICK_C	LDA	|UNPACK_BUFFER,X
	STA	|MODE7_MAKEUP+1,Y
	INX
	INY
	INY	
	CPX	#256 MULT 64	; maybe max amount
	BNE	QUICK_C
	PLB
	RTS

	LDY	#$0000
	TYX
do_all	LDA	#8
	STA	<XTEMP
whole_char	LDA	#BIT7
next_plane	STA	<TEMP1
	STZ	<TEMP2
	LDA	|UNPACK_BUFFER,Y	; first plane 0
	AND	<TEMP1
	BEQ	not_bit1
	LDA	#BIT0
	STA	<TEMP2
not_bit1	LDA	|UNPACK_BUFFER+1,Y	; next plane 1
	AND	<TEMP1
	BEQ	not_bit2
	LDA	<TEMP2
	ORA	#BIT1
	STA	<TEMP2
not_bit2	LDA	|UNPACK_BUFFER+16,Y	; plane 2
	AND	<TEMP1
	BEQ	not_bit3
	LDA	<TEMP2
	ORA	#BIT2
	STA	<TEMP2
not_bit3	LDA	|UNPACK_BUFFER+17,Y	; plane 3
	AND	<TEMP1
	BEQ	not_bit4
	LDA	<TEMP2
	ORA	#BIT3
	STA	<TEMP2
not_bit4	LDA	<TEMP2
	STA	|MODE7_MAKEUP+1,X	; data side by side of map
	INX
	INX
	LDA	<TEMP1	; get bit mask
	LSR	A	; down a bit
	BNE	next_plane	; all 8 bitdone
	INY
	INY
	DEC	<XTEMP
	BNE	whole_char
	LongA
	TYA
	CLC
	ADC	#16
	TAY
	ShortA
	CPY	#8192
	BCC	do_all
	PLB
	RTS

;**+	MODE7 Rotation control called from NMI
DO_ROTATION	LongAI
	LDA	<ROTATION
	AND	#255	; JUST IN CASE
	ASL	A
	TAX
	;JSR	|GET_COS
	LDA	>COS_TAB,X
	JSR	|MULTIPLY
	STA	<MATRIX_A
	;JSR	|GET_SIN
	LDA	>SIN_TAB,X
	JSR	|MULTIPLY
	STA	<MATRIX_B
	EOR	#$FFFF
	INC	A
	STA	<MATRIX_C
	;JSR	|GET_COS
	LDA	>COS_TAB,X
	JSR	|MULTIPLY
	STA	<MATRIX_D
	RTS

;GET_SIN	LDA	>SIN_TAB,X
;	JMP	|MULTIPLY

;GET_COS	LDA	>COS_TAB,X
;	JMP	|MULTIPLY

MULTIPLY	ShortA
	STA	<ROT_TEMP
	LDA	<X_SCALE
	STA	|M7A
	LDA	<X_SCALE+1
	STA	|M7A
	LDA	<ROT_TEMP
	STA	|M7B
	;NOP
	;NOP
	;NOP
	;NOP
	;NOP
	;NOP
	LongA
	LDA	|MPYM
	RTS
