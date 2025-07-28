; x64ASM_sbs4/chap07/newsandbox/11_div.asm

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
; Page 203 Division:
; RAX and RDX: implicit operand respectively holding low and high order bytes
; of the dividend. When the dividend is small enough to fit in RAX make sure
; to zero out RDX to avoid code crash from SIGFPE (Arithmetic exception)
; After running: div r/m8-64
; RAX holds the quotient
; RDX holds the remainder

  mov rax,0          ; Dividend,try: 250, 247
  xor rdx,rdx        ; Clear RDX (upper part of dividend)
  mov rbx,17         ; Divisor try: 5, 17 and O to see SIGFPE (Arithmetic exception)
  div rbx            ; Does not allow immediate data

; Put your experiment between the two nops
  nop                ; CTRL-C from within GDB not to fall off the edge

section .bss

