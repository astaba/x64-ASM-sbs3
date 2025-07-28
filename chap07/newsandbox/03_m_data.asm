; x64ASM_sbs4/chap07/newsandbox/04_m_data.asm
section .note.GNU-stack noalloc noexec nowrite progbits

; TRICK: gdb displays EatMsg chars: x/13cb &EatMsg
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

  ; INFO: Memory data and effective address
  ; The size of the mov is decided by the size of the destination operand
  mov rdx,EatMsg         ; In assembly variables hold address not data.
  mov rdx,[EatMsg]       ; reads 'Eat at J' from memory into rdx
  mov al,[EatMsg]        ; reads 'Ea' from memory into rax
  mov eax,[EatMsg]       ; reads 'Eat ' from memory into rax
  mov byte [EatMsg],'G'  ; Immediate_data to -> the memory address of 1 byte
; Put your experiment between the two nops
  nop

  mov rax,60         ; Code for exit syscall
  mov rdi,0          ; Return a code of zero
  syscall            ; Make kernel call

section .bss

