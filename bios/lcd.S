	.include "via1.S"
	
; constants
LCD_RS = %00100000
LCD_E  = %01000000
LCD_RW = %10000000

.macro lcd_write_string msg
	; print using indexing
	ldx #0
next:
	lda msg, x         ; load next byte from string
	beq end            ; branch out if it's zero
	jsr lcd_write_byte ; write the byte to the lcd
	inx                ; increment index
	jmp next           ; write next byte
end:
	.endmacro
	
; sends an instruction to the LCD
; inputs: A - instruction
; outputs: none
; affects: none
lcd_write_instruction:
	; set the data bits accordingly
	sta VIA1_ORB
	
	txa ; save x on stack
	pha
	
	; pulse required signals
	; set RS to low (instruction), RW to low (write), E to low (don't enable)
	ldx #0
	stx VIA1_ORA
	
	; set RS to low (instruction), RW to low (write), E to high (enable)
	ldx #LCD_E
	stx VIA1_ORA
	
	; set RS to low (instruction), RW to low (write), E to low (don't enable)
	ldx #0
	stx VIA1_ORA	

	pla ; restore X
	tax

	rts
	
; writes a byte to the LCD
; inputs: A - instruction
; outputs: none
; affects: none
lcd_write_byte:
	; set the data bits accordingly
	sta VIA1_ORB

	txa ; save x on stack
	pha

	; pulse required signals
	; set RS to high (data), RW to low (write), E to low (don't enable)
	ldx #LCD_RS
	stx VIA1_ORA
	
	; set RS to low (instruction), RW to low (write), E to high (enable)
	ldx #(LCD_RS|LCD_E)
	stx VIA1_ORA
	
	; set RS to high (data), RW to low (write), E to low (don't enable)
	ldx #LCD_RS
	stx VIA1_ORA	

	pla ; restore X
	tax
	
	rts

; initialises the lcd
; inputs: none
; outputs: none
; affects: A
lcd_init:
	; initialise the LCD in 8 bit mode
	; LCD data bits are in VIA1 port B
	; LCD RS bit 5, E bit 6, RW bit 7
	lda #%11111111 ; set VIA1 PORTB as outputs
	sta VIA1_DDRB
	
	lda #%11100000 ; set top bits of VIA1 PORTA as outputs
	sta VIA1_DDRA
	
	lda #%00111000 ; set interface data length to 8 bits and 5x8 font
	jsr lcd_write_instruction	

	lda #%00001110 ; enable display
	jsr lcd_write_instruction
	
	lda #%00000001 ; clear display
	jsr lcd_write_instruction
	
	rts