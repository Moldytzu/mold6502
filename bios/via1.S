VIA1_BASE = $8800
VIA1_DDRA = VIA1_BASE + 3
VIA1_DDRB = VIA1_BASE + 2
VIA1_ORA = VIA1_BASE + 1
VIA1_ORB = VIA1_BASE + 0
VIA1_T1CL = VIA1_BASE + 4
VIA1_T1CH = VIA1_BASE + 5
VIA1_PCR = VIA1_BASE + 12
VIA1_ACL = VIA1_BASE + $B
VIA1_IER = VIA1_BASE + $E
VIA1_IFR = VIA1_BASE + $D

VIA1_TIMER_COUNT_L = $01
VIA1_TIMER_COUNT_H = $02
VIA1_TIMER_INT_COUNT_L = $03
VIA1_TIMER_INT_COUNT_H = $04

via1_timer_init:
	lda #0
	sta VIA1_TIMER_COUNT_L
	sta VIA1_TIMER_COUNT_H
	
	lda #%01000000 ; enable timer 1
	sta VIA1_IER
	
	lda #%01000000 ; free-running mode for timer 1
	sta VIA1_ACL
	
	jmp via1_reset_timer
	
via1_timer_irq_handle:
	bit VIA1_T1CL
	inc VIA1_TIMER_COUNT_L
	bne end_irq
	inc VIA1_TIMER_COUNT_H
end_irq:
	rts
	
via1_reset_timer:
	lda #$FF
	sta VIA1_TIMER_INT_COUNT_L
	sta VIA1_T1CL
	lda #$FF
	sta VIA1_TIMER_INT_COUNT_H
	sta VIA1_T1CH
	rts