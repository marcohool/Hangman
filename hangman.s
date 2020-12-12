correctGuess:
    push {r0-r3, lr}

    mov r4, #1 @ returns correct guesses = true
    ldr r1, =correctLetters
    strb r0, [r1, r3]

    /* checks correctly entered words to see if all have been guessed */
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

    /* clear misses asciz in preparation for a new game */
newGame:
    ldr r0, =misses
    mov r2, #0
clearMisses:
    ldrb r1, [r0], #1
    cmp r1, #0
    strne r2, [r1], #1
    bne clearMisses

.global main
main:
    /* open file */
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

    /* display welcome message */
    ldr r0, =welcomeTextMessage
    bl puts
	pop {r0-r3}
    mov r8, r2 @ move file descriptor to r8 to be used to close the file at the end

    /* scan each line and store the line that has the same line number as the rand numb */
    mov r5, #0 
    ldr r0, =buffer
    mov r1, #100
forLine:    
    cmp r5, r4
    bgt endfor
    push {r0-r3}
    bl fgets
    pop {r0-r3}
    add r5, r5, #1
    b forLine

    /* Initiate varaible to hold correctly guessed letters */
endfor:   
    ldr r0, =buffer
    mov r1, #0
    ldr r3, =correctLetters
    mov r4, #95
forLength:
    ldrb r8, [r0], #1
    cmp r8, #10
    moveq r6, #0 @number of lives
    beq newGuess
    str r4, [r3], #1
    b forLength

    /* called when new guess is permitted */
newGuess:
    ldr r0, =wordMessage
    bl printf
    ldr r0, =correctLetters
    bl puts
    ldr r0, =missesMessage
    bl printf
    ldr r0, =misses
    bl puts

    /* display hangman figure depending on amount of lives user has */
    push {r0-r3}
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
    
    bl puts

    /* if user is out of lives branch */
    cmp r6, #6
    beq loose

    /* prompt user to enter input */
    ldr r0, =enterTextMessage
    bl printf
    pop {r0-r3}
    b readInput

    /* notifies user when they enter an invalid character */
invalidInput:
    push {r0-r3}
    ldr r0, =invalidInputText
    bl printf

    /* gets guess from user */
readInput:
    ldr r0, =inputFormat
    ldr r1, =letterRead
    bl scanf
    pop {r0-r3}

    ldr r0, =letterRead
    ldr r0, [r0]

    /* checks if user has inputted 0 (quit) or an invalid character */
    cmp r0, #48
    beq quit
    cmp r0, #96
    subgt r0, r0, #32
    cmp r0, #65
    blt invalidInput
    cmp r0, #90
    bgt invalidInput

    /* checks strings containing correct guesses and misses to see if they have already guesses that character */
    ldr r2, =misses
    mov r7, #0 @ number of strings checked (if it is 2 both have been checked)
checkAlreadyGuessed:
    ldrb r5, [r2], #1
    cmp r5, #0
    addeq r7, r7, #1
    ldreq r2, =correctLetters
    cmp r7, #2
    beq notAlreadyGuessed
    cmp r5, r0 
    push {r0-r3}
    ldreq r0, =alreadyGuessedText
    bleq puts 
    pop {r0-r3} 
    beq newGuess
    b checkAlreadyGuessed

    /* continutes if they guess has not already been entered */
notAlreadyGuessed:
    ldr r1, =buffer 
    mov r3, #0
    mov r4, #0 @ 0 = no correct guesses, 1 = correct guesses
    /* checks entered guess with characters from randomly generated word to see if there is a match */
checkMatches:
    ldrb r2, [r1], #1
    cmp r2, r0
    bleq correctGuess
    cmp r2, #10
    addne r3, r3, #1
    bne checkMatches
    cmp r4, #0
    push {r0-r3}
    ldreq r1, =misses
    streq r0, [r1, r6] 
    pop {r0-r3}
    addeq r6, r6, #1 @ adds life lost
    b newGuess

loose:
    /* if user has lost, lost message is displayed and word is revealed */
    ldr r0, =looseTextMessage
    bl puts
    ldr r0, =displayWordMessage
    bl puts
    ldr r0, =buffer
    bl puts
    b end

win:
    /* if user has won, displays win message */
    ldr r0, =winTextMessage
    bl puts
    b end

end:
    /* asks user if they would like to play again */
    ldr r0, =playAgainText
    bl puts

    ldr r0, =inputFormat
    ldr r1, =letterRead
    bl scanf

    ldr r0, =letterRead
    ldr r0, [r0]
    /* if user choses yes (1), game restarts */
    cmp r0, #49
    beq newGame

quit:
    /* close file */
    mov r0, r8
    bl fclose

    /* ends program */
	mov r7, #1
	svc #0

.data
filename: .asciz "words.txt"
filemode: .asciz "r"
welcomeTextMessage: .asciz "\nWelcome to Hangman!\n"
enterTextMessage: .asciz "Please enter your next character (A-Z), or 0 to exit:\n"
looseTextMessage: .asciz "You have LOST !\n"
invalidInputText: .asciz "Please enter a valid character (A-Z):\n"
alreadyGuessedText: .asciz "You have already guessed that character!\n"
winTextMessage: .asciz "You have WON !\n"
displayWordMessage: .asciz "The correct word was:"
playAgainText: .asciz "Would you like to play again? (1 = yes, 0 = no)\n"
wordMessage: .asciz "Word: "
missesMessage: .asciz "Misses: "
inputFormat: .asciz "\n%c"
letterRead: .word 0
buffer: .space 20
correctLetters: .space 20
misses: .space 20
lostlives0: .asciz "_________\n|    |\n|\n|\n|\n|\n|\n|________\n"
lostlives1: .asciz "_________\n|    |\n|    O\n|\n|\n|\n|________\n"
lostlives2: .asciz "_________\n|    |\n|    O\n|    |\n|    |\n|\n|________\n"
lostlives3: .asciz "_________\n|    |\n|    O\n|   \\|\n|    |\n|\n|________\n"
lostlives4: .asciz "_________\n|    |\n|    O\n|   \\|/\n|    |\n|\n|________\n"
lostlives5: .asciz "_________\n|    |\n|    O\n|   \\|/\n|    |\n|   / \n|________"
lostlives6: .asciz "_________\n|    |\n|    O\n|   \\|/\n|    |\n|   / \\ \n|________"

