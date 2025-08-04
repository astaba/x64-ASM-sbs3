; x64ASM_sbs4/chap09/xlat1gcc/my_xlat.asm
; Version         : 2.0
; Created date    : Mon Aug  4 18:45:20 +01 2025
; Author          : Youta Jerome
; Description     : A simple program in assembly for Linux, using NASM
;                 : demonstrating the XLAT instruction to translate characters
;                 : using translation tables.

; Run it either in SASM or using this command in the Linux terminal:
; xlat1gcc < input file > output file

SECTION .note.GNU-stack

SECTION .data
    StartMsg: db "Processing >>>",0Ah
    StartLen equ $-StartMsg
    EndMsg: db 0Ah,"<<< Complete",0Ah
    EndLen equ $-EndMsg

; The following translation table translates all lowercase characters
; to uppercase. It also translates all non-printable characters to
; spaces, except for LF and HT. This is the table used by default in
; this program.
    UpCase:
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,09h,0Ah,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,21h,22h,23h,24h,25h,26h,27h,28h,29h,2Ah,2Bh,2Ch,2Dh,2Eh,2Fh
    db 30h,31h,32h,33h,34h,35h,36h,37h,38h,39h,3Ah,3Bh,3Ch,3Dh,3Eh,3Fh
    db 40h,41h,42h,43h,44h,45h,46h,47h,48h,49h,4Ah,4Bh,4Ch,4Dh,4Eh,4Fh
    db 50h,51h,52h,53h,54h,55h,56h,57h,58h,59h,5Ah,5Bh,5Ch,5Dh,5Eh,5Fh
    db 60h,41h,42h,43h,44h,45h,46h,47h,48h,49h,4Ah,4Bh,4Ch,4Dh,4Eh,4Fh
    db 50h,51h,52h,53h,54h,55h,56h,57h,58h,59h,5Ah,7Bh,7Ch,7Dh,7Eh,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h

; The following translation table is "stock" in that it translates all
; printable characters as themselves, and converts all non-printable
; characters to spaces except for LF and HT. You can modify this to
; translate anything you want to any character you want. To use it,
; replace the default table name (UpCase) with Custom in the code below.
    Custom:
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,09h,0Ah,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,21h,22h,23h,24h,25h,26h,27h,28h,29h,2Ah,2Bh,2Ch,2Dh,2Eh,2Fh
    db 30h,31h,32h,33h,34h,35h,36h,37h,38h,39h,3Ah,3Bh,3Ch,3Dh,3Eh,3Fh
    db 40h,41h,42h,43h,44h,45h,46h,47h,48h,49h,4Ah,4Bh,4Ch,4Dh,4Eh,4Fh
    db 50h,51h,52h,53h,54h,55h,56h,57h,58h,59h,5Ah,5Bh,5Ch,5Dh,5Eh,5Fh
    db 60h,61h,62h,63h,64h,65h,66h,67h,68h,69h,6Ah,6Bh,6Ch,6Dh,6Eh,6Fh
    db 70h,71h,72h,73h,74h,75h,76h,77h,78h,79h,7Ah,7Bh,7Ch,7Dh,7Eh,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h

SECTION .bss
    BUFFSIZE equ 400h
    Buffer resb BUFFSIZE

SECTION .text
    global main

main:
    mov rbp,rsp
    ; Display starting message
    mov rax, 1             ; load sys_write ID
    mov rdi, 1             ; On stdout fd 1
    mov rsi, StartMsg      ; At
    mov rdx, StartLen      ; # char
    syscall                ; invoke kernel

Read:
    mov rax, 0             ; load sys_read ID
    mov rdi, 0             ; On stdin fd 0
    mov rsi, Buffer        ; At Buffer
    mov rdx, BUFFSIZE      ; # char
    syscall                ; invoke kernel

    cmp rax, 0             ; check if stdin is depleted
    je Exit

    mov r12, rax           ; Stash sys_read return value
    mov rsi, Buffer        ; Re-init callee-clobbered register
    xor rcx, rcx           ; init loop counter
    mov rbx, UpCase        ; load XLAT implicit operand

Translate:
    xor rax, rax
    mov al, byte [rsi+rcx] ; Load character as XLAT 2nd implicit operand
    xlat
    mov byte [rsi+rcx], al
    inc rcx                ; Update loop counter
    cmp rcx, r12
    jb Translate           ; If RCX < R12 then Translate loops again

; Write translation to stdout
    mov rax, 1             ; load sys_write ID
    mov rdi, 1             ; On stdout fd 1
    mov rsi, Buffer        ; At Buffer
    mov rdx, r12           ; # char
    syscall                ; invoke kernel
    jmp Read

Exit:
    ; Display end message
    mov rax, 1             ; load sys_write ID
    mov rdi, 1             ; On stdout fd 1
    mov rsi, EndMsg        ; At
    mov rdx, EndLen        ; # char
    syscall                ; invoke kernel
    ; exit
    mov rax, 60            ; load sys_exit ID
    mov rdi, 0             ; exit status 0
    syscall                ; invoke kernel

