; handy manifest constants for use with 65816

Cflag.b	EQU	%00000001
Zflag.b	EQU	%00000010
Iflag.b	EQU	%00000100
Dflag.b	EQU	%00001000
Xflag.b	EQU	%00010000
Mflag.b	EQU	%00100000
Vflag.b	EQU	%01000000
Nflag.b	EQU	%10000000

; use to increase readability
bytesperword	EQU 2
bitsperbyte	EQU 8

; Booleans for easier-to-read conditional assembly
TRUE	EQU	-1
FALSE	EQU	0

