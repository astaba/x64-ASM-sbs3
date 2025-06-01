; x64ASM_sbs4/chap08/uppercaser1gcc/sandbox.asm
; ------------------------------------------------------------------------------
; Source file   : x64ASM_sbs4/chap08/uppercaser1gcc/sandbox.asm
; Version       : 1.0
; Description   : demonstrating simple text file I/O (through redirection) for
;                 reading an input file to a buffer in blocks, forcing lowercase
;                 characters to uppercase, and writing the modified buffer to an
;                 output file.
; Usage         : uppercaser2 > (output file) < (input file)
; Build commands: nasm -f elf64 -g -F stabs eatsyscall.asm
; NOTE: Process input one char at a time in reverse order from last one to first
; one making a syscall for each char. Need improvement
; ------------------------------------------------------------------------------
section .note.GNU-stack

section .data

section .bss
    Buff resb 1                 ; Reserve 1 byte in uninitialized data section
                                ; for input character

section .text
    global main

main:
    mov rbp, rsp               ; Set up base pointer (for debugging purposes)

Read:
    ; read(0, &Buff, 1)
    mov rax, 0                 ; syscall ID: 0 (sys_read)
    mov rdi, 0                 ; arg_01: 0 (stdin file descriptor)
    mov rsi, Buff              ; arg_02: Buff (address of buffer)
    mov rdx, 1                 ; arg_03: 1 (read 1 byte)
    syscall                    ; invoke kernel
    ; if (rax == 0) goto Exit;
    cmp rax, 0                 ; check if EOF (syscall returned 0)
    je Exit                    ; if so, exit program

    ; if (Buff < 'a') goto Write;
    cmp byte [Buff], 061h      ; compare with ASCII 'a'
    jb Write                   ; jump if below (i.e., not lowercase)
    ; if (Buff > 'z') goto Write;
    cmp byte [Buff], 07Ah      ; compare with ASCII 'z'
    ja Write                   ; jump if above (i.e., not lowercase)

    ; Buff = Buff - 0x20;  // convert lowercase to uppercase
    sub byte [Buff], 020h      ; convert ASCII lowercase to uppercase

Write:
    ; write(1, &Buff, 1)
    mov rax, 1                 ; syscall ID: 1 (sys_write)
    mov rdi, 1                 ; arg_01: 1 (stdout file descriptor)
    mov rsi, Buff              ; arg_02: Buff (address of character to write)
    mov rdx, 1                 ; arg_03: 1 (write 1 byte)
    syscall                    ; invoke kernel

    jmp Read                   ; loop back to read next character

Exit:
    ret                        ; return from main (end program)
