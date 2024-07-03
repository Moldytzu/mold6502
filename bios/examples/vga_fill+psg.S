	.feature STRING_ESCAPES
	.segment "CODE"
	.include "lcd.S"
	.include "psg.S"
	.include "acia.S"
	.include "kbd.S"
	.include "utils.S"
	
	VIA3_BASE = $8020
	VIA3_DDRA = VIA3_BASE + 3
	VIA3_DDRB = VIA3_BASE + 2
	VIA3_ORA = VIA3_BASE + 1
	VIA3_ORB = VIA3_BASE + 0
	VIA3_T1CL = VIA3_BASE + 4
	VIA3_T1CH = VIA3_BASE + 5
	VIA3_PCR = VIA3_BASE + 12
	VIA3_ACL = VIA3_BASE + $B
	VIA3_IER = VIA3_BASE + $E
	VIA3_IFR = VIA3_BASE + $D
	
	VGA_DATA = $8010
	VGA_LOW = VIA3_ORA
	VGA_HIGH = VIA3_ORB
	
	START = $FF
	
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

	lda #%11111111
	sta VIA3_DDRB
	sta VIA3_DDRA
	stz VIA3_ORA
	stz VIA3_ORB

	; umple cu paleta de culori
	ldy #0
fill_negru:
	ldx VIA1_ORA
	bne fill_negru

	sty VGA_DATA

	inc VIA3_ORA
	bne skip_inca_negru
	inc VIA3_ORB
skip_inca_negru:
	lda VIA3_ORB
	cmp #255
	beq fill_end_negru
	
	jmp fill_negru
fill_end_negru:

	; umple cu paleta de culori
	stz START
	ldy START
fill:
	jsr play_psg
	ldx VIA1_ORA
	bne fill

	sty VGA_DATA
	iny
	
	inc VIA3_ORA
	bne skip_inca
	inc VIA3_ORB
	iny
skip_inca:
	
	lda VIA3_ORB
	cmp #255
	beq fill_end
	
	jmp fill
fill_end:
	inc START
	ldy START
	stz VIA3_ORA
	stz VIA3_ORB
	jmp fill

	jmp halt
	
play_psg:
	pha
	lda ACIA_STATUS ; read the ACIA status
	and #%1000      ; and the receiver full bit
	beq exit_psg    ; if it's not set then skip
	
	lda ACIA_DATA ; read the received byte
	jsr psg_write 
exit_psg:
	pla
	rts
	
hello_msg:
	.asciiz "MOLD-I\n"
	
	.segment "RESET_VECTOR"
	.word _irq
	.word _reset
	.word _irq