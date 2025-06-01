; x64ASM_sbs4/chap07/newsandbox/02_i_data.asm
section .note.GNU-stack noalloc noexec nowrite progbits

section .data
section .text

global main

main:
  mov rbp,rsp        ; Save stack pointer for debugger
  nop
; Put your experiment between the two nops
  ; NASM allows for some character strings as immediate data.
  ; Since rax is a number register the string is addressed as a number
  ; and read in little endian order:
  ; smallest memory addresses are bearers of least significant bits.
  ; So right before moving (copying) it to the register this immediate data
  ; is turned into number on little endian basis.
  mov eax,'WXYZ'
; Put your experiment between the two nops
  nop

  mov rax,60         ; Code for exit syscall
  mov rdi,0          ; Return a code of zero
  syscall            ; Make kernel call

section .bss

