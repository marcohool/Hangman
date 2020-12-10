
.global main
main:
    ldr r0, =filename
    ldr r1, =filemode
	bl fopen
    mov r2, r0

    /* generate rand numb */
	push {r0-r3}
	mov r0, #0
	bl time
	bl srand
	bl rand
	and r0, r0, #10
	mov r4, r0	@ random number
	pop {r0-r3}

    mov r5, #0 
    ldr r0, =buffer
    mov r1, #100
forLoop:
    cmp r5, r4
    bgt newGuess
    push {r0-r3}
    bl fgets
    @bl printf
    pop {r0-r3}
    add r5, r5, #1
    b forLoop

newGuess:
    push {r0-r3}
    ldr r0, =enterTextMessage
    bl printf

    ldr r0, =inputFormat
    ldr r1, =letterRead
    bl scanf
    pop {r0-r3}



end:
	mov r7, #1
	svc #0

.data
filename: .asciz "words.txt"
filemode: .asciz "r"
enterTextMessage: .asciz "Please enter your next character (A-Z), or 0 to exit\n"
inputFormat: .asciz "\n%c"
letterRead: .word 0
buffer: .space 100



