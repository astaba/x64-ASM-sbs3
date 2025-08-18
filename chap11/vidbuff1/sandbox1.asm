; x64ASM_sbs4/chap11/vidbuff1/sandbox.asm
;  Description     : A simple program in assembly for Linux, using NASM
;                  : demonstrating string instruction operation by "faking"
;                  : full-screen memory-mapped text I/O.
;
;    Note that the output to the console from this program will NOT display
;    correctly unless you have enabled the "Code page 437" character encoding
;    in the terminal program being used to display the console!
;
;  Link:      ld source.o -o source.out
;  Compile:   nasm -f elf64 -g -F dwarf source.asm -l source.lst
;

    COLS     equ 81        ; VidBuff width
    ROWS     equ 25        ; VidBuff height
    FillBuff equ 20h       ; ASCII space char to clear VidBuff lines
    EOL      equ 0Ah       ; ASCII newline char to terminate VidBuff lines
    FillData equ 2dh       ; ASCII dash char to populate dataset lines

section .note.GNU-stack noalloc noexec nowrite progbits

section .data
    ClearStr db 27,"[2J",27,"[01;01H"
    CLEARLEN equ $ - ClearStr
    RulerStr db "12345678901234567890123456789012345678901234567890123456789012345678901234567890"
    RULERLEN equ $ - RulerStr
    Message  db "Wed Aug 13 06:35:32 +01 2025"
    MSGLEN   equ $ - Message
; The dataset is just a table of byte-length numbers:
    Dataset  db 9,17,71,52,55,18,29,36,18,68,77,63,58,44,0

section .bss
    VidBuff  resb COLS*ROWS

section .text

    global _start

;-------------------------------------------------------------------------
; SendtoShell:  Send data to standard output.
; UPDATED:      Sun Aug 17 16:34:36 +01 2025
; IN:           RSI = data source, RDX = data size
; RETURNS:      Nothing
; MODIFIES:     Nothing
; CALLS:        Linux sys_write
; DESCRIPTION:

SendtoShell:
    push rax
    push rdi
    push rcx
    push r11

    mov rax, 1
    mov rdi, 1
    syscall

    pop r11
    pop rcx
    pop rdi
    pop rax
    ret

;-------------------------------------------------------------------------
; ResetBuff:    Clears a buffer to spaces and replaces overwritten EOLs
; UPDATED:      Sun Aug 17 16:39:31 +01 2025
; IN:           Nothing
; RETURNS:      Nothing
; MODIFIES:     VidBuff, EFLAGS (DF direction flag)
; CALLS:        Nothing
; DESCRIPTION:  Fills the buffer VidBuff with a predefined character
;               (FILLCHR) and then places an EOL character at the end
;               of every line, where a line ends every COLS bytes in
;               VidBuff.
ResetBuff:
    push rax
    push rdi
    push rcx

    cld
    mov rdi, VidBuff
    mov al, FillBuff
    mov rcx, COLS*ROWS
    rep stosb

    mov rdi, VidBuff
    dec rdi
    mov rcx, ROWS
.putEOL:
    add rdi, COLS
    mov byte [rdi], EOL
    loop .putEOL

    pop rcx
    pop rdi
    pop rax
    ret

;-------------------------------------------------------------------------
WrtRuler:
; Remember: cursor position on the screen (X,Y) is 1-based while buffer index
; is 0-based, as a result to convert cursor position to buffer index never
; forget to decrement by one all (X,Y) coordinates.
; Remember: the algorithm to convert (X,Y) coordinates to buffer index is
; buffer_index = Y * number_of_columns + X
    push rax
    push rdi
    push rbx
    push rdx
    push rcx

    mov rdi, VidBuff
    dec rax
    dec rbx
; TEST: Treating AH as a signed value with signed multiplication IMUL
; would do no harm to the program with the current value of COLS.
; However, bumping the 8-bit AH value beyond 127 would result in IMUL
; returning a negative value, treated as unsigned value by subsequent
; instructions its actual value would be huge enough to crash the program
; by segmentation fault.
    ; mov ah, 128
    ; imul ah
    mov ah, COLS
    mul ah

    add rdi, rax
    add rdi, rbx

    mov rdx, RulerStr
.concat:
    mov al, [rdx]
    stosb
    inc rdx
    loop .concat

    pop rcx
    pop rdx
    pop rbx
    pop rdi
    pop rax
    ret

;-------------------------------------------------------------------------
WrtMsg:
    push rax
    push rbx
    push rcx
    push rdi

    cld
    mov rdi, VidBuff
    dec rax
    dec rbx
    mov ah, COLS
    mul ah
    add rdi, rax
    add rdi, rbx
    rep movsb

    pop rdi
    pop rcx
    pop rbx
    pop rax
    ret

;-------------------------------------------------------------------------
WrtData:
    push rax
    push rbx
    push rcx
    push rdi

    cld
    mov rdi, VidBuff
    dec rax
    dec rbx
    mov ah, COLS
    mul ah
    add rdi, rax
    add rdi, rbx
    mov al, FillData
    rep stosb

    pop rdi
    pop rcx
    pop rbx
    pop rax
    ret

;-------------------------------------------------------------------------
; MAIN PROGRAM

_start:
    push rbp             ; stack alignment prolog
    mov rbp, rsp
    and rsp, -16

; 1) Set the stage by cleaning the screen and setting the cursor position
    mov rsi, ClearStr
    mov rdx, CLEARLEN
    call SendtoShell
; 2) Reset the buffer with omni-space char lines EOL-terminated
    call ResetBuff
; 3) Populate the buffer
; 3.1) Start with a ruler bar at the beginning of the buffer
    mov rax, 1           ; cursor 1-based Y position on the screen
    mov rbx, 1           ; cursor 1-based X position on the screen
    mov rcx, RULERLEN
    call WrtRuler
; 3.2) Insert a message centered near the bottom of the buffer
    mov rsi, Message
    mov rbx, COLS
    sub rbx, MSGLEN
    shr rbx, 1            ; Set cursor X so as to center the message
    mov rax, 20           ; at line 20 for cursor Y
    mov rcx, MSGLEN
    call WrtMsg
; 3.3) Insert random pseudo data lines after the intro ruler
    mov r12, Dataset      ; Set RCX count source index
    mov rbx, 1            ; Set X position
    xor r15, r15          ; Set loop counter
.blast:
    mov rax, r15          ; cursor 1-based Y position on the screen
    add rax, 2            ; Set 2-based Y position to skip first RulerStr
    mov cl, [r12+r15]     ; Get the Data to init RCX
    cmp cl, 0             ; Check if last data = 0 is reached
    je .ruler2
    call WrtData          ; Machine gun the line
    inc r15               ; Update loop counter
    jmp .blast
; 3.4) a ruler bar after the dataset
.ruler2:
    mov rax, r15         ; skip the dataset lines
    add rax, 2           ; Set 2-based Y position to skip first RulerStr
    mov rbx, 1           ; cursor 1-based X position on the screen
    mov rcx, RULERLEN
    call WrtRuler
; 4) Display buffer
    mov rsi, VidBuff
    mov rdx, COLS*ROWS
    call SendtoShell

Exit:
    mov rsp, rbp
    pop rbp

    mov rax, 60
    mov rdi, 0
    syscall

