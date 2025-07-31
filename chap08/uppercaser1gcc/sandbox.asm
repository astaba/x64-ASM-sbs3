; x64ASM_sbs4/chap08/uppercaser1gcc/sandbox.asm

section .note.GNU-stack

section .data

section .bss
    Buff resb 1

section .text
    global main

main:
    mov rbp, rsp

Read:
    mov rax, 0
    mov rdi, 0
    mov rsi, Buff
    mov rdx, 1
    syscall

    cmp rax, 0
    je Exit

    cmp byte [Buff], 061h
    jb Write
    cmp byte [Buff], 07ah
    ja Write

    sub byte [Buff], 020h

Write:
    mov rax, 1
    mov rdi, 1
    mov rsi, Buff
    mov rdx, 1
    syscall

    jmp Read

Exit:
    ret
