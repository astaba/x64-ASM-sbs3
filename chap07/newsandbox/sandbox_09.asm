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

; Moving 1 byte signed value into a bigger register and loosing the signed bit
  ; xor rax,rax

  mov ax,-42         ; loads 0xFFD6 because AX is 16-bit (not 8-bit).
  ; mov ebx,eax       ; moves the value, but doesn't sign-extend it,
                     ; causing unexpected behavior.
  movsx rbx,ax

; Put your experiment between the two nops
  nop                ; CTRL-C from within GDB not to fall off the edge

section .bss

