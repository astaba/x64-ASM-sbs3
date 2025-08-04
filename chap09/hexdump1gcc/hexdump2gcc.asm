; Source file   : x64ASM_sbs4/chap09/hexdump1gcc/hexdump2gcc.asm
; Created       : Fri Aug  1 12:00:00 +01 2025
; Version       : 3.0
; Description   : A simple program in assembly for Linux, using NASM,
;                 demonstrating the conversion of binary values to hexadecimal
;                 strings. It acts as a very simple hex dump utility for files,
;                 without the ASCII equivalent column.
; Usage         : hexdump2gcc.out < (input file)
; Build commands: nasm -f elf64 -g -F stabs eatsyscall.asm
; NOTE: Improvement:
; * Fixed bug with test condition at the end of Scan for{}loop that caused
;   one iteration too many, goes out of bound and corrupt the look up table:
;   replacing jna with jb
; * Print nybbles to HexStr upwards (memory-wise)
; ------------------------------------------------------------------------------
; TODO: error handling

SECTION .note.GNU-stack noalloc noexec nowrite progbits

BUFFSIZE equ 0x10

SECTION .data
    ; NOTE: For every single input byte will be output 3 bytes:
    ; 1st: the space character
    ; 2nd: the character for the most significant nybble (high half byte)
    ; 3rd: the character for the least significant nybble (low half byte)
    HexStr: times BUFFSIZE db " 00"
    db 0x0A
    HEXLEN equ $ - HexStr

    MSN_OFF equ 1    ; Most Significant Nybble (MSN)  offset in HexStr pattern.
    LSN_OFF equ 2    ; Least Significant Nybble (LSN)  offset in HexStr pattern.

    ; NOTE: USING A LOOKUP TABLE
    ; The trick is that each character offset is the exact hexa
    ; representation the character holds, as a result from the initial
    ; pointer add the character binary nybble and you point right on it.
    LookupTable: db "0123456789ABCDEF"

SECTION .bss
    Buffer: resb BUFFSIZE

SECTION .text
global main

main:
    ; mov rbp, rsp        ;Save stack pointer for debugger in SAMS editor.

; Read from input stream until EOF
Read_While:
    ; read(0, &Buffer, BUFFSIZE)
    mov rax, 0                              ; sys_read ID: 0
    mov rdi, 0                              ; arg1: stdin file descriptor
    mov rsi, Buffer                         ; arg2: input buffer
    mov rdx, BUFFSIZE                       ; arg3: read buffer size
    syscall                                 ; invoke kernel
    ; if (rax == 0) goto Done
    cmp rax, 0                              ; check if EOF (syscall returned 0)
    jz Done                                 ; if so, exit(0) otherwise save

    ; Initialize for{}loop variables
    mov r15, rax                            ; stash #char read for loop test
    mov rsi, Buffer                         ; Re-initialize volatile register
    xor rcx, rcx                            ; Zero out loop counter

; Iterate until Buffer is depleted: for(rcx = 0; rcx < r15; rcx++)
Scan_for:
    ; Initialize iteration variables
    xor rax, rax                            ; Clear container for current char
    mov rdx, rcx                            ; keep input Buffer pointer and
    lea rdx, [rdx*3]                        ; Hexstr's in sync ; by 1/3 ratio
    ; Get one-byte character from input buffer and stash it
    mov al, byte [rsi + rcx]                ; Get one character from buffer
    mov rbx, rax                            ; Save the byte MSN late processing
    ; Tanslate the Most Significant Nybble (MSN) of the character
    shr al, 4                               ; Dump the LSN on the right
    mov al, byte [LookupTable + rax]        ; Get the MSN hexa translation
    mov byte [HexStr + rdx + MSN_OFF], al   ; Write MSN translation to HexStr
    ; Tanslate the Least Significant Nybble (LSN) of the character
    and bl, 0b00001111                      ; Mask the MSN
    mov bl, byte [LookupTable + rbx]        ; Get the LSN hexa translation
    mov byte [HexStr + rdx + LSN_OFF], bl   ; Write LSN translation to HexStr
    ; Now keep tally, update loop variables and test the condition.
    inc rcx                                 ; Keep iterations tally (pointers)
    cmp rcx, r15                            ; if (rcx < r15) goto Scan_for
    jb Scan_for                             ; Otherwise ...

    ; write(1, &HexStr, HEXLEN)
    mov rax, 1                              ; sys_write ID
    mov rdi, 1                              ; arg_01: stdout file descriptor
    mov rsi, HexStr                         ; arg_02: destination pointer
    mov rdx, HEXLEN                         ; arg_03: write byte num
    syscall                                 ; invoke kernel
    ; Loop back to input stream
    jmp Read_While

Done:
    ; exit(0)
    mov rax, 60                             ; sys_exit ID
    mov rdi, 0                              ; arg_01: exit status
    syscall                                 ; invoke kernel
