; x64ASM_sbs4/chap11/showchargcc/sandbox1.asm
;
;  Description     : A simple program in assembly for Linux,
;    demonstrating discontinuous string writes to memory using STOSB without
;    REP. The program loops through characters 32 through 255 and writes a
;    simple "ASCII chart" in a display buffer. The chart consists of 8 lines
;    of 32 characters, with the lines not continuous in memory.
;
;  Build using the standard SASM x64 build lines
;  Link:      gcc source.o -o source.out
;  Compile:   nasm -f elf64 -g -F dwarf source.asm -l source.lst
;

COLS     equ 81
ROWS     equ 25
FILLBUFF equ 20h
EOL      equ 0Ah
CHARTOFF equ 2           ; ASCII chart first line offset (0-based)
CHARTLEN equ 32          ; ASCII chart line length
CHARTSIZ equ 224         ; ASCII chart total characters numbers
section .note.GNU-stack noalloc noexec nowrite progbits

section .data
    ClearStr db 27,"[2J",27,"[01;01H"
    CLEARLEN equ $-ClearStr
    RulerStr db "12345678901234567890123456789012345678901234567890123456789012345678901234567890"
    RULERLEN equ $-RulerStr

section .bss
    VidBuff resb COLS*ROWS

section .text
global main

;-------------------------------------------------------------------------------
ClearHome:
    push rsi
    push rdx

    mov rsi,ClearStr    ; load sys_write agr#2
    mov rdx,CLEARLEN    ; load sys_write agr#3
    call SendtoShell

    pop rdx
    pop rsi
    ret

;-------------------------------------------------------------------------------
Display:
    push rsi
    push rdx

    mov rsi,VidBuff      ; load sys_write agr#2
    mov rdx,COLS*ROWS    ; load sys_write agr#3
    call SendtoShell

    pop rdx
    pop rsi
    ret

;-------------------------------------------------------------------------------
SendtoShell:
    push rax
    push rdi
    push r11
    push rcx

    mov rax,1       ; load sys_write ID
    mov rdi,1       ; load agr#1: source fd 1 stdout
    syscall         ; invoke kernel

    pop rcx
    pop r11
    pop rdi
    pop rax
    ret

;-------------------------------------------------------------------------------
ResetVidBuff:
    push rdi
    push rax
    push rcx

    cld
    mov rdi,VidBuff
    mov al,FILLBUFF
    mov rcx,COLS*ROWS
    rep stosb

    mov rdi,VidBuff
    dec rdi
    mov rcx,ROWS
.putEOL:
    add rdi,COLS
    mov byte[rdi],EOL
    loop .putEOL

    pop rcx
    pop rax
    pop rdi
    ret

;-------------------------------------------------------------------------------
Ruler:
    push rdi
    push rsi

    mov rdi,VidBuff
    dec rax
    dec rbx
    mov ah,COLS
    mul ah
    add rdi,rax
    add rdi,rbx
    mov rsi,RulerStr
.putChar:
    mov al,[rsi]
    stosb
    inc rsi
    loop .putChar

    pop rsi
    pop rdi
    ret

;-------------------------------------------------------------------------------
main:
    mov rbp,rsp

    call ClearHome
    call ResetVidBuff

    mov rax,1     ; cursor Y position (1-based)
    mov rbx,1     ; cursor X position (1-based)
    mov rcx,64    ; byte # to print on VidBuff
    call Ruler

    mov rdi,VidBuff
    add rdi,COLS*CHARTOFF
    mov rcx,CHARTSIZ
    mov al,20h     ; Start ASCII chart with Space char
.loop1:
    mov bl,CHARTLEN
.loop2:
    stosb
    jrcxz .show
    inc al
    dec bl
    loopnz .loop2
    add rdi,COLS-CHARTLEN
    jmp .loop1

.show:
    call Display
Exit:
    ret
