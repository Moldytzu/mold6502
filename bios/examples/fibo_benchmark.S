	.feature STRING_ESCAPES
	.segment "CODE"
	.include "lcd.S"
	.include "psg.S"
	.include "acia.S"
	.include "kbd.S"
	.include "utils.S"
	
	Av = $F0
	Bv = $F1
	Cv = $F2
	
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

	dey
	bne loop_fibo
	
	ply
	rts
	
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
	
	lda #'S'
	sta ACIA_DATA
	
	ldy #100
	ldx #255
	
loopy:
loopx:
	jsr fibonaci
	dex
	bne loopx
	dey
	bne loopy
	
	lda #'F'
	sta ACIA_DATA

loop:
	lda ACIA_STATUS ; read the ACIA status
	and #%1000      ; and the receiver full bit
	beq loop        ; if it's not set then loop
	
	jmp _reset
	
hello_msg:
	.asciiz "MOLD-I\n"
	
	.segment "RESET_VECTOR"
	.word _irq
	.word _reset
	.word _irq