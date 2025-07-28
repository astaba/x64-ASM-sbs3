; x64ASM_sbs4/chap07/newsandbox/03_r_data.asm
section .note.GNU-stack noalloc noexec nowrite progbits

section .data
section .text

global main

main:
  mov rbp,rsp        ; Save stack pointer for debugger
  nop
; Put your experiment between the two nops
  ; EAX is part of RAX, AX is part of EAX, and CL is part of ECX, etc.
  ; Anything you place in RAX is already in EAX, AX, and AL.
  xor rbx,rbx
  xor rcx,rcx

  mov rax,067FEh
  mov rbx,rax
  mov cl,bh
  mov ch,bl
  ; The XCHG instruction exchanges the values contained in its two operands.
  xchg cl,ch
; Put your experiment between the two nops
  nop

  mov rax,60         ; Code for exit syscall
  mov rdi,0          ; Return a code of zero
  syscall            ; Make kernel call

section .bss

