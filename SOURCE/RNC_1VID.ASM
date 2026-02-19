65C816

	#INCLUDE "816CONST.ASM"
	#INCLUDE "MACROS.ASM"
	#INCLUDE "SNES_IO.ASM"
	LONGS
;-------------------------------------------------------------------------
; PROPACK Unpack (to VIDEO RAM) Source Code - Super NES, Method 1
;
; Copyright (c) 1992-93 Rob Northen Computing, UK
;
; File: RNC_1VID.S
;
; Date: 24.03.93
;-------------------------------------------------------------------------

; Source code written for Cross Product's SNASM Development System

;-------------------------------------------------------------------------
; PROPACK Unpack Routine (to VIDEO RAM) - Super NES, Method 1
;
; To unpack a PROPACK Method 1 packed file to VIDEO RAM.
;
; The unpacked file MUST be an even number of bytes in length, since all
; writes to VIDEO RAM are in words. The packed and unpacked files must
; not exceed 64K in length.
;
; Prior to ASSEMBLING this code you must:
;
; (1) Equate the workspace buffers BUFF1 and BUFF2.
;
; (2) Equate the DICSIZ, dictionary buffer size variable (if necessary).
;     The buffer size must be greater than or equal to the size of the
;     buffer specified with the "-d" option when the files were packed
;     with PROPACK. Either change the DICSIZ value or re-pack the files
;     with the new buffer size. The default "-d" value is 32K.
;
; (3) Set the BANKCHECK conditional assembly flag to "1" if any packed
;     files cross ROM banks.
;
; (4) Set the BANKBASE variable to the base address of the ROM banks. This
;     will be either $8000 for 32K ROM banks or $0 for 64K ROM banks.
;     $8000 means that your packed files occupy the upper 32K of each ROM
;     bank.
;
; Prior to CALLING this function you must:
;
; (1) set up the VIDEO RAM ADDRESSES, $002116 (low byte) and $002117 (high
;     byte) with the address in video ram you want the packed file
;     unpacked to.
;
; (2) set up the VIDEO RAM MODE to auto increment on writes to the high
;     byte video ram address ($2119).
;
; To call (assumes 16-bit accumulator)
;
;           PEA pack_file&$FFFF     ; push low word of packed file
;           PEA ^pack_file          ; push high word of packed file
;           JSL UNPACKM1VID         ; unpack file to VIDEO RAM
;           PLA
;           PLA
;
; On exit,
;
; A, X, Y undefined, M=0, X=0
;-------------------------------------------------------------------------

;-------------------------------------------------------------------------
; Conditional Assembly Flags
;-------------------------------------------------------------------------

BANKCHECK	EQU	0	; 0 = all of packed file in same ROM
			; 1 = packed file can cross ROM banks

BANKBASE	EQU	$8000	; base address of ROM bank ($8000 or 0)


	EXTERN	UNPACK_BUFFER.L

BUFF2	EQU	UNPACK_BUFFER	;$7E8000	; 24-bit address of $1A0+DICSIZ byte buffer
TMPTAB	EQU	BUFF2	; indexed from BUFF2
RAWTAB	EQU	TMPTAB+$20	; indexed from BUFF2
POSTAB	EQU	RAWTAB+$80	; indexed from BUFF2
SLNTAB	EQU	POSTAB+$80	; indexed from BUFF2
DICBUF	EQU	SLNTAB+$80	; indexed from BUFF2

;-------------------------------------------------------------------------
; Equates
;-------------------------------------------------------------------------

	SEGMENT	'banklowRAM'


IN	DS.L
DICPTR	DS.W
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
VIDFLG	DS.W

;-------------------------------------------------------------------------
; Constants
;-------------------------------------------------------------------------

DICSIZ	EQU	$400	; size of the dictionary buffer
			; this value must be >= buffer size
			; specified with -d<n> option when
			; file was packed with PROPACK.
VIDRAM_LO	EQU	$2118	; low byte address of output port
VIDRAM_HI	EQU	$2119	; high byte address of output port


;-------------------------------------------------------------------------
; Add immediate value to packed file pointer (IN)
; On entry,
;   carry must be clear
;-------------------------------------------------------------------------
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

;-------------------------------------------------------------------------
; Increment packed file pointer (IN)
;-------------------------------------------------------------------------
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
	JSR	GETWORDSUB
	#ENDIF

	MEND

;-------------------------------------------------------------------------


	Segment	'bank0ROM'


;           PEA pack_file&$FFFF     ; push low word of packed file
;           PEA ^pack_file          ; push high word of packed file
;           JSL UNPACKM1VID         ; unpack file to VIDEO RAM
;           PLA
;           PLA

	; Y VRAM Address
	; X source data
	; A source data BANK

	AssertM16X16
.UNPACKM1VID
	STY	|VMADDL	; start of VRAM address
	STX	<IN
	STA	<IN+2
	ShortA
	LDA	#SEG BUFF2	; data bank @ buffer
	PHA
	ASSUME	databank BUFF2 AND $FF0000
	PLB
	LongA
	ADDIN	$11
	LDA	[IN]
	AND	#$FF
	STA	<BLOCKS
	INCIN
	GETWORD
	STA	<BITBUFL
	STZ	<BUFBITS
	LDA	#2
	JSR	|GBITM1V
	LDA	#$5555
	STA	<VIDFLG
	STZ	<DICPTR
UNPKM1V2
	LDY	#OFFSET RAWTAB
	JSR	|MHUFM1V
	LDY	#OFFSET POSTAB
	JSR	|MHUFM1V
	LDY	#OFFSET SLNTAB
	JSR	|MHUFM1V
	LDA	#16
	JSR	|GBITM1V
	STA	<COUNTS
	JMP	|UNPKM1V16

UNPKM1V3
	LDY	#OFFSET POSTAB
	JSR	|GVALM1V
	STA	<TEMP3
	LDA	<DICPTR
	CLC
	SBC	<TEMP3
	BCS	UNPKM1V4
	ADC	#DICSIZ
UNPKM1V4
	PHA	         ; source data buffer pointer
	LDY	#OFFSET SLNTAB
	JSR	|GVALM1V
	INC	A
	INC	A
	STA	<TEMP1
	PLY
UNPKM1V5
	LDX	<DICPTR
	LDA	<VIDFLG-1
	BMI	UNPKM1V12           ; branch if write to VIDRAM_HI next
	TYA
	CMP	<DICPTR
	BCS	UNPKM1V6
	TXA
	SEC
UNPKM1V6
	SBC	#DICSIZ
	EOR	#$FFFF
	INC	A
	CMP	<TEMP1
	BCC	UNPKM1V7
	LDA	<TEMP1
UNPKM1V7
	LSR	A
	BEQ	UNPKM1V11
	PHP
	STA	<TEMP2
	LDA	<TEMP1
	SEC
	SBC	<TEMP2
	SBC	<TEMP2
	STA	<TEMP1
	LDA	<TEMP3
	BNE	UNPKM1V9
	ShortA
	LDA	|DICBUF,Y
	XBA
	LDA	|DICBUF,Y
	LongA
UNPKM1V8
	STA	|DICBUF,X	; write word
	STA	>VIDRAM_LO	; write word
	INX
	INX
	DEC	<TEMP2
	BNE	UNPKM1V8
	TXY
	DEY
	BRA	UNPKM1V10
UNPKM1V9
	LDA	|DICBUF,Y	; read word
	STA	|DICBUF,X	; write word
	STA	>VIDRAM_LO	; write word
	INY
	INY
	INX
	INX
	DEC	<TEMP2
	BNE	UNPKM1V9
UNPKM1V10
	PLP
UNPKM1V11
	BCC	UNPKM1V15
UNPKM1V12
	ShortA
	LDA	|DICBUF,Y	;  read byte
	STA	|DICBUF,X	; write byte
	ASL	<VIDFLG
	BCC	UNPKM1V13
	INC	<VIDFLG
	STA	>VIDRAM_HI	; write byte
	BRA	UNPKM1V14
UNPKM1V13
	STA	>VIDRAM_LO	; write byte
UNPKM1V14
	LongA
	INY
	INX
	DEC	<TEMP1
UNPKM1V15
	TYA
	AND	#DICSIZ-1
	TAY
	TXA
	AND	#DICSIZ-1
	STA	<DICPTR
	LDA	<TEMP1
	BEQ	UNPKM1V16
	JMP	|UNPKM1V5
UNPKM1V16
	LDY	#OFFSET RAWTAB
	JSR	|GVALM1V
	TAY
	BNE	UNPKM1V17
	JMP	|UNPKM1V29
UNPKM1V17
	STA	<TEMP1
	LDX	<DICPTR
	LDY	#0
	LDA	<VIDFLG-1
	BMI	UNPKM1V22	; branch if write to VIDRAM_HI next
	LDA	#DICSIZ
	SEC
	SBC	<DICPTR	; bytes before output buffer pointer wrap-round
	CMP	<TEMP1
	BCC	UNPKM1V18
	LDA	<TEMP1
UNPKM1V18
	#IF	BANKCHECK EQ 1
	#IF	BANKBASE GT 0	; if 64K ROMs [<IN],Y can cross ROMs
	STA	<TEMP2	; therefore skip bytes length check
	LDA	#0	; before end of ROM
	SEC
	SBC	<IN
	CMP	<TEMP2
	BCC	UNPKM1V19
	LDA	<TEMP2
UNPKM1V19
	#ENDIF
	#ENDIF
	LSR	A
	BEQ	UNPKM1V21
	PHP
	STA	<TEMP2
UNPKM1V20
	LDA	[IN],Y	; read word
	STA	|DICBUF,X	; write word
	STA	>VIDRAM_LO	; write word
	INY
	INY
	INX
	INX
	DEC	<TEMP2
	BNE	UNPKM1V20
	PLP
UNPKM1V21
	BCC	UNPKM1V25
UNPKM1V22
	ShortA
	LDA	[IN],Y
	STA	|DICBUF,X
	ASL	<VIDFLG
	BCC	UNPKM1V23
	INC	<VIDFLG
	STA	>VIDRAM_HI
	BRA	UNPKM1V24
UNPKM1V23
	STA	>VIDRAM_LO
UNPKM1V24
	LongA
	CLC
	INY
	INX
UNPKM1V25
	TYA
	ADC	<IN
	#IF	BANKCHECK EQ 1
	BCC	UNPKM1V26
	#IF	BANKBASE GT 0
	ORA	#BANKBASE
	#ENDIF
	INC	<IN+2
UNPKM1V26
	#ENDIF
	STA	<IN
	TXA
	AND	#DICSIZ-1
	STA	<DICPTR
	STY	<TEMP2
	LDA	<TEMP1
	SEC
	SBC	<TEMP2
	BNE	UNPKM1V17
	STZ	<BITBUFH
	LDA	<BUFBITS
	TAY
	ASL	A
	TAX
	GETWORD
	CPY	#0
	BEQ	UNPKM1V28
UNPKM1V27
	ASL	A
	ROL	<BITBUFH
	DEY
	BNE	UNPKM1V27
UNPKM1V28
	STA	<TEMP1
	LDA	>MTABM1V,X
	AND	<BITBUFL
	ORA	<TEMP1
	STA	<BITBUFL
UNPKM1V29
	DEC	<COUNTS
	BEQ	UNPKM1V30
	JMP	|UNPKM1V3
UNPKM1V30
	DEC	<BLOCKS
	BEQ	UNPKM1V31
	JMP	|UNPKM1V2
UNPKM1V31
	PLB		; restore old data bank
	RTS

;-------------------------------------------------------------------------

GVALM1V
	LDX	<BITBUFL
	BRA	GVALM1V3
GVALM1V2
	INY
	INY
GVALM1V3
	TXA
	AND	|BUFF2,Y
	INY
	INY
	CMP	|BUFF2,Y
	BNE	GVALM1V2
	TYA
	ADC	#{15 mult 4+1}
	TAY
	LDA	|BUFF2,Y
	PHA
	XBA
	AND	#$FF
	JSR	|GBITM1V
	PLA
	AND	#$FF
	CMP	#2
	BCC	GVALM1V4
	DEC	A
	ASL	A
	PHA
	LSR	A
	JSR	|GBITM1V
	PLX
	ORA	>BTABM1V,X
GVALM1V4
	RTS

BTABM1V
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

;-------------------------------------------------------------------------

GBITM1V
	TAY
	ASL	A
	TAX
	LDA	>MTABM1V,X
	AND	<BITBUFL
	PHA
	LDA	<BITBUFH
	LDX	<BUFBITS
	BEQ	GBITM1V3
GBITM1V2
	LSR	A
	ROR	<BITBUFL
	DEY
	BEQ	GBITM1V4
	DEX
	BEQ	GBITM1V3
	LSR	A
	ROR	<BITBUFL
	DEY
	BEQ	GBITM1V4
	DEX
	BNE	GBITM1V2
GBITM1V3
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
	BRA	GBITM1V2
GBITM1V4
	DEX
	STX	<BUFBITS
	STA	<BITBUFH
	PLA
GBITM1V5
	RTS

MTABM1V
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

;-------------------------------------------------------------------------

MHUFM1V
	STY	<TEMP4
	LDA	#5
	JSR	|GBITM1V
	BEQ	GBITM1V5
	STA	<TEMP1
	STA	<TEMP2
	LDY	#0
MHUFM1V2
	PHY
	LDA	#4
	JSR	|GBITM1V
	PLY
	STA	|BUFF2,Y
	INY
	INY
	DEC	<TEMP2
	BNE	MHUFM1V2
	STZ	<HUFCDE
	LDA	#$8000
	STA	<HUFBSE
	LDA	#1
	STA	<BITLEN
MHUFM1V3
	LDA	<BITLEN
	LDX	<TEMP1
	LDY	#0
MHUFM1V4
	CMP	|BUFF2,Y
	BNE	MHUFM1V8
	PHX
	STY	<TEMP3
	ASL	A
	TAX
	LDA	>MTABM1V,X
	LDY	<TEMP4
	STA	|BUFF2,Y
	INY
	INY
	LDA	#16
	SEC
	SBC	<BITLEN
	PHA
	LDA	<HUFCDE
	STA	<TEMP2
	LDX	<BITLEN
MHUFM1V5
	ASL	<TEMP2
	ROR	A
	DEX
	BNE	MHUFM1V5
	PLX
	BEQ	MHUFM1V7
MHUFM1V6
	LSR	A
	DEX
	BNE	MHUFM1V6
MHUFM1V7
	STA	|BUFF2,Y
	INY
	INY
	STY	<TEMP4
	TYA
	CLC
	ADC	#15 MULT 4
	TAY
	LDA	<BITLEN
	XBA
	ShortA
	LDA	<TEMP3
	LSR A
	LongA
	CLC
	STA	|BUFF2,Y
	LDA	<HUFBSE
	ADC	<HUFCDE
	STA	<HUFCDE
	LDA	<BITLEN
	LDY	<TEMP3
	PLX
MHUFM1V8
	INY
	INY
	DEX
	BNE	MHUFM1V4
	LSR	<HUFBSE
	INC	<BITLEN
	CMP	#16
	BNE	MHUFM1V3
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
	LDA	[IN]	   ; read byte
	XBA
	LongA
	DEC	<IN+2
	#IF	BANKBASE GT 0
	STZ	<IN
	#ENDIF
GETWORDSUB2
	DEC	<IN
	RTS
	#ENDIF


	END
