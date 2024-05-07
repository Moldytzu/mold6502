	.feature STRING_ESCAPES
	.segment "CODE"
	.include "lcd.S"
	.include "utils.S"
	
	ACIA_BASE = $8100
	ACIA_DATA = ACIA_BASE + 0
	ACIA_STATUS = ACIA_BASE + 1
	ACIA_COMMAND = ACIA_BASE + 2
	ACIA_CONTROL = ACIA_BASE + 3
	
; program entry point
_reset:
	cld ; disable decimal mode
	cli ; disable interrupts
	
	jsr lcd_init        ; initialise the LCD
	
	lda #$1F ; 8N1 @ 19600 baud
	sta ACIA_CONTROL
	
	lda #%00001011 ; no parity, irqs disabled, rx/tx enabled
	sta ACIA_COMMAND
	
	lda #'X'
	sta ACIA_DATA
	
	lda ACIA_STATUS
	jsr lcd_write_uint8 
	
loop:
	lda ACIA_DATA
	beq loop
	
	jsr lcd_write_byte
	
	jmp loop
	
	;jsr via1_timer_init ; initialise the timer
	
	;lcd_write_string hello_msg
	
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