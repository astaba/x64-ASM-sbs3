;  Source file     : x64ASM_sbs4/chap08/eastsyscall/eatsyscall.asm
;  Architecture    : x64
;  Syntax          : Intel
;  From            : x64 Assembly Language Step By Step, 4th Edition
;  Description     : demonstrating the use of the syscall instruction to display text.
;  Build commands  : nasm -f elf64 -g -F stabs eatsyscall.asm
;                    ld -o eatsyscall eatsyscall.o
;   WARNING: Not for use with SASM which requires main()
; ----------------------------------------------------------------------------------------

SECTION .note.GNU-stack noalloc noexec nowrite progbits ; Mark stack non-executable (security)

SECTION .data
    Msg: db "Eat at Joe's!",0x0A    ; The string to print followed by newline
    MsgLen: equ $ - Msg             ; Compute the length of the string

SECTION .bss                        ; No uninitialized data in this program

SECTION .text

global _start                       ; Make _start symbol visible to the linker

_start:
    ; Function prologue (for debugger's sake, though not required in bare syscalls)
    push    rbp                    ; Step 1: save old rbp value (from CPU) to the stack
    mov     rbp, rsp               ; Step 2: Overwrite rbp (in CPU) with current stack pointer
    ; Setup for write syscall: write(1, Msg, MsgLen)
    mov     rax, 1                 ; syscall number 1 = write
    mov     rdi, 1                 ; file descriptor: 1 = stdout
    mov     rsi, Msg               ; pointer to the string to write
    mov     rdx, MsgLen            ; length of the string
    syscall                        ; invoke kernel syscall
    ; Setup for exit syscall: exit(0)
    mov     rax, 60                ; syscall number 60 = exit
    mov     rdi, 0                 ; exit status code 0
    syscall                        ; invoke kernel syscall

