/*
 * Assembly language implementation of the main function
 * for the asm_textsearch_fns program
 */
 
.section .rodata
	.align 8

cFmtStr:
	.string	"-c"
insufficientArgs:
	.string	"User did not supply sufficient arguments."
tooManyArgs:
	.string	"User supplied too many arguments."
readStr:
	.string	"r"
cannotOpenFile:
	.string	"File cannot be opened. "
numOcc:
	.string	"%d occurrence(s)\n"
errorMsg:
	.string	"Error!"

.section .text
	.globl	main

main:
	pushq 	%r15 //pointer to argvs initially & then pointer to input file handle
	pushq	%r14 //used for printOccurrences var
	pushq	%r13 //address of search string
	pushq	%r12 //stores filename idx
	pushq 	%rbp
	pushq	%rbx //stores argc (in lower 32 bits)
	subq $8, %rsp

	movl	%edi, %ebx //move argc to low 32 of rbx
	movq	%rsi, %rbp //move pointer to argv to rbp
	movslq	%edi, %rax //move num args to rax

	movq	-16(%rsi,%rax,8), %r13 //move address of search string into r13
	leaq	-1(%rdi), %r12 //store index in argvs of filename(=argc-1)
	
	movq	8(%rsi), %rdi //adress of rsi + 8 = argv[1] bc its an array of ptrs
	movq	$cFmtStr, %rsi //load "-c" format string address into second arg
	call	strings_equal //check if args contains c flag
	cmpl	$3, %ebx //check if argc < 3
	jl	.Lmain_exitOnError_insufficientArgs //if less than - error not enough args
	movl	%eax, %r14d //else move ret val from strings_equal call to r14d
	cmpl	$4, %ebx //check if argc > 4
	jg	.Lmain_exitOnError_tooManyArgs //if greater than - error too many args

	movq	(%rbp,%r12,8), %rdi //use filename idx to get pointer to filename from argvs
	movq	$readStr, %rsi //get "r" string into 2nd arg
	call	fopen //try to open file
	movq	%rax, %r15 //move file handle to rbp
	testq	%rax, %rax //if zero i.e. input is null
	je	.Lmain_exitOnError_cantOpenFile
	cmpl	$3, %ebx //if argc ==3 & user requests to display matches (not num matches)
	sete	%dl //if equals -> set this =1
	testl	%r14d, %r14d //if print occurrences == 0
	sete	%al //then set this = 1
	testb	%al, %dl //if al = 1 & print occ == 0 -> disp. matches
	jne	.Lmain_findAllOccurrences_displayMatches
	//only other case is if argc !=3 -> al= 0 & print occ == 0
	cmpl	$4, %ebx //if argc == 4
	jne	.Lmain_exitOnError_other
	//else: 
	movq	%r15, %rdi //move file handle into 1st arg
	movq	%r13, %rsi //move search string into 2nd arg
	movq	$0, %rdx //set print occ == 0 (3rd arg)
	call	find_all_occurrences
	movl	%eax, %edx //move number of occurrences ret by find all occ into 3rd arg of printf
	movq	$numOcc, %rsi
	movl	$1, %edi //number of args
	movl	$0, %eax //zero out ret val
	call	printf

.Lmain_closeFilePtr:
	movq	%rbp, %rdi
	call	fclose

.Lmain_setReturnValue0:
	movq	%r15, %rdi
	call	fclose
	movl	$0, %eax
	jmp .Lmain_alignStackAndRet

.Lmain_findAllOccurrences_displayMatches:
	movl	$1, %edx
	movq	%r13, %rsi
	movq	%r15, %rdi
	call	find_all_occurrences
	jmp	.Lmain_closeFilePtr

.Lmain_exitOnError_insufficientArgs:
	movq	$insufficientArgs, %rsi //move fmt str to first arg
	jmp .Lmain_printErrorMsg

.Lmain_exitOnError_tooManyArgs:
	movq	$tooManyArgs, %rsi
	jmp .Lmain_printErrorMsg

.Lmain_exitOnError_cantOpenFile:
	movq	$cannotOpenFile, %rsi
	jmp .Lmain_printErrorMsg

.Lmain_exitOnError_other:
	movq	$errorMsg, %rsi
	jmp .Lmain_printErrorMsg

.Lmain_printErrorMsg:
	movq	stderr(%rip), %rdi
	call	fprintf
	movl	$1, %eax

.Lmain_alignStackAndRet:
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq 	%r15
	addq 	$8, %rsi
	ret