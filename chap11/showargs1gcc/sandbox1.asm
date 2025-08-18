; x64ASM_sbs4/chap11/showargs1gcc/sandbox.asm
; Because of the preset routines derived from the main function and provided
; by glibc, at run time all command line arguments are stored on the stack and
; accessible through RSI which holds an memory address to a table of memory
; addresses and RDI which holds the number of arguments. This program attempt
; to retrieve those command line arguments and send them to stdout.

MAXARGS equ 5          ; command string + 4 arguments string

section .note.GNU-stack noalloc noexec nowrite progbits

section .data
    ErrorMsg db "Error: at most four arguments allowed",0Ah
    ERRORLEN equ $-ErrorMsg
    ErrArg db "Error: stack arguments fault",0Ah
    ERRARGLEN equ $-ErrArg

section .bss

section .text

global main

main:

    mov r14,rsi
    mov r15,rdi

    cmp r15,MAXARGS
    ja BadArgNmb

    ; init retrieve-arguments loop counter which is also the index reference
    xor rbx,rbx            ; within the address table (the array of pointers)
.getArg:
    ; init REPNE implicit operands
    mov rcx,0000FFFFh      ; roof SCASB scan repetitions to 65535
    ; init SCASB implicit operands
    xor rax,rax            ; Set SCASB comparision byte to AL == 0
    mov rdi,qword[r14+rbx*8] ; Dereference and load the 8-byte pointer value
    ; save string-head for string length computation
    mov rdx,rdi              ; before SCASB takes RDI to the other end

    cld                    ; make SCASB searches memory up by clearing the DF
    repne scasb            ; scan string bytes until byte == '\0' = 0
    ; make sure in the event REPNE stopped because of RCX == 0 it happened
    ; on the very iteration SCASB compared AL with the researched '\0'.
    ; Otherwise something is broken with those arguments on the stack.
    jne BabCode

    mov byte[rdi-1],0Ah
    sub rdi,rdx
    mov r13,rdi

    mov rax,1
    mov rdi,1
    mov rsi,rdx
    mov rdx,r13
    syscall

    inc rbx
    cmp r15,rbx
    ja .getArg
    jmp Exit

BadArgNmb:
    mov rax,1
    mov rdi,2
    mov rsi,ErrorMsg
    mov rdx,ERRORLEN
    syscall
    jmp Exit

BabCode:
    mov rax,1
    mov rdi,2
    mov rsi,ErrArg
    mov rdx,ERRARGLEN
    syscall
    jmp Exit

Exit:
    ret
