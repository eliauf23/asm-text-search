/*
 * Elizabeth Aufzien, eaufzie1@jh.edu
 * Rosie Wolkind, rwolkin1@jh.edu
 * CSF Assignment 2
 * Assembly language implementation of the main function
 * for the asm_textsearch_fns program
 */	
 

 .section .rodata

insufficientArgs:
	.string	"User did not supply sufficient arguments.\n"
tooManyArgs:
	.string	"User supplied too many arguments.\n"
cFlag:
	.string	"-c"
readStr:
	.string	"r"
cantOpenFile:
	.string	"File cannot be opened.\n"
numOcc:
	.string	"%d occurrence(s)\n"
errorMsg:
	.string	"Error!\n"

.section .text
	.globl	main


main:

	/* push callee saved registers & align stack */
	pushq	%r13					//offset: 8
	pushq	%r12					//offset: 16
	pushq	%rbp					//offset: 24
	pushq	%rbx					//offset: 32
	subq	$8, %rsp			 	//to properly align stack (offset = 40 - odd. mult of 8)
	
	cmpl	$2, %edi 				//check if argc < 3
	jle	.Lmain_errorInsufficientArgs

	movl	%edi, %ebx				//store argc in ebx so we can check if argc = 3 or 4 (to set value of print occurrences)
	cmpl	$4, %edi				//check if argc <= 4 (& to get here must be >= 3)
	jle	.Lmain_openFileAndCountOcc

.Lmain_errorTooManyArgs:
	movq	stderr(%rip), %rdi		//move output stream=stderr to 1st arg
	leaq	tooManyArgs(%rip), %rsi	//move error message to 2nd arg
	jmp .Lmain_printErrorMsgExit1	//jmp to label where msg is printed & exit(1)


.Lmain_errorInsufficientArgs:
	movq	stderr(%rip), %rdi			 //move output stream=stderr to 1st arg
	leaq	insufficientArgs(%rip), %rsi //move error message to 2nd arg
	jmp .Lmain_printErrorMsgExit1		 //jmp to label where msg is printed & exit(1)


.Lmain_openFileAndCountOcc:
	movslq	%edi, %rax 				//move & sign extend argc to rax 
	movq	-16(%rsi,%rax, 8), %r12 //move search string = argv[argc - 2] to r12
	movq	-8(%rsi,%rax, 8), %rbp  //move filename = argv[argc - 1] to rbp
	
	movq	8(%rsi), %rdi 			//move argv[1] to 1st arg
	leaq	cFlag(%rip), %rsi 		//move "-c" string to second arg
	call	strings_equal 			//check if strings equal
	movl	%eax, %r13d 			//move result = has_c_flag to r13d

	movq	%rbp, %rdi 				//move pointer to filename to first arg
	leaq	readStr(%rip), %rsi 	//load "r" string to second arg
	call	fopen					//try to open file

	movq	%rax, %rbp				//store file pointer in rbp (rax not eax bc its a mem. address)
	testq	%rax, %rax				//check if rax is null (i.e. rax & rax bitwise = zero vector)
	jz	.Lmain_errorcantOpenFile	//if file ptr is NULL --> print err msg to stderr & exit(1)
	
	cmpl	$3, %ebx				//check if argc == 3
	sete	%dl						//set %dl = 1 if ^
	testl	%r13d, %r13d			//if has_c_flag is not true -> sets zero flag
	sete	%cl						//set %cl = 1 if ^
	testb	%dl, %cl				//if dl != cl -> argc == 4 or error
									//if dl == cl -> argc == 3 & has_c_flag not true
	jne	.Lmain_printAllOcc
	cmpl	$4, %ebx				//check if argc == 4
	je	.Lmain_getNumOcc			//if so, get number of occurrences
									//else, print error message

.Lmain_errorOther:
	movq	%rbp, %rdi				//move file pointer to 1st arg
	call	fclose					//close file
	movq	stderr(%rip), %rdi		//move output stream=stderr to 1st arg
	leaq	errorMsg(%rip), %rsi	//move error message to 2nd arg
	jmp .Lmain_printErrorMsgExit1	//jmp to label where msg is printed & exit(1)


.Lmain_errorcantOpenFile:
	movq	stderr(%rip), %rdi		//move output stream=stderr to 1st arg
	leaq	cantOpenFile(%rip), %rsi//move error message to 2nd arg
	jmp .Lmain_printErrorMsgExit1	//jmp to label where msg is printed & exit(1)


.Lmain_printAllOcc:
	movq	%rbp, %rdi				//(1st arg) move file pointer to rdi
	movq	%r12, %rsi				//(2nd arg) move search string to rsi
	movl	$1, %edx				//(3rd arg) move printOccurrences = 1 to lower half of rdx
	call	find_all_occurrences	//call find all occurrences (will print output in function)

.Lmain_closeFileExit0:
	movq	%rbp, %rdi				//move file pointer to 1st arg
	call	fclose					//close file
	movl	$0, %edi				//set exit code = 0
	call	exit					//exit(0)

.Lmain_printErrorMsgExit1:
	call	fprintf					//print error message (arguments loaded before jmp)
	xor 	%rdi, %rdi				//zero out rdi (was formerly ptr address)
	movl	$1, %edi				//set exit code = 1
	call	exit					//exit(1)


.Lmain_getNumOcc:

	movq	%rbp, %rdi				//(1st arg) move file pointer to rdi
	movq	%r12, %rsi				//(2nd arg) move search string to rsi
	movl	$0, %edx				//(3rd arg) move printOccurrences = 0 to lower half of rdx
	call	find_all_occurrences 	//call find all occurrences (need to print output after functions)

	movl	%eax, %edx				//move value returned from find_all_occurrences to 3rd arg
	leaq	numOcc(%rip), %rsi		//move format string to 2nd arg
	movq	stdout(%rip), %rdi		//move output stream to 1st arg
	call	fprintf					//print num occ. to stdout

	jmp	.Lmain_closeFileExit0		//close input file & exit with exit code=0