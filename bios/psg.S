psg_write:
	sta VIA1_ORB
	
	lda #%11111101
	sta VIA1_PCR
	
	php
	plp
	php
	plp
	php
	plp
	php
	plp
	
	lda #%11111111
	sta VIA1_PCR
	
	rts
	
psg_silence_all:
	lda #%11111001
	jsr psg_write
	
	lda #%11111011
	jsr psg_write
	
	lda #%11111101
	jsr psg_write
	
	lda #%11111111
	jmp psg_write