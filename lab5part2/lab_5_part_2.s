	.data
	 .global UART0_Handler
 	.global Switch_Handler
 	.global interrupt_init
check: .string " ",0
.text
 	.global lab5
UARTICR: .equ 0x044
UARTIM: .equ 0x038
EN0: .equ 0x100
U0FR: .equ 0x18
CLOCK: .equ 0x608
DIR: .equ 0x400
DATA: .equ 0x3FC
DIGI: .equ 0x51C
PULL: .equ 0x510
GPIOIS: .equ 0x404
GPIOIBE: .equ 0x408
GPIOIV: .equ 0x40C
GPIOIM: .equ 0x410
ptr_to_check:	.word check

lab5:
 	STMFD SP!,{r0-r12,lr} ; Store register lr on stack

 	; Your code is placed here

	bl gpio_init

 	bl interrupt_init

loop:
	ldr r1, ptr_to_check
	ldrb r0, [r1]
	CMP r0, #0x71
	BNE loop

 	LDMFD sp!, {r0-r12,lr}
 	MOV pc, lr

interrupt_init:
 	STMFD SP!,{r0-r12,lr} ; Store register lr on stack

 	; Your code is placed here
 	; address of UART
 	mov r1, #0xC000
	movt r1, #0x4000
	; addrees of EN0
	mov r3, #0xE000
	movt r3, #0xE000

	mov r2, #0x10
	strb r2, [r1, #UARTIM]
	mov r2, #0x0020
	movt r2, #0x4000
	str r2, [r3, #EN0]

	mov r4, #0x5000
	movt r4, #0x4002

	mov r5, #0x10
	strb r5, [r4, #GPIOIS]
	strb r5, [r4, #GPIOIBE]
	strb r5, [r4, #GPIOIV]
	strb r5, [r4, #GPIOIM]

	mov r0, #0

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

gpio_init:
	STMFD SP!,{lr, r1-r11}

	mov r3, #0xE000
    movt r3, #0x400F
    mov r4, #0x20
    strb r4, [r3, #CLOCK]
    ; enable pin 4
	; set these pin as input
	mov r1, #0x5000
    movt r1, #0x4002
    mov r4, #0x10
    strb r4, [r1, #DIGI]	; enable pin 4
    strb r4, [r1, #PULL]	; pull-up
    mov r4, #0x00
    strb r4, [r1, #DIR]		; set it as input

    LDMFD sp!, {lr, r1-r11}
	MOV pc, lr

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

	.end
