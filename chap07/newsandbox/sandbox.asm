; x64ASM_sbs4/chap07/newsandbox/sandbox.asm
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
  mov rbp, rsp        ; Unless debugging in gdb save stack pointer IDE debugger
  nop
; Put your experiment between the two nops

; Put your experiment between the two nops
  nop                 ; CTRL-C from within GDB not to fall off the edge

  mov rax ,60         ; Code for exit syscall
  mov rdi,0           ; Return a code of zero
  syscall             ; Make kernel call
