; x64ASM_sbs3/chap07/newsandbox/newsandbox.asm
; The nop (no operations) instructions force the debugger to stop when
; stem next, therefore preventing the program to run off the edge with
; segmentation fault for bad exit. Really handy for debugging session.
section .note.GNU-stack noalloc noexec nowrite progbits

section .data
section .text

global main

main:
  mov rbp, rsp        ;Save stack pointer for debugger
  nop
; Put your experiment between the two nops
; Put your experiment between the two nops
  nop                 ; CTRL-C from within GDB not to fall off the edge

section .bss

