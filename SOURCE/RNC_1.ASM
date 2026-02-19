65C816

	#INCLUDE "816CONST.ASM"
	#INCLUDE "MACROS.ASM"
	#INCLUDE "SNES_IO.ASM"
	LONGS

;-------------------------------------------------------------------------
; PROPACK Unpack Source Code - Super NES, Method 1
;
; Copyright (c) 1992 Rob Northen Computing, UK
;
; File: RNC_1.S
;
; Date: 22.03.93
;-------------------------------------------------------------------------

; Source code written for Cross Product's SNASM Development System

;-------------------------------------------------------------------------
; PROPACK Unpack Routine - Super NES, Method 1
;
; To unpack a PROPACK Method 1 packed file.
;
; The packed and unpacked files must not exceed 64K in length.
;
; Prior to ASSEMBLING this code you must:
;
; (1) Equate the workspace buffers BUFF1 and BUFF2.
;
; (2) Set the BANKCHECK conditional assembly flag to "1" if any packed
;     files cross ROM banks.
;
; (3) Set the BANKBASE variable to the base address of the ROM banks. This
;     will be either $8000 for 32K ROM banks or $0 for 64K ROM banks.
;     $8000 means that your packed files occupy the upper 32K of each ROM
;     bank.
;
; To call (assumes 16-bit accumulator)
;
;           PEA pack_file&$FFFF     ; push low word of packed file
;           PEA ^pack_file          ; push high word of packed file
;           PEA destn_buf&$FFFF     ; push low word of output buffer
;           PEA ^destn_buf          ; push high word of output buffer
;           JSL UNPACKM1            ; unpack file to output buffer
;           PLA
;           PLA
;           PLA
;           PLA
;
; On exit,
;
; A, X, Y undefined, M=0, X=0
;---------------------------------------------------------

;---------------------------------------------------------
; Conditional Assembly Flags
;---------------------------------------------------------

BANKCHECK	EQU	1	; 0 = all of packed file in same ROM bank
			; 1 = packed file can cross ROM banks

BANKBASE	EQU	$8000	; base address of ROM bank ($8000 or 0)

;---------------------------------------------------------
; Equates
;---------------------------------------------------------

	EXTERN	UNPACK_BUFFER.L

BUFF2	EQU	UNPACK_BUFFER	;$7E8000	; 24-bit address of $1A0+DICSIZ byte buffer
TMPTAB	EQU	BUFF2	; indexed from BUFF2
RAWTAB	EQU	TMPTAB+$20	; indexed from BUFF2
POSTAB	EQU	RAWTAB+$80	; indexed from BUFF2
SLNTAB	EQU	POSTAB+$80	; indexed from BUFF2

	SEGMENT	'banklowRAM'

IN	DS.L
OUT	DS.W
WRKBUF	DS.W
	DS.B
COUNTS	DS.W
BLOCKS	DS.W
BITBUFL	DS.W
BITBUFH	DS.W
BUFBITS	DS.W
BITLEN	DS.W
HUFCDE	DS.W
HUFBSE	DS.W
TEMP1	DS.W
TEMP2	DS.W
TEMP3	DS.W
TEMP4	DS.W


;---------------------------------------------------------
; Add immediate value to packed file pointer (IN)
; On entry,
;   carry must be clear
;---------------------------------------------------------
ADDIN	MACRO	VALUE
	LOCAL	ADDIN2
			
	LDA	<IN
	ADC	#VALUE
	#IF	BANKCHECK EQ 1
	BCC	ADDIN2
	#IF	BANKBASE GT 0
	ORA	#BANKBASE	; add base address for bank
	#ENDIF
	INC	<IN+2	; increment bank number
ADDIN2
	#ENDIF
	STA	<IN

	MEND

;---------------------------------------------------------
; Increment packed file pointer (IN)
;---------------------------------------------------------
INCIN	MACRO	VALUE
	LOCAL	INCIN2

	INC	<IN
	#IF	BANKCHECK EQ 1
	BNE	INCIN2
	#IF	BANKBASE GT 0
	LDA	#BANKBASE	; base address for bank
	STA	<IN
	#ENDIF
	INC	<IN+2	; increment bank number
INCIN2
	#ENDIF

	MEND

;---------------------------------------------------------
; Fetch word from packed file without updating pointer
;---------------------------------------------------------
GETWORD	MACRO

	#IF	BANKCHECK EQ 0
	LDA	[IN]
	#ELSE
	JSR	|GETWORDSUB
	#ENDIF

	MEND

;---------------------------------------------------------

	SEGMENT	'bank0ROM'


	;LDX	#OFFSET DEST
	;LDY	#OFFSET SOURCE
	;LDA	#SEG SOURCE+{SEG DEST MULT 256}

	AssertM16X16
.UNPACKM1
	STX	<OUT	; dest low word
	STA	<IN+2
	STY	<IN

	PHB		; save current data bank
	;XBA
	PHA		; push 2 bytes
	PLB		; 0
	PLB		; make output buffer default data bank
	LDA	#OFFSET BUFF2
	STA	<WRKBUF
	LDA	#SEG BUFF2
	STA	<WRKBUF+2
	CLC
	ADDIN	$11
	LDA	[IN]
	AND	#$FF
	STA	<BLOCKS
	INCIN
	GETWORD
	STA	<BITBUFL
	STZ	<BUFBITS
	LDA	#2
	JSR	|GTBITS

UNPACK2
	LDY	#OFFSET RAWTAB
	JSR	|MAKEHUFF
	LDY	#OFFSET POSTAB
	JSR	|MAKEHUFF
	LDY	#OFFSET SLNTAB
	JSR	|MAKEHUFF
	LDA	#16
	JSR	|GTBITS
	STA	<COUNTS
	JMP	|UNPACK8

UNPACK3
	LDY	#OFFSET POSTAB
	JSR	|GTVAL
	STA	<TEMP2
	LDA	<OUT
	CLC
	SBC	<TEMP2
	STA	<TEMP3
	LDY	#OFFSET SLNTAB
	JSR	|GTVAL
	INC	A
	INC	A
	LSR	A
	TAX
	LDY	#0
	LDA	<TEMP2
	BNE	UNPACK5
	ShortA		; 8-bit accumulator
	LDA	(TEMP3),Y
	XBA
	LDA	(TEMP3),Y
	LongA		; 16-bit accumulator
UNPACK4
	STA	(OUT),Y
	INY
	INY
	DEX
	BNE	UNPACK4
	BRA	UNPACK6
UNPACK5
	LDA	(TEMP3),Y
	STA	(OUT),Y
	INY
	INY
	DEX
	BNE	UNPACK5
UNPACK6
	BCC	UNPACK7
	ShortA		; 8-bit accumulator
	LDA	(TEMP3),Y
	STA	(OUT),Y
	INY
	LongA		; 16-bit accumulator, clear carry
	CLC
UNPACK7
	TYA
	ADC	<OUT
	STA	<OUT

UNPACK8
	LDY	#OFFSET RAWTAB
	JSR	|GTVAL
	TAX
	BNE	UNPACK9
	JMP	|UNPACK17
UNPACK9
	STA	<TEMP1
	#IF	BANKCHECK EQ 1
	#IF	BANKBASE GT 0	; if 64K ROMs [<IN],Y can cross ROMs
	LDA	#0	; before end of ROM
	SEC
	SBC	<IN
	CMP	<TEMP1
	BCC	UNPACK10
	LDA	<TEMP1
UNPACK10
	#ENDIF
	#ENDIF
	LDY	#0
	LSR	A
	BEQ	UNPACK12
	TAX
UNPACK11
	LDA	[IN],Y	; read word
	STA	(OUT),Y	; write word
	INY
	INY
	DEX
	BNE	UNPACK11
UNPACK12
	BCC	UNPACK13
	ShortA
	LDA	[IN],Y	; read byte
	STA	(OUT),Y	; write byte
	LongA
	CLC
	INY
UNPACK13
	TYA
	ADC	<IN

	#IF	BANKCHECK EQ 1
	BCC	UNPACK14
	#IF	BANKBASE GT 0
	ORA	#BANKBASE
	#ENDIF
	INC	<IN+2
	CLC
UNPACK14
	#ENDIF

	STA	<IN
	TYA
	ADC	<OUT
	STA	<OUT
	STY	<TEMP2
	LDA	<TEMP1
	SEC
	SBC	<TEMP2
	BNE	UNPACK9

	STZ	<BITBUFH
	LDA	<BUFBITS
	TAY
	ASL	A
	TAX
	GETWORD
	CPY	#0
	BEQ	UNPACK16
UNPACK15
	ASL	A
	ROL	<BITBUFH
	DEY
	BNE	UNPACK15
UNPACK16
	STA	<TEMP1
	LDA	>MSKTAB,X
	AND	<BITBUFL
	ORA	<TEMP1
	STA	<BITBUFL
UNPACK17
	DEC	<COUNTS
	BEQ	A1
	JMP	|UNPACK3
A1
	DEC	<BLOCKS
	BEQ	A2
	JMP	|UNPACK2
A2
	PLB		; restore old data bank
	RTS

;-----------------------------------------------------------

GTVAL
	LDX	<BITBUFL
	BRA	GTVAL3
GTVAL2
	INY
	INY
GTVAL3
	TXA
	AND	[WRKBUF],Y
	INY
	INY
	CMP	[WRKBUF],Y
	BNE	GTVAL2
	TYA
	ADC	#{15 MULT 4+1}
	TAY
	LDA	[WRKBUF],Y
	PHA
	XBA
	AND	#$FF
	JSR	|GTBITS
	PLA
	AND	#$FF
	CMP	#2
	BCC	GTVAL4
	DEC	A
	ASL	A
	PHA
	LSR	A
	JSR	|GTBITS
	PLX
	ORA	>BITTAB,X
GTVAL4
	RTS

BITTAB
	WORD	1
	WORD	2
	WORD	4
	WORD	8
	WORD	$10
	WORD	$20
	WORD	$40
	WORD	$80
	WORD	$100
	WORD	$200
	WORD	$400
	WORD	$800
	WORD	$1000
	WORD	$2000
	WORD	$4000
	WORD	$8000

;-----------------------------------------------------------

GTBITS
	TAY
	ASL	A
	TAX
	LDA	>MSKTAB,X
	AND	<BITBUFL
	PHA
	LDA	<BITBUFH
	LDX	<BUFBITS
	BEQ	GTBITS3
GTBITS2
	LSR	A
	ROR	<BITBUFL
	DEY
	BEQ	GTBITS5
	DEX
	BEQ	GTBITS3
	LSR	A
	ROR	<BITBUFL
	DEY
	BEQ	GTBITS5
	DEX
	BNE	GTBITS2
GTBITS3
	#IF	BANKCHECK EQ 1
	CLC
	ADDIN	2
	GETWORD
	#ELSE
	INC	<IN
	INC	<IN
	LDA	[IN]
	#ENDIF

	LDX	#16
	BRA	GTBITS2
GTBITS5
	DEX
	STX	<BUFBITS
	STA	<BITBUFH
	PLA
GTBITS6
	RTS

MSKTAB
	WORD	0
	WORD	1
	WORD	3
	WORD	7
	WORD	$F
	WORD	$1F
	WORD	$3F
	WORD	$7F
	WORD	$FF
	WORD	$1FF
	WORD	$3FF
	WORD	$7FF
	WORD	$FFF
	WORD	$1FFF
	WORD	$3FFF
	WORD	$7FFF
	WORD	$FFFF

;-----------------------------------------------------------

MAKEHUFF
	STY	<TEMP4
	LDA	#5
	JSR	|GTBITS
	BEQ	GTBITS6
	STA	<TEMP1
	STA	<TEMP2
	LDY	#0
MAKEHUFF2
	PHY
	LDA	#4
	JSR	|GTBITS
	PLY
	STA	[WRKBUF],Y
	INY
	INY
	DEC	<TEMP2
	BNE	MAKEHUFF2
	STZ	<HUFCDE
	LDA	#$8000
	STA	<HUFBSE
	LDA	#1
	STA	<BITLEN
MAKEHUFF3
	LDA	<BITLEN
	LDX	<TEMP1
	LDY	#0
MAKEHUFF4
	CMP	[WRKBUF],Y
	BNE	MAKEHUFF8
	PHX
	STY	<TEMP3
	ASL	A
	TAX
	LDA	>MSKTAB,X
	LDY	<TEMP4
	STA	[WRKBUF],Y
	INY
	INY
	LDA	#16
	SEC
	SBC	<BITLEN
	PHA
	LDA	<HUFCDE
	STA	<TEMP2
	LDX	<BITLEN
MAKEHUFF5
	ASL	<TEMP2
	ROR	A
	DEX
	BNE	MAKEHUFF5
	PLX
	BEQ	MAKEHUFF7
MAKEHUFF6
	LSR	A
	DEX
	BNE	MAKEHUFF6
MAKEHUFF7
	STA	[WRKBUF],Y
	INY
	INY
	STY	<TEMP4
	TYA
	CLC
	ADC	#{15 MULT 4}
	TAY
	LDA	<BITLEN
	XBA
	ShortA		; 8-bit accumulator
	LDA	<TEMP3
	LSR A
	LongA
	CLC
	STA	[WRKBUF],Y
	LDA	<HUFBSE
	ADC	<HUFCDE
	STA	<HUFCDE
	LDA	<BITLEN
	LDY	<TEMP3
	PLX
MAKEHUFF8
	INY
	INY
	DEX
	BNE	MAKEHUFF4
	LSR	<HUFBSE
	INC	<BITLEN
	CMP	#16
	BNE	MAKEHUFF3
	RTS

	#IF	BANKCHECK EQ 1
GETWORDSUB
	LDA	[IN]
	INC	<IN
	BNE	GETWORDSUB2
	#IF	BANKBASE GT 0
	SEC
	ROR	<IN
	#ENDIF
	INC	<IN+2
	ShortA
	XBA
	LDA	[IN]	; read byte
	XBA
	LongA		; 16-bit accumulator
	DEC	<IN+2
	#IF	BANKBASE GT 0
	STZ	<IN
	#ENDIF
GETWORDSUB2
	DEC	<IN
	RTS

	#ENDIF

	END


