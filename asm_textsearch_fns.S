; #define MAXLINE 511

/*
 * Assembly language implementations of functions declared in
 * textsearch_fns.h
 */

	.section .text 
	.section .bss

	.align 8

	countOccSubstr: .space(512 * 1)

.globl strings_equal
.globl find_string_length
.globl read_line
.global count_occurrences

/*--------BEGIN: find_string_length------------------------------------------------*/
find_string_length:
	subq $8, %rsp 						//align stack pointer - restore address to multiple of 16
	movl $0, %eax 						//zero out eax - could also XOR with itself?
	
.LfindStrLen_checkNullTerm: 			//check for null term.
	cmpb $0, (%rdi) 					//cmp \0 with (%rdi)
	je .LfindStrLen_doneWithLoop 		// if \0 == (%rdi), jump to .LfindStrLen_doneWithLoop 

.LfindStrLen_incrementLengthAndPointer:
	incq %rdi 							//increment rdi to point to next char 
	incl %eax 							//increment eax which stores str len
	jmp .LfindStrLen_checkNullTerm 		//check for null terminator after each loop 

.LfindStrLen_doneWithLoop:
	addq $8, %rsp 						//align stack ptr
	ret
/*--------END: find_string_length------------------------------------------------*/


	
	/*s1 stores in %rdi, s2 stored in %rsi*/

/*--------BEGIN: strings_equal-------------------------------------------------*/
strings_equal:
	//push callee saved registers r12, rbp, rbx
	//need to pop in reverse order before returning to maintain stack alignment
	pushq	%r12 				//(8 bytes offset)
	pushq	%rbp 				//(8 bytes offset)
	pushq	%rbx 				//(8 bytes offset)

	movq	%rdi, %rbp 			//rbp will maintain value of s1
	movq	%rsi, %r12 			//r12 will maintain value of s2
	call	find_string_length 	//find_str_len(%rdi = string 1)
	movl	%eax, %ebx 			//store result = str_len(s1) to ebx
	movq	%r12, %rdi			//move stored s2(in r12) to rdi to call fn
	call	find_string_length	//find_str_len(%rdi = string 2)
	cmpl	%eax, %ebx			//compare string lengths (eax=s2_len, ebx=s1_len)
	je	.LstrEq_lengthsAreEqual //jump if equal - will zero out eax + enter main loop
	movl	$0, %eax			//else: move 0 into eax (to return strings_equal = false)
.LstrEq_restoreStackAndReturn:
	popq	%rbx				//pop callee saved registers in reverse order that we pushed them
	popq	%rbp				//	"
	popq	%r12				//	"
	ret

.LstrEq_lengthsAreEqual:
	movl	$0, %eax				//zero out eax before entering main loop as it's being used as a counter

.LstrEq_checkCharEq: 				//Main loop: checks each char to see if eq.
	cmpl	%ebx, %eax				// compare ebx to eax
	je	.LstrEq_isTrue				//if(eax = ebx: know str eq is true)
	//TODO: I know the textbook says movslq isn't a thing, but the gcc assembler is ok with it?
	movslq	%eax, %rdx				//move 4 byte val in eax to rdx so you can address the current char. in each string
	movzbl	0(%r12, %rdx, 1), %ecx	//zero out upper 56 bits & move char in str2[r12] & index[rdx] to low 8 bits of rcx[cl]
	cmpb	%cl, 0(%rbp, %rdx, 1)	//compare char from str2 [cl] with char from str1 [0(%rbp, %rdx, 1) = 0 + str1_mem_loc[rbp] + (index[rdx] * offset[1])]	
	jne	.LstrEq_isFalse				//if chars aren't equal - strings can't be equal! Jump to return false.
	incl %eax						//else: increment eax
	jmp	.LstrEq_checkCharEq			//go back to top!

.LstrEq_isTrue:
	movl	$1, %eax				//set return value = 1
	jmp	.LstrEq_restoreStackAndReturn

.LstrEq_isFalse:
	movl	$0, %eax				//set return value = 0
	jmp	.LstrEq_restoreStackAndReturn

/*--------END: strings_equal-------------------------------------------------*/



.globl count_occurances

/* %rdi -> *line %rsi -> *str

/*--------BEGIN: count_occurances-------------------------------------------------*/

//push callee saved registers r12, rbp, rbx
//need to pop in reverse order before returning to maintain stack alignment
	pushq	%r13				//(8 bytes offset)
	pushq	%r12 				//(8 bytes offset)
	pushq	%rbp 				//(8 bytes offset)
	pushq	%rbx 				//(8 bytes offset)
	subq $8, %rsp 				//-8 from stack pointer so that stack align. is an odd mult. of 8

	movq	%rdi, %rbp 			//rbp will maintain value of *line
	movq	%rsi, %r12 			//r12 will maintain value of *str

	call	find_string_length 	//find_str_len(%rdi = *line)
	movl	%eax, %ebx 			//store result = str_len(*line) to ebx
	cmpl    $0, %ebx 			//if str_len(*line) == 0
	jmpe	.LcountOccur_errorExit

	movq	%r12, %rdi			//move stored *str(in r12) to rdi to call fn
	call	find_string_length	//find_str_len(%rdi = *str)

	cmpb 	$512, %eax 			//see if find_str_len(*str) > 512
	jge 	.LcountOccur_substringOverMaxline	//If it is, greater, then you need to set %ebx to 512
	jmp 	.LcountOccur_lastIndex 			  	//If it is less than 512, it remains (%eax)


.LcountOccur_substringOverMaxline:
	movb $512, %rax
	jmp .LcountOccur_lastIndex

.LcountOccur_setLastIndex
	subb 	%eax, %ebx			//subtract str_len(*line) - str_len(*str), save in %ebx
	movl	(%ebx), %r13d		//store the difference in calle-saved %r13
	cmpb 	$0, (%r12)			//if *line len < *str len, return 0
	jl	 	.LcountOccur_errorExit


.LcountOccur_errorExit:
	movl $0, %eax
	call .LcountOccur_restoreStackAndReturn

.LcountOccur_restoreStackAndReturn
	popq	%rbx				//pop callee saved registers in reverse order that we pushed them
	popq	%rbp				//	"
	popq	%r12				//	"
	popq	%r13				//  "
	ret
/*--------BEGIN: read_line---------------------------------------------------*/

read_line:
	pushq %r12 //using to store file handle
    pushq %rbp //using for buffer argument storage
    pushq %rbx // using for index in buffer - 3*8 offset

    movq %rdi, %r12//move file handle into r12
	movq %rsi, %rbp //move buf(2nd argument) into rbp
	call fgetc //get first character from file - will return char in %al (char -> 1 byte)
	movl $0, %ebx //initialize index to be zero


.LreadLine_checkIfValidChar:

	cmpb	$-1, %al //check if fgetc gets negative result: i.e EOF
	setne	%cl //sets ZF be ~ZF
	cmpb	$10, %al //check if char is newline -> if so return val is 1
	setne	%dl //sets ZF be ~ZF
	testb	%dl, %cl //if equal, return 1, else continue in loop
	je	.LreadLine_setReturnValue 

	//beginning of "while loop"
	movslq	%ebx, %rdx //sign extend ebx-> rdx
	movb	%al, 0(%rbp,%rdx, 1)
	cmpl	$511, %ebx //if ebx >=511, break out of loop
	jge	.LreadLine_setReturnValue
	movq	%r12, %rdi //move file ptr back into rdi
	call	fgetc
	incl	%ebx
	jmp	.LreadLine_checkIfValidChar

	je .LreadLine_setReturnValue

.LreadLine_setReturnValueTo0:
	movl $0, %eax
	jmp .LreadLine_alignStackAndReturn

.LreadLine_setReturnValue:
	//null terminate before returning buffer
	movslq %ebx, %rbx //extend index to be 8 byte num
	movb $0, 0(%rbp, %rbx, 1) 	//null terminate buffer
	cmpb $-1, %al //check if last char was EOF
	je .LreadLine_setReturnValueTo0
	
	movl $1, %eax

.LreadLine_alignStackAndReturn:
	popq %rbx
	popq %rbp
	popq %r12
	ret

/*--------END: read_line---------------------------------------------------*/



/*--------BEGIN: count_occurrences--------------------------------------------------*/
count_occurrences

/*--------END: count_occurrences----------------------------------------------------*/





















