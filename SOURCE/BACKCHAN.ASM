; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; Define IO area for EM4
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

._BackChannel
bchan_byte		DC.B	0	; 0
bchan_status		DC.B	0	; 1
			DC.B	0	; 2
			DC.B	0	; 3
			DC.B	0	; 4
			DC.B	0	; 5
			DC.B	0	; 6
			DC.B	0	; 7
bchan_mark_atr		DC.B	0	; 8
bchan_send00		DC.B	0	; 9
bchan_mark_write	DC.B	0	; 10
bchan_send01		DC.B	0	; 11
bchan_mark_ss		DC.B	0	; 12
bchan_send10		DC.B	0	; 13
bchan_mark_odd		DC.B	0	; 14
bchan_send11		DC.B	0	; 15

