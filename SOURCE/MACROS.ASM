; *************************************************************************
; General purpose macros.			Hybrid 24/7/92  Version 1
; 
; Requires previous #include of 816const.h
; *************************************************************************


; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; Manipulation of the M,X bits individually requires a record of the INSET
; state to update it accordingly. This macro keeps a record of it; use
; instead of ANY INSET directive.
; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Last_Inset CEQU m1x1

UpdateInset	MACRO	newins
Last_Inset	CEQU	newins
	INSET	newins
	MEND


; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; Setting up of M, X bits in all possible states, including INSET directives
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;SetM8X8	; A=8 X/Y=8
ShortAI	MACRO
	SEP	#Mflag+Xflag
	UpdateInset m1x1
	MEND

;SetM16X16	; A=16 X/Y=16
LongAI	MACRO
	REP	#Mflag+Xflag
	UpdateInset m0x0
	MEND

;SetM8X16	; A=8 X/Y=16
ShortA_LongI	MACRO
	SEP	#Mflag
	REP	#Xflag
	UpdateInset m1x0
	MEND

;SetM16X8	; A=16 X/Y=8
LongA_ShortI	MACRO
	REP	#Mflag
	SEP	#Xflag
	UpdateInset m0x1
	MEND

; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; 4 alternatives, to manipulate bits individually
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;SetM8	; A = 8 bits
ShortA	MACRO
	SEP	#Mflag
	#IF	{Last_Inset eq m0x0} or {Last_Inset eq m1x0}
	UpdateInset m1x0
	#ELSE
	UpdateInset m1x1
	#ENDIF
	MEND

;SetM16	; A = 16 bits
LongA	MACRO
	REP	#Mflag
	#IF	{Last_Inset eq m0x0} or {Last_Inset eq m1x0}
	UpdateInset m0x0
	#ELSE
	UpdateInset m0x1
	#ENDIF
	MEND

;SetX8	; X,Y index at 8 bits
ShortI	MACRO
	SEP	#Xflag
	#IF	{Last_Inset eq m0x0} or {Last_Inset eq m0x1}
	UpdateInset m0x1
	#ELSE
	UpdateInset m1x1
	#ENDIF
	MEND

;SetX16	; X,Y index at 16 bits
LongI	MACRO
	REP	#Xflag
	#IF	{Last_Inset eq m0x0} or {Last_Inset eq m0x1}
	UpdateInset m0x0
	#ELSE
	UpdateInset m1x0
	#ENDIF
	MEND

; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; Assertion of M, X bits, for use before subroutine definition (when previous
; routine has left the assembler with the wrong state).
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

AssertM8X8	MACRO
	UpdateInset m1x1
	MEND

AssertM16X16	MACRO
	UpdateInset m0x0
	MEND

AssertM8X16	MACRO
	UpdateInset m1x0
	MEND

AssertM16X8	MACRO
	UpdateInset m0x1
	MEND

; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; Generalised ASSERT: quoted expression must be true
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

ASSERT	MACRO	expr
	#IF	{ expr } eq 0
; Assertion failed, so we want to cause an error: bad syntax is the only
; available way to do this.
	Assertion expr failed!
	#ENDIF
	MEND

; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; Load (8-bit) constant into DB
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

LoadDB	MACRO	expr
	PEA	#{ expr } mult 256	; push low/high onto stack
	PLB		; pull low
	PLB		; pull high
	MEND

; end of macros
	; slow macros
TABLE	MACRO	FOR,NEXT,TIM,ADD
	LOCAL	value
	; FOR A= @2 TO @3 ; VALUE = A*@4+@5
value	EQU	FOR
	REPEAT		; Define Lable
	WORD	{{value MULT TIM}+ADD}	; Low Byte
value	CEQU	value + 1
	UNTIL	value GT NEXT
	MEND

NOB	MACRO
	DB	&24		; BIT xx
	MEND

NOW	MACRO
	DB	&2C		; BIT xx xx
	MEND


