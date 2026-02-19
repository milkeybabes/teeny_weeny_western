

HIT_HORSE	; Set PLAYERS collide Params
	; these positions may have to change to replect the true position
	; as some frames are not on top of each other !!
	;MONST
	PHY

	LDA	|SPRITE_WORLDX+PLAY_SPR
	CLC
	ADC	#12
	STA	<COLLIDE_LEFT	; ripley left low as map position
	ADC	#8	; 12 pixels length *2 for hires
	STA	<COLLIDE_RIGHT	; right low
	LDA	|SPRITE_WORLDY+PLAY_SPR
	ADC	#26
	STA	<COLLIDE_TOP
	ADC	#5	; 1 pixel down
	STA	<COLLIDE_BOT

	LDA	<HORSE_DIRECTION	; get sprite frame
	ASL	A
	ASL	A
	ASL	A
	TAY
	LDA	|SPRITE_WORLDX+HORSE_SPR
	PHA
	CLC
	ADC	|XADD AND $FFFF,Y
	STA	<TEMP1	; left side little add in
	PLA
	ADC	|XADD+4 AND $FFFF,Y	; enemy x right
	STA	<TEMP2	; low right

	LDA	|SPRITE_WORLDY+HORSE_SPR
	PHA
	CLC
	ADC	|XADD+2 AND $FFFF,Y	; sprite pointer offset
	STA	<TEMP3	; top side little add in
	PLA
	ADC	|XADD+6 AND $FFFF,Y	; length of enemy y to check
	STA	<TEMP4	; low right

	; Source left with Enemy left
	LDA	<COLLIDE_RIGHT
	CMP	<TEMP1
	BCC	QUICK_EXIT
	LDA	<TEMP2
	CMP	<COLLIDE_LEFT
	BCC	QUICK_EXIT

	LDA	<COLLIDE_BOT
	CMP	<TEMP3
	BCC	QUICK_EXIT
	LDA	<TEMP4
	CMP	<COLLIDE_TOP
QUICK_EXIT	PLY
	RTS

XADD	; BOX data from file stand2.box
	; data : x1, y1, x2, y2, type
	WORD	23, 35, 39, 55	; 0
	WORD	79-64, 38, 107-64, 48 ;51	; 1
	WORD	142-128, 38, 170-128, 47	; 2
	WORD	203-192, 39, 231-192, 49 ;54	; 3
	WORD	280-256, 40, 295-256, 55	; 4
	WORD	343-320, 40, 371-320, 49 ;53	; 5
	WORD	404-384, 38, 434-384, 47	; 6
	WORD	469-448, 36, 497-448, 48 ;51	; 7
