	.data
	.global UART0_Handler
	.global Switch_Handler
	.global Timer_Handler
	.global timer_init
	.global interrupt_init
check: .string " ",0
.text
 	.global lab5
;UART0
UARTICR: .equ 0x044
UARTIM: .equ 0x038
EN0: .equ 0x100
U0FR: .equ 0x18
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

ptr_to_check:	.word check

lab5:
 	STMFD SP!,{r0-r12,lr} ; Store register lr on stack

 	; Your code is placed here

	bl gpio_init

	bl timer_init

 	bl interrupt_init

loop:
	ldr r1, ptr_to_check
	ldrb r0, [r1]
	CMP r0, #0x71
	BNE loop

 	LDMFD sp!, {r0-r12,lr}
 	MOV pc, lr

gpio_init:
	STMFD SP!,{lr, r1-r11}

	; GPIO Base Address
	mov r3, #0xE000
    movt r3, #0x400F

    ; enable Port F
    ldr r4, [r3, #CLOCK]
    ORR r4, r4, #0xFFFFFFFF
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
	ldr r2, [r4, #GPIOIS]
	ORR r2, r5, #0x10
	str r2, [r4, #GPIOIS]

	; Allow GPIO interrupt event
	ldr r2, [r4, #GPIOIBE]
	ORR r2, r5, #0x10
	str r2, [r4, #GPIOIBE]

	; set to high trigger
	ldr r2, [r4, #GPIOIV]
	ORR r2, r5, #0x10
	str r2, [r4, #GPIOIV]

	; allow interrupt to be triggered
	ldr r2, [r4, #GPIOIM]
	ORR r2, r5, #0x10
	str r2, [r4, #GPIOIM]

	;; Timer
	; enable timer
	ldr r2, [r3, #EN0]
	ORR r2, r2, #0x80000
	str r2, [r3, #EN0]

	; base address of timer
	mov r5, #0x0000
	movt r5, #0x4003

	; Configure Interval
	ldr r2, [r5, #GPTMTAILR]
	ORR r2, r2, #0xFFFFFFFF
	str r2, [r5, #GPTMTAILR]


	; set timer interrupt
	ldr r2, [r5, #GPTMIMR]
	ORR r2, r2, #0x1
	str r2, [r5, #GPTMIMR]

	; Disable timer
	ldr r2, [r5, #GPTMCTL]
	AND r2, r2, #0x0
	str r2, [r5, #GPTMCTL]


 	LDMFD sp!, {r0-r12,lr}
	MOV pc, lr

timer_init:
 STMFD SP!,{r0-r12,lr} ; Preserve registers on the stack

	; Your code is placed here

	; Base address timer Clock
	mov r4, #0xE000
	movt r4, #0x400F

	; Enable Timer Clock
 	ldr r2, [r4, #RCGCTIMER]
	ORR r2, r2, #0x1
	str r2, [r4, #RCGCTIMER]

	; base address of timer
	mov r1, #0x0000
	movt r1, #0x4003

	; Enable Timer
	ldr r2, [r1, #GPTMCTL]
	ORR r2, r2, #0x1
	str r2, [r1, #GPTMCTL]

	; 32-bit
	ldr r2, [r1, #GPTMCFG]
	AND r2, r2, #0x0
	str r0, [r1, #GPTMCFG]

	; Set to Periodic Mode
	ldr r2, [r1, #GPTMTAMR]
	ORR r2, r2, #0x2
	str r2, [r1, #GPTMTAMR]

	LDMFD sp!, {r0-r12,lr}
	MOV pc, lr

UART0_Handler:
	STMFD SP!,{r0-r12,lr} ; Store register lr on stack

	; Your code is placed here
	; base address of UART
	mov r1, #0xC000
	movt r1, #0x4000

	bl read_character
	bl output_character

	ldr r3, ptr_to_check
	strb r0, [r3]

	mov r2, #0x10
	strb r2, [r1, #UARTICR]

	LDMFD sp!, {r0-r12,lr}
	BX lr

Switch_Handler:
	STMFD SP!,{r0-r12,lr} ; Store register lr on stack

 	; Your code is placed here
 	mov r1, #0xC000
	movt r1, #0x4000

	bl read_from_push_btn

	mov r2, #0x10
	strb r2, [r1, #UARTICR]

 	LDMFD sp!, {r0-r12,lr}
	MOV pc, lr

read_character:  			;Stores Character From PuTTy into r0 (Changes r0)
	STMFD SP!,{lr}			; Store registers on stack
	mov r1, #0xC000
	movt r1, #0x4000
	ldrb r0, [r1]			;store PuTTy into r0
	LDMFD sp!, {lr}
    mov pc, lr

output_character: 			;Outputs Character From r0 into PuTTy (Changes r1,r2)
    STMFD SP!,{lr}
    mov r1, #0xC000
	movt r1, #0x4000
    strb r0, [r1]		 	;print string
    LDMFD sp!, {lr}
    mov pc, lr

read_from_push_btn:
	STMFD SP!,{lr, r1-r11}	; Store register lr on stack

          ; Your code is placed here
    ldrb r2, [r1, #DATA]
    AND r2, #0x10
    CMP r2, #0
    BEQ pushed

	LDMFD sp!, {lr, r1-r11}
	MOV pc, lr

pushed:
	CMP r0, #0	; Light blue
    BEQ blue
    CMP r0, #1	; Light green
    BEQ green
    CMP r0, #2	; Light red
    BEQ red

	LDMFD sp!, {lr, r1-r11}
	MOV pc, lr

blue:
	mov r2, #0x04
    strb r2, [r1, #DATA]
    mov r0, #1
    LDMFD sp!, {lr, r1-r11}
	MOV pc, lr
green:
	mov r2, #0x08
    strb r2, [r1, #DATA]
    mov r0, #2
    LDMFD sp!, {lr, r1-r11}
	MOV pc, lr
red:
	mov r2, #0x02
    strb r2, [r1, #DATA]
    mov r0, #0
    LDMFD sp!, {lr, r1-r11}
	MOV pc, lr

Timer_Handler:
	STMFD SP!,{r0-r12,lr} ; Preserve registers on the stack

	; Your code is placed here
	mov r1, #0x0000
	movt r1, #0x4003

	mov r0, #1
	strb r0, [r1, #GPTMICR]

	LDMFD sp!, {r0-r12,lr}
	BX lr


	.end
