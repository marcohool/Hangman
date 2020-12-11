correctGuess:
    push {r0-r3, lr}

    mov r4, #1 @ correct guesses = true
    ldr r1, =correctLetters
    strb r0, [r1, r3]

    ldr r0, =correctLetters
    mov r2, #1 @ boolean win
checkWin:
    ldrb r1, [r0], #1
    cmp r1, #0
    beq endCheckWin
    cmp r1, #95
    moveq r2, #0
    beq endCheckWin
    b checkWin
endCheckWin:
    cmp r2, #1
    beq win
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
    moveq r6, #0 @number of lives
    beq newGuess
    str r4, [r3], #1
    b forLength

newGuess:
    ldr r0, =correctLetters
    bl puts
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
    pop {r0-r3}
    b readInput

invalidInput:
    push {r0-r3}
    ldr r0, =invalidInputText
    bl printf

readInput:
    ldr r0, =inputFormat
    ldr r1, =letterRead
    bl scanf
    pop {r0-r3}

    ldr r0, =letterRead
    ldr r0, [r0]

    cmp r0, #97
    subgt r0, r0, #32
    cmp r0, #65
    blt invalidInput
    cmp r0, #90
    bgt invalidInput

    ldr r1, =buffer

    mov r3, #0
    mov r4, #0 @ 0 = no correct guesses, 1 = correct guesses
checkMatches:
    ldrb r2, [r1], #1
    cmp r2, r0
    bleq correctGuess
    cmp r2, #10
    addne r3, r3, #1
    bne checkMatches
    cmp r4, #0
    addeq r6, r6, #1
    b newGuess

loose:
    ldr r0, =looseTextMessage
    bl printf
    b end

win:
    ldr r0, =winTextMessage
    bl printf
    b end

end:

    # close file

	mov r7, #1
	svc #0

.data
filename: .asciz "words.txt"
filemode: .asciz "r"
enterTextMessage: .asciz "Please enter your next character (A-Z), or 0 to exit:\n"
looseTextMessage: .asciz "You have LOST !\n"
invalidInputText: .asciz "Please enter a valid character (A-Z):\n"
winTextMessage: .asciz "You have WON !\n"
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

