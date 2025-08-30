; x64ASM_sbs4/chap12/charsin/sandbox.asm
; Created date    : Tue Aug 19 12:59:00 +01 2025
; Description     : A character input demo for Linux, build with NASM
;                 : using calls to scanf() for both string and number input.
;
; Build using these commands:
; nasm -f elf64 -g -F dwarf eatlibc.asm
; gcc eatlibc.o -o eatlibc -no-pie
;

SECTION .data
    Prompt_Age  db "Enter your age: ",0
    Prompt_Name db "Enter your name: ",0
    Scan_Age    db "%d",0
    Scan_Name   db " %19[^ ]%19s",0
    Pr_Age      db "Your age is: %d",0Ah,0
    Pr_Name     db "Your name is: %s %s",0Ah,0

SECTION .bss
    Age    resd 1
    Name   resb 20
    Surname   resb 20

SECTION .text
extern scanf
extern printf
extern getchar
global main

main:
    push rbp
    mov rbp,rsp

    mov rdi,Prompt_Age
    call printf

    mov rdi,Scan_Age
    mov rsi,Age
    call scanf

.clear_kb:           ; Flush stdin the right way
    call getchar
    cmp rax,0
    jz .kb_cleared
    cmp rax,10
    je .kb_cleared
    cmp rax,-1       ; EOF set by OS at stream depletion
    je .kb_cleared
    jmp .clear_kb
.kb_cleared:

    mov rdi,Prompt_Name
    call printf

    mov rdi,Scan_Name
    mov rsi,Name
    mov rdx,Surname
    call scanf

    mov rdi,Pr_Age
    mov esi,[Age]
    call printf

    mov rdi,Pr_Name
    mov rsi,Name
    mov rdx,Surname
    call printf

    xor rax,rax        ; return 0

    pop rbp
    ret


SECTION .note.GNU-stack
