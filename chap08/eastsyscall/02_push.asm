; ./chap08/eastsyscall/02_push.asm

; HACK: After pushing values to the stack start examining it with the following
; command to have a clear vue of the precise way individual data are piled
; downward in upward little endian order for each data.
; x/2xh <rsp value> : display 2 times in hexadecimal(x) halfwords(h:16-bits)
; x/4xb <rsp value> : display 4 times in hexadecimal(x) onebytes(b:8-bits)
; x/3xh <rsp new value>
; x/6xb <rsp new value>

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

  xor rax, rax      ; First zero out all 4 64-bit general-purpose registers
  xor rbx, rbx      ; so that there are no leftovers in the high bits
  xor rcx, rcx
  xor rdx, rdx

  mov ax, 01234h    ; Place values in AX, BX ans CX
  mov bx, 04ba7h
  mov cx, 0ff17h

  push ax           ; Place values in AX, BX ans CX
  push bx
  push cx           ; Examine the stack with

  pop dx            ; Pop the top of the stack into DX

  nop
