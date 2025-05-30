; x64ASM_sbs3/chap07/newsandbox/newsandbox.asm
section .note.GNU-stack noalloc noexec nowrite progbits

section .data
  EatMsg: db "Eat at Joe's!"
section .text

global main

main:
  mov rbp,rsp        ; Save stack pointer for debugger
  nop
; Put your experiment between the two nops
  xor rax,rax
  xor rdx,rdx

  ; Memory data and effective address
  mov rdx,[EatMsg]
  mov al,[EatMsg]
  mov byte [EatMsg],'G'
; Put your experiment between the two nops
  nop

  mov rax,60         ; Code for exit syscall
  mov rdi,0          ; Return a code of zero
  syscall            ; Make kernel call

section .bss

