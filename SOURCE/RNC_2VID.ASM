65C816

	#INCLUDE "816CONST.ASM"
	#INCLUDE "MACROS.ASM"
	#INCLUDE "SNES_IO.ASM"
	LONGS
;-------------------------------------------------------------------------
; PROPACK Unpack (to VIDEO RAM) Source Code - Super NES, Method 2
;
; Copyright (c) 1992 Rob Northen Computing, UK
;
; File: RNC_2VID.S
;
; Date: 23.11.92
;-------------------------------------------------------------------------

; Source code written for Cross Product's SNASM Development System

;-------------------------------------------------------------------------
; PROPACK Unpack Routine (to VIDEO RAM) - Super NES, Method 2
;
; To unpack a PROPACK Method 2 packed file to VIDEO RAM.
;
; The unpacked file MUST be an even number of bytes in length, since all
; writes to VIDEO RAM are in words. Both packed and unpacked files must
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
;     with the new buffer size. The default "-d" value is 4K.
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
;           JSL UNPACKM2VID         ; unpack file to VIDEO RAM
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

	EXTERN	UNPACK_BUFFER.L

BANKCHECK	EQU	0	; 0 = all of packed file in same ROM bank
			; 1 = packed file can cross ROM banks

BANKBASE	EQU	$8000	; base address of ROM bank ($8000 or 0)

	#IF BANKBASE EQ 0
BANKCHECK	EQU 0	       ; if using 64K ROMs then indexing (,Y)
	#ENDIF	       ; is used to read bytes across ROMs



;-------------------------------------------------------------------------
; Equates
;-------------------------------------------------------------------------

BUFF2	EQU	UNPACK_BUFFER	; 24-bit address of DICSIZ byte buffer
DICBUF	EQU	BUFF2	; 24-bit address of DICSIZ byte buffer

	SEGMENT	'banklowRAM'

IN	DS.L
SPOS        	DS.W
	DS.B
SLEN        	DS.W
TEMP1       	DS.W
VIDFLG      	DS.B

;---------------------------------------------------------
; Other Equates
;---------------------------------------------------------


;---------------------------------------------------------
; Constants
;---------------------------------------------------------

DICSIZ      EQU $400	    ; size of the dictionary buffer
	 	           ; this value must be >= buffer size
	 	           ; specified with -d<n> option when
	 	           ; file was packed with PROPACK.

VIDRAM_LO   EQU $2118	   ;  low byte address of output port
VIDRAM_HI   EQU $2119	   ; high byte address of output port

;---------------------------------------------------------
; Macros
;---------------------------------------------------------


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

	#IF	BANKCHECK EQ 1
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
	ROL	A
	MEND

;---------------------------------------------------------
; move next bit from accumulator into carry
;---------------------------------------------------------
GETBIT	MACRO
	ASL	A
	MEND

;---------------------------------------------------------
; Copy one byte from packed file to output buffer
;---------------------------------------------------------
GETBYTE	MACRO
	LOCAL	GETBYTE2
	LOCAL	GETBYTE3
	LOCAL	GETBYTE4
	GETIN
	STA	|DICBUF,X
	INX
	CPX	#DICSIZ
	BNE	GETBYTE2
	LDX	#0
GETBYTE2
	ASL	<VIDFLG
	BCC	GETBYTE3
	INC	<VIDFLG
	STA	>VIDRAM_HI
	BRA	GETBYTE4
GETBYTE3
	STA	>VIDRAM_LO
GETBYTE4
	MEND

;---------------------------------------------------------
; Long BEQ
;---------------------------------------------------------
JEQ	MACRO	ADD
	BNE	*+5
	JMP	|ADD
	MEND

;---------------------------------------------------------

	segment	'bank0ROM'
	AssertM16X16
.UNPACKM2VID
	STY	|VMADDL	; start of VRAM address
	STX	<IN
	STA	<IN+2
	PHB		; save current data bank

	ShortA
	CLC
	LDA	#$55
	STA	<VIDFLG

	ASSUME	databank BUFF2 AND $FF0000
	LDA	#SEG BUFF2
	PHA
	PLB		; make output buffer default data bank
	STZ	<SPOS+2
	STZ	<SLEN+1
	LDX	#0

	#IF	BANKCHECK EQ 1
	LongA
	CLC
	LDA	<IN
	ADC	#18
	BCC	G1
	ORA	#BANKBASE	; add base address for bank
	INC	<IN+2	; increment bank number
G1
	STA	<IN
	ShortA
	CLC
	LDY	#0
	#ELSE
	LDY	#18	; skip 18 byte pack header
	#ENDIF

	RELOAD
	GETBIT
	JMP	|VXLOOP

;---------------------------------------------------------

VFETCH0
	RELOAD
	BRA	VBACK0

VRAW
	PLA
	PHX
	LDX	#4
VX4BITS
	GETBIT
	BEQ	VFETCH0
VBACK0
	ROL	<SPOS+1
	DEX
	BNE	VX4BITS
	PLX
	PHA
	LongA
	CLC
	LDA	<SPOS+1
	ADC	#3
	ASL	A
	ASL	A
	STA	<SLEN
VRAWLP
	LDA	<VIDFLG-1
	BMI	VRAWLP6
	STX	<TEMP1
	LDA	#DICSIZ
	SEC
	SBC	<TEMP1
	CMP	<SLEN
	BCC	VRAWLP2
	LDA	<SLEN
VRAWLP2
	#IF	BANKCHECK EQ 1
	STA	<TEMP1
	LDA	#0
	SEC
	SBC	<IN
	CMP	<TEMP1
	BCC	VRAWLP3
	LDA	<TEMP1
VRAWLP3
	#ENDIF
	LSR	A
	BEQ	VRAWLP5
	PHP
	STA	<TEMP1
	LDA	<SLEN
	SEC
	SBC	<TEMP1
	SBC	<TEMP1
	STA	<SLEN
VRAWLP4
	LDA	[IN],Y
	STA	|DICBUF,X
	STA	>VIDRAM_LO
	INY
	INY
	INX
	INX
	DEC	<TEMP1
	BNE	VRAWLP4
	PLP
VRAWLP5
	BCC	VRAWLP9
VRAWLP6
	ShortA
	LDA	[IN],Y
	STA	|DICBUF,X
	ASL	<VIDFLG
	BCC	VRAWLP7
	INC	<VIDFLG
	STA	>VIDRAM_HI
	BRA	VRAWLP8
VRAWLP7
	STA	>VIDRAM_LO
VRAWLP8
	LongA
	CLC
	INY
	INX
	DEC	<SLEN
VRAWLP9
	#IF	BANKCHECK EQ 1
	TYA
	ADC	<IN
	BCC	VRAWLP10
	#IF	BANKBASE GT 0
	ORA	#BANKBASE
	#ENDIF
	INC	<IN+2
VRAWLP10
	STA	<IN
	LDY	#0
	#ENDIF
	TXA
	AND	#DICSIZ-1
	TAX
	LDA	<SLEN
	BNE	VRAWLP
	ShortA
	PLA
	JMP	|VXLOOP

;---------------------------------------------------------

VFETCH1
	RELOAD
	JMP	|VBACK1
VFETCH2
	RELOAD
	BRA	VBACK2
VFETCH3
	RELOAD
	BRA	VBACK3
VFETCH4
	RELOAD
	BRA	VBACK4
VFETCH5
	RELOAD
	BRA	VBACK5
VFETCH6
	RELOAD
	BRA	VBACK6
VFETCH7
	RELOAD
	BRA	VBACK7

VGTLEN
	GETBIT
	JEQ	VFETCH1
VBACK1
	ROL	<SLEN
	GETBIT
	BEQ	VFETCH2
VBACK2
	BCC	VCOPY
	GETBIT
	BEQ	VFETCH3
VBACK3
	DEC	<SLEN
	ROL	<SLEN
	PHA
	LDA	<SLEN
	CMP	#9
	JEQ	VRAW
	PLA

;---------------------------------------------------------

VCOPY
	GETBIT
	BEQ	VFETCH4
VBACK4
	BCC	VBYTEDISP
	GETBIT
	BEQ	VFETCH5
VBACK5
	ROL	<SPOS+1
	GETBIT
	BEQ	VFETCH6
VBACK6
	BCC	Z1
	JMP	|VBIGDISP
Z1
	INC	<SPOS+1
	DEC	<SPOS+1
	BNE	VBYTEDISP
	INC	<SPOS+1
VANOTHER
	GETBIT
	BEQ	VFETCH7
VBACK7
	ROL	<SPOS+1
VBYTEDISP
	PHA
	GETIN
	STA	<SPOS
	PHY
	LongA
	CLC
	TXA
	SBC	<SPOS
	BCS	VBYTEDISP2
	ADC	#DICSIZ
VBYTEDISP2
	TAY
VBYTEDISP3
	LDA	<VIDFLG-1
	BMI	VBYTEDISP10
	STX	<TEMP1
	TYA
	CMP	<TEMP1
	BCS	VBYTEDISP4
	TXA
	SEC
VBYTEDISP4
	SBC	#DICSIZ
	EOR	#$FFFF
	INC	A
	CMP	<SLEN
	BCC	VBYTEDISP5
	LDA	<SLEN
VBYTEDISP5
	LSR	A
	BEQ	VBYTEDISP9
	PHP
	STA	<TEMP1
	LDA	<SLEN
	SEC
	SBC	<TEMP1
	SBC	<TEMP1
	STA	<SLEN
	LDA	<SPOS
	BNE	VBYTEDISP7
	ShortA
	LDA	|DICBUF,Y
	XBA
	LDA	|DICBUF,Y
	LongA
VBYTEDISP6
	STA	|DICBUF,X
	STA	>VIDRAM_LO
	INX
	INX
	DEC	<TEMP1
	BNE	VBYTEDISP6
	TXY
	DEY
	BRA	VBYTEDISP8
VBYTEDISP7
	LDA	|DICBUF,Y
	STA	|DICBUF,X
	STA	>VIDRAM_LO
	INY
	INY
	INX
	INX
	DEC	<TEMP1
	BNE	VBYTEDISP7
VBYTEDISP8
	PLP
VBYTEDISP9
	BCC	VBYTEDISP13
VBYTEDISP10
	ShortA
	LDA	|DICBUF,Y
	STA	|DICBUF,X
	ASL	<VIDFLG
	BCC	VBYTEDISP11
	INC	<VIDFLG
	STA	>VIDRAM_HI
	BRA	VBYTEDISP12
VBYTEDISP11
	STA	>VIDRAM_LO
VBYTEDISP12
	LongA
	INY
	INX
	DEC	<SLEN
VBYTEDISP13
	TXA
	AND	#DICSIZ-1
	TAX
	LDA	<SLEN
	BEQ	VBYTEDISP14
	TYA
	AND	#DICSIZ-1
	TAY
	JMP	|VBYTEDISP3
VBYTEDISP14
	ShortA
	PLY
	PLA
	BRA	VXLOOP

;---------------------------------------------------------

VGTBITSM2
	RELOAD
	BCS	VSTRING
VXBYTE
	XBA
	GETBYTE
	XBA
VXLOOP
	GETBIT
	BCS	VCHKZ
	XBA
	GETBYTE
	XBA
	GETBIT
	BCC	VXBYTE
VCHKZ
	BEQ	VGTBITSM2

;---------------------------------------------------------

VSTRING
	STZ	<SPOS+1
	STZ	<SLEN
	INC	<SLEN
	INC	<SLEN
	GETBIT
	BEQ	VFETCH8
VBACK8
	BCS	VSMALLS
	JMP	|VGTLEN
VSMALLS
	GETBIT
	BEQ	VFETCH9
VBACK9
	BCS	R1
	JMP	|VBYTEDISP
R1
	INC	<SLEN
	GETBIT
	BEQ	VFETCH10
VBACK10
	BCS S1
	JMP	|VCOPY
S1
	XBA
	GETIN
	STA	<SLEN
	XBA
	INC	<SLEN
	DEC	<SLEN
	BEQ	VOVERNOUT
	XBA
	LDA	<SLEN
	CLC
	ADC	#8
	STA	<SLEN
	XBA
	JMP	|VCOPY
VBIGDISP
	GETBIT
	BEQ	VFETCH11
VBACK11
	XBA
	LDA	<SPOS+1
	ROL	A
	ORA	#4
	STA	<SPOS+1
	XBA
	GETBIT
	BEQ	VFETCH12
VBACK12
	BCC	E1
	JMP	|VBYTEDISP
E1
	JMP	|VANOTHER
VFETCH8
	RELOAD
	BRA	VBACK8
VFETCH9
	RELOAD
	JMP	|VBACK9
VFETCH10
	RELOAD
	JMP	|VBACK10
VFETCH11
	RELOAD
	BRA	VBACK11
VFETCH12
	RELOAD
	BRA	VBACK12
VOVERNOUT
	GETBIT
	BNE	VCHECK4END
	RELOAD
VCHECK4END
	BCC	M1
	JMP	|VXLOOP
M1
	PLB	         ; restore old data bank
	LongAI
	RTS


	END
