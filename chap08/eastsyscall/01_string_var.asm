; x64ASM_sbs4/chap08/eastsyscall/01_string_var.asm

SECTION .note.GNU-stack

SECTION .data
	Msg: db "This is it",0Ah, "Let's si of it works",10
	WordString:		dw 'CQ'
	DoubleString:	dd 'Stop'
	QuadString:		dq 'KANGAROO',00h
	MsgLen equ $ - Msg     ; $: source address
                         ; So, MsgLen just holds the difference (-) of two memory locations

SECTION .bss

SECTION .text

global _start

_start:

	push rbp
	mov rbp,rsp

	nop

	mov ax,[WordString]
	mov eax,[DoubleString]
	mov rax,[QuadString]

	nop
