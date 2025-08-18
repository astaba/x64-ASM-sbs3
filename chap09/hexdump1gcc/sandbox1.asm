; x64ASM_sbs4/chap07/newsandbox/sandbox.asm
; The nop (no operations) instructions force the debugger to stop when
; stem next, therefore preventing the program to run off the edge with
; segmentation fault for bad exit. Really handy for debugging session.

BUFFSIZE equ 010h
MSN_OFF equ 1       ; Most Significant Nybble Offset in "␣XX" Hexstr pattern
LSN_OFF equ 2       ; Least Significant Nybble Offset in "␣XX" Hexstr pattern

section .note.GNU-stack

section .data
    HexStr: times BUFFSIZE db " XX"
    db 0ah
    LookUpTable: db "0123456789ABCDEF"

section .bss
    Buffer: resb BUFFSIZE

section .text
    global main

main:
    mov rbp, rsp

Read_While_1:
    mov rax, 0         ; Invoque sys_read
    mov rdi, 0         ; arg#1: stdin fd 0
    mov rsi, Buffer    ; arg#2: destination pointer
    mov rdx, BUFFSIZE  ; arg#3: reading size
    syscall            ; invoque kernel

    cmp rax, 0         ; Test if stdin is depleted
    je Done            ; Exit with success

    ; Initialize for{}loop variables
    mov r15, rax       ; Save sys_read return #of char for for{}loop test
    mov rsi, Buffer    ; Re-initialize callee-clobbered register
    xor rcx, rcx       ; Initialize loop counter

Scan_for:
    ; Update iteration variables
    xor rax, rax       ; Clear char container
    mov rdx, rcx       ; Keep HexStr offset in sync with Buffer tracker
    lea rdx, [rdx*3]   ; Since for +1 in Buffer => +3 in HexStr
    ; Retrieve one char from Buffer and stash it to RAX and RBX
    mov al, byte [rsi + rcx]
    mov rbx, rax       ; And duplicate it for second half nybble
    ; Translate MSN
    shr al, 4
    mov al, byte [LookUpTable + rax]
    mov byte [HexStr + rdx + MSN_OFF], al
    ; Translate LSN
    and bl, 00001111b
    mov bl, byte [LookUpTable + rbx]
    mov byte [HexStr + rdx + LSN_OFF], bl
    ; Test for{}loop condition
    inc rcx            ; Update counter
    cmp rcx, r15
    jb Scan_for        ; Loop again if rcx < r15

    ; Otherwise write to stdout
    mov rax, 1                    ; Invoque sys_write
    mov rdi, 1                    ; arg#1: stdout fd 1
    mov rsi, HexStr               ; arg#2: destination pointer
    add rdx, 3                    ; Account for last iteration
    mov byte [HexStr + rdx], 0ah  ; Append new line char
    inc rdx                       ; Account for new line char
    syscall                       ; invoque kernel

    jmp Read_While_1

Done:
    mov rax, 60        ; Invoque sys_exit
    mov rdi, 0         ; arg#1: exit status 0
    syscall            ; invoque kernel
