/*
 * Assembly language implementations of functions declared in textsearch_fns.h
 * CSF Assignment 2
 * Elizabeth Aufzien eaufzie1@jh.edu
 * Rosie Wolkind rwolkin1@jh.edu
 */
 
 #define MAXLINE 511


 .section .rodata

	.formatStr:	
		.string	"%s\n"

.section .text 

	.globl find_string_length
	.globl strings_equal
	.globl read_line
	.global count_occurrences
	.global print_line
	.global find_all_occurrences
/*
 * Description: Counts number of characters up to null terminator.
 *
 * Parameters:
 *   s - string.
 *
 * Returns:
 *   length of string s
 */

/*--------BEGIN: find_string_length------------------------------------------------*/
find_string_length:
	subq $8, %rsp 						//align stack pointer - restore address to multiple of 16
	xorl %eax, %eax 					//zero out eax
	jmp .LfindStrLen_checkNullTerm

.LfindStrLen_incLenAndPtr:
	incl %eax 							//increment eax which stores str len
	jmp .LfindStrLen_checkNullTerm 		//check for null terminator after each loop 
.LfindStrLen_checkNullTerm: 			//check for null term.
	movslq	%eax, %rdx					
	cmpb	$0, (%rdi,%rdx)				//check if 0 ==  (%rdi+ rdx)
	jne .LfindStrLen_incLenAndPtr 		// if \0 == (%rdi), jump to .LfindStrLen_doneWithLoop 

.LfindStrLen_doneWithLoop:
	addq $8, %rsp 						//align stack ptr
	ret
/*--------END: find_string_length------------------------------------------------*/

/*
 * Description: Checks equality of two strings.
 *
 * Parameters:
 *   s1 - string 1.
 *   s2 - string 2.
 * Returns:
 *   0 - if not equal
 *   1 - if equal
 */
/*--------BEGIN: strings_equal-------------------------------------------------*/
strings_equal:
	//push callee saved registers r12, rbp, rbx
	//need to pop in reverse order before returning to maintain stack alignment
	pushq 	%r12 					//(8 bytes offset)
	pushq	%rbp 					//(8 bytes offset)
	pushq	%rbx 					//(8 bytes offset)
	
	movq	%rdi, %rbp 				//rbp will maintain value of s1
	movq	%rsi, %r12 				//r12 will maintain value of s2
	call	find_string_length 		//find_str_len(%rdi = string 1)
	movl	%eax, %ebx 				//store result = str_len(s1) to ebx
	movq	%r12, %rdi				//move stored s2(in r12) to rdi to call fn
	call	find_string_length		//find_str_len(%rdi = string 2)
	cmpl	%eax, %ebx				//compare string lengths (eax=s2_len, ebx=s1_len)
	je	.LstrEq_lengthsAreEqual 	//jump if equal - will zero out eax + enter main loop to check strings
	movl	$0, %eax				//else: move 0 into eax (to return strings_equal = false), and goes straight to LstrEq_restoreStackAndReturn
.LstrEq_restoreStackAndReturn:
	popq	%rbx					//pop callee saved registers in reverse order that we pushed them
	popq	%rbp					//	"
	popq	%r12					//	"
	ret

.LstrEq_lengthsAreEqual:
	xorl	%eax, %eax				//zero out eax before entering main loop(bc it's used as counter)

.LstrEq_checkCharEq: 				//Main loop: checks each char to see if eq.
	cmpl	%ebx, %eax				// compare ebx to eax: 
	je	.LstrEq_isTrue				//if they're equal, every char is eq. and reached end of str
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
 * Description: Count instances of search string in line from text file.
 *
 * Parameters:
 *   line - line from text file.
 *   str - target string to match.
 *
 * Returns:
 *   number of occurrences of target string
 */
/*--------BEGIN: count_occurrences-------------------------------------------------*/
count_occurrences:
    pushq	%r15 					//will be storing search string into r15
	pushq	%r14 					//will be using it for string length of line & modif. when calc last_index
	pushq	%r13 					//intermediary return value
	pushq	%r12 					//will be storing line into r12
	pushq	%rbp 					//pointer to array
	pushq	%rbx  					//will be storing string length (termination condition for inner loop)
	subq	$520, %rsp 				//allocate a total of 568

    movq	%rdi, %r12 				//store first arg (from rdi) in r12
	movq	%rsi, %r15 				//store 2nd arg (from rsi) in r15

.LcountOcc_getSearchStrLength:
	xorl 	%eax, %eax 				//zero out eax (faster to xor w itself than move a 0 immediate val)
	movq	%rsi, %rdi				//move search string to 1st arg
	call	find_string_length 		//find str len of line
	testl %eax, %eax 				//check if length of search str = 0
	jne	.LcountOcc_getLineLength 	//if not, get line length
	jmp .LcountOcc_setRetValEq0 	//else, search string has len=0 -> num occ = 0

.LcountOcc_getLineLength:
	movl	%eax, %ebx				//move search string length to ebx
	movq	%r12, %rdi				//move line to 1st arg
	call	find_string_length		//call find str length
	cmpl	$MAXLINE, %eax			//compare line length with 511
	jle	.LcountOcc_findLastIndex	//if less than or equal to 511, calculate last index
	movl	$MAXLINE, %eax			//else, set last index to search in line to = 511
	
.LcountOcc_findLastIndex:	
	subl	%ebx, %eax				//calc last index = line len - str len
	movl	%eax, %r14d				//store in r14d
	js	.LcountOcc_setRetValEq0
	movl	$0, %ebp 				//int i = 0
	movl	$0, %r13d 				//line_total = 0 (counter)
	jmp	.LcountOcc_checkCondition_iLessThanLastIndex

.LcountOcc_getSubstringFromLine:
	leaq	0(%rbp,%rax), %rdx 		//rdx = i + j
	movzbl	(%r12,%rdx), %ecx		//move line[i+j] into %cl
	movslq	%eax, %rdx 				//rdx = j
	movb	%cl, (%rsp,%rdx) 		//set substr[j] = line[i+j]
	incl    %eax 					//increment j
.LcountOcc_checkJLessThanStrLen:
	cmpl	%ebx, %eax 				//compare str_len to j
	setl	%cl						//if eax =ebx cl is set=1
	cmpl	$MAXLINE, %eax
	setle	%dl						//IF eax = 511, 0 flag set & dl=1
	testb	%dl, %cl 				//double exit conditions in inner for loop
	jne	.LcountOcc_getSubstringFromLine

	movslq	%ebx, %rax 				//sign extend str_len to 8 bytes 
	movb	$0, (%rsp,%rax) 		//null terminate substr
	movq	%rsp, %rdi 				//move substr to 1st arg
	movq	%r15, %rsi 				//move target str to 2nd arg
	call	strings_equal			//check if strs equal
	addl	%eax, %r13d 			//add return val to line_total
	incl	%ebp 					//increment i
.LcountOcc_checkCondition_iLessThanLastIndex:
	cmpl	%r14d, %ebp  			//compare i to last index. If i is greater than equal, return line total
	jg	.LcountOcc_alignStackAndReturn
	xorl %eax, %eax 				//else set j = 0 
	jmp	.LcountOcc_checkJLessThanStrLen //jump into j loop
.LcountOcc_setRetValEq0:
	xorl	%r13d, %r13d 			//set line_total = 0
.LcountOcc_alignStackAndReturn:
	movl	%r13d, %eax 			//move line total to return value
	addq	$520, %rsp 				//align stack

	popq	%rbx	//pop callee saved registers in reverse order that we pushed them
	popq	%rbp	//"
	popq	%r12	//"
	popq	%r13	//"
	popq	%r14	//"
	popq	%r15	//"
	ret
/*--------END: count_occurrences----------------------------------------------------*/

/*
 * Description: Puts characters from text file until encounters newline or EOF.
 * 
 *
 * Parameters:
 *   in - File pointer.
 *   buf - character buffer to store line.
 *
 * Returns:
 *   0 - EOF
 *   1 - has next line = true
 */
/*--------BEGIN: read_line---------------------------------------------------*/
read_line:
	pushq	%r12 				//counter var to store position in buffer
	pushq	%rbp				//stores buffer
	pushq	%rbx				//stores file pointer

	movq	%rdi, %rbx 			//move file handle into rbx
	movq	%rsi, %rbp			//move buffer to rbp
	call	fgetc				//get first char from file
	movl	$0, %r12d			//initialize counter var
	jmp	.LreadLine_topOfWhileLoop

.LreadLine_getCharFromFile:
	movq	%rbx, %rdi			//move file pointer to 1st arg
	call	fgetc				//call fgetc (to get char from specified file)
.LreadLine_topOfWhileLoop:
	cmpb	$-1, %al 			//check if fgetc gets negative result: i.e EOF
	setne	%cl 				//sets ZF be ~ZF
	cmpb	$10, %al	 		//check if char is newline -> if so return val is 1
	setne	%dl 				//sets ZF be ~ZF
	testb	%dl, %cl 			//if equal, return 1, else continue in loop
	je	.LreadLine_setReturnValue
	cmpl	$MAXLINE, %r12d 	//compare counter to 511, if greater and theres still chars left in file-> get them & dont do anything until encounter newline or EOF
	jg	.LreadLine_getCharFromFile
	movslq	%r12d, %rdx			//sign extend counter variable to put next char in buf[counter]
	movb	%al, 0(%rbp,%rdx)	//move 1 byte (char) returned by fget c to buffer + counter
	movq	%rbx, %rdi			//move file ptr back into rdi
	call	fgetc				//get next char
	incl 	%r12d 				//increment counter
	jmp	.LreadLine_topOfWhileLoop

.LreadLine_setReturnValue:
	movslq %r12d, %r12 			//extend index to be 8 byte num
	movb $0, 0(%rbp, %r12, 1) 	//null terminate buffer
	cmpb $-1, %al 				//check if last char was EOF (ubuntu 1804 EOF should always = -1)
	je .LreadLine_return0		//if last char was EOF -> return 0
	movl $1, %eax				//else, move 1, (has next line = true) into return register

.LreadLine_alignStackAndReturn:
	popq	%rbx				//pop callee saved registers in reverse order that we pushed them
	popq	%rbp				//"
	popq	%r12				//"
	ret

.LreadLine_return0:
	movl	$0, %eax	//move 0 (indicating EOF) to return register
	jmp	.LreadLine_alignStackAndReturn
/*--------END: read_line---------------------------------------------------*/

/*
 * Description: Prints line of text contained in buf.
 *
 * Parameters:
 *   out - output file/output stream
 *   buf - buffer with line to print
 */
/*--------BEGIN: print_line---------------------------------------------------*/
print_line:
	subq	$8, %rsp 			//align stack ptr
	testq %rdi, %rdi 			//check if rdi is null
	je .LprintLine_return		//return w/o printing if null
	movq	%rsi, %rdx 			//move buffer ptr to rdx = 3rd arg
	movq	$.formatStr, %rsi 	//move format str to 2nd arg
	movl	$0, %eax 			//zero out return value
	call	fprintf				//arg in rdi, previously verified is not null

.LprintLine_return:
	addq $8, %rsp				//realign stack ptr
	ret
/*--------END: print_line--------------------------------------------------*/

/*
 * Description: Find number of occurrences in entire text file (and print if argc=3)
 * 
 * Parameters:
 *   in - file ptr.
 *   search - search string
 *   printOccurrences - boolean: if 1, then print matching lines when you find them. 
 *
 * Returns:
 *   unsigned num of occurrences
 */
/*--------BEGIN: find_all_occurrences---------------------------------------------------*/
find_all_occurrences:
	/* push callee saved registers r15, r14, r13, r12, rbp, rbx	
	need to pop in reverse order before returning to maintain stack alignment */
	pushq	%r15					//offset -8	: stores
	pushq	%r14					//offset -16:
	pushq	%r13					//offset -24:
	pushq	%r12					//offset -32:
	pushq	%rbp					//offset -40:
	pushq	%rbx					//offset -48:
	subq	$520, %rsp 				//total stack offset = abs(-48 - 520) = 568 bytes on stack
	movq	%rdi, %r14  			//store file ptr
	movq	%rsi, %r13 				//store search str
	movl	%edx, %r12d				//store boolean: printOccurrences

	xorl	%eax, %eax 				//zero out eax
	xorl	%ebx, %ebx				//zero out ebx
	movl	$1, %ebp 				//set hasNextLine=true

.LfindAllOcc_whileHasNextLine:
	testl	%ebp, %ebp				//check if == 0 (0 = has next line, 1 = EOF)
	je	.LfindAllOcc_alignStackAndReturn
	movb	$0, MAXLINE(%rsp)		//null terminate char buffer[511]
	movq	%rsp, %r15				//store stack pointer in r15
	movq	%rsp, %rsi				//additionally move it to 2nd arg bc %rsp pts to buffer
	movq	%r14, %rdi				//Move file ptr to 1st arg register
	call	read_line				//call read_line (rdi = File ptr)
	movl	%eax, %ebp				//move return value to ebp (either 0 or 1)
	movq	%r13, %rsi				//move search string to 2nd arg
	movq	%r15, %rdi				//move buffer containing line to 1st arg
	call	count_occurrences 		//call count_occ(*line, *searchstr)
	addl	%eax, %ebx				//add return val (unsigned int) to ebx which stores the total count of matches in file
	cmpl	$1, %r12d				//check if printOccurrences = true (== 1)
	sete	%dl						//if so, set %dl = 1
	testl	%eax, %eax				//check if eax == 0, set ZF accordingly
	setne	%al						//eax != 0, set %al to 0, otherwise set %al to 1
	testb	%al, %dl				//if they both = 1: i.e. num occurrences != 0 & printOcc == 1 -> print results
	je	.LfindAllOcc_whileHasNextLine //else, don't print (just store num occ)
	movq	%rsp, %rsi				//to print: move line to 2nd arg
	movq	stdout(%rip), %rdi		//move output stream to 1st arg
	call	print_line				//call print line
	jmp	.LfindAllOcc_whileHasNextLine
.LfindAllOcc_alignStackAndReturn:
	movl	%ebx, %eax 				//total stack offset at this point = 512 + 6*8 + 8(so stack is odd multiple of 8) = 568
	addq	$520, %rsp				//add 520 back to stack
	popq	%rbx					//pop callee saved registers in reverse order that they were pushed
	popq	%rbp		
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
/*--------END: find_all_occurrences--------------------------------------------------*/
