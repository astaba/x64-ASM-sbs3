; x64ASM_sbs4/chap09/hexdump1gcc/bit-test.asm
; The nop (no operations) instructions force the debugger to stop when
; stem next, therefore preventing the program to run off the edge with
; segmentation fault for bad exit. Really handy for debugging session.

; NOTE: BT: but-test instruction
; Something to be careful of, especially if you’re used to using TEST, is that
; you are not creating a bit mask. With BT’s source operand you are specifying
; the ordinal number of a bit. The literal constant 4 shown in the previous code
; is the bit’s number, not the bit’s value, and that’s a crucial difference

section .note.GNU-stack

section .data

section .bss

section .text
    global main

main:
    push rbp
    mov rbp,rsp

    nop
    ; Put your experiment here
Loop:
    xor rax, rax
    mov rax, 16

    bt rax, 4
    jc Loop

    ; Put your experiment above
    nop
