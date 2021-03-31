.text
	.global lab5
	.global read_character
	.global output_character
	.global output_string
	.global read_string
	.global uart_init
	.global gpio_init
	.global read_from_push_btn
	.global illuminate_RGB_LED
	.global num_digits
	.global int2str
	.global str2int
	.global string_read
	.global interrupt_init
	.global timer_init
	.global gpio_init
	.global clear_board
	.global update_x_y
	.global update_board
	.global ded_check
	.global ded

UARTICR: .equ 0x044
UARTIM: .equ 0x038
EN0: .equ 0x100
U0FR:  .equ 0x18
CLOCK: .equ 0x608
DIR: .equ 0x400
DATA: .equ 0x3FC
DIGI: .equ 0x51C
PULL: .equ 0x510
; switch
GPIOIS: .equ 0x404
GPIOIBE: .equ 0x408
GPIOIV: .equ 0x40C
GPIOIM: .equ 0x410
; timer
RCGCTIMER: .equ 0x604
GPTMCTL: .equ 0x00C
GPTMCFG: .equ 0x000
GPTMTAMR: .equ 0x004
GPTMTAILR: .equ 0x028
GPTMIMR: .equ 0x018
GPTMICR: .equ 0x024
string_read: .string " ",0
ptr_to_string_read:	.word string_read



read_character:  			;Stores Character From PuTTy into r0 (Changes r0)
	STMFD SP!,{lr, r4-r11}			; Store registers on stack
	bl uart_init
	ldrb r0, [r1]			;store PuTTy into r0
	LDMFD sp!, {lr, r4-r11}
    mov pc, lr


output_character: 			;Outputs Character From r0 into PuTTy (Changes r1,r2)
    STMFD SP!,{lr, r4-r11}

    strb r0, [r1]		 	;print string

    LDMFD sp!, {lr, r4-r11}
    mov pc, lr


output_string: 				; Outputs String From r0 into PuTTy, sets r0 to 0. (Changes r0)
	STMFD SP!,{lr, r4-r11}  ; Store register lr on stack
    MOV r3, r0 				; move string into r3 clearing r0 for output_char
    bl uart_init
output_loopy:
    ldrb r0, [r3] 			;store the character into r0
    CMP r0, #0
    BEQ output_done
    strb r0, [r1]		 	;output character
    ADD r3, r3, #1			;move pointer
    bl output_loopy
output_done:
	mov r0, #0x0A
	strb r0, [r1]
	mov r0, #0x0D
	strb r0, [r1]
    LDMFD sp!, {lr, r4-r11}
    mov pc, lr

read_string:  				;Stores a string read from PuTTy into r0 (Changes r0)
	STMFD SP!,{lr, r1-r11}			;Store register lr on stack
	ldr r5, ptr_to_string_read
	MOV r4, #0				;Sets Counter
read_string_loop:
	bl read_character		;Read Character from PuTTY into r0
	ADD r4,r4,#1			;Increment Counter
	CMP r0, #0xD			;Cmp (#0xD is 'enter' key)
	BEQ read_string_done	;jump because string is taken
	strb r0, [r5]
	ADD r5, r5, #1			;move pointer to the next slot in array
	BNE read_string_loop	;loop back for more letters
read_string_done:
	mov r2, #0
	strb r2, [r5]			; insert 0 at the end
	SUB r5, r5, r4			; back to base address
	LDMFD sp!, {lr, r1-r11}
	mov pc, lr

uart_init: ; initialize uart register to r1 (Changes r1)
	STMFD SP!,{lr, r0}

	mov r1, #0xC000
	movt r1, #0x4000

 	LDMFD sp!, {lr, r0}
	mov pc, lr

read_from_push_btn:					;reads if button was pressed, calls pushed tell the code that
	STMFD SP!,{lr, r1-r11}			;button was pushed for other logic
    ldrb r2, [r1, #DATA]
    AND r2, #0x10
    CMP r2, #0

	LDMFD sp!, {lr, r1-r11}
	MOV pc, lr


illuminate_RGB_LED: ;Changes LED Color based on value in r3, 0 is blue, 1 is green, 2 is red, more to come
	STMFD SP!,{lr, r4-r11}	; Store register lr on stack
	bl gpio_init
    CMP r3, #0	; Light blue
    BEQ blue
    CMP r3, #1	; Light green
    BEQ green
    CMP r3, #2	; Light red
    BEQ red

	LDMFD sp!, {lr, r4-r11}
	MOV pc, lr

blue:
	mov r2, #0x04
    strb r2, [r1, #DATA]
    LDMFD sp!, {lr, r4-r11}
	MOV pc, lr
green:
	mov r2, #0x08
    strb r2, [r1, #DATA]
    LDMFD sp!, {lr, r4-r11}
	MOV pc, lr
red:
	mov r2, #0x02
    strb r2, [r1, #DATA]
    LDMFD sp!, {lr, r4-r11}
	MOV pc, lr


num_digits:  				;Determines the number of digits in r0 , output in r1 (Changes r0,r1)
	STMFD SP!, {lr,r2}
	MOV r1, #0				; initialize the number of digits
	MOV r2, #10 			; store 10 for multiplication
Loop_num_digits:
	UDIV r0, r0, r2			; Divide by 10
	ADD r1, r1, #1			; add 1 to the number of digits
	CMP r0, #0				; compare current integer is 0
	BNE Loop_num_digits		; if not 0, go to the loop
	LDMFD sp!, {lr, r2}
	mov pc, lr



	; Initialize r0 with the integer used to test num_digits
	; and r2 with the number of digits returned by num_digits.
	; Initialize r1 with the pointer to my_string, then call
	; int2str using the lines shown below.
int2str:
	STMFD SP!, {lr,r3-r11}
	ADD r1, r1, r2
	MOV r1, #0x30
	SUB r1, #1
	bl loopy
loopy:
	MOV r5, #10
	UDIV r3,r0, #10
	MUL r3,r3, r5
	SUB r4,r3,r0
	ADD r4,#0x30
	MOV r4, r1
	beq retVal
	SUB r1,#1
	bl loopy
retVal:
	LDMFD sp!, {lr,r3-r11}
	MOV pc, lr

str2int: ;Converts a String to an Integer.  Ptr to String in r0, becomes ptr to int in r0
	STMFD sp!, {lr,r1-r11}
	MOV r7, r0
	MOV r2, #0				; initialize r2 with 0
	MOV r4, #10 			; store 10 for multiplication
	MOV r5, #0x30			; subtract to get exact number
	BL Loop_str2int 		; go to the loop

str2int_done:
	MOV r0,r7
	LDMFD sp!, {lr,r1-r11}
	MOV pc, lr

Loop_str2int:
	ldrb r1, [r0]		; load content from pointer of string
	CMP r1, #0			; compare my string to 0
	BEQ str2int_done	; if it is 0, stop
	MUL r2, r2, r4		; multiply 10 to shift left
	SUB r1, r1, r5		; substract 0x30 to get integer
	ADD r2, r2, r1		; add digit to the integer
	ADD r0, r0, #1		; move to the next pointer
	BL Loop_str2int		; back to the beginning of the loop

interrupt_init:
 	STMFD SP!,{r0-r12,lr} ; Store register lr on stack

 	; Your code is placed here

	; addrees of EN0
	mov r3, #0xE000
	movt r3, #0xE000

	;; UART
	; Enable interrupt
	ldr r2, [r3, #EN0]
	ORR r2, r2, #0x20
	str r2, [r3, #EN0]

	; address of UART
 	mov r1, #0xC000
	movt r1, #0x4000

	; Enable interrupt
	ldr r2, [r1, #UARTIM]
	ORR r2, r2, #0x10
	str r2, [r1, #UARTIM]

	;; Switch
	; enable switch
	ldr r2, [r3, #EN0]
	ORR r2, r2, #0x40000000
	str r2, [r3, #EN0]

	; switch init
	mov r4, #0x5000
	movt r4, #0x4002

	; configuring level sensitive
	ldrb r2, [r4, #GPIOIS]
	BIC r2, r2, #0x10
	strb r2, [r4, #GPIOIS]

	; Allow GPIO interrupt event
	ldr r2, [r4, #GPIOIBE]
	BIC r2, r2, #0x10
	str r2, [r4, #GPIOIBE]

	; set to high trigger
	ldr r2, [r4, #GPIOIV]
	ORR r2, r2, #0x10
	str r2, [r4, #GPIOIV]

	; allow interrupt to be triggered
	ldr r2, [r4, #GPIOIM]
	ORR r2, r2, #0x10
	str r2, [r4, #GPIOIM]

	LDMFD sp!, {r0-r12,lr}
	MOV pc, lr

timer_init:
 STMFD SP!,{r0-r12,lr} ; Preserve registers on the stack

	; Base address timer Clock
	mov r4, #0xE000
	movt r4, #0x400F

	; Enable Timer Clock
 	ldr r2, [r4, #RCGCTIMER]
	ORR r2, r2, #0x1
	str r2, [r4, #RCGCTIMER]

	; base address of timer
	mov r5, #0x0000
	movt r5, #0x4003

	; Disable timer
	ldrb r2, [r5, #GPTMCTL]
	AND r2, r2, #0xFE
	strb r2, [r5, #GPTMCTL]

	; 32-bit
	ldrb r2, [r4, #GPTMCFG]
	AND r2, r2, #0x0
	strb r0, [r4, #GPTMCFG]

		; Set to Periodic Mode
	ldr r2, [r4, #GPTMTAMR]
	ORR r2, r2, #0x2
	str r2, [r4, #GPTMTAMR]

	; Configure Interval
	MOV r2, #0x2400
	MOVT r2, #0x00F4
	str r2, [r5, #GPTMTAILR]

	; set timer interrupt
	ldr r2, [r5, #GPTMIMR]
	ORR r2, r2, #0x1
	str r2, [r5, #GPTMIMR]

	; enable timer
	ldr r2, [r3, #EN0]
	ORR r2, r2, #0x80000
	str r2, [r3, #EN0]

	; base address of timer
	mov r5, #0x0000
	movt r5, #0x4003

	; Enable Timer
	ldr r2, [r4, #GPTMCTL]
	ORR r2, r2, #0x1
	str r2, [r4, #GPTMCTL]

	LDMFD sp!, {r0-r12,lr}
	MOV pc, lr

gpio_init:
	STMFD SP!,{lr, r1-r11}

	; GPIO Base Address
	mov r3, #0xE000
    movt r3, #0x400F

    ; enable Port F
    ldr r4, [r3, #CLOCK]
    ORR r4, r4, #0x20
    strb r4, [r3, #CLOCK]

    ; Port F Address
    mov r1, #0x5000
    movt r1, #0x4002

    ; enable pin 4
    ldr r4, [r1, #DIGI]
    ORR r4, r4, #0x10
    strb r4, [r1, #DIGI]

    ; pull-up pin 4
    ldr r4, [r1, #PULL]
    ORR r4, r4, #0x10
    strb r4, [r1, #PULL]

    ; set pin 4 in as input
    ldrb r4, [r1, #DIR]
    AND r4, r4, #0xEF
    strb r4, [r1, #DIR]

    LDMFD sp!, {lr, r1-r11}
	MOV pc, lr


clear_board:
	STMFD SP!,{r5-r12,lr}

	MOV r5, #14
	MUL r5, r5, r1
	ADD r5, r5, r0
	strb r3, [r2, r5]

	LDMFD sp!, {r5-r12,lr}
	MOV pc, lr


update_x_y:  ; updates X and Y values
	STMFD SP!,{r6-r12,lr}

	CMP r5, #1 ;up
	IT EQ
	SUBEQ r1, r1,#1
	CMP r5, #2 ; left
	IT EQ
	SUBEQ r0, r0,#1
	CMP r5, #3 ;down
	IT EQ
	ADDEQ r1, r1,#1
	CMP r5, #2 ;right
	IT EQ
	ADDEQ r0, r0,#1
	LDMFD sp!, {r6-r12,lr}
	MOV pc, lr

ded_check:
	STMFD SP!,{r3-r12,lr}
	MOV r3, #10
	CMP r3, r0 ;if y or x are over 10, we hit the wall
	BGT ded
	CMP r3,r1
	BGT ded
	MOV r3,#0
	CMP r3,r0 ;if y or x are 0, we hit the wall
	BGT ded
	CMP r3,r1
	BGT ded
	LDMFD sp!, {r0-r12,lr}
	MOV pc, lr

update_board:
	STMFD SP!,{r5-r12,lr}

	MOV r5, #14
	MUL r5, r5, r1
	ADD r5, r5, r0
	strb r4, [r2, r5]

	LDMFD sp!, {r5-r12,lr}
	MOV pc, lr












	.end
