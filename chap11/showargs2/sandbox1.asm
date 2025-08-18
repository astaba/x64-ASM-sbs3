; x64ASM_sbs4/chap11/showargs2/sandbox1.asm
; Created date : Mon Aug 18 00:31:42 +01 2025
; Description  : A simple program in assembly for Linux, using NASM,
;                demonstrating the way to access command line arguments on
;                the stack. This version accesses the stack "nondestructively"
;                by using memory references calculated from RBP rather than
;                POP instructions.
;
; ld -o source.out -g source.o
; nasm -f elf64 -g -F dwarf source.asm -l source.lst
;

MAXARGS equ 10

section .data
    ErrMsg  db "Error: only 9 arguments allowed.",0Ah
    ERRLEN  equ $ - ErrMsg
    ErrInit db "Terminates with error.",0Ah
    ERRILEN equ $ - ErrMsg

section .bss
    ArgLens resq MAXARGS

section .text
global _start

_start:
    push rbp               ; Stack alignment prolog
    mov rbp,rsp
    and rsp,-16
    ; Get argc from the stack and check <= MAXARGS
    mov r13,[rbp+8]
    cmp r13,MAXARGS
    ja ErrorArg

    ; NOTE: RBX is a 1-based counter to the push from the prolog and
    ; rightly index arguments down the stack (up memory)
    mov rbx,1              ; init next loop counter
    xor rax,rax            ; init SCASB impl operand: compare target
.fetchLengths:
    mov rdi,[rbp+rbx*8+8]  ; init SCASB impl operand: string to scan
    mov rdx,rdi            ; Stash string head for length calculation
    mov rcx,0FFh           ; init REPNE impl operand: repetition count

    cld                    ; Set search direction to memory up
    repne scasb            ; Search for AL (null) in string at RDI
    jne ErrorInit          ; Make sure ZF==1 when REPNE breaks

    mov byte[rdi-1],0Ah
    sub rdi,rdx
    ; NOTE: Since ArgLens is 0-based indexable and RBX is 1-based,
    ; -8 displacement counteracts index*scale and rebases RBX to 0
    mov qword[ArgLens+rbx*8-8],rdi
    ; Make loop house-keeping based on argc
    inc rbx
    cmp rbx,r13
    jbe .fetchLengths

    mov rbx,1
.showArgs:
    mov rax,1
    mov rdi,1
    mov rsi,[rbp+rbx*8+8]
    mov rdx,[ArgLens+rbx*8-8]
    syscall
    ; Make loop house-keeping based on argc
    inc rbx
    cmp rbx,r13
    jbe .showArgs
    jmp Exit

ErrorArg:
    mov rax,1
    mov rdi,2
    mov rsi,ErrMsg
    mov rdx,ERRLEN
    syscall
    jmp Exit

ErrorInit:
    mov rax,1
    mov rdi,2
    mov rsi,ErrInit
    mov rdx,ERRILEN
    syscall
    jmp Exit

Exit:
    mov rsp,rbp
    pop rbp

    mov rax,60
    mov rdi,0
    syscall
