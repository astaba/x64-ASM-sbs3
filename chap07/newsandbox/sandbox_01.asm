; x64ASM_sbs3/chap07/newsandbox/newsandbox.asm
; The last syscall enable graceful exit when you run off the last nop.
section .note.GNU-stack noalloc noexec nowrite progbits

section .data
section .text

global main

main:
  mov rbp, rsp        ;Save stack pointer for debugger
  nop
; Put your experiment between the two nops
; Put your experiment between the two nops
  nop

  mov rax, 60         ; Code for exit syscall
  mov rdi, 0          ; Return a code of zero
  syscall

section .bss

