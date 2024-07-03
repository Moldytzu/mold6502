	ACIA_BASE = $8100
	ACIA_DATA = ACIA_BASE + 0
	ACIA_STATUS = ACIA_BASE + 1
	ACIA_COMMAND = ACIA_BASE + 2
	ACIA_CONTROL = ACIA_BASE + 3
	
acia_init:
	lda #$00 ; software reset
	sta ACIA_STATUS

	lda #%00010000 ; 8N1 @ 115200 baud
	sta ACIA_CONTROL
	
	lda #%00001011 ; no parity, irqs disabled, rx/tx enabled
	sta ACIA_COMMAND
	rts