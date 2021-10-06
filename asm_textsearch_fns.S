;#define MAXLINE 511

/*
 * Assembly language implementations of functions declared in
 * textsearch_fns.h
 */

 .section .rodata

	.printStr_formatStr:	
		.string	"%s\n"

.section .text 

	.globl find_string_length
	.globl strings_equal
	.globl read_line
	.global count_occurrences
	.global print_line
	.global find_all_occurrences
/*
 * Description
 *
 * Parameters:
 *   s - pointer to a NUL-terminated character string
 *   c - character to search for
 *
 * Returns:
 *    pointer to first occurrence of the search character,
 *    or NULL if the character does not occur in the string
 */
/*--------BEGIN: find_string_length------------------------------------------------*/
find_string_length:
	subq $8, %rsp 						//align stack pointer - restore address to multiple of 16
	movl $0, %eax 						//zero out eax - could also XOR with itself?
	jmp .LfindStrLen_checkNullTerm

.LfindStrLen_incrementLengthAndPointer:
	incl %eax 							//increment eax which stores str len
	jmp .LfindStrLen_checkNullTerm 		//check for null terminator after each loop 
.LfindStrLen_checkNullTerm: 			//check for null term.
	movslq	%eax, %rdx					
	cmpb	$0, (%rdi,%rdx)				//check if 0 ==  (%rdi+ rdx)
	jne .LfindStrLen_incrementLengthAndPointer 		// if \0 == (%rdi), jump to .LfindStrLen_doneWithLoop 

.LfindStrLen_doneWithLoop:
	addq $8, %rsp 						//align stack ptr
	ret
/*--------END: find_string_length------------------------------------------------*/

/*
 * Description
 *
 * Parameters:
 *   s - pointer to a NUL-terminated character string
 *   c - character to search for
 *
 * Returns:
 *    pointer to first occurrence of the search character,
 *    or NULL if the character does not occur in the string
 */
/*--------BEGIN: strings_equal-------------------------------------------------*/
strings_equal:
	//push callee saved registers r12, rbp, rbx
	//need to pop in reverse order before returning to maintain stack alignment
	pushq 	%r12 				//(8 bytes offset)
	pushq	%rbp 				//(8 bytes offset)
	pushq	%rbx 				//(8 bytes offset)
	
	movq	%rdi, %rbp 			//rbp will maintain value of s1
	movq	%rsi, %r12 			//r12 will maintain value of s2
	call	find_string_length 	//find_str_len(%rdi = string 1)
	movl	%eax, %ebx 			//store result = str_len(s1) to ebx
	movq	%r12, %rdi			//move stored s2(in r12) to rdi to call fn
	call	find_string_length	//find_str_len(%rdi = string 2)
	cmpl	%eax, %ebx			//compare string lengths (eax=s2_len, ebx=s1_len)
	je	.LstrEq_lengthsAreEqual //jump if equal - will zero out eax + enter main loop to check strings
	movl	$0, %eax			//else: move 0 into eax (to return strings_equal = false), and goes straight to LstrEq_restoreStackAndReturn
.LstrEq_restoreStackAndReturn:
	popq	%rbx				//pop callee saved registers in reverse order that we pushed them
	popq	%rbp				//	"
	popq	%r12				//	"
	ret

.LstrEq_lengthsAreEqual:
	movl	$0, %eax				//zero out eax before entering main loop because it's being used as a counter

.LstrEq_checkCharEq: 				//Main loop: checks each char to see if eq.
	cmpl	%ebx, %eax				// compare ebx to eax TODO: why?
	je	.LstrEq_isTrue				//if(eax = ebx: know str eq is true)
	movslq	%eax, %rdx				//move 4 byte val in eax to rdx so you can address the current char. in each string
	movzbl	0(%r12, %rdx, 1), %ecx	//zero out upper 56 bits & move char in str2[r12] & index[rdx] to low 8 bits of rcx[cl]
	cmpb	%cl, 0(%rbp, %rdx, 1)	//compare char from str2 [cl] with char from str1 [0(%rbp, %rdx, 1) = 0 + str1_mem_loc[rbp] + (index[rdx] * offset[1])]	
	jne	.LstrEq_isFalse				//if chars aren't equal - strings can't be equal! Jump to return false.
	incl %eax						//else: increment eax
	jmp	.LstrEq_checkCharEq			//go back to top of loop!

.LstrEq_isTrue:
	movl	$1, %eax				//set return value = 1
	jmp	.LstrEq_restoreStackAndReturn

.LstrEq_isFalse:
	movl	$0, %eax				//set return value = 0
	jmp	.LstrEq_restoreStackAndReturn

/*--------END: strings_equal-------------------------------------------------*/

/*
 * Description
 *
 * Parameters:
 *   s - pointer to a NUL-terminated character string
 *   c - character to search for
 *
 * Returns:
 *    pointer to first occurrence of the search character,
 *    or NULL if the character does not occur in the string
 */
/*--------BEGIN: count_occurrences-------------------------------------------------*/
count_occurrences:
    pushq	%r15 		//will be storing search string into r15
	pushq	%r14 		//will be using it for string length of line & modif. when calc last_index
	pushq	%r13 		//intermediary return value
	pushq	%r12 		//will be storing line into r12
	pushq	%rbp 		//pointer to array
	pushq	%rbx 		//will be storing string length (termination condition for inner loop)
	subq	$536, %rsp 	//allocate a total of 592 bytes on stack? TODO: make sure this is correct

    
    movq	%rdi, %r12 	//store first arg (from rdi) in r12
	movq	%rsi, %r15 	//store 2nd arg (from rsi) in r15

	movl 	$0, %eax 			//zero out eax
	call	find_string_length 	//find str len of line
	movl	%eax, %r14d 		//move result into r14d
	movq	%r15, %rdi 			//move 2nd arg into rdi
	call	find_string_length 	//find string length(rdi = search string) of search string
	testl	%eax, %eax 			//check if str_len == 0
	je	.LcountOcc_setRetValEq0 //if str len = 0, nothing matches - align stack & ret
	movl	%eax, %ebx			// else store length to be used as counter
	cmpl	$510, %eax 			//check if string length >= 511 (i.e. > 510)
	jg	.LcountOcc_setRetValEq0	//if greater than, jump to return 0
	cmpl	$512, %r14d			//check if line is >= 512
	jle	.LcountOcc_findLastIndex //if not, go to loop
	movl	$512, %r14d			//if line is >512, then we should only search the first 512 chars so we move 512 to line_len variable
.LcountOcc_findLastIndex:	
	subl	%ebx, %r14d 		//calc last index = line len - str len
	js	.LcountOcc_setRetValEq0
	movl	$0, %ebp 			//int i = 0
	movl	$0, %r13d 			//line_total = 0 (counter)
	jmp	.LcountOcc_checkCondition_iLessThanLastIndex
.LcountOcc_getSubstringFromLine:
	leaq	0(%rbp,%rax), %rdx //rdx = i + j
	movzbl	(%r12,%rdx), %ecx//move line[i+j] into %cl
	movslq	%eax, %rdx //rdx = j
	movb	%cl, (%rsp,%rdx) //set substr[j] = line[i+j]
	incl    %eax //increment j
.LcountOcc_checkCondition_jLessThanStrLen:
	cmpl	%ebx, %eax //compare str_len to j
	jl	.LcountOcc_getSubstringFromLine		//
	movslq	%ebx, %rax //sign extend str_len to 8 bytes 
	movb	$0, (%rsp,%rax) //null terminate substr
	movq	%rsp, %rdi //move substr to 1st arg
	movq	%r15, %rsi //move target str to 2nd arg
	call	strings_equal //check if strs equal
	addl	%eax, %r13d //add return val to line_total
	incl	%ebp //increment i
.LcountOcc_checkCondition_iLessThanLastIndex:
	cmpl	%r14d, %ebp  //compare i to last index. If i is greater than equal, return line total
	jge	.LcountOcc_alignStackAndReturn
	movl	$0, %eax //else set j = 0 
	jmp	.LcountOcc_checkCondition_jLessThanStrLen //jump into j loop
.LcountOcc_setRetValEq0:
	movl	$0, %r13d //set line_total = 0
.LcountOcc_alignStackAndReturn:
	movl	%r13d, %eax //move line total to return value
	addq	$536, %rsp //align stack

	popq	%rbx		//pop callee saved registers in reverse order that we pushed them
	popq	%rbp		//"
	popq	%r12		//"
	popq	%r13		//"
	popq	%r14		//"
	popq	%r15		//"
	ret
/*--------END: count_occurrences----------------------------------------------------*/

/*
 * Description
 *
 * Parameters:
 *   s - pointer to a NUL-terminated character string
 *   c - character to search for
 *
 * Returns:
 *    pointer to first occurrence of the search character,
 *    or NULL if the character does not occur in the string
 */
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
	call	fgetc	//get file (rdi = file ptr)
	incl	%ebx	// increment counter
	jmp	.LreadLine_checkIfValidChar
	//TODO: does the code ever get here?
	je .LreadLine_setReturnValue

.LreadLine_setReturnValueTo0:
	movl $0, %eax	//move 0 (indicating EOF) to return register
	jmp .LreadLine_alignStackAndReturn

.LreadLine_setReturnValue:
	//null terminate before returning buffer
	movslq %ebx, %rbx //extend index to be 8 byte num
	movb $0, 0(%rbp, %rbx, 1) 	//null terminate buffer
	cmpb $-1, %al //check if last char was EOF
	je .LreadLine_setReturnValueTo0
	
	movl $1, %eax	//move 1, (has next line = true) into return register

.LreadLine_alignStackAndReturn:
	popq %rbx	//pop callee saved registers in reverse order that we pushed them
	popq %rbp	//"
	popq %r12	//"
	ret

/*--------END: read_line---------------------------------------------------*/

/*
 * Description
 *
 * Parameters:
 *   s - pointer to a NUL-terminated character string
 *   c - character to search for
 *
 * Returns:
 *    pointer to first occurrence of the search character,
 *    or NULL if the character does not occur in the string
 */
/*--------BEGIN: print_line---------------------------------------------------*/

print_line:
	subq	$8, %rsp //align stack ptr
	testq %rdi, %rdi //check if rdi is null
	//don't do anything to rdi except check if its null
	je .LprintLine_return

	movq	%rsi, %rdx //move buffer ptr to rdx = 3rd arg
	movq	$.printStr_formatStr, %rsi //move format str to 2nd arg
	movl	$0, %eax //zero out return value
	call	fprintf	//arg in rdi, previously verified is not null
.LprintLine_return:
	addq $8, %rsp	//realign stack ptr
	ret

/*--------END: print_line--------------------------------------------------*/




/*
 * Description
 *
 * Parameters:
 *   s - pointer to a NUL-terminated character string
 *   c - character to search for
 *
 * Returns:
 *    pointer to first occurrence of the search character,
 *    or NULL if the character does not occur in the string
 */
/*--------BEGIN: find_all_occurrences---------------------------------------------------*/
find_all_occurrences:
	//push callee saved registers r15, r14, r13, r12, rbp, rbx	
	//need to pop in reverse order before returning to maintain stack alignment
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rbx
	subq	$536, %rsp 	//allocate a total of 536 bytes on stack
	movq	%rdi, %r14  //store file ptr
	movq	%rsi, %r13  //store search str
	movl	%edx, %r12d //store bool: printOccurrences
	movq	%rax, 520(%rsp)	//TODO add comments
	xorl	%eax, %eax
	movl	$0, %ebx	
	movl	$1, %ebp //hasNextLine=true
.LfindAllOcc_whileHasNextLine:
	testl	%ebp, %ebp	//check if == 0 (0 = has next line, 1 = EOF)
	je	.LfindAllOcc_alignStackAndReturn	//does not have next line, return
	movb	$0, 511(%rsp)
	movq	%rsp, %r15	//TODO: Why are we moving rsp to r15 and then r15 to rsi?
	movq	%r15, %rsi
	movq	%r14, %rdi	//Move file ptr to 1st arg register
	call	read_line	//call readline (rdi = File prt)
	movl	%eax, %ebp
	movq	%r13, %rsi
	movq	%r15, %rdi
	call	count_occurrences
	addl	%eax, %ebx
	cmpl	$1, %r12d
	sete	%dl
	testl	%eax, %eax	//check if eax == 0, set ZF accordingly
	setne	%al	//eax != 0, set %al to 0, otherwise set %al to 1
	testb	%al, %dl
	je	.LfindAllOcc_whileHasNextLine
	movq	%rsp, %rsi
	movq	stdout(%rip), %rdi
	call	print_line
	jmp	.LfindAllOcc_whileHasNextLine
.LfindAllOcc_alignStackAndReturn:
	movl	%ebx, %eax
	movq	520(%rsp), %rcx
	addq	$536, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
/*--------END: find_all_occurrences--------------------------------------------------*/
