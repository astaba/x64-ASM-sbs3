; x64ASM_sbs4/chap12/answer/answer.asm
; Listing 12.2
; TODO: Make some research about floating-points and vector registers

section .note.GNU-stack

section .data
    answermsg db "The answer is %d ... or is it %d? No! It's %#x!",10,0
    answernum dd 42

section .bss

section .text

extern  printf

global  main

main:
    push rbp            ; Prolog
    mov rbp,rsp

    mov rax,0           ; Count of floating point args..here, 0

    mov rdi,answermsg   ; Message/format string goes in RDI
    mov rsi,[answernum] ; Second arg in RSI
    mov rdx,43          ; Third arg in RDX. You can use a numeric literal
    mov rcx,42          ; Fourth arg in RCX. Show this one in hex
    mov rax,0           ; This tells printf no vector params are coming
    call printf         ; Call printf()

    mov rsp,rbp         ; Epilog
    pop rbp

    ret                 ; Return from main() to shutdown code
