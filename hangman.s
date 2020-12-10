correctGuess:
    push {r0-r3, lr}

    ldr r1, =correctLetters
    strb r0, [r1, r3]

    pop {r0-r3, lr}
    bx lr

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

    mov r4, #0 @temporary
    mov r5, #0 
    ldr r0, =buffer
    mov r1, #100
forLine:
    cmp r5, r4
    bgt endfor
    push {r0-r3}
    bl fgets
    @bl printf
    pop {r0-r3}
    add r5, r5, #1
    b forLine

endfor:    /* Initiate varaible to hold correctly guessed letters */
    ldr r0, =buffer
    mov r1, #0
    ldr r3, =correctLetters
    mov r4, #95
forLength:
    ldrb r2, [r0], #1
    cmp r2, #10
    moveq r6, #0 @number of guesses
    beq newGuess
    str r4, [r3], #1
    b forLength

newGuess:
    cmp r6, #0
    ldreq r0, =lostlives0
    cmp r6, #1
    ldreq r0, =lostlives1
    cmp r6, #2
    ldreq r0, =lostlives2
    cmp r6, #3
    ldreq r0, =lostlives3
    cmp r6, #4
    ldreq r0, =lostlives4
    cmp r6, #5
    ldreq r0, =lostlives5
    cmp r6, #6
    ldreq r0, =lostlives6

    push {r0-r3}
    bl puts

    cmp r6, #6
    beq loose

    ldr r0, =enterTextMessage
    bl printf

    ldr r0, =inputFormat
    ldr r1, =letterRead
    bl scanf
    pop {r0-r3}

    ldr r0, =letterRead
    ldr r0, [r0]
    ldr r1, =buffer

    mov r3, #0
checkMatches:
    ldrb r2, [r1], #1
    cmp r2, r0
    bleq correctGuess
    cmp r2, #10
    addne r3, r3, #1
    bne checkMatches
    add r6, r6, #1
    b newGuess

loose:
    ldr r0, =looseTextMessage
    bl printf

end:
	mov r7, #1
	svc #0

.data
filename: .asciz "words.txt"
filemode: .asciz "r"
enterTextMessage: .asciz "Please enter your next character (A-Z), or 0 to exit:\n"
looseTextMessage: .asciz "You have lost\n"
inputFormat: .asciz "\n%c"
letterRead: .word 0
buffer: .space 20
correctLetters: .space 20
lostlives0: .asciz "_________\n|    |\n|\n|\n|\n|\n|\n|________\n"
lostlives1: .asciz "_________\n|    |\n|    O\n|\n|\n|\n|________\n"
lostlives2: .asciz "_________\n|    |\n|    O\n|    |\n|    |\n|\n|________\n"
lostlives3: .asciz "_________\n|    |\n|    O\n|   \\|\n|    |\n|\n|________\n"
lostlives4: .asciz "_________\n|    |\n|    O\n|   \\|/\n|    |\n|\n|________\n"
lostlives5: .asciz "_________\n|    |\n|    O\n|   \\|/\n|    |\n|   / \n|________"
lostlives6: .asciz "_________\n|    |\n|    O\n|   \\|/\n|    |\n|   / \\ \n|________"

