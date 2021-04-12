.data
U0FR:  .equ 0x18

board: 	.string " _______ ",0xA,0xD
		.string "|",27,"[1;32m*","    ",27,"[1;31m*",  27,"[1;34m*", 27,"[1;37m|",0xA,0xD
		.string "| ",27,"[1;33m*",27,"[1;32m*"," ",27,"[1;33m*",27,"[1;37m  |",0xA,0xD
		.string "| ",27,"[1;31m*","    ",27,"[1;34m*",27,"[1;37m|",0xA,0xD
		.string "|      ",27,"[1;36m*",27,"[1;37m|",0xA,0xD
		.string "|",27,"[1;36m*","     ",27,"[1;35m*",27,"[1;37m|",0xA,0xD
		.string "|       |",0xA,0xD
		.string "|*  *",27,"[1;35m*",27,"[1;37m  |",0xA,0xD
		.string "---------",0xA,0xD, 0
print: .string 27,"[1;32m",0xA,0xD, 0
reset: .string 27,"[1;37m", 0xA,0xD, 0
clear: .string 27,"[2J", 0xA, 0xD, 0

.text
	.global lab6
ptr_to_board: 	.word board
ptr_to_print:	.word print
ptr_to_clear:	.word clear
ptr_to_reset:	.word reset

lab6:
 	STMFD SP!,{r0-r12,lr}

	bl print_board

 	LDMFD sp!, {r0-r12,lr}
 	MOV pc, lr

print_board:
 	STMFD SP!,{r0-r12,lr}

	ldr r0, ptr_to_board
	bl output_string

	ldr r0, ptr_to_reset
	bl output_string

	ldr r0, ptr_to_clear
	bl output_string

 	LDMFD sp!, {r0-r12,lr}
 	MOV pc, lr

output_string: 				; Outputs String From r0 into PuTTy, sets r0 to 0. (Changes r0)
	STMFD SP!,{lr, r0-r11}  ; Store register lr on stack
    mov r1, #0xC000
	movt r1, #0x4000
output_loopy:
    ldrb r2, [r0] 			;store the character into r0
    CMP r2, #0
    BEQ output_done
    strb r2, [r1]		 	;output character
    ADD r0, r0, #1			;move pointer
    bl output_loopy
output_done:
    LDMFD sp!, {lr, r0-r11}
    mov pc, lr
