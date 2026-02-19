; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; Basic routines to drive the backchannel: serget, sersend
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

; Enter in any mode, call with JSL >
; Return A: EQ = byte waiting, NE no byte waiting

sergetstatus
	PHP
	ShortA
	
	LDA	>bchan_status
	AND	#$C1
	EOR	#$81			;

	PLP
	RTL

; Enter in any mode, call with JSL >
; Wait for byte and return it byte in A

serget	
	PHP				; push M
	ShortA				; DON'T modify X flag if possible!
					; NB this routine doesn't use X or Y!
	LDA	#0
	XBA				; clear top of A for 16 bit callers
	JSL	>sget_wait
	LDA	>bchan_byte
	PLP				; restore M, X
	RTL

sget_wait
	PHP
	ShortA
sget_wait_loop
	LDA	>bchan_status
	AND	#$C1			; check chan OK + byte ready bits
	CMP	#$81
	BNE	sget_wait_loop
	PLP
	RTL

; Enter in any mode, call with JSL >
; Send byte from A

sersend	PHP				; preserve M, X
	ShortA_LongI			; get full width X
					; as swap to 8 bit may trash XH,YH
	PHX				; save ALL of X
	PHY
	LDX	#low {bchan_send10-bchan_send00}
	LDY	#8

ssend_loop

	PHA
ssend_wait
	LDA	>bchan_status
	AND	#$C2
	CMP	#$80
	BNE	ssend_wait
	PLA

	ASL	A
	BCC	ssend_iszero
	INX
	INX
ssend_iszero
	PHA
	LDA	>bchan_send00,X
	PLA
	LDX	#0			; not on start bit any more

	DEY
	BNE	ssend_loop

	PLY
	PLX
	PLP
	RTL
