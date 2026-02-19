; IO Address Manifests for Super NES

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; PPU segment
; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	; PPU REGISTERS
INIDISP	equ	$2100 ; Forced blank + brightness
OBJSEL	equ	$2101 ; Object size, object data area
OAMADDL	equ	$2102 ; Address to read/write in OAM (low)
OAMADDH	equ	$2103 ;   "     "     "       "   "  (high)
OAMDATA	equ	$2104 ; write OAM (low then high F/VBLANK only)
BGMODE	equ	$2105 ; Screen mode, BG3 priority, BG char size
MOSAIC	equ	$2106 ; mosaic screen
BG1SC	equ	$2107 ; BG1 size and VRAM base address
BG2SC	equ	$2108 ; BG2 size and VRAM base address
BG3SC	equ	$2109 ; BG3 size and VRAM base address
BG4SC	equ	$210A ; BG4 size and VRAM base address
BG12NBA	equ	$210B ; BG1&2 bases for character data
BG34NBA	equ	$210C ; BG3&4 bases for character data
BG1HOFS	equ	$210D ; BG1 horizontal scroll (low then high)
BG1VOFS	equ	$210E ; BG1 vertical scroll (low then high)
BG2HOFS	equ	$210F ; BG2 horizontal scroll (low then high)
BG2VOFS	equ	$2110 ; BG2 vertical scroll (low then high)
BG3HOFS	equ	$2111 ; BG3 horizontal scroll (low then high)
BG3VOFS	equ	$2112 ; BG3 vertical scroll (low then high)
BG4HOFS	equ	$2113 ; BG4 horizontal scroll (low then high)
BG4VOFS	equ	$2114 ; BG4 vertical scroll (low then high)
VMAINC	equ	$2115 ; VRAM address increment
VMADDL	equ	$2116 ; Address to read/write in VRAM (low)
VMADDH	equ	$2117 ;   "      "     "      "   "   (high)
VMDATAL	equ	$2118 ; write VRAM data low (F/VBLANK only)
VMDATAH	equ	$2119 ; write VRAM data high (F/VBLANK only)
M7SEL	equ	$211A ; Mode 7 attribute selection
M7A	equ	$211B ; 16 bit operand for multiply (low then high)
M7B	equ	$211C ; 8 bit operand for multiply
M7C	equ	$211D
M7D	equ	$211E
M7X	equ	$211F
M7Y	equ	$2120
CGADD	equ	$2121 ; Address to read/write in CG RAM
CGDATA	equ	$2122 ; write CG RAM data (low/high H/F/VBLANK only)
W12SEL	equ	$2123 ; Window masks for BG1, BG2
W34SEL	equ	$2124 ; Window masks for BG3, BG4
WOBJSEL	equ	$2125 ; Window masks for objects, colour window
WH0	equ	$2126 ; Window 1 left pos
WH1	equ	$2127 ; Window 1 right pos
WH2	equ	$2128 ; Window 2 left pos
WH3	equ	$2129 ; Window 2 right pos
WBGLOG	equ	$212A ; Mask logic for BG windowing
WOBJLOG	equ	$212B ; Mask logic for objects, colour window
TM	equ	$212C ; Designate main screen
TS	equ	$212D ; designate addition/subtraction screen
TMW	equ	$212E ; window mask selection for main screen
TSW	equ	$212F ; window mask selection for add/sub screen
CGSWSEL	equ	$2130 ; main/sub/constant colour/direct selection
CGADSUB	equ	$2131 ; enable add/sub for BG1-4, OBJ, BACK
COLDATA	equ	$2132 ; fixed colour data
SETINI	equ	$2133 ; screen setup (nlines, interlace, ...)
MPYL	equ	$2134 ; Multiply result (driven by MATRIX regs)
MPYM	equ	$2135 ; mid byte of multiply result
MPYH	equ	$2136 ; high byte of multiply result
slhv	equ	$2137 ; latch horizontal/vertical counters
oamdata2	equ	$2138 ; read OAM (low then high, H/F/VBLANK only)
vmdatal2	equ	$2139 ; read VRAM dat low (H/F/VBLANK only)
vmdatah2	equ	$213A ; read VRAM data high (H/F/VBLANK only)
cgdata2	equ	$213B ; read CG RAM data (low/high H/F/VBLANK only)
ophct	equ	$213C ; latched horizontal counter (low then high)
opvct	equ	$213D ; latched vertical counter (low then high)
stat77	equ	$213E ; PPU status and version
STAT78	equ	$213F ; PPU status and version
APUIO0	equ	$2140 ; 4 ports to communicate with Audio PU
APUIO1	equ	$2141
APUIO2	equ	$2142
APUIO3	equ	$2143

WMDATA	equ	$2180 ; DATA to read/write to WRAM
WMADDL	equ	$2181 ; WORK RAM Address Low
WMADDM	equ	$2182 ; Mid
WMADDH	equ	$2183 ; High

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; Controller segment
; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

; No point using these locations, unless automatic reading has some
; disadvantage.
; $4016 reads serially from controllers 1 and 3
; $4016 writes 3 bits, presumably to clock more bits in
; $4017 reads serially from controllers 2 and 4

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; CPU segment
; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
NMITIMEN	equ	$4200 ; enable NMI, IRQ, auto-controller read
WRIO	equ	$4201 ; write to IO port
WRMPYA	equ	$4202 ; 8 bit multiply operand 1
WRMPYB	equ	$4203 ; 8 bit multiply operand 2
WRDIVL	equ	$4204 ; 16 bit dividend low
WRDIVH	equ	$4205 ; 16 bit dividend high
WRDIVB	equ	$4206 ; 8 bit divisor
HTIMEL	equ	$4207 ; set H pos for IRQ (low)
HTIMEH	equ	$4208 ; set H pos for IRQ (high)
VTIMEL	equ	$4209 ; set V pos for IRQ (low)
VTIMEH	equ	$420A ; set V pos for IRQ (high)
MDMAEN	equ	$420B ; general purpose DMA start
HDMAEN	equ	$420C ; HDMA channel enable
MEMSEL	equ	$420D ; memory speed selection
RDNMI	equ	$4210 ; NMI flag and version number
TIMEUP	equ	$4211 ; Timer IRQ status
HVBJOY	equ	$4212 ; H/VBLANK status, JOY being read
rdio	equ	$4213 ; read from IO port
rddivl	equ	$4214 ; 16 bit quotient (low)
rddivh	equ	$4215 ; 16 bit quotient (high)
rdmpyl	equ	44216 ; 16 bit multiply result, or remainder (low)
rdmpyh	equ	44217 ; 16 bit multiply result, or remainder (high)
JOY1L	equ	$4218 ; controller 1 data (low)
JOY1H	equ	$4219 ; controller 1 data (high)
JOY2L	equ	$421A ; controller 2 data (low)
JOY2H	equ	$421B ; controller 2 data (high)
JOY3L	equ	$421C ; controller 3 data (low)
JOY3H	equ	$421D ; controller 3 data (high)
JOY4L	equ	$421E ; controller 4 data (low)
JOY4H	equ	$421F ; controller 4 data (high)

PPU_MATRIXLOW   equ	M7Y   ; low byte of ANY matrix low/high pair
; Useful for storing low byte only in M16 mode
; WARNING: 16-bit store corrupts following PPU_CGRAM

; DMA setup addresses; base addresses only
DMA_SETUP	equ	$4300 ; DMA setup for each channel
DMA_BADDR	equ	$4301 ; B bus address (low byte, high byte=$21)
DMA_A1ADDR	equ	$4302 ; A1 bus address low
DMA_A1ADDR_H	equ	$4303 ; A1 bus address high
DMA_A1ADDRB	equ	$4304 ; A bus address bank number
DMA_COUNT	equ	$4305 ; Transfer count for general DMA
DMA_COUNT_H	equ	$4306 ; (used internally by H-DMA)
DMA_HBANK	equ	$4307 ; data bank for H-DMA - internal use only?
DMA_A2ADDR	equ	$4308 ; internal transfer address for DMA?
DMA_A2ADDR_H	equ	$4309 ;	"        "         "     "   "
DMA_HLINE	equ	$430A ; line count during HDMA - internal only

	; Init for DMA channels add to register
DMA0	equ	$00
DMA1	equ	$10
DMA2	equ	$20
DMA3	equ	$30
DMA4	equ	$40
DMA5	equ	$50
DMA6	equ	$60
DMA7	equ	$70

BIT0	equ	%0000000000000001
BIT1	equ	%0000000000000010
BIT2	equ	%0000000000000100
BIT3	equ	%0000000000001000
BIT4	equ	%0000000000010000
BIT5	equ	%0000000000100000
BIT6	equ	%0000000001000000
BIT7	equ	%0000000010000000
BIT8	equ	%0000000100000000
BIT9	equ	%0000001000000000
BITA	equ	%0000010000000000
BITB	equ	%0000100000000000
BITC	equ	%0001000000000000
BITD	equ	%0010000000000000
BITE	equ	%0100000000000000
BITF	equ	%1000000000000000

	; Joypad switch bit masks

Joy_R	equ	BIT4 ; R button
Joy_L	equ	BIT5 ; L button
Joy_X	equ	BIT6 ; X button
Joy_A	equ	BIT7 ; A button
Joy_Right	equ	BIT8 ; joystick right
Joy_Left	equ	BIT9 ; joystick left
Joy_Down	equ	BITA ; joystick down
Joy_Up	equ	BITB ; joystick up
Joy_Start	equ	BITC ; Start button
Joy_Select	equ	BITD ; Select button
Joy_Y	equ	BITE ; Y button
Joy_B	equ	BITF ; B button
