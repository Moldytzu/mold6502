	ACIA_BASE = $8100
	ACIA_DATA = ACIA_BASE + 0
	ACIA_STATUS = ACIA_BASE + 1
	ACIA_COMMAND = ACIA_BASE + 2
	ACIA_CONTROL = ACIA_BASE + 3
	
acia_init:
	lda #$1F ; 8N1 @ 19600 baud
	sta ACIA_CONTROL
	
	lda #$0B ; no parity, irqs disabled, rx/tx enabled
	sta ACIA_COMMAND
	rts