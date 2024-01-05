; halts the CPU
; inputs: none
; outputs: none
; affects: none
; note: doesn't return
halt:
	; in emulator we exit if we jump to 0xFFFF
	jmp $FFFF

	jmp halt