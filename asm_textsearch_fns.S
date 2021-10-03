; #define MAXLINE 511

/*
 * Assembly language implementations of functions declared in
 * textsearch_fns.h
 */

	.section .bss
	.align 16

countOccSubstr: .space (512 * 1)

.section .text 

	.globl find_string_length

	.globl strings_equal
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




/* %rdi -> *line %rsi -> *str

/*--------BEGIN: count_occurances-------------------------------------------------*/

//push callee saved registers r15, r14, 413, r12, rbp, rbx
//need to pop in reverse order before returning to maintain stack alignment
count_occurrences:
	pushq	%r15 //moving search string into r15
	pushq	%r14 //using it for string length of line & modif. when calc last_index
	pushq	%r13 //intermediary return value

	pushq	%r12 //moving line into r12
	pushq	%rbp //pointer to array
	pushq	%rbx //storing string length (termination condition for inner loop)

	subq	$8, %rsp

	movq	%rdi, %r12
	movq	%rsi, %r15

	movl $0, %eax //zero out eax
	call	find_string_length //find str len of line
	movl	%eax, %r14d //move result into r14d



	movq	%r15, %rdi //move 2nd arg into rdi
	call	find_string_length //find string length of search string

	//check if string length == 0
	testl	%eax, %eax //check if str_len == 0
	je	.LcountOcc_setRetValEq0 			//if str len = 0, nothing matches - align stack & ret
	cmpl	$510, %eax //check if string length >= 511 (i.e. > 510)
	jg	.LcountOcc_setRetValEq0				//if greater than, jump to return 0
	movl	%eax, %ebx //else move str_len into ebx


//check if line length > 512
	cmpl	$512, %r14d //if line len <=512...go directly to check if last index < 0
	jg	.LcountOcc_fixLastIndexIfNec
	
	subl	%ebx, %eax //calc last index = line len - str len
	movl	%eax, %r14d //store in r14d
	//if less than 0, return 0
	js	.LcountOcc_setRetValEq0
	movq	$0, %r10 //set int i = 0
	movl	$0, %r13d //set line_total = 0 (return val)
	movq $countOccSubstr, %rbp

	jmp	.LcountOcc_checkConditionOfOuterLoop

.LcountOcc_fixLastIndexIfNec:
	movl	$512, %r14d //else set line len = 512

.LcountOcc_getSubstringFromLine:
	//figure out the base address of substring array (%rbp)
	//enter j loop
	//get substring[j] anything from 0, 4 (len = 5)
	//
	leaq	0(%rbp,%rax), %rdx //get substr[j] & move address into rdx
	movzbl	(%r12,%rdx), %ecx //move char @ line[i+j] into %ecx
	movb	%cl, (%rbp,%rdx)
	addl	$1, %eax //inc j

.LcountOcc_outerLoop:
	cmpl %r10d, %r14d
	//cmpl	%ebx, %eax //compare str_len to j
	jl	.LcountOcc_getSubstringFromLine 			//if j < str_len jmp to LcountOcc_getSubstringFromLine
	movslq	%ebx, %rax //move str_len to rax
	movb	$0, (%rbp,%rax) //null terminate substr[str_len]
	
	movq	%rbp, %rdi //move substr(alloc on stack) address into 1st arg register before making function call
	movq	%r15, %rsi //move orig ptr of string into 2nd argument before calling strings equal
	call	strings_equal
	addl	%eax, %r13d //add the return value (0 or 1) to line_total 
	addl	$1, %r10d //increment i (outer loop)
	addq $1, %rbp
	addq $1, %r15

.LcountOcc_checkConditionOfOuterLoop:

	cmpl	%r14d, %r10d //compare i to last index. If i is greater than equal, return line total
	jge	.LcountOcc_alignStackAndReturn
	movl	$0, %eax //else set j = 0 
	jmp	.LcountOcc_outerLoop
.LcountOcc_setRetValEq0:
	movl	$0, %r13d
.LcountOcc_alignStackAndReturn:
	movl	%r13d, %eax
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	addq $8, %rsp
	ret

/*--------END: count_occurrences----------------------------------------------------*/



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





















