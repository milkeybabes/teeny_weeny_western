z80

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;Em4 Shadow Monitor for Z80
; (c)1992 Crash Barrier Ltd

._ShadowAtr	equ	0
hardcall_size	equ	3


;++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;set up all vectors how we want them to act when swallowing interrupts
;Em4send can overwrite what we put here if user selects a particular vector
;is to remain active while broke.


	segment byte at 0000 'code'	;reset, RST0
	jp dum

	segment at 0008 'code'			;RST1
	ret

	segment at 0010 'code'			;RST2
	ret

	segment at 0018 'code'			;RST3
	ret

	segment at 0020 'code'			;RST4
	ret

	segment at 0028 'code'			;RST5
	ret

	segment at 0030 'code'			;RST6
	ret

	segment at 0038 'code'			;RST7
	ret

	segment at 0066 'code'			;NMI
	retn


;++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;SHADOW MONITOR CODE

	segment at 0100 'code'		;monitor stuff

reset_here:
	jp	reset_here



;++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;subroutine to get 'map' and four ads, low first.

get_ads_and_map
	call	serget
	ld	d,a	;map (0= normal, 1=IO ads)
	call	serget	; low byte of ads
	ld	l,a
	call	serget	; high byte
	ld	h,a
	call	serget	; ignore b16-b31
	jp	serget



;++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;Subroutine to read from address in HL, but will not ever
;see shadow monitor code, instead either main Em4 RAM,
;by default, or if previously read from bc_mark_atr, then
;Em4 atrribute RAM for that address.  If previously read
;from bc_mark_write, then instead of performing read,
;selected Em4 RAM array is written to with contents of
;Backchannel PC data register.

e4_access_service:
	nop

._DualMarker

	ld	a,(hl)	;perform dual-port read/write
	ret



;++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; this is where we come into the monitor after HardCall

monitor_entry_point:

; push all the registers we want to be visible to the debugger

					;PC is already on stack at 
	push	iy		;iyl=20, iyh=21
	push	ix		;ixl=18, ixh=19
	push	hl		;l=16, h=17
	push	de		;e=14, d=15
	push	bc		;c=12, b=13
	push	af		;f=10, a=11

	ld		hl,12
	add	hl,sp	
	push	hl		;application SP, SPL=8, SPH=9
	
	ex	af,af'
	push	af		;f'=6, a'=7
	ex	af,af'
	exx
	push	bc		;c'=4, b'=5
	push	de		;e'=2, d'=3
	push	hl		;l'=0, h'=1
	exx


	ld	a,(bc_pcdata)	;clear bch



	ld	hl,22	;subtract hardcall operation from stacked PC
	add	hl,sp
	ld	a,(hl)
	inc	hl
	ld	b,(hl)
	sub	hardcall_size
	jr	nc,after_carry
	dec	b

after_carry
	ld	(hl),b
	dec	hl
	ld	(hl),a



;++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;main command loop

mon_loop:
	call	serget	;get next command


;++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;command 0 for online test

	cp	0	;is it a SYNC command?
	jr	nz,t1

do_55
	ld	a,(bc_status)	;check to see if was an External BRK
	and	010h
	jr	z,not_ext
	ld	a,60h or 128	;if it was, set b7 of return code
	jp	send_back
not_ext
	ld	a,60h	;else keep it clear
send_back
	call	sersend	;return code of 60h
	jp	mon_loop



;++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;command 1 stores byte stream from given addresses
; IMPORTANT cmd 7 is sent instead if addresses to change are
; in Em4 address range (the debugger knows)

t1:	cp	1	;is it a store bytes command?
	jr	nz,t2

	call	get_ads_and_map	;yes - get map & ads to start from

	call	serget	;and get number of bytes to store
	ld	b,a
	
t1l1
	ld	a,d
	cp	0
	jr	z,t1l2

iomap12				;map!=0, use IO map for write
	ld		c,l
	out	(c),a
	
t1l2					
	call	serget	;get nth byte
	ld	(hl),a

	inc	hl	;bump address
	dec	b	
	jr	nz,t1l1	;until out of bytes
	jp	mon_loop



;++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;command 2 returns bytes from given address

t2:	cp	2	;is command a 'return bytes' ?
	jr	nz,t5

	call	get_ads_and_map	;yes - get map & ads to start from
	call	serget	;and get number of bytes to store
	ld	e,a

t2l1
	ld	a,d
	cp	0
	jr	nz,iomap2

	
						; if addresses in range of shadow monitor memory,
						; do not do direct read, but use the _DualMarker
	ld	a,h				; mechanism to see underlying Main Ram data instead
	and	0f8h				; of shadow memory.
	jp	nz,normal

	call	e4_access_service
	jp	t2l2

normal
	ld	a,(hl)	;get nth byte by direct reading
	jr	t2l2

iomap2			;IO map
	ld	c,l
	in	a,(c)

t2l2
	call	sersend	;and send it back

	inc	hl	;bump address
	dec	e
	jr	nz,t2l1	;until out of bytes

	jp	mon_loop



;++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;command 5 is caused by user doing a CTRL-X Exit from Monitor
; pop all the registers
; special label _ExitMarker must be given address of very last byte of
; routine (ret or rts, etc) - if multi-byte return instruction, use dummy
; label to get address of first byte, and equate _ExitMarker to dummy+1


t5:
	cp	5	;was it an 'execute' command?
	jp	nz,t7

leave_monitor:
	exx
	pop	hl
	pop	de
	pop	bc
	exx
	ex	af,af'
	pop	af
	ex	af,af'

	pop	hl	;discard SP

	pop	af
	pop	bc
	pop	de
	pop	hl
	pop	ix
	pop	iy
	jp	_ExitMarker

	segment	para 'code'

._ExitMarker:
	ret

	skip	13,0
dum	jp	0

._ExitMarker_1	equ	dum+2


;++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;command 7 stores byte stream from given addresses
; WHICH MUST MAP ON TO EM4 MEMORY AND BE IN MAP 0
; otherwise exactly like command 1

t7:	cp	7	;is it a store bytes command?
	jr	nz,t8

	call	get_ads_and_map	;yes - get map & ads to start from

	call	serget	;and get number of bytes to store
	ld	b,a
	
t7l1
	call	loop_for_pc_byte

	ld		a,(bc_mark_write)

	call	e4_access_service
	call	serget	;eat it for next

	inc	hl	;bump address
	dec	b	
	jr	nz,t7l1	;until out of bytes
	jp	mon_loop


;++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;command 8  perform single-step exit

t8:
	cp	8
	jp	nz,t10

	ld	a,(bc_mark_ss)	; tell em4 hardware that this is a single-step type
	jp	leave_monitor	; exit, and go and perform it, as if command 5

	

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;command 10  perform ATR RAM modifications

; accepts map and 32-bit address in usual format
; accepts dummy 0ffh byte (can be discarded)
; does read from Backchannel register 8 (bc_mark_atr)
; reads from address sent using _DualMarker instruction
; sends back what it read (which will be Em4 attribute ram for that ads)
; waits for PC to send back a byte down backchannel BUT DOES NOT READ IT YET
; does read from Backchannel register 8 (bc_mark_atr)
; does read from Backchannel register 10 (bc_mark_write)
; reads from address sent using _DualMarker instruction
; do a dummy serget to eat byte sent (and discard it)


t10:
	cp	10
	jp	nz,t11

	call	get_ads_and_map	;yes - get map & ads to start from in HL

	call	serget				;dummy 0xff byte
	
	ld	a,(bc_mark_atr)		;set ATR flag
	call	e4_access_service	;get ATR value

	call	sersend
	call	loop_for_pc_byte

	ld	a,(bc_mark_write)		;set DUAL WRITE flag
	ld	a,(bc_mark_atr)		;set DUAL ATR flag
	call	e4_access_service

	call	serget

	jp	mon_loop


;++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;command 11	 return register list
; returns whole of register list, character for character from table stored
; in shadow monitor.  Debugger knows table terminates with -1 (255) as first
; character of main register name
; Debugger uses this command once after first ONLINE
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++


t11:
	cp	11
	jp	nz,t12

	ld	hl,register_list

t11_1:
	ld	a,(hl)
	call	sersend
	inc	hl
	ld	a,l
	cp	low end_of_reg_list
	jr	nz,t11_1
	ld	a,h
	cp	high end_of_reg_list
	jr	nz,t11_1

	jp	mon_loop



;++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;command 12  return address of base of stacked regs
; returns start address of register list stack frame as a 32-bit address,
; LSB first
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++


t12:
	cp	12
	jp	nz,mon_loop

	ld	hl,0
	add	hl,sp	

	ld	a,l		;stack base LSB
	call	sersend
	ld	a,h		;stack base MSB
	call	sersend

	ld	a,0		;dummy padding to 32 bits
	call	sersend
	ld	a,0
	call	sersend

	jp	mon_loop



	segment	para 'code'	; force us to para alignment for BackChannel

	#include	"bchz80.asm"	; #include the Z80 BackChannel routines


;++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; HardCall mechanism table - first word, LSB first using
; WORD directive, is number of fetches in HardCall instr.
; followed by up to 8 bytes of HardCall instruction.
; Usually just a CALL or JSR to monitor_entry_point.
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++


._ForceCount
	word	hardcall_size
	call	monitor_entry_point


;++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; REGISTER LIST
;
; format is ASCIIZ register name, followed by 4 offsets
; from the stack from address returned by command 12
; to read the bytes to make up register value, in LSB
; first ordering. Unused bytes in register can be set to
; 0.  Next is list of bitfields, for simple registers
; it is the MSB bit number followed by the LSB bit number,
; followed by -1 (0ffh).
;
; For compound registers (eg CCR, flags, etc), there
; are multiple entries here of form MSB bit number,
; LSB bit number, ASCII char.  This list is terminated
; by a -1 (0ffh) at the MSB bit number position.
;
; The whole list is terminated by a -1 (0ffh) at the start
; of the next register name
;
; current maximum of 64 registers, and up to 8 bitfields
; per compound register (cut 16-bit ccr into two 8-bit
; halves).
;
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++


register_list

	byte	0	;register index for program counter
	byte	hardcall_size	;value to subtract from PC to get to actual BRK address

	string	"pc",0,		22,23,0,0,		15,	0,			-1

	string	"sp",0,		8,9,0,0,		15,	0,			-1

	string	"f",0,		10,0,0,0
	string		7,7,"s"
	string		6,6,"z"
	string		5,5,"-"
	string		4,4,"a"
	string		3,3,"-"
	string		2,2,"p"
	string		1,1,"n"
	string		0,0,"c"
	string		-1

	string	"a",0,		11,0,0,0,		 7,	0,			-1

	string	"bc",0,		12,13,0,0,	15,	0,			-1

	string	"de",0,		14,15,0,0,	15,	0,			-1

	string	"hl",0,		16,17,0,0,	15,	0,			-1

	string	"ix",0,		18,19,0,0,	15,	0,			-1

	string	"iy",0,		20,21,0,0,	15,	0,			-1

	string	"f'",0,		6,0,0,0
	string		7,7,"s"
	string		6,6,"z"
	string		5,5,"-"
	string		4,4,"a"
	string		3,3,"-"
	string		2,2,"p"
	string		1,1,"n"
	string		0,0,"c"
	string		-1

	string	"a'",0,		7,0,0,0,		 7,	0,			-1

	string	"bc'",0,		4,5,0,0,		15,	0,			-1

	string	"de'",0,		2,3,0,0,		15,	0,			-1

	string	"hl'",0,		0,1,0,0,		15,	0,			-1

	string	-1

end_of_reg_list

	end

