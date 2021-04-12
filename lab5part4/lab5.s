.data
	.global lab5library
	.global UART0_Handler
	.global Switch_Handler
	.global Timer_Handler
	.global timer_init
	.global interrupt_init
	.global gpio_init
	.global read_character
	.global read_from_push_btn
	.global exiting
	.global vert
	.global output_string
	.global clear_board
	.global update_x_y
	.global update_board
	.global ded_check
	.global ded
UARTICR: .equ 0x044
GPTMICR: .equ 0x024


board: 	.string " __________ ",0xA,0xD
		.string "|          |",0xA,0xD
		.string "|          |",0xA,0xD
		.string "|          |",0xA,0xD
		.string "|          |",0xA,0xD
		.string "|    *     |",0xA,0xD
		.string "|          |",0xA,0xD
		.string "|          |",0xA,0xD
		.string "|          |",0xA,0xD
		.string " __________ ",0xA,0xD, 0
wasd:	.byte 4 ;direction variable, 1,2,3,4 are ULDR respectively.  We move right initially
x:      .byte 5 ;coordinate variable, helps for bounds checking and plotting a point
y:		.byte 5 ;coordinate variable, helps for bounds checking and plotting a point
check: 	.byte " "	; used to check and see if spacebar was hit, also used in update_board
star: 	.byte "*"	; used to update the board in update_board

.text
	.global lab5
;Pointers
ptr_to_board: 	.word board
ptr_to_wasd: 	.word wasd
ptr_to_x: 		.word x
ptr_to_y: 		.word y
ptr_to_check:	.word check
ptr_to_star:	.word star


lab5:
 	STMFD SP!,{r0-r12,lr}

	bl gpio_init		;initialize

	bl interrupt_init

	bl timer_init

	bl print_board

loop:						;loop
	ldr r0, ptr_to_check 	;check if q to quit early.
	CMP r0, #0x71
	BNE loop

 	LDMFD sp!, {r0-r12,lr}
 	MOV pc, lr


UART0_Handler:
	STMFD SP!,{r0-r12,lr}
	mov r1, #0xC000
	movt r1, #0x4000
	ldr r3, ptr_to_check
	bl read_character ;r0 set to character
	;Checking Value of Character
	CMP r0, #0x20
	BNE YUPT
	; Include Logic For Directions
	;r0 is wasd, put new number into r2
	;then put r2 into wasd.
	ldr r4, ptr_to_wasd
	ldrb r0, [r4]

    CMP r0, #1
    IT EQ
    MOVEQ r2, #3

    CMP r0, #2
    IT EQ
    MOVEQ r2, #4

    CMP r0, #3
    IT EQ
    MOVEQ r2, #1

    CMP r0, #4
    IT EQ
    MOVEQ r2, #2

    strb r2, [r4]

    mov r2, #0x10
	strb r2, [r1, #UARTICR]
	;clear interrupt
	LDMFD sp!, {r0-r12,lr}
	BX lr

YUPT: ; y u press that? Exit jump
	strb r0, [r3]
	mov r2, #0x10
	strb r2, [r1, #UARTICR]
	;clear interrupt
	LDMFD sp!, {r0-r12,lr}
	BX lr

;I've manually debugged up to hereish

Switch_Handler:
	STMFD SP!,{r0-r12,lr}
 	mov r1, #0xC000
	movt r1, #0x4000

	ldrb r4, ptr_to_wasd
	ldrb r0, [r4]

	CMP r2, #2	; left
	BEQ vert;

	CMP r2, #4	; right
	BEQ vert

	MOV r2, #4	; up and down
	strb r2, [r0]
	b exiting

vert:
	STMFD SP!,{r0-r12,lr}

	MOV r2, #1
	strb r2, [r0]

	LDMFD sp!, {r0-r12,lr}
	MOV pc, lr

exiting:
	mov r2, #0x10
	strb r2, [r1, #UARTICR]
	LDMFD sp!, {r0-r12,lr}
	BX lr

print_board:
	STMFD SP!,{r0-r12,lr}

	ldr r0, ptr_to_board
	bl output_string


	LDMFD sp!, {r0-r12,lr}
	MOV pc, lr

Timer_Handler:
	STMFD SP!,{r0-r12,lr}
	ldrb r0, ptr_to_x
	ldrb r1, ptr_to_y
	ldrb r2, ptr_to_board
	ldrb r3, ptr_to_check
	ldrb r4, ptr_to_star
	ldrb r5, ptr_to_wasd

	bl clear_board
	bl update_x_y

	ldrb r6, ptr_to_x
	ldrb r7, ptr_to_y
	strb r0, [r6]
	strb r1, [r7]
	ldrb r0, ptr_to_x
	ldrb r1, ptr_to_y


	bl ded_check
	bl update_board
	bl print_board

	mov r5, #0x0000
	movt r5, #0x4003
	mov r0, #1
	strb r0, [r5, #GPTMICR]
	LDMFD sp!, {r0-r12,lr}
	BX lr

ded:

	.end
