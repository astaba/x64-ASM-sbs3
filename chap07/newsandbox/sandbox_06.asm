; x64ASM_sbs3/chap07/newsandbox/newsandbox.asm

; In modern systems, making the stack non-executable is a security
; best practice (prevents exploits like stack-based shellcode).
; The .note.GNU-stack section is a marker added by assemblers to say,
; "this code doesn't need an executable stack."

section .note.GNU-stack noalloc noexec nowrite progbits

section .data

section .text

global main

main:
  mov rbp,rsp        ; Save stack pointer for debugger
  nop
; Put your experiment between the two nops

  ; Labels are descriptive names given to locations in your programs.
  ; Here the label DoMore enable a loop.
  mov rax,5
  DoMore: dec rax
  jnz DoMore

; Put your experiment between the two nops
  nop                ; CTRL-C from within GDB not to fall off the edge

section .bss

