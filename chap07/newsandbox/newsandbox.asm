; x64ASM_sbs4/chap07/newsandbox/newsandbox.asm
; Listing 7.1

; 1. The nop (no operations) instructions force the debugger to stop when
;    stem next, therefore preventing the program to run off the edge with
;    segmentation fault for bad exit. Really handy for debugging session.
; 2. In modern systems, making the stack non-executable is a security
;    best practice (prevents exploits like stack-based shellcode).
;    The .note.GNU-stack section is a marker added by assemblers to say,
;    "this code doesn't need an executable stack."

section .note.GNU-stack noalloc noexec nowrite progbits

section .data

section .text
global main

main:
    mov rbp, rsp ;Save stack pointer for SASM debugger
    nop
; Put your experiments between the two nops..

; Put your experiments between the two nops...
    nop

    section .bss
