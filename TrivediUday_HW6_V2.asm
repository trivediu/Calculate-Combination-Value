;TITLE Program TrivediUday_HW5_V8 (.asm)     

; Author: Uday Trivedi
; Email : trivediu@oregonstate.edu
; Class Number / Section: CS 271-400
; Assignment Number: 6B
; Assignment Due Date: 12/3/2017
; Program Description:  Homework five that will generate an array of random
; numbers and then sort them while also displaying the median and implementing
; susbequent extra credit options


INCLUDE Irvine32.inc

; (insert constant and macro definitions here)

mWriteStr		MACRO	buffer							;macro to write a string
	push edx											;save the edx register
	mov edx, OFFSET buffer
	call WriteString
	call Crlf
	pop edx												;restore the edx register
ENDM

mWriteStrLine	MACRO	buffer							;same as above macro, but does not have a line break
	push edx											;save the edx register
	mov edx, OFFSET buffer
	call WriteString
	pop edx												;restore the edx register
ENDM


.data
; (insert variable definitions here)

	;String Variable Definitions
	introPlaceholder	BYTE	"Some intro stuff goes here. Enter a number: ",0
	problemTitle		BYTE	"Problem #: ",0
	problemLine1		BYTE	"NUmber of elements in the set: ",0
	problemLine2		BYTE	"Number of elements to choose from the set: ",0
	problemLine3		BYTE	"How many ways can you choose? ",0
	tInput				BYTE	21 DUP (0)		;temporary value to hold user input 
	error				BYTE	"ERROR!",0

	;Numerical (integer and/or float) variable definitions
	n			real4	0.			;the value of n 
	n2			real4	1.
	r			real4	0.			;the value of r
	answer		DWORD	?			;the user's answer
	int1		DWORD	?			;temporary int for now
	realv1		real4	1.0			;
	dwordebx	DWORD	?			;
	dwordeax	DWORD	?			;
	answerSize	DWORD	?			;


;***START PROGRAM HERE***
.code
;**************************************************************************************
;MAIN PROCEDURE
;main Procedure that will call all sub procedures.  it will also print out a simple
;goodbye message at the end.
;**************************************************************************************
main PROC
; (insert executable instructions here)
	
		call Randomize						;seed random number generator
		finit							;initialize the FPU, though not used some commented out

		call intro

		push OFFSET n				;push the reference address of n onto stack
		push OFFSET r				;push the reference address of r onto the stack
		call showProblem

		push OFFSET tInput
		push OFFSET answer
		push OFFSET answerSize
		call getData

		push n2
		call factorial
		mov dwordeax,eax
		fild dwordeax
		call WriteFloat

		
	
	call Crlf
	exit	; exit to operating system
main ENDP





;**************************************************************************************
;INTRODUCTION PROCEDURE
; Procedure to print out instructions to the user
; receives: none.
; returns: instructions shifted over into EDX registers.
; preconditions: none
; registers changed: none (because edx is pushed and popped in macro)
;**************************************************************************************
intro PROC
	
	mWriteStr introPlaceHolder			;print a temp intro output for now
	
	
	ret

intro ENDP
;//**************************************************************************************




;**************************************************************************************
;FACTORIAL PROCEDURE
; Procedure to calculate the factorial of a number n
; receives: accepts n and r by value and result by reference address
; returns: factorial value stored in eax
; preconditions: none
; registers changed: eax, ebx
;**************************************************************************************
factorial PROC
	
		push ebp
		mov ebp,esp
		mov eax,[ebp+8]
		cmp eax,0
		ja L1

		mov eax,1
		jmp L2

	L1: dec eax
		push eax
		call factorial


	ReturnFact:
		
		mov ebx, [ebp+8]
		mov dwordebx,ebx
		mov dwordeax,eax

		fild dwordebx
		fild dwordeax
		fmul
		fistp dwordeax
		mov eax,dwordeax

		;mul ebx		


	L2: pop ebp
		ret 4

factorial ENDP




;**************************************************************************************
;FACTORIAL PROCEDURE
; Procedure to show the problem to the user and generate a random number n between
;[3..12] and random number r from the range of [1...n]
; receives: accepts n and r by value and result by reference address
; returns: updated values of n and r by reference
; preconditions: none
; registers changed: eax, esi
;**************************************************************************************
showProblem PROC
	
		push ebp						
		
		mov ebp,esp
		
		mov esi,[ebp+12]					;move n to esi

		add esi,4							;now move to the next 4-byte segment of esi

		mov esi,[ebp+8]						;move r to esi+4

		sub esi,4							;now return esi back to it's original mem value

		;now we generate a random number between 3 to 12 for the value of n

		mov eax,12							;move the upper bound to the eax register
		
		sub eax,3							;subtract the lower bound from the eax register

		inc eax								;now increment eax by one

		call RandomRange					;eax will be in the range of [0..9]

		add eax,3							;eax will be in the range of [3..12]

		;now move the randomly generated value for n, into the memory address referenced by it
		mov [esi], eax						;move the value of n into esi

		;now generate a random value for r in the range of [1..n]

		;mov eax, eax						;this line commented out, basically we have max already in eax

		sub eax,1							;subtract 1 from eax

		inc eax								;add one to eax

		call RandomRange					;generate a value for r in the range of [0...n-1]

		add eax,1							;generate a value for r in the range of [1...n]

		;now move randomly generate value of r, into mem address esi+4 
		add esi,4							;increment esi by 4 bytes

		mov [esi],eax						;move the value of r into esi+4

		sub esi,4							;restore esi to it's original mem position

		;Now print the problem and accompanying details
		call Crlf
		mWriteStr ProblemTitle				;print the title of the problem

		mWriteStrLine ProblemLine1			;print the first line of the problem

		mov eax,[esi]						;move the value of n into eax

		call WriteDec						;write the value of n

		call Crlf							;line break

		mWriteStrLine ProblemLine2			;print the second line of the problem

		mov eax,[esi+4]						;move the value of r into eax

		call WriteDec						;write the value of r

		call Crlf							;line break


	pop ebp
	ret 8

showProblem ENDP




;************************************************************************************************************
; prompts / gets the user’s answer.
; receives: the OFFSET of answer and temp and value of answerSize
; returns: none
; preconditions: none
; registers changed:  eax, ebx, ecx, edx, ebp, esi, esp
; resources used: stackoverflow.com/questions/13664778/converting-string-to-integer-in-masm-esi-difficulty
;************************************************************************************************************
getData PROC
	push ebp						;push ebp onto stack
		
	mov ebp,esp						;move esp into ebp

LoopA:
	mWriteStrLine   problemLine3	;print the part that prompts the user to input their answer
	
	;call Crlf						;insert line break over here

	mov	edx, [ebp+16]			    ;move offset of the tInput for the string of ints to be read into

	mov ecx, 12						;move the value of 12 into ecx register					

	call ReadString					;call the irvine proc to read the string

	cmp eax, 10						;make sure string size does not exceed 10

	jg invalidInput					;if string size is greater than 10 jump to invalidInput

	mov ecx, eax			        ;loop for each char in string - basically set loop equal to string length
	
	mov esi,[ebp+16]				;point at char in string

pushad
loopString:							;loop looks at each char in string
    
	mov		ebx,[ebp+12]			;move answer into ebx
   
	mov     eax,[ebx]				;move address of answer into eax
    
	mov     ebx,10d					;move 10 into ebx 
    
	mul     ebx					    ;multiply answer by 10
    
	mov     ebx,[ebp+12]			;move address of answer into ebx
    
	mov     [ebx],eax				;add product to answer
    
	mov     al,[esi]		        ;move value of char into al register
    
	inc     esi				        ;point to next char
    
	sub     al,48d			        ;subtract 48 from ASCII value of char to get integer  

    cmp     al,0		            ;error checking to ensure values are digits 0-9
    
	jl      invalidInput			;if it is just less than 0 then jump to invalid input
    
	cmp     al,9					;cmp the value in al to 9
    
	jg      invalidInput			;if it is just greater than 9 then jump to invalid input

    mov     ebx,[ebp+12]		    ;move address of answer into ebx
   
	add     [ebx],al				;add int to value in answer

    loop        loopString  
	
	popad
	
	jmp     moveOn

invalidInput:						;set reg and variabls values to zero
    mov     al,0
    
	mov     eax,0					;mov 0 to the eax register
    
	mov     ebx,[ebp+12]			;mov the ans value into ebx

    mov     [ebx],eax				;mov the value of ebx into ebx dereferenced
    
	mov     ebx,[ebp+16]			;move the temp value back to ebx

    mov     [ebx],eax				;mov the eax value into [ebx]
    
	mWriteStr   error				;output an error message

    jmp     LoopA					;jump back to the beginning of loopA
moveOn:
    pop     ebp
    ret     12
getData ENDP
;//**************************************************************************************
;// (insert additional procedures here)


END main











;Jay Swaminarayan