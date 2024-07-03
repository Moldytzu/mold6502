	.include "via1.S"
	
; constants
LCD_E  = %10000000
LCD_RW = %01000000
LCD_RS = %00100000
LCD_STATUS = %00000001

; variables
LCD_CURRENT_LINE = $00

.macro lcd_write_string msg
	.local next
	.local end
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
	
; wait for the LCD to be ready
lcd_wait:
	pha
	lda #0 ; input
	sta VIA1_DDRB
	
busy:
	lda #(LCD_RW | LCD_STATUS)
	sta VIA1_ORA
	
	lda #(LCD_RW | LCD_E | LCD_STATUS)
	sta VIA1_ORA
	
	lda VIA1_ORB
	and #%10000000
	bne busy
	
	lda #0
	sta VIA1_ORA

	lda #%11111111 ; output
	sta VIA1_DDRB
	pla
	rts
	
; sends an instruction to the LCD
; inputs: A - instruction
; outputs: none
; affects: none
lcd_write_instruction:
	jsr lcd_wait

	; set the data bits accordingly
	sta VIA1_ORB
	
	phx
	
	; pulse required signals
	; set RS to low (instruction), RW to low (write), E to low (don't enable)
	ldx #LCD_STATUS
	stx VIA1_ORA
	
	; set RS to low (instruction), RW to low (write), E to high (enable)
	ldx #(LCD_E | LCD_STATUS)
	stx VIA1_ORA
	
	; set RS to low (instruction), RW to low (write), E to low (don't enable)
	ldx #0
	stx VIA1_ORA	

	plx
	rts
	
; clears display ram and resets cursor of the LCD
lcd_clear:
	lda #%00000001 ; clear display
	jsr lcd_write_instruction
	
	lda #0
	sta LCD_CURRENT_LINE ; reset current line
	rts

; resets cursor of the LCD
lcd_home:
	lda #%00000010 ; return home
	jsr lcd_write_instruction
	
	lda #0
	sta LCD_CURRENT_LINE ; reset current line
	rts
	
; writes a byte to the LCD
; inputs: A - instruction
; outputs: none
; affects: none
lcd_write_byte:
	jsr lcd_wait

	cmp #$0A ; LF
	bne continue_write
	
	; handle special case of line feed
	lda LCD_CURRENT_LINE
	bne lcd_clear
	
	lda #%11000000 ; move cursor to second line
	jsr lcd_write_instruction
	
	inc LCD_CURRENT_LINE ; increment current line 
	rts
continue_write:
	; set the data bits accordingly
	sta VIA1_ORB

	phx

	; pulse required signals
	; set RS to high (data), RW to low (write), E to low (don't enable)
	ldx #(LCD_RS | LCD_STATUS)
	stx VIA1_ORA
	
	; set RS to low (instruction), RW to low (write), E to high (enable)
	ldx #(LCD_RS | LCD_E | LCD_STATUS)
	stx VIA1_ORA
	
	; set RS to high (data), RW to low (write), E to low (don't enable)
	ldx #LCD_RS
	stx VIA1_ORA	

	plx
	
	rts

; initialises the lcd
; inputs: none
; outputs: none
; affects: A
lcd_init:
	lda #0
	sta LCD_CURRENT_LINE

	; disable the PSG
	lda #%11111111
	sta VIA1_PCR

	; initialise the LCD in 8 bit mode
	; LCD data bits are in VIA1 port B
	; LCD RS bit 5, E bit 6, RW bit 7
	lda #%11111111 ; set VIA1 ports as outputs
	sta VIA1_DDRB
	
	lda #%01111111
	sta VIA1_DDRA
	
	rts
	
	lda #%00111000 ; set interface data length to 8 bits and 5x8 font
	jsr lcd_write_instruction

	lda #%00001110 ; enable display
	jsr lcd_write_instruction
	
	jsr lcd_clear ; clear display
	
	rts
	
lcd_write_uint8:
	phx
	pha
	
	; get top bits
	and #%11110000
	lsr
	lsr
	lsr
	lsr
	tax
	lda lcd_hex, x
	
	jsr lcd_write_byte
	
	pla
	
	and #%00001111
	tax
	lda lcd_hex, x
	jsr lcd_write_byte
	
	plx
	rts
	
lcd_hex:
	.asciiz "0123456789ABCDEF"