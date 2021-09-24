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

; read_line:
; 	/* TODO: implementation of read_line function */
; 	ret

find_string_length:

	subq $8, %rsp /* align stack pointer - restore address to multiple of 16 */
	movl $0, %eax //will be storing length in eax register (bc its return val)

	//check if pointer to string char == null term
.LcheckNullTerm:
	cmpb $0, (%rdi)
	je .LendOfLoop

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