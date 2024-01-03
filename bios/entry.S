	.org $C000
	
; constants
VIA1_BASE = $A000
VIA1_ORB  = VIA1_BASE + 0
VIA1_ORA  = VIA1_BASE + 1
VIA1_DDRB = VIA1_BASE + 2
VIA1_DDRA = VIA1_BASE + 3

LCD_RS = %00100000
LCD_E  = %01000000
LCD_RW = %10000000

; halts the CPU
; inputs: none
; outputs: none
; affects: none
; note: doesn't return
halt:
	; in emulator we exit if we jump to 0xFFFF
	jmp 0xFFFF

	jmp halt
	
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
	
; program entry point
_start:
	cld ; disable decimal mode
	jsr lcd_init
	
	lda #'H'
	jsr lcd_write_byte
	lda #'e'
	jsr lcd_write_byte
	lda #'l'
	jsr lcd_write_byte
	lda #'l'
	jsr lcd_write_byte
	lda #'o'
	jsr lcd_write_byte
	
	jsr halt
	
	.org $FFFC
	.word _start
	.word $0000