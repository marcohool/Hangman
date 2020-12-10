correctGuess:
	push {r0-r3, lr}

	ldr r0, =correct
	bl printf

	pop {r0-r3, lr}
	bx lr

.global main
main:
	/* display welcome message */
	push {r0-r3, lr}
	ldr r0, =welcomeMessage
	bl printf
	pop {r0-r3, lr}

	/* open file */
	ldr r0, =filename     
	mov r1, #0x42
	mov r2, #384           
	mov r7, #5
	svc 0

	/* read file */
	ldr r1, =buffer	
	mov r2, #106
	mov r7, #3
	svc 0
	mov r3, r1

	/* generate rand numb */
	push {r0-r3}
	mov r0, #0
	bl time
	bl srand
	bl rand
	and r0, r0, #9
	mov r5, r0	@ random number
	pop {r0-r3}

	mov r4, #0	@ word counter
	ldr r6, =array @ array to hold chars of word
	mov r5, #0 @ delete
newLine:
	cmp r4, r5
	bgt newGuess 
	add r4, r4, #1
newChar:
	ldrb r1, [r3], #1
	cmp r1, #10 
	beq newLine 
	cmp r1, #0 
	beq newGuess 

	cmp r4, r5 
	ble newChar 
	
	str r1, [r6], #1
	b newChar

	mov r8, #0 @ number of guesses
newGuess:
	push {r0-r3, lr}
	/* enter text prompt */
	ldr r0, =enterCharText
	bl printf

	/* read input from keyboard */
	ldr r0, =format
	ldr r1, =letterRead
	bl scanf
	pop {r0-r3, lr}

	ldr r5, =array
	ldr r1, =letterRead
	ldr r1, [r1]
loopWord:
	ldrb r2, [r5], #1
	/* TEMPORARY PRINT START */
	@ push {r0-r3, lr}
	@ ldr r0, =printformat
	@ mov r1, r2
	@ bl printf
	@ pop {r0-r3, lr}
	/* TEMPORARY PRINT END */
	cmp r1, r2 @ if input letter is in texts
	bleq correctGuess
	cmp r2, #0
	bne loopWord
	add r8, r8, #1
	cmp r8, #6 @ max number of guesses
	bne newGuess

loose:
	ldr r0, =looseMessage
	bl printf

end:
	mov r7, #1
	svc #0

.data
welcomeMessage: .asciz "Welcome to Hangman!\n"
enterCharText: .asciz "Enter Letter:\n"
looseMessage: .asciz "You are out of guesses!\n"
correct: .asciz "Correct!\n"
format: .asciz "\n%c"
@printformat: .asciz "%d"
letterRead: .word 0
filename: .asciz "words.s"
buffer: .space 110
array: .byte 16
