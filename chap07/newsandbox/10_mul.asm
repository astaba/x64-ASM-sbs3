; x64ASM_sbs4/chap07/newsandbox/10_mul.asm

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
; Multiplication with implicit operand

  ; mov eax,447
  ; mov ebx,1739
  ; mul ebx

  mov eax,0xFFFFFFFF
  mov ebx,0x3B72
  mul ebx


; Put your experiment between the two nops
  nop                ; CTRL-C from within GDB not to fall off the edge

section .bss

