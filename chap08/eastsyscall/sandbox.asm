; x64ASM_sbs4/chap08/eastsyscall/sandbox.asm

; Remember that the MOV instruction will not operate on the RFlags register.
; If you want to load a copy of RFlags into a 64-bit register,
; you must first push RFlags onto the stack with PUSHFQ and then
; pop the flags value off the stack into the register of your choice with POP.
; Getting RFlags into RBX is thus done with the following code

; After pushing the RFlags onto the stack start examining with
; x/tg <rsp value> : display 1 time in binary(t) quadword(g:64-bits)

SECTION .note.GNU-stack

SECTION .data

SECTION .bss

SECTION .text

global _start

_start:

  push rbp
  mov rbp,rsp

  nop
  ; Put your experiment here

  xor rbx, rbx        ; clear RBX first
  pushfq              ; Push the RFLAGS onto the stack
  pop qword rbx       ; ... and pop immediately into RBX

  nop
