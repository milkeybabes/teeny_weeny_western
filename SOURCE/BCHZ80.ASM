;++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; BackChannel routines for Z80
;
; IMPORTANT - before #include-ing this file in your code,
; preceed the #include line with a segment para 'class'
; directive, where class is your classname for where you
; want these routines to live.  The para is critical.
; an example, in your code:
;
;	segment para 'code'
;	#include "bchz80.asm"
;
;	call	serget	; etc...
;
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++



._BackChannel		;set up backchannel constants

.bc_pcdata			;read from here to get byte from PC
	byte	055h
.bc_status			;read from here for BCH status
	byte	040h,0,0
	byte	0,0,0
	byte	0

.bc_mark_atr		;Used by E4 Shadow monitor, ignore
	byte	0
.bc_send0			;return 0 bit, not start bit
	byte	0
.bc_mark_write	;Used by E4 Shadow monitor, ignore
	byte	0
.bc_send1			;return 1 bit, not start bit
	byte	0
.bc_mark_ss		;Used by E4 Shadow monitor, ignore
	byte	0
.bc_firstsend0	;return 0 bit, is start bit
	byte	0,0
bc_firstsend1		;return 1 bit, is start bit
	byte	0


;++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;SERSEND
; routine to send a byte in A down backchannel
; all registers preserved
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++

.sersend:
	push	af	;store all registers
	push	bc	;used by routine
	push	de
	push	hl

	ld	e,a	;take a copy of byte to be sent in e
	ld	b,0	;zero high byte of BC
	ld	c,4	;set low byte of BC to 4 for 'start bit' offsets
	ld	d,8	;set bit count to 8

s7a:	ld	a,(bc_status)	;get status byte
	and	0c2h	;mask off 'PC read target data' bit
	cp	080h
	jr	nz,s7a	;has PC read prev. bit yet?

	ld	a,e	;yes - ready for new one.  Get data
	and	128	;mask off 'next' bit
	jr	nz,one	;a '1'?
	ld	hl,bc_send0	;no, must be a '0'.  Point to
	add	hl,bc	;either bc_send0 or bc_firstsend0
	ld	a,(hl)	;and read from it
	jp	done_bit
one
	ld	hl,bc_send1	;a '1'.  Point to either bc_send1
	add	hl,bc	;or bc_firstsend1 (dep. on offset in BC)
	ld	a,(hl)	;and read from it

done_bit
	rl	e	;OK - done that bit; shift data left
	ld	c,0	;clear BC offset so all future tx
			;will not be to bc_firstsendX
	dec	d	;decrement bit count
	jr	nz,s7a	;loop if not yet zero

	pop	hl	;pull old copies of messed
	pop	de	;up registers
	pop	bc
	pop	af

	ret		;and leave


;++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; routine loops until PC has sent a byte for us to eat
; returns when byte ready to eat, but does not actually read it
; AF destroyed
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++


.loop_for_pc_byte:

	ld	a,(bc_status)	;get bc status
	and	0c1h	;get 'byte unread from PC' bit
	cp	081h
	jr	nz,loop_for_pc_byte
	ret


;++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; routine to loop waiting for byte from PC, and return with it in A
; AF destroyed
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++

.serget
	call	loop_for_pc_byte		;hold here until PC sends byte
	ld	a,(bc_pcdata)				;read it (clearing hs regs in hardware)
	ret								;return with byte read in A

