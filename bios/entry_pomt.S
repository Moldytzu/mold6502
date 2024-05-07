	.feature STRING_ESCAPES
	.segment "CODE"
	.include "lcd.S"
	.include "via2.S"
	.include "psg.S"
	.include "utils.S"
	
; program entry point
_reset:
	cld ; disable decimal mode
	cli ; disable interrupts
	
pomt: ; perform power-on memory test
	; test zero page presence
	lda #$55
	sta $00
	lda $00
	cmp #$55
	bne pomt_fail ; failed
	
	; test stack presence
	lda #$55
	pha
	pla
	cmp #$55
	bne pomt_fail ; failed

	jmp pomt_success
pomt_fail:
	jmp halt
	
pomt_success:
	jsr lcd_init
	jsr psg_silence_all
	lcd_write_string hello_msg
	
	jmp halt
	
_irq:
	rti
	
hello_msg:
	.asciiz "MOLD-I\n"
	
	.segment "RESET_VECTOR"
	.word _irq
	.word _reset
	.word _irq