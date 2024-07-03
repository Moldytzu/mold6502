	.feature STRING_ESCAPES
	.segment "CODE"
	.include "lcd.S"
	.include "psg.S"
	.include "acia.S"
	.include "kbd.S"
	.include "utils.S"
	
; program entry point
_reset:
	cld ; disable decimal mode
	sei ; disable interrupts
	
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
	jsr acia_init
	jsr kbd_init
	
	cli ; enable interrupts
	
	lda #'X'
	sta ACIA_DATA
loop:
	lda ACIA_STATUS ; read the ACIA status
	and #%1000      ; and the receiver full bit
	beq loop        ; if it's not set then loop
	
	lda ACIA_DATA ; read the received byte
	;sta ACIA_DATA ; echo it back
	
	jsr psg_write 
	;jsr lcd_write_byte
	
	jmp loop
	
	jmp halt
	
hello_msg:
	.asciiz "MOLD-I\n"
	
	.segment "RESET_VECTOR"
	.word _irq
	.word _reset
	.word _irq