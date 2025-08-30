; x64ASM_sbs4/chap12/showargs3/sandbox1.asm
; Created date : Fri Aug 22 19:11:05 +01 2025
; Description  : Demonstrate how glibc the System V ABI arguments standards
; to passe command line arguments to the main procedure (function in C)

[SECTION .data]           ; Section for initialized data
	Str_Arg db "Argument %d: %s",0Ah,0

[SECTION .bss]            ; Section for uninitialized data

[SECTION .text]           ; Section for executable code
	global main           ; Make 'main' visible to the linker
	extern printf         ; Declare 'printf' as an external function

main:
	push rbp              ; Save old base pointer
	mov rbp, rsp          ; Set up new stack frame

	mov r14, rdi          ; Store argument count (argc) in R14
	mov r13, rsi          ; Store argument array pointer (argv) in R13

	xor r12, r12          ; Loop counter and argument index (0-based)
.dowhile:
	mov rdi, Str_Arg      ; Arg 1 (format string)
	mov rsi, r12          ; Arg 2 (loop index)
	mov rdx, [r13+r12*8]  ; Arg 3 (current argument string)
	call printf           ; Call printf to display

	inc r12               ; Increment index
	dec r14               ; Decrement count
	jnz .dowhile          ; Repeat if count is not zero

	xor rax, rax          ; Return 0

	mov rsp, rbp          ; Restore stack pointer
	pop rbp               ; Restore old base pointer
	ret                   ; Return from main

; A marker that tells the linker the stack is executable,
[SECTION .note.GNU-stack] ;not typically needed in modern systems but still used.
