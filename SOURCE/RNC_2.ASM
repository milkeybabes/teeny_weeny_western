65C816

	#INCLUDE "816CONST.ASM"
	#INCLUDE "MACROS.ASM"
	#INCLUDE "SNES_IO.ASM"
	LONGS
;-------------------------------------------------------------------------
; PROPACK Unpack Source Code - Super NES, Method 2
;
; Copyright (c) 1992 Rob Northen Computing, UK
;
; File: RNC_2.S
;
; Date: 24.03.93
;-------------------------------------------------------------------------

; Source code written for Cross Product's SNASM Development System

;-------------------------------------------------------------------------
; PROPACK Unpack Routine - Super NES, Method 2
; (enhancement by Robert Trevellyan)
;
; To unpack a PROPACK Method 2 packed file.
;
; The packed and unpacked files must not exceed 64K in length.
;
; Prior to ASSEMBLING this code you must:
;
; (1) Equate the workspace buffer BUFF1.
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
;           JSL UNPACKM2	; unpack file to output buffer
;           PLA
;           PLA
;           PLA
;           PLA
;
; On exit,
;
; registers A, X, Y are undefined, status bits M=0, X=0
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

	SEGMENT	'banklowRAM'

IN	DS.L
OUT	DS.W
SPOS	DS.W
	DS.B
SLEN	DS.W
TEMP1	DS.W

;---------------------------------------------------------
; Macros
;---------------------------------------------------------

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
	CLC
	#IF	BANKBASE GT 0
	ORA	#BANKBASE	; add base address for bank
	#ENDIF
	INC	<IN+2	; increment bank number
ADDIN2
	#ENDIF
	STA	<IN

	MEND

;---------------------------------------------------------
; Increment packed file pointer without corrupting accumulator
;---------------------------------------------------------
INCIN	MACRO
	LOCAL	INCIN2

	#IF	BANKCHECK EQ 1
	INC	<IN
	BNE	INCIN2
	INC	<IN+1
	BNE	INCIN2
	#IF	BANKBASE EQ $8000
	SEC
	ROR	<IN+1
	#ENDIF
	INC	<IN+2
INCIN2
	#ELSE
	INY
	#ENDIF

	MEND

;---------------------------------------------------------
; Reload accumulator with next byte from packed file
;---------------------------------------------------------
GETIN	MACRO

	#IF	BANKCHECK EQ  1
	LDA	[IN]
	#ELSE
	LDA	[IN],Y
	#ENDIF

	INCIN
	MEND

;---------------------------------------------------------
; Reload accumulator with next byte from packed file
;---------------------------------------------------------
RELOAD	MACRO
	GETIN
	ROL A
	MEND

;---------------------------------------------------------
; move next bit from accumulator into carry
;---------------------------------------------------------
GETBIT	MACRO
	ASL A
	MEND

;---------------------------------------------------------
; Copy one byte from packed file to output buffer
;---------------------------------------------------------
GETBYTE	MACRO
	LOCAL	GETBYTE2

	GETIN
	STA	(OUT)
	INC	<OUT
	BNE	GETBYTE2
	INC	<OUT+1
GETBYTE2
	MEND

;---------------------------------------------------------
; Long BEQ
;---------------------------------------------------------
JEQ	MACRO	ADD
	BNE	*+5
	JMP	|ADD
	MEND

;---------------------------------------------------------

	Segment	'bank0ROM'

	AssertM16X16
.UNPACKM2
	STX	<OUT
	STY	<IN
	STA	<IN+2

	ShortA
	CLC
	PHB	         ; save current data bank
	XBA
	PHA
	PLB	         ; make output buffer default data bank
	STZ	<SPOS+2
	STZ	<SLEN+1
	LDX	#0

	#IF	BANKCHECK EQ 1
	LongA
	CLC
	ADDIN	18
	ShortA
	SEC	
	#ELSE
	LDY	#18	; skip 18 byte pack header
	#ENDIF

	RELOAD
	GETBIT
	JMP	|XLOOP

;---------------------------------------------------------

FETCH0
	RELOAD
	BRA	BACK0

RAW
	LDX	#4
X4BITS
	GETBIT
	BEQ	FETCH0
BACK0
	ROL	<SPOS+1
	DEX
	BNE	X4BITS
	PHA
	LongA
	CLC
	#IF	BANKCHECK EQ 0
	TYA
	ADC	<IN
	STA	<IN
	#ENDIF

	LDY	#0
	LDA	<SPOS+1
	ADC	#3
	ASL	A
	ASL	A
RAWLP
	STA	<SLEN
	#IF	BANKCHECK EQ 1
	LDA	#0
	SEC
	SBC	<IN
	CMP	<SLEN
	BCC	RAWLP2
	LDA	<SLEN
RAWLP2
	#ENDIF
	STA	<TEMP1
	LSR	A
	BEQ	RAWLP4
	TAX
RAWLP3
	LDA	[IN],Y
	STA	(OUT),Y
	INY
	INY
	DEX
	BNE	RAWLP3
RAWLP4
	BCC	RAWLP5
	ShortA
	LDA	[IN],Y
	STA	(OUT),Y
	LongA
	CLC
	INY
RAWLP5
	TYA
	ADC	<OUT
	STA	<OUT

	#IF	BANKCHECK EQ 1
	TYA
	ADC	<IN
	BCC	RAWLP6
	#IF	BANKBASE GT 0
	ORA	#BANKBASE
	#ENDIF
	INC	<IN+2
RAWLP6
	STA	<IN
	LDY	#0
	LDA	<SLEN
	SEC
	SBC	<TEMP1
	BNE	RAWLP
	#ENDIF

	ShortA
	PLA
	JMP	|XLOOP

;---------------------------------------------------------

FETCH1
	RELOAD
	JMP	|BACK1
FETCH2
	RELOAD
	BRA	BACK2
FETCH3
	RELOAD
	BRA	BACK3
FETCH4
	RELOAD
	BRA	BACK4
FETCH5
	RELOAD
	BRA	BACK5
FETCH6
	RELOAD
	BRA	BACK6
FETCH7
	RELOAD
	BRA	BACK7

GTLEN
	GETBIT
	JEQ	FETCH1
BACK1
	ROL	<SLEN
	GETBIT
	BEQ	FETCH2
BACK2
	BCC	COPY
	GETBIT
	BEQ	FETCH3
BACK3
	DEC	<SLEN
	ROL	<SLEN
	LDX	<SLEN
	CPX	#9
	JEQ	RAW
	LDX	#0

;---------------------------------------------------------

COPY
	GETBIT
	BEQ	FETCH4
BACK4
	BCC	BYTEDISP
	GETBIT
	BEQ	FETCH5
BACK5
	ROL	<SPOS+1
	GETBIT
	BEQ	FETCH6
BACK6
	BCC	R1
	JMP	|BIGDISP
R1
	CPX	<SPOS+1
	BNE	BYTEDISP
	INC	<SPOS+1
ANOTHER
	GETBIT
	BEQ	FETCH7
BACK7
	ROL	<SPOS+1
BYTEDISP
	PHA
	GETIN
	STA	<SPOS
	PHY
	LongA
	CLC
	LDA	<SPOS
	PHA
	LDA	<OUT
	SBC	<SPOS
	STA	<SPOS
	LDY	#0
	LSR	<SLEN
	LDX	<SLEN
	PLA
	BNE	BYTEDISP3
	ShortA
	LDA	(SPOS),Y
	XBA
	LDA	(SPOS),Y
	LongA
BYTEDISP2
	STA	(OUT),Y
	INY
	INY
	DEX
	BNE	BYTEDISP2
	BRA	BYTEDISP4
BYTEDISP3
	LDA	(SPOS),Y
	STA	(OUT),Y
	INY
	INY
	DEX
	BNE	BYTEDISP3
BYTEDISP4
	ShortA
	BCC	BYTEDISP5
	LDA	(SPOS),Y
	STA	(OUT),Y
BYTEDISP5
	TYA
	ADC	<OUT
	STA	<OUT
	BCC	S1
	INC	<OUT+1
S1
	PLY
	PLA
	BRA	XLOOP

;---------------------------------------------------------

GTBITSM2
	RELOAD
	BCS	STRING
XBYTE
	XBA
	GETBYTE
	XBA
XLOOP
	GETBIT
	BCS	CHKZ
	XBA
	GETBYTE
	XBA
	GETBIT
	BCC	XBYTE
CHKZ
	BEQ	GTBITSM2

;---------------------------------------------------------

STRING
	STZ	<SPOS+1
	STZ	<SLEN
	INC	<SLEN
	INC	<SLEN
	GETBIT
	BEQ	FETCH8
BACK8
	BCS	SMALLS
	JMP	|GTLEN
SMALLS
	GETBIT
	BEQ	FETCH9
BACK9
	BCS	D1
	JMP	|BYTEDISP
D1
	INC	<SLEN
	GETBIT
	BEQ	FETCH10
BACK10
	BCS	E1
	JMP	|COPY
E1
	XBA
	GETIN
	STA	<SLEN
	XBA
	CPX	<SLEN
	BEQ	OVERNOUT
	XBA
	LDA	<SLEN
	CLC
	ADC	#8
	STA	<SLEN
	XBA
	JMP	|COPY
BIGDISP
	GETBIT
	BEQ	FETCH11
BACK11
	XBA
	LDA	<SPOS+1
	ROL	A
	ORA	#4
	STA	<SPOS+1
	XBA
	GETBIT
	BEQ	FETCH12
BACK12
	BCC	A1
	JMP	|BYTEDISP
A1
	JMP	|ANOTHER
FETCH8
	RELOAD
	BRA	BACK8
FETCH9
	RELOAD
	JMP	|BACK9
FETCH10
	RELOAD
	JMP	|BACK10
FETCH11
	RELOAD
	BRA	BACK11
FETCH12
	RELOAD
	BRA	BACK12
OVERNOUT
	GETBIT
	BNE	CHECK4END
	RELOAD
CHECK4END
	BCC	J1
	JMP	|XLOOP
J1
	PLB		; restore old data bank
	LongAI		; 16-bit AXY
	RTS



	END

