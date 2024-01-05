	.segment "CODE"
	.include "lcd.S"
	.include "utils.S"
	
; program entry point
_start:
	cld ; disable decimal mode
	cli ; disable interrupts
	
	jsr lcd_init ; initialise the LCD
	
	lcd_write_string message ; write a message

	jsr halt
	
message:
	.asciiz "Test123"
	
	.segment "RESET_VECTOR"
	.word _start
	.word $0000