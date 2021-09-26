/*
 * Assembly language implementations of functions declared in
 * textsearch_fns.h
 */

	.section .text 

/*
 * The following is just an example of how an assembly language
 * function would be defined
 */
	//.globl read_line

.globl find_string_length

	//; read_line:
//; 	/* TODO: implementation of read_line function */
//; 	ret







find_string_length:

	subq $8, %rsp /* align stack pointer - restore address to multiple of 16 */
	movl $0, %eax //will be storing length in eax register (bc its return val)

	//check if pointer to string char == null term
.LcheckNullTerm:
	cmpq (%rdi), $0x00
	jae .LendOfLoop
	/*compare je .LendOfLoop /*if pointer to string char == 0, jump to end of loop*/

.LincrementLenIfValidChar:
	cmpb $1,  (%rdi)   /* if cur char < 97, not lower case */
	jge .LcontinueLoop /* Jump if not lowercase(Uppercase Ascii < lowercase) */
	cmpb $127, (%rdi)   /* if cur char > 122, not lower case */
	jle .LcontinueLoop /* ignore upper symbols */
	
.LcontinueLoop:
	incl %eax //else, if not null term -> inc eax
	incq %rdi //increment pointer to point at next char
	jmp .LcheckNullTerm

.LendOfLoop:
	addq $8, %rsp
	ret

.globl strings_equal
	
	/*s1 stores in %rdi, s2 stored in %rsi*/

strings_equal:
	subq $8, %rsp /*align stack pointer */

.LcompareStrLength:
	call find_string_length     /*automatically uses arg1, s1*/
	/* TODO: double check movzwq */
	movzwq %ax, %r10          /*moving length of string 1 (which will always be <= 512/16 bites) to callee saved r10*/
	push %rdi                  /*push s1 to the top of the stack */
	movq (%rsi), %rdi          /* store s2 in %rdi so it will be arg1 */
	call find_string_length    /*find length of string 2 which is now stored in arg1 */
	movzwq %ax, %r11          /*move result, length of string 2 (which will always be =< 512 / 16 bites) to calle saved r11 */
	pop %rdi                   /*move string 1 back to %rdi*/
	cmpq %r10, %r11 		   /*compare q bc we've movzwq both string lengths */
	jne .LstringsEqualresultStringsNotEqual /*jump to not equal condition*/
	leaq (%rdi, %r10, 1), %r12 /*save  register value of thing after the last char in caller saved %r12*/

.LstringsEqualCompareStrContentsEqual:
//check to make sure we haven't reached end of string 1
	movq (%rdi), %r10
	cmpq (%r12), %r10
	je .LstringsEqualresultStringsAreEqual 	//if so, jump to end and return true
	cmpq %rsi, %rdi //else: compare equality of current character
	jne .LstringsEqualresultStringsNotEqual	//if not equal jump return false
	inc %rsi	//increment & 
	inc %rdi	//increment & 
	jmp .LstringsEqualCompareStrContentsEqual
	//jump top of of the current label

.LstringsEqualresultStringsAreEqual:
	movl $1, %eax /*set default return value to 1, true*/
	ret
.LstringsEqualresultStringsNotEqual:
	movl $0, %eax /*set return value to false*/ 
	ret 

