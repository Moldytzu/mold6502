	.feature STRING_ESCAPES
	.segment "CODE"
	.include "lcd.S"
	.include "utils.S"
	
delay:
	pha
	
	lda #255 
delay_loop:
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
	php
	plp
	php
	plp
	php
	plp
	php
	plp
	dec
	bne delay_loop
	
	pla
	rts
	
psg_write:
	sta VIA1_ORB
	
	lda #0
	sta VIA1_ORA
	
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
	
	lcd_write_string hello_msg
	
	ldx #0
loop1:
	lda song, x
	beq do_delay
	
	jsr psg_write
	jmp continue
	
do_delay:
	jsr delay
	jsr delay
	jsr delay
	
continue:
	inx
	beq exit
	jmp loop1
	
exit:
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
	
song:
	.byte $f1, $0, $9, $0, $0, $f9, $0, $9, $0, $0, $f9, $0, $9, $0, $0, $f9, $0, $f9, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $f9, $0, $9, $0, $0, $f9, $0, $9, $0, $0, $0, $0, $0, $0, $0, $0, $f9, $0, $f9, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $f9, $0, $9, $0, $0, $f9, $0, $9, $0, $0, $0, $0, $0, $0, $0, $0, $f9, $0, $9, $0, $0, $f9, $0, $9, $0, $0, $f9, $0, $f9, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $f9, $0, $9, $0, $0, $f9, $0, $9, $0, $0, $f9, $0, $9, $0, $0, $0, $0, $0, $0, $0, $0, $f9, $0, $f9, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $f9, $0, $9, $0, $0, $0, $0, $0, $0, $0, $0, $f9, $0, $0, $f9, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0

irq_msg:
	.asciiz "Q"
	
hello_msg:
	.asciiz "MOLD-I\n"
	
gata_msg:
	.asciiz "Am gatat"
	
	.segment "RESET_VECTOR"
	.word _reset
	.word _irq