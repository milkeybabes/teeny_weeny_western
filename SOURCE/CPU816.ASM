65C816
	LONGS

useBRK		EQU	0

; ************************************************************************
; 65C816 monitor for Em4.		Hybrid 11/01/93	Version 4
; Requires 65C816.TAB Version 7 or later.
; ************************************************************************
	
; For system-independant shadow monitor, assemble in bank 0. If the
; target system's EPROM does not start in bank 0, EM4SEND's ORing mechanism
; handles this.

	SEGMENT	byte at 0000F800-0000FF00 'code'
	SEGMENT	para at 0000FF10-0000FF1F 'backchannel'
	SEGMENT byte at 0000FF80-0000FFE0 'vecdests'
	SEGMENT	byte at 0000FFE4-0000FFFF 'vectors'

	#INCLUDE	"816const.h"
	#INCLUDE	"macros.h"

._ShadowAtr	EQU	0		; required of us!
._SPfromReset	EQU	$700		; required !!!

; Would rather not know this detail of EM4's limits, but it's that or
; assume more about the ROM mapping.
shadow_monitor_size	EQU	2 mult 1024

; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; EM4 Monitor code
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	SEGMENT	byte 'code'

	ASSUME	databank	?
	ASSUME	direct		?

shadow_monitor_start

register_list
	BYTE	0				; PC is first listed register
	BYTE	hardcall_end-hardcall_start	; why's this one needed?
	STRING	"PC",0,13,14,15, 0, 23,0,-1
	STRING	"A", 0,10,11, 0, 0, 15,0,-1
	STRING	"X", 0, 8, 9, 0, 0, 15,0,-1
	STRING	"Y", 0, 6, 7, 0, 0, 15,0,-1
	STRING	"DP",0, 3, 4, 0, 0, 15,0,-1
	STRING	"DB",0, 5, 0, 0, 0,  7,0,-1
	STRING	"S", 0, 1, 2, 0, 0, 15,0,-1
	STRING	"P", 0,12, 0, 0, 0
	STRING		7,7,"N"
	STRING		6,6,"V"
	STRING		5,5,"M"
	STRING		4,4,"X"
	STRING		3,3,"D"
	STRING		2,2,"I"
	STRING		1,1,"Z"
	STRING		0,0,"C"
	STRING		-1
	STRING	-1
register_list_end

; entry: called with JSL in native mode, M/X don't care
; Processor has stacked PB,PCH,PCL
; OR: called with BRK, stack has PB,PCH,PCL,P

monitor_entry_point

	#IF	useBRK
	#ELSE
	PHP
	#ENDIF

	SetM16X16
	PHA
	PHX
	PHY
	PHB
	PHD
	TSX
	TXA
	CLC
	ADC	#13		; 13 bytes already stacked
	PHA			; program's stack pointer

; final stack: S  D  B  Y  X  A  P PC PB
;	       1  3  5  6  8 10 12 13 15

	LDA	13,S		; now adjust for hardcall size
	SEC
	#IF	useBRK
	SBC	#2
	#ELSE
	SBC	#hardcall_end-hardcall_start-1
	#ENDIF
	STA	13,S

	SetM8
	LDA	>bchan_byte	; clear backchannel

MON_loop
	SetM16X16
	JSL	>serget			; get byte from host
	CMP	#low {{MON_despatch_end-MON_despatch}/2}
	BGE	MON_loop

;	despatch reason code from host (in A)
	ASL	A
	TAX
	JMP	(MON_despatch,X)

MON_despatch
	WORD	MON_sync		; 0
	WORD	MON_write		; 1
	WORD	MON_read		; 2
	WORD	MON_loop		; 3 - used to read registers
	WORD	MON_loop		; 4 - used to write registers
	WORD	MON_execute		; 5
	WORD	MON_loop		; 6 - used to be RAMPAUSE
	WORD	MON_write_EM4		; 7
	WORD	MON_single_step		; 8
	WORD	MON_loop		; 9 - no longer used
	WORD	MON_modify_attrs	; 10
	WORD	MON_reglist		; 11
	WORD	MON_reg_area		; 12
MON_despatch_end

MON_sync	; reply with proof of existence
	SetM8
	LDA	>bchan_status
	AND	#1 shl 4
	BNE	external_brk
	LDA	#$60
	JMP	|sync_up

external_brk
	LDA	#$60 + $80
sync_up
	JSL	>sersend
	JMP	|MON_loop

get_address
	SetM8X8
	JSL	>serget		; map byte - discard
	JSL	>serget		; lobyte of address
	TAX
	JSL	>serget		; mid byte of address
	TAY
	JSL	>serget		; hi byte address
	PHA
	PLB			; point data bank at address
	JSL	>serget		; discarded byte of address
	JSL	>serget		; number of bytes
	RTS

; write: uses only stack workspace
MON_write
	JSR	|get_address
	AssertM8X8
	PHY
	PHX			; 16 bit address on stack in order lo-hi
	TAX			; loop count
	LDY	#0
MON_write_loop
	JSL	>serget		; data byte
	STA	(1,S),Y		; store into memory
	INY			; use Y so cases where bank wraps are easy
	DEX
	BNE	MON_write_loop
	SetM16X16
	PLA			; discard address pointer
	JMP	|MON_loop


MON_read
	JSR	|get_address
	AssertM8X8
	PHY
	PHX			; 16 bit address on stack in order lo-hi
	TAX			; loop count
	LDY	#0
MON_read_loop
; now inspect address to see if it's shadow monitor space
; Note that a read from shadow monitor space HAS to have set the
; data bank to the shadow bank, as (n,S),Y cannot reach far enough in 8 bit
; index mode.
	PHB
	PLA
; check the bank number for any of the 4 (always and only 4) possibilities
	CMP	#0
	BEQ	check_offset
	CMP	#$40
	BEQ	check_offset
	CMP	#$80
	BEQ	check_offset
	CMP	#$C0
	BNE	simple_read
check_offset
	SetM16
	TYA
	AND	#255
	CLC
	ADC	1,S		; offset to read
	SEC
	SBC	#offset shadow_monitor_start
	CMP	#shadow_monitor_size
	SetM8
	BGE	simple_read
; within shadow monitor range: must do dual port read
	JSR	|e4_access_service
	JMP	|return_read_byte

simple_read
; NB this code relies on stack indirect indexing successfully reading
; across bank boundaries.
	LDA	(1,S),Y		; direct read
return_read_byte
	JSL	>sersend
	INY
	DEX
	BNE	MON_read_loop
	SetM16X16
	PLA			; discard 16-bit address
	JMP	|MON_loop


MON_single_step
	SetM8
	LDA	>bchan_mark_ss
; and fall into exit code

; final stack: S  D  B  Y  X  A  P PC PB
;	       1  3  5  6  8 10 12 13 15
MON_execute
	SetM16X16
	PLA			; discard stack pointer
	PLD
	PLB
	PLY
	PLX
	PLA
._ExitMarker
	RTI

MON_write_EM4
	JSR	|get_address
	AssertM8X8
	PHY
	PHX			; address on stack
	TAX			; loop count
	LDY	#0		; initialise address offset
em4write_loop
	JSL	>sget_wait
	LDA	>bchan_mark_write
	JSR	|e4_access_service
	JSL	>serget
	INY
	DEX
	BNE	em4write_loop
	SetM16X16
	PLA			; discard stacked addr
	JMP	|MON_loop

MON_modify_attrs
	JSR	|get_address	; reads dummy byte as count
	AssertM8X8
	PHY
	PHX

	LDY	#0
	LDA	>bchan_mark_atr
	JSR	|e4_access_service	; read byte
	JSL	>sersend		; give it to host
	JSL	>sget_wait
	LDY	#0
	LDA	>bchan_mark_write
	LDA	>bchan_mark_atr
	JSR	|e4_access_service
	JSL	>serget
	SetM16X16
	PLA			; discard stacked addr
	JMP	|MON_loop

MON_reglist
	SetM8X16
	LDX	#0
	LDY	#register_list_end-register_list
reglist_loop
	LDA	>register_list,X
	JSL	>sersend
	INX
	DEY
	BNE	reglist_loop
	SetM16X16
	JMP	|MON_loop

MON_reg_area
	SetM16X16
	TSX
	TXA
	JSL	>sersend	; LSB
	XBA
	JSL	>sersend	; MSB
	LDA	#0
	JSL	>sersend	; HSB
	JSL	>sersend	; pad to 32 bits
	JMP	|MON_loop

; read from stacked address with Y: was 1,S then 16 bits for RTS were added
e4_access_service
	NOP			; cf example - assumed to be prefetch avoid
	LDA	(3,S),Y
._DualMarker	EQU	* -1
	RTS

._ForceCount
	WORD	hardcall_end-hardcall_start
hardcall_start
    #IF	useBRK
	BRK
    #ELSE
	JSL	>monitor_entry_point
    #ENDIF
hardcall_end

	#INCLUDE	"bchcomms.h"

	SEGMENT	'backchannel'

	#INCLUDE	"backchan.h"

; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;**+ Vector handling
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	SEGMENT 'vecdests'

NMIjmp
	RTI

RESETjmp
	JMP	>RESETjmp

BRKentry
	JMP	>BRKentry

COPentry
	JMP	>COPentry

ABORTentry
	JMP	>ABORTentry

unusedvec	; call means we got into emulation mode!
	JMP	>unusedvec

IRQentry
	RTI

; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; 65816 Vectors
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	SEGMENT	'vectors'

COPvec	WORD	offset COPentry
	#IF	useBRK
BRKvec	WORD	offset monitor_entry_point
	#ELSE
BRKvec	WORD	offset BRKentry
	#ENDIF
ABRTvec WORD	offset ABORTentry
NMIvec	WORD	offset NMIjmp
	WORD	offset unusedvec
IRQvec	WORD	offset IRQentry

	WORD	0
	WORD	0

; Now aligned to FFF4: emulation vectors
; Vectors called while E bit is set; we're only interested in RESET

	WORD	offset unusedvec	; COP
	WORD	offset unusedvec	; BRK
	WORD	offset unusedvec	; ABORT
	WORD	offset unusedvec	; NMI
RSTvec	WORD	offset RESETjmp
	WORD	offset unusedvec	; IRQ
;**+

	END

