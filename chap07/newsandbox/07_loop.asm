; x64ASM_sbs4/chap07/newsandbox/07_loop.asm

; In modern systems, making the stack non-executable is a security
; best practice (prevents exploits like stack-based shellcode).
; The .note.GNU-stack section is a marker added by assemblers to say,
; "this code doesn't need an executable stack."

section .note.GNU-stack noalloc noexec nowrite progbits

section .data
  ; To track it down the memory from within gdb: x/s &Snippet
  Snippet db "KANGAROO"

section .text

global main

main:
  mov rbp,rsp        ; Save stack pointer for debugger

  nop
; Put your experiment between the two nops

  mov rbx,Snippet
  mov rax,8
DoMore: add byte [rbx],0x20
  inc rbx
  dec rax
  jnz DoMore

; Put your experiment between the two nops
  nop                ; CTRL-C from within GDB not to fall off the edge

section .bss

