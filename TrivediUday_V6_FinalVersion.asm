; Author: Uday Trivedi
; Program Description:  This program will prompt the user to enter the correct
; value of combination numbers.  The values of n and r will be randomly generated.
; you can enter your answer and the system will inform you whether or not your answer
; is correct.  If not correct, it will display the right answer with several additional
; options implemented.


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
	problemTitle		BYTE	" ",0
	problemLine1		BYTE	"NUmber of elements in the set (n): ",0
	problemLine2		BYTE	"Number of elements to choose from the set (r): ",0
	problemLine3		BYTE	"How many ways can you choose? ",0
	tInput				BYTE	21 DUP (0)		;temporary value to hold user input 
	error				BYTE	"ERROR! Please try again",0
	userChoice			BYTE	5 DUP (?)			;create a placeholder for y/n

	showResult1			BYTE	"There are ",0
	showResult2			BYTE	" combinations of ",0
	showResult3			BYTE	" items from a set of ",0
	showResultBad		BYTE	"You need more practice.",0
	showResultGood		BYTE	"You are correct!",0
	showResultDot		BYTE	".",0
	showResultEC1a		BYTE	"EXTRA CREDIT AMAZING 1: The sum calculated recursively starting from 'r' to 'n' is: ",0
	showResultEC2		BYTE	"EXTRA CREDIT AMAZING 2: The FPU-Calculated mean of your answer and the actual answer is: ",0
	askContinue			BYTE	"Another problem? (y/n): ",0
	tempEnd				BYTE	"Ok....goodBye",0
	tempStart			BYTE	"start",0
	dispProbNum			BYTE	"Problem #: ",0
	dispRight			BYTE	"Number of Questions Right: ",0
	dispWrong			BYTE	"Number of Questions Wrong: ",0

	;intro strings
	intro1				BYTE	"Welcome to the Combination Calculator",0
	intro2				BYTE	"         Implemented by Uday S. Trivedi",0
	intro3				BYTE	"I'll give you a combinations problem. You enter the answer," ,0
	intro4				BYTE	"and I'll let you know if you're right",0

	intro5				BYTE	"Extra Credit[#1a]: Each Problem will be numbered",0
	intro6				BYTE	"Extra Credit[#1b]: Score will be shown when user chooses to quit",0
	intro7				BYTE	"Extra Credit[#2]: Factorials will be calculated/displayed in floating point",0
	intro8				BYTE	"Do Something Amazing [3A]: Color Coding of Program for ease of viewing.  Wrong answers shown in red.",0
	intro9				BYTE	"Do Something Amazing [3B]: The total sum from r to n will be calculated recursively",0
	intro10				BYTE	"Do Something Amazing [3C]: The mean of your answer and the actual answer will be computed",0


	;Numerical (integer and/or float) variable definitions
	n			real4	0.			;the value of n 
	r			real4	0.			;the value of r
	answer		DWORD	?			;the user's answer
	int1		DWORD	?			;temporary int for now
	dwordebx	DWORD	?			;just a temp dword variable to hold the value in ebx
	dwordeax	DWORD	?			;just a temp dword variable to hold the value in eax
	answerSize	DWORD	?			;originally was going to be used, but now just a placeholder 
	result		real4	?			;the correct value of the calculation
	sum			real4	?			;extra credit, the sum from r to n calculated recursively
	realTwo		real4	2.			;value of 2

	problemNum	dword	0			;the problem number
	right		dword	0			;the number of questions right
	wrong		dword	0			;the number of questions wrong

	orangeTextOnBlack = white + (lightblue)
	whiteTextOnRed = white + (Red *16)
	whiteTextOnGreen = white + (Green)
	DefaultColor = lightgreen ;+ (Black) 
	whiteTextOnBlack = white + (Black * 17)
	lightColor = lightGray + (Black*16)


;***START PROGRAM HERE***
.code
;**************************************************************************************
;MAIN PROCEDURE
;main Procedure that will call all sub procedures.  it will also print out a simple
;goodbye message at the end.
;**************************************************************************************
main PROC
; (insert executable instructions here)
	
		call Randomize				;seed random number generator
		;finit						;initialize the FPU, though not used some commented out

		;INTRO PROCEDURE
		call intro					;call the intro procedure

	_start:							;this label is used to loop if the user chooses to play again
		finit
		mov answer,0				;initialize answer
		mov sum,0					;initialize sum
		
		;SHOW PROBLEM PROCEDURE
		call Crlf
		;inc problemNum				;increment the extra credit problem number by one
		;mWriteStr dispProbNum		;display the current problem number
		push OFFSET problemNum
		push OFFSET n				;push the reference address of n onto stack
		push OFFSET r				;push the reference address of r onto the stack
		call showProblem			


		;GETDATA PROCEDURE
		push OFFSET tInput			;[ebp+16]  push the string array by reference
		push OFFSET answer			;[ebp+12]  push the users answer by reference
		push OFFSET answerSize		;[ebp+8]   push the answersize (as of now used as placeholder)
		call getData				;call the getData procedure

		

		;call the COMBINATIONS procedure, which also calls the FACTORIAL procedure
		push n						;[ebp+16] push the value of n by value
		push r						;[ebp+12] push the value of r by value
		push OFFSET	result			;[ebp+8]  push the result variable by reference
		call combinations			;call the combinations procedure


		;showResults procedure
		push OFFSET right			;push the right number of questions by reference
		push OFFSET wrong			;push the wrong number of questions by reference
		push result					;push the value of result
		push answer					;push the value of the user's answer
		push n						;push the value of n
		push r						;push the value of r
		call showResults			;call the showResults procedure

		
		;EXTRA CREDIT AMAZING 1: Recursively calculate the sum from r to n
		push r						;push the value of r
		push n						;push the value of n
		push OFFSET sum				;push the offset address of sum
		call summation				;call the summation procedure
		call writefloat				;call writeFloat

		;EXTRA CREDIT AMAZING 2: Calculate the mean within the FPU of the user's answer and the actual answer
		push realTwo				;the divisor
		push answer					;the answer
		push result					;the result
		call average
		call Crlf

		;Ask the user whether to continue or not (this was not required to be a procedure)

		_YNLoop:	
			mov eax,LightColor
			call SetTextColor
			mWriteStrLine askContinue							;print the statement asking user to continue
			mov edx, OFFSET userChoice							;move offset of userchoice string to read into edx
			mov ecx, 5											;read up to 5 chars
			call ReadString										;call readstring procedure

			cmp eax,1											;if user string input is greater than 1, then error
			jg _err												;jump to error message
			mov esi, OFFSET userChoice							;move the string input offset to esi
			mov al,[esi]										;move value of userchoice to al

			cmp al,79h											;is al = y?
			je _start											;then go back to start of program
			cmp al, 59h											;is al = Y?
			je _start											;then go back to start of program

			cmp al, 6Eh											;is al = n?
			je _end												;then go to end label of the program
			cmp al, 4Eh											;is al = N?
			je _end												;then go to end label of the program

		_err:													;error label
		mWriteStr error											;output errror message											
		jmp _YNLoop												;jump back to prompt the user again y/n

		_end:													;end label
		mov eax,DefaultColor
		call SetTextColor
		
		mWriteStrLine dispRight									;output prompt of how many right
		mov eax,right											;move right value to eax
		call writeDec											;print out right value

		call Crlf												;line break
		mWriteStrLine dispWrong									;output prompt of how many wrong
		mov eax,wrong											;move wrong value to eax
		call writeDec											;print out wrong value
		call Crlf												;linebreak
		mWriteStr	tempEnd										;good bye statement
	
	
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
	
	;the following code will write the output lines of the introduction and extrac credit options
	mWriteStr intro1			
	mWriteStr intro2
	mWriteStr intro3
	mWriteStr intro4
	call Crlf
	mWriteStr intro5
	mWriteStr intro6
	mWriteStr intro7
	mWriteStr intro8
	mWriteStr intro9
	mWriteStr intro10
	
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
	
		push ebp							;push ebp on stack
		mov ebp,esp							;move the value of esp into ebp
		
		sub esp,8							;make space for two local variables

		mov eax,[ebp+8]						;access variable number 1 that was pushed and save into eax
		;mov eax,[ebp+20]


		cmp eax,0							;if eax is not zero then go to l1
		ja L1

		mov eax,1							;if eax is zero, then set it to one
		jmp L2								;then jump to l2

	L1: dec eax
		push eax							;push eax onto stack
		call factorial						;calll the factorial proc recursively


	ReturnFact:
		
		mov ebx, [ebp+8]					;mov first variable to ebx
		;mov ebx,[ebp+20]
		
		mov [ebp-4],ebx						;mov ebx to first local variable
		;mov [ebp-24], ebx					
		mov [ebp-8],eax						;mov eax to second local variable
		;mov [ebp-28], ebx


		fild dword ptr [ebp-4]				;integer load of first local variable
		;fild dword ptr [ebp-24]
		fild dword ptr [ebp-8]				;integer load of second local varibale
		;fild dword ptr [ebp-28]


		fmul								;calculate product in the FPU
		fistp dword ptr [ebp-8]				;pop stack into second local varible
		;fistp dword ptr [ebp-28]
		
		mov eax,[ebp-8]						;mov second local variable real4 number into eax
		;mov eax,[ebp-28]


	L2: mov esp,ebp
		pop ebp
		ret 4

factorial ENDP




;**************************************************************************************
; SWOWPROBLEM PROCEDURE
; Procedure to show the problem to the user and generate a random number n between
; [3..12] and random number r from the range of [1...n]
; receives: accepts n and r by value and result by reference address
; returns: updated values of n and r by reference
; preconditions: none
; registers changed: eax, esi
;**************************************************************************************
showProblem PROC
	
		push ebp						
		
		mov ebp,esp
		
		;set background
		mov eax, whiteTextOnBlack
		call SetTextColor


		mov esi,[ebp+16]					;move problem number to esi
		mov eax,[esi]						;move esi dereferenced value into eax
		inc eax								;increment eax by one (now we have incremented problem #)
		mov [esi],eax						;move updated value into dereferenced esi

		mWriteStrLine dispProbNum			;display prompt of extra credit problem number
		call writeDec						;output value from eax
		call Crlf							;line break

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
		;call Crlf
		;mWriteStr ProblemTitle				;print the title of the problem

		mWriteStrLine ProblemLine1			;print the first line of the problem

		mov eax,[esi]						;move the value of n into eax

		call WriteDec						;write the value of n

		call Crlf							;line break

		mWriteStrLine ProblemLine2			;print the second line of the problem

		mov eax,[esi+4]						;move the value of r into eax

		call WriteDec						;write the value of r

		call Crlf							;line break


	pop ebp
	ret 12

showProblem ENDP




;************************************************************************************************************
; GETDATA PROCEDURE
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
	
	mov eax,DefaultColor
	call SetTextColor
	
	;call Crlf						;insert line break over here

	mov	edx, [ebp+16]			    ;move offset of the tInput for the string of ints to be read into

	mov ecx, 12						;move the value of 12 into ecx register					

	call ReadString					;call the irvine proc to read the string

	cmp eax, 10						;make sure string size does not exceed 10

	jg invalidInput					;if string size is greater than 10 jump to invalidInput

	mov ecx, eax			        ;loop for each char in string - basically set loop equal to string length
	
	mov esi,[ebp+16]				;point at char in string

;pushad
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
	
	;popad
	
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




;************************************************************************************************************
; COMBINATIONS PROCEDURE
; calulates the correct value of combvinations by calling the recursive factoral function
; receives: the value of n,r, and offset of result
; returns: updated result via reference
; preconditions: none
; registers changed:  eax, ebx, esi
;************************************************************************************************************
combinations PROC
	;ebp+16 = n
	;ebp+12 = r
	;ebp+ 8 = result offset
		
		push ebp						;push ebp onto stack
	
		mov ebp,esp						;move esp into ebp
	
		sub esp,20						;make space for five local variables

	;[STEP 1] calculate n!
	
		push [ebp+16]					;push the value of n
	
		call factorial					;call the factorial recursive function
		mov [ebp-4], eax				;store the value of n! in ebp-4

	;[STEP 2] calculate r!
	
		push [ebp+12]					;push the value of r
	
		call factorial					;call the factorial recursive function
	
		mov [ebp-8],eax					;store the value of r! in ebp-8

	;[STEP 3] calculate the value of (n-r)!
	
		fild dword ptr [ebp+16]			;load n on to the fpu stack
	
		fild dword ptr [ebp+12]			;load r on to the fpu stack
	
		fsub							;calculate n-r and pop the result in st(0)
	
		fistp dword ptr [ebp-12]		;pop the difference in to ebp-12
	
		push [ebp-12]					;push the difference onto the stack
	
		call factorial
		mov [ebp-12], eax				;store the value of (n-r)! in ebp-12


	;[STEP 4 ] Calculate actual combination result
		;so far we have the following:
		;n! is stored in ebp-4
		;r! is stored in ebp-8
		;(n-r)! is stored in ebp-12

	;[STEP 4A] Calculate r!*(n-r)!  where * represents a multiplication procedure
		fild dword ptr [ebp-8]			;load the value of r! into the fpu
		fild dword ptr [ebp-12]			;load the value of (n-r)! into the fpu

		fmul st(0), st(1)				;multiply the two values the value is stored in st(0)
		


		fild dword ptr [ebp-4]			;load the value of n! - this will be the numerator 
										;now st(0) holds n! while st(1) holds the denominator r!(n-r)!

		fdiv st(0),st(1)				;divide numerator by the denominator and store result in st(0)
										;now the official result is stored in st(0)
		
		mov esi, [ebp+8]				;mov address of result into esi				
		fistp dword ptr [esi]			;mov st(0) into esi, which is offset address of result
										;the value of "result" is now updated


	mov esp,ebp							;restore value of ebp back to esp
    pop     ebp							;pop esp
    ret     12						
combinations ENDP




;************************************************************************************************************
; SHOWRESULTS PROCEDURE
; displays the correct results and gives an opinion about the user's answer
; receives: the value of result, answer, n, r
; returns: none
; preconditions: none
; registers changed:  eax, 
;************************************************************************************************************
showResults PROC
		;VARIABLES used
		;push OFFSET right [ebp+28]
		;push OFFSET wrong [ebp+24]
		;push result [ebp+20]
		;push answer [ebp+16]
		;push n		 [ebp+12]
		;push r		 [ebp+8]
		
		push ebp								;push ebp onto stack
		mov ebp,esp								;move esp into ebp
		sub esp,20								;make space for five local variables

		mov eax,defaultColor
		call SetTextColor



		call Crlf
		mWriteStrLine		showResult1			;"There are "
		fild dword ptr		[ebp+20]			;move result from real4 format into 
		call WriteFloat

		mWriteStrLine		showResult2			; " combinations of "
		fild dword ptr	    [ebp+8]				;move r from real4 format into fpu
		call WriteFloat

		mWriteStrLine		showResult3			; "from a set of "
		fild dword ptr		[ebp+12]			;move n from real4 format into fpu
		call WriteFloat

		mWriteStr			showResultDot		;"."

		mov eax,[ebp+16]						;move the answer into eax
		mov ebx,[ebp+20]						;move the official result into ebx

		cmp eax,ebx
		je _Success

		_Fail:
			mov eax,whiteTextOnRed
			call SetTextColor

			mWriteStr showResultBad					;display a message informing user to improve
			mov esi,[ebp+24]						;move value of wrong into esi
			mov eax,[esi]							;move deref val into eax
			inc eax									;inc eax by one
			mov [esi],eax							;move value back into deref esi
			
			;mov eax,whiteTextOnBlack
			mov eax,DefaultColor
			call SetTextColor


			jmp _End

		_Success:
			mWriteStr showResultGood				;display a message informing user is correct

			mov esi,[ebp+28]						;move value of right into esi
			mov eax,[esi]							;move deref val into eax
			inc eax									;inc eax by one
			mov [esi],eax							;move value back into deref esi

		_End:
		mWriteStrLine showResultEC1a				;"Extra Credit the sum from r to n is: ";

		
		
	mov esp,ebp
    pop     ebp
    ret     24
showResults ENDP



;****************************************************************************************
;RECURSIVE procedure to calculate the summation of integers from x to y.
;Implementation note: This procedure implements the following
;	recursive algorithm:
;	if (x == y)
;		return x
;	else
;		return x + summation(x+1,y)
;receives: values of x and y, address of result ... on the system stack
;returns: sum = x + sum of (x+1)+ ... +y
;preconditions:  x <= y
;registers changed: eax,ebx,edx
;
;**************************************************************************************

summation	PROC
	push	ebp
	mov		ebp,esp
	finit
	mov		eax,[ebp+16]	;eax = r
	mov		ebx,[ebp+12]	;ebx = n
	mov		edx,[ebp+8]		;@sum in edx
	
	add		[edx],eax		;add current value of x
	cmp		eax,ebx
	je		quit			;base case: sum = x
recurse:
	inc		eax				;recursive case
	push	eax
	push	ebx
	push	edx
	call	summation
quit:
	pop		ebp
	fild  real4 ptr	[edx]	;load sum into the fpu
	ret		12
summation	ENDP




;****************************************************************************************
;AVERAGE procedure will calculate the mean of the user's answer and the correct answer
;receives: values of answer and result and outputs the mean value
;returns: nothing
;preconditions:  answer and result must exit
;registers changed: eax
;**************************************************************************************

average	PROC
	;push 2.0 [ebp+16]
	;push answer [ebp+12]
	;push result [ebp+8]
	
	push	ebp						;push ebp
	mov		ebp,esp					;set esp value into ebp

	finit							;reinitialize
	
	fild real4 ptr [ebp+12]			;load value of answer into fpu
	
	fild real4 ptr [ebp+8]			;load value of result into fpu
	
	fadd							;add the first two portions of fpu stack st(0) + st(1)
	
	fld dword ptr [ebp+16]			;load the value of 2.
	
	fdiv							;divide the sum by 2
	
	call Crlf						;line break
	
	mWriteStrLine showResultEC2		;output result
	
	call writeFloat					;write st(0) to output
	
	call Crlf						;line break

quit:
	pop		ebp
	ret		12
average	ENDP





;************************************************************************************************************
; GETDATA2 PROCEDURE
; prompts / gets the user’s answer.
; receives: the OFFSET of answer and temp and value of answerSize
; returns: none
; preconditions: none
; registers changed:  eax, ebx, ecx, edx, ebp, esi, esp
; resources used: stackoverflow.com/questions/13664778/converting-string-to-integer-in-masm-esi-difficulty
;************************************************************************************************************
getData2 PROC
	push ebp						;push ebp onto stack
		
	mov ebp,esp						;move esp into ebp

LoopA:
	mWriteStrLine   problemLine3	;print the part that prompts the user to input their answer
	
	;call Crlf						;insert line break over here

	;mov	edx, [ebp+16]			;move offset of the tInput for the string of ints to be read into

	mov ecx, 1						;move the value of 1 into ecx register					

	call ReadString					;call the irvine proc to read the string

	cmp eax, 1						;make sure string size does not exceed 1

	jg invalidInput					;if string size is greater than 10 jump to invalidInput

	mov al, [esi]					;move deref into al
	cmp al,79h						;compare to hex 79
	je _start						;if equal goto start
	jmp invalidInput				;if not output error message through invalid label

	_start:
	mwritestr tempStart

	
	
	
	;popad
	
	jmp     moveOn

invalidInput:						;set reg and variabls values to zero
    mov     al,0
    
	mov     eax,0					;mov 0 to the eax register
    
    mov     [ebx],eax				;mov the eax value into [ebx]
    
	mWriteStr   error				;output an error message

    jmp     LoopA					;jump back to the beginning of loopA
moveOn:
    pop     ebp
    ret     12
getData2 ENDP


;//**************************************************************************************
;// (insert additional procedures here)


END main











;Jay Swaminarayan