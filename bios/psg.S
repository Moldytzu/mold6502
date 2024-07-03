psg_write:
	sta VIA2_ORB
	
	lda #%11111101
	sta VIA2_PCR
	
	php
	plp
	php
	plp
	php
	plp
	php
	plp
	php
	plp
	
	lda #%11111111
	sta VIA2_PCR
	
	rts
	
psg_init:
	lda #$FF
	sta VIA2_DDRB
	
	lda #%11111101
	sta VIA2_PCR
psg_silence_all:
	lda #%10011111
	jsr psg_write
	
	lda #%11011111
	jsr psg_write
	
	lda #%10111111
	jsr psg_write
	
	lda #%11111111
	jmp psg_write