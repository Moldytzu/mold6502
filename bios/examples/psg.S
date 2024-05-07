	.feature STRING_ESCAPES
	.segment "CODE"
	.include "lcd.S"
	.include "utils.S"
	
delay:
	pha
	
	lda #255 
delay_loop:
	nop
	dec
	bne delay_loop
	
	pla
	rts
	
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
	
; program entry point
_reset:
	cld ; disable decimal mode
	cli ; disable interrupts
	
	jsr lcd_init ; initialise the LCD and VIA1
	
	; silence all voices
	lda #%11111001
	jsr psg_write
	
	lda #%11111011
	jsr psg_write
	
	lda #%11111101
	jsr psg_write
	
	lda #%11111111
	jsr psg_write
	
	; play a tune on first voice
	lda #%11110001
	jsr psg_write
	
	lda #%00000000
	jsr psg_write
	
	lda #%00001001
	jsr psg_write
	
	lcd_write_string hello_msg
	
	jsr halt
	
_irq:
	phx
	phy
	pha

	;jsr via1_timer_irq_handle
	;lcd_write_string irq_msg
	
	pla
	ply
	plx
	rti

irq_msg:
	.asciiz "Q"
	
hello_msg:
	.asciiz "MOLD-I\n"
	
gata_msg:
	.asciiz "Am gatat"
	
	.segment "RESET_VECTOR"
	.word _reset
	.word _irq