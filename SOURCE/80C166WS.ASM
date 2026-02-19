80c166

; MONST V2 CPU Em4 monitor for 80C166
; (C) Crash Barrier Ltd 1993

; ****   This is for 16-bit Data Bus mode
; ****   Segmentation ENABLED (chip default)


;**+ shadow atr

; b0 set means this monitor requires 16-bit Em4 mode
; b1 set means this monitor uses HARDVECTOR, so Em4 will not fill the Opcode
;         attribute RAM as normal, but will use the _IntAckMarker address
;         as the sole opcode-marked address
; b2 set means do not delay for one access before allowing break after exit


._ShadowAtr	equ	03h

;**+ vectors

._ExitMarker	equ	2

	segment word at 0 'code'

	jmps	0,0		;reset vector

e4_exit_service:
	reti
._ExitMarker_1:

	segment	word at 8 'code'

._IntAckMarker
	jmpr	evil

	segment	word at 28 'code'	;Bad Instruction, etc

evil:
	mov	r0,TFR
	mov	r1,r0
	shr	r0,#9
	and	r0,070h
	or	r0,r1
	and	r0,255
loopo
	mov	P2,r0
;	mov	r1,#bc_status
;	mov	r0,[r1]
	jmpr	loopo	

;**+ BackChannel inclusion

	segment	at 100 'code'

	;the shadow monitor backchannel seems to need to be on a PAGE boundary
	;at the moment

;	segment	page 'code'

	#include	"bch166.asm"

	string	"Monitor Code"


; this is the monitor code

;**+ subroutines

	segment	word 'code'

; subroutine to get map and address bytes for monitor

get_map_ads:				;gets 16-bit address into R4
	calla	serget			;ignore MAP
	calla	serget
	movb	rl4,rl0			;save low half of ads
	calla	serget
	movb	rh4,rl0			;and high half
	calla	serget			;and dump upper 16 bits
	jmpa	serget


; Hardcall gets us to here, with PC and Segment data already on stack


;**+ MONST Monitor Entry Point


.NMI_entry:		; HardVector points to here

	bset	PSW.6			;indicate interrupt entry
	bclr	TFR.15			;kill NMI trap request

			; PSW already on stack  +39/+38
			; CSP already on stack  +37/+36
			; PC already on stack   +35/+34

	push	R0	;+33/+32
	push	SP	;+31/+30
	push	R1	;+29/+28
	push	R2	;+27/+26
	push	R3	;+25/+24
	push	R4	;+23/+22
	push	R5	;+21/+20
	push	R6	;+19/+18
	push	R7	;+17/+16
	push	R8	;+15/+14
	push	R9	;+13/+12
	push	R10	;+11/+10
	push	R11	;+9/+8
	push	R12	;+7/+6
	push	R13	;+5/+4
	push	R14	;+3/+2
	push	R15	;+1/+0


;	mov	r0,SP	; adjust PC stored on stack to account for Hardcall
;	add	r0,#36	; length, so it points to real break address
;	mov	r1,[r0]
;	sub	r1,#low { hardcall_end-hardcall_begin }
;	mov	[r0],r1

	mov	r0,SP	; adjust SP stored on stack to account for already
	add	r0,#30	; pushed regs, so it points to real top of stack
	mov	r1,[r0]
	add	r1,#8
	mov	[r0],r1

;**- MONST COMMAND LOOP

main:
	calla	serget			;grab next command byte

;**- MONST CMD 0   Test On-Line

	cmpb	rl0,#0			;SYNC byte
	jmpr	nz,try_1
	movb	r0,#060h		;return sync code for V1.2 compatiblity
	calla	sersend
	jmpr	main


;**- MONST CMD 1   Store RAM Bytes from Start Address
try_1:
	cmpb	rl0,#1			;store bytes
	jmpr	nz,try_2

	callr	get_map_ads		;get start address

	calla	serget			;now get byte count
	movb	rl5,rl0			;into rl5

retloop1:
	calla	serget
	movb	[r4],rl0
	add	r4,#1			;bump ads pointer
	subb	rl5,#1			;dec loop counter
	jmpr	nz,retloop1
	jmpa	uc,main


;**+ MONST CMD 2   Return Bytes from Start Address

try_2:
	cmpb	rl0,#2			;return bytes
	jmpr	nz,try_5

	callr	get_map_ads		;get start address

	calla	serget			;now get byte count
	movb	rl5,rl0			;into rl5

retloop:
	push	r4
	and	r4,#03fffh		;16K
	cmp	r4,#1000h		;shadow monitor area 0000-1000
					;currently unaware that shadow   !!!!
					;may not appear on non-0 166 seg !!!!
	jmpr	uge,normal

	pop	r4
	calla	e4_access_service	; underneath shadow; use magic read
	jmpr	send_it			; to get app code instead

normal:
	pop	r4
	movb	rl0,[r4]		;get 'next' byte

send_it:
	calla	sersend
	add	r4,#1			;bump ads pointer
	subb	rl5,#1			;dec loop counter
	jmpr	nz,retloop
	jmpa	uc,main


;**- MONST CMD 5   leave the monitor

try_5:	cmpb	rl0,#5			;eXit monitor?
	jmpr	nz,try_7

leave_monitor:
	pop	R15
	pop	R14
	pop	R13
	pop	R12
	pop	R11
	pop	R10
	pop	R9
	pop	R8
	pop	R7
	pop	R6
	pop	R5
	pop	R4
	pop	R3
	pop	R2
	pop	R1
	pop	R0
	pop	R0

	jmpa	e4_exit_service


;**- MONST CMD 7   Store Em4 bytes

try_7:	cmpb	rl0,#7
	jmpr	nz,try_8

	callr	get_map_ads		;get start address

	calla	serget			;now get byte count
	movb	rl5,rl0			;into rl5

retloop7:
	calla	await_byte_from_host
	mov	r1,#bc_mark_write
	mov	r0,[r1]
	calla	e4_access_service	; perform write to E4 APP memory

	calla	sersend
	add	r4,#1			;bump ads pointer
	subb	rl5,#1			;dec loop counter
	jmpr	nz,retloop7
	jmpa	uc,main



;**- MONST CMD 8   Single Step Exit

try_8:	cmpb	rl0,#8
	jmpr	nz,try_10

	mov	r1,#bc_mark_ss
	mov	r0,[r1]
	jmpa	leave_monitor


;**- MONST CMD 10  Em4 Attribute RAM Control

try_10:	cmpb	rl0,#10
	jmpr	nz,try_11
	
	calla	get_map_ads
	calla	serget

	mov	r1,#bc_mark_atr		;
	mov	r0,[r1]

	calla	e4_access_service	; perform read from E4 ATR memory
	calla	sersend			; send back what we read
	calla	await_byte_from_host	; wait for modified version
	
	mov	r1,#bc_mark_write	;
	mov	r0,[r1]
	mov	r1,#bc_mark_atr		;
	mov	r0,[r1]

	calla	e4_access_service	; perform read from E4 ATR memory

	calla	serget
	jmpr	main


;**- MONST CMD 11  Return Register List Table

try_11:	cmpb	rl0,#11
	jmpr	nz,try_12
	
	mov	r1,# register_list
l11_1:
	movb	rl0,[r1]
	calla	sersend
	add	r1,#1
	cmp	r1,# end_of_reg_list
	jmpr	nz,l11_1
	jmpa	main

;**- MONST CMD 12  Return Start of Register Stack

try_12:	cmpb	rl0,#12
	jmpa	nz,main

	mov	r0,SP
	calla	sersend
	mov	r0,SP
	movb	rl0,rh0
	calla	sersend
	mov	r0,#0
	calla	sersend	
	mov	r0,#0
	calla	sersend	
	jmpa	main



;**+ HardCall Table

._ForceCount
	word	hardcall_end-hardcall_begin
hardcall_begin:
;	nop
	jmpa	NMI_entry
hardcall_end
	word	0,0,0,0,0,0

;**- DUAL PORT service - for read, returns in rl0

	segment	word 'code'

e4_access_service:
	push	r4
	and	r4,#1
	jmpr	z,even_cycle

	mov	r4,#bc_mark_odd
	mov	r0,[r4]

even_cycle:
	pop	r4
	push	r4
	and	r4,#0fffeh
	nop
	nop
	nop
	nop
				;due to Alien Pipeline from Hell in 80c166,
	mov	r0,[r4]		;we have to place the DualMarker at the
				;address AFTER the MOV, as fetching to keep
				;the pipeline full has higher priority than
				;operand cycles (!)
._DualMarker
	nop
	nop
	nop
	nop
	pop	r4
	push	r4
	and	r4,#1
	jmpr	z,even
	movb	rl0,rh0
even:
	pop	r4
	ret


;**+ Register List

register_list:
	byte	0
	byte	hardcall_end-hardcall_begin
	
	string	"pc",0,		34,35,0,0,	15,0,	-1
	string	"seg",0,	36,37,0,0,	15,0,	-1
	string	"psw",0,	38,39,0,0,	15,0,	-1
	string	"sp",0,		30,31,0,0,	15,0,	-1
	string	"r0",0,		32,33,0,0,	15,0,	-1
	string	"r1",0,		28,29,0,0,	15,0,	-1
	string	"r2",0,		26,27,0,0,	15,0,	-1
	string	"r3",0,		24,25,0,0,	15,0,	-1
	string	"r4",0,		22,23,0,0,	15,0,	-1
	string	"r5",0,		20,21,0,0,	15,0,	-1
	string	"r6",0,		18,19,0,0,	15,0,	-1
	string	"r7",0,		16,17,0,0,	15,0,	-1
	string	"r8",0,		14,15,0,0,	15,0,	-1
	string	"r9",0,		12,13,0,0,	15,0,	-1
	string	"r10",0,	10,11,0,0,	15,0,	-1
	string	"r11",0,	8,9,0,0,	15,0,	-1
	string	"r12",0,	6,7,0,0,	15,0,	-1
	string	"r13",0,	4,5,0,0,	15,0,	-1
	string	"r14",0,	2,3,0,0,	15,0,	-1
	string	"r15",0,	0,1,0,0,	15,0,	-1
	string	-1
end_of_reg_list




	end

