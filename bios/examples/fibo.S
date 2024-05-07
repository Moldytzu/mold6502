	.feature STRING_ESCAPES
	.segment "CODE"
	.include "lcd.S"
	.include "utils.S"
	
	Av = $05
	Bv = $06
	Cv = $07
	
fibonaci:
	phy
	ldy #12 ; 233
	
	lda #0
	sta Av
	sta Bv
	sta Cv
	
	lda #1
	sta Bv
loop_fibo:
	jsr lcd_home
	
	clc
	
	; C=A+B
	lda Av
	adc Bv
	sta Cv
	
	; A=B
	lda Bv
	sta Av
	
	; B=C
	lda Cv
	sta Bv
	
	; print C 
	lda Cv
	jsr lcd_write_uint8

	dey
	bne loop_fibo
	
	ply
	rts
	
; program entry point
_reset:
	cld ; disable decimal mode
	cli ; disable interrupts
	
	jsr lcd_init        ; initialise the LCD
	;jsr via1_timer_init ; initialise the timer
	
	lcd_write_string hello_msg
	
	ldx #255
loop1:
	jsr fibonaci
	jsr fibonaci
	jsr fibonaci
	jsr fibonaci
	dex
	bne loop1 
	
	jsr lcd_clear
	lcd_write_string gata_msg
	
	jsr halt
	
_irq:
	phx
	phy
	pha

	jsr via1_timer_irq_handle
	lcd_write_string irq_msg
	
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