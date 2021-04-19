	.data
	.global num_prompt
	.global opp_prompt
	.global restart_prompt
	.global results
	.global sum_results_prompt
	.global sub_results_prompt
	.global num_1
	.global num_2
numb_prompt: .string "Enter Your Number",0
opp_prompt:	.string "Enter + or -",0
retry_prompt: .string "Would you like to go again? y/n",0
results:	.string "No Solution",0
sum_results_prompt: .string "Sum is:",0
sub_results_prompt: .string "Difference is:",0
num_1: .string "Blank string",0
num_2: .string "Blank string",0
.text
	.global lab3
U0FR:  .equ 0x18			; UART0 Flag Register
ptr_to_num_prompt:	.word numb_prompt
ptr_to_opp_prompt:	.word opp_prompt
ptr_to_restart_prompt:	.word retry_prompt
ptr_to_results:	.word results
ptr_to_sum_results_prompt: .word sum_results_prompt
ptr_to_sub_results_prompt: .word sub_results_prompt
ptr_to_num_1:	.word num_1
ptr_to_num_2:	.word num_2


lab3:
	STMFD SP!,{lr}	; Store register lr on stack

	bl uart_init ; r1 is set... do not ever change!

	bl num_prompt ; num1 and echo

	bl num_prompt ; num2 and echo

	bl opt_prompt ; opp and echo

	bl results_prompt

	bl restart_prompt

 	LDMFD sp!, {lr}
	mov pc, lr

; initialize uart
uart_init:
	STMFD SP!,{lr}

	ldr r5, ptr_to_results
	ldr r6, ptr_to_num_1
	ldr r7, ptr_to_num_2

	mov r0, #0x99
	strb r0, [r6]	; add indicator for blank

	mov r1, #0xC000
	movt r1, #0x4000	; base address of UART Data register

 	LDMFD sp!, {lr}
	mov pc, lr

;Prompts
num_prompt:
	STMFD SP!,{lr}

	ldr r0, ptr_to_num_prompt ; r0 has the string, call output string
	bl output_string ; Prompt User Input
	bl read_string ; Read User Input
	bl output_string ;Echo

	LDMFD sp!, {lr}
	mov pc, lr


opt_prompt:
	STMFD SP!,{lr}

	ldr r0, ptr_to_opp_prompt ; r0 has the string, call output string
	bl output_string ; Prompt User Input
	bl read_character ; Read User Input

	LDMFD sp!, {lr}
	mov pc, lr

results_prompt:
	STMFD SP!,{lr}

	bl output_string
	ldr r0, ptr_to_results
	bl output_string

	LDMFD sp!, {lr}
	mov pc, lr

restart_prompt:
	STMFD SP!,{lr}

	ldr r0, ptr_to_restart_prompt
	bl output_string
	bl read_character
	bl output_character

	LDMFD sp!, {lr}
	mov pc, lr

;Function in Calling Order
read_string:
	STMFD SP!,{lr}	; Store register lr on stack

		; Your code for your read_string routine is placed here

	mov r8, #0

	ldrb r0, [r6]
	CMP r0, #0x39	; check whether there is a first integer or not
	BGT first		; r0>#0x39, then it is not a number
	BL second

read_loop:
	ldrb r2, [r1, #U0FR]
	AND r2, r2, #0x10
	CMP r2, #0
	BNE read_loop

	ldrb r3, [r1]

	CMP r3, #0xD		; #0xD is 'enter' key
	BEQ read_done		; if user hits enter, go to int2str

	strb r3, [r0]
	ADD r0, r0, #1	; move pointer to the next slot
	ADD r8, r8, #1	; add 1 for counting the number of digits
	BNE read_loop

first:
	mov r0, r6
	BL read_loop

second:
	mov r0, r7
	BL read_loop

read_done:
	mov r2, #0
	strb r2, [r0]	; insert 0 at the end
	SUB r0, r0, r8	; back to base address

	LDMFD sp!, {lr}
	mov pc, lr

output_string: 				; getting string in r0
	STMFD SP!,{lr}    		; Store register lr on stack

    MOV r3, r0 				; move string into r3 clearing r0 for output_char
    BL output_loopy

output_loopy:
    ldrb r0, [r3] 			;store the character into r0
    CMP r0, #0
    BEQ output_done
    bl output_character 	;output character
    ADD r3, r3, #1			;move pointer
    bl output_loopy

output_done:
	mov r0, #0x0A
	strb r0, [r1]

	mov r0, #0x0D
	strb r0, [r1]

    LDMFD sp!, {lr}
    mov pc, lr

output_character:
    STMFD SP!,{lr}    ; Store register lr on stack

	BL Loop_TxFF

Loop_TxFF:
    ldrb r2, [r1, #U0FR]
    AND r2,r2, #0x20
    CMP r2,#0
    BNE Loop_TxFF
    strb r0, [r1]

        ; IM WRITING
        ; Your code to output a character to be displayed in PuTTy
        ; is placed here.  The character to be displayed is passed
        ; into the routine in r0.

    LDMFD sp!, {lr}
    mov pc, lr

read_character:
	STMFD SP!,{lr}	; Store register lr on stack

		; Your code to receive a character obtained from the keyboard
		; in PuTTy is placed here.  The character is received in r0.

	BL read_loop2

read_loop2:
	ldrb r2, [r1, #U0FR]
	AND r2, r2, #0x10
	CMP r2, #0
	BNE read_loop2

	ldrb r8, [r1]
	CMP r8, #0x2B	; compare r3 with plus, then check operator
	BEQ opt
	CMP r8, #0x2D
	BEQ opt
	CMP r8, #0x79
	BEQ opt
	CMP r8, #0x6E
	BEQ opt

	CMP r8, #0xD		; #0xD is 'enter' key
	BEQ print_opt		; if user does not hit enter, go to loop

	strb r11, [r1]		; print n for no

	LDMFD sp!, {lr}
	mov pc, lr

opt:
	mov r11, r8
	bl read_loop2	; back to loop

print_opt:
	mov r0, r11
	bl output_character

	mov r0, #0x0A
	strb r0, [r1]

	mov r0, #0x0D
	strb r0, [r1]

	CMP r11, #0x79
	BEQ Yes				; it is not operator

	CMP r11, #0x6E
	BNE getnum1

	LDMFD sp!, {lr}
	mov pc, lr

getnum1:
	MOV r0, r6
	MOV r2, #0
	MOV r9, #0
	MOV r10, #10 			; store 10 for multiplication
	BL Loop_getnum1			; go to the loop

Loop_getnum1:
	ldrb r9, [r0]		; load content from pointer of string
	CMP r9, #0			; compare my string to 0
	BEQ getnum2			; if it is 0, stop
	MUL r2, r2, r10		; multiply 10 to shift left
	SUB r9, r9, #0x30	; substract 0x30 to get integer
	ADD r2, r2, r9		; add digit to the integer
	ADD r0, r0, #0x1	; move to the next pointer
	BL Loop_getnum1		; back to the beginning of the loop

getnum2:
	MOV r0, r7
	MOV r3, #0
	MOV r9, #0
	MOV r10, #10 			; store 10 for multiplication
	BL Loop_getnum2			; go to the loop

Loop_getnum2:
	ldrb r9, [r0]		; load content from pointer of string
	CMP r9, #0			; compare my string to 0
	BEQ minus			; if it is 0, stop
	MUL r3, r3, r10		; multiply 10 to shift left
	SUB r9, r9, #0x30	; substract 0x30 to get integer
	ADD r3, r3, r9		; add digit to the integer
	ADD r0, r0, #0x1	; move to the next pointer
	BL Loop_getnum2

minus:
	CMP r11, #0x2B		; not minus
	BEQ plus

	CMP r3, r2
	BGT neg_ret

	SUB r2, r2, r3

	ldr r0, ptr_to_results

	bl num_digits

	LDMFD sp!, {lr}
	mov pc, lr

plus:
	ADD r2, r2, r3

	ldr r0, ptr_to_results

	bl num_digits

	LDMFD sp!, {lr}
	mov pc, lr

neg_ret:
	mov r12, #0x2D
	ldr r0, ptr_to_results
	strb r12, [r0]
	ADD r0, r0, #1
	SUB r2, r3, r2

	bl num_digits

read_done2:
	LDMFD sp!, {lr}
	mov pc, lr

num_digits:
	STMFD r13!, {r14}

	; Your code for the num_digits routine goes here.
	MOV r3, r2	; save original result
	MOV r8, #0	; initialize the number of digits
	MOV r9, #10 ; store 10 for multiplication
	BL Loop_num_digits

Loop_num_digits:
	UDIV r3, r3, r9			; Divide by 10
	ADD r8, r8, #1			; add 1 to the number of digits
	CMP r3, #0				; compare current integer is 0
	BNE Loop_num_digits		; if not 0, go to the loop
	BL int2str				; finish num_digits


int2str:
	ADD r0, r0, r8	; Add number of digits to pointer
	MOV r3, #0		; initialize r3
	strb r3, [r0]	; store Null(0) to pointer
	SUB r0, r0, #1	; move pointer
	MOV r8, #10 	; store 10 for multiplication
	MOV r9, #0x30	; subtract to get exact number
	BL loopy

loopy:
	UDIV r3, r2, r8 ; Divide 10 to eliminate least significant digit
	MUL r3, r3, r8	; Multiple 10 to maintain the number of digits
	SUB r10, r2, r3	; get least significant digit
	ADD r10, r9		; add 0x30 to get ASCII
	strb r10, [r0]	; store digit to pointer
	UDIV r2, r2, r8	; Divide 10 to get new number without least significant digit
	CMP r2, #0		; compare current value and 0
	BEQ retVal		; if 0, it is done
	SUB r0, r0, #1	; move pointer
	BL loopy		; back to loop

retVal:
	ldr r0, ptr_to_sum_results_prompt
	CMP r11, #0x2B		; r11 == +
	BNE Dif				; go to Dif if -

	LDMFD r13!, {r14}
	MOV pc, lr

Dif:
	ldr r0, ptr_to_sub_results_prompt

	LDMFD sp!, {lr}
	mov pc, lr
Yes:
	bl lab3


	.end
