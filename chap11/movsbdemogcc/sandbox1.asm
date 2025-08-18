; x64ASM_sbs4/chap11/movsbdemogcc/sandbox.asm
; We need to insert a character at the beginning of the String tailed
; with a useless byte. For that the whole string must be shifted to
; left. Using overlapping memory buffer and the MOVSB working
; backward courtesy of STD (set directoin flag) we can acheive this in
; the blink of an eye.
;
;  Link:      gcc source.o -o source.out
;  Compile:   nasm -f elf64 -g -F dwarf source.asm -l source.lst
;
; INFO: New Instructions:
; 1. CLD and STD: CLear and SeT Direction flag
;   Operand: none
;   CLD makes DF==0, instructions process data memory up
;   STD makes DF==1, instructions process data memory down
; 3. MOVSB, MOVSW, MOVSD and MOVSQ: MOVe String Byte/W/D/Qword
;   Implicit Operand: RSI source address, RDI destination address
;   Copy the data in RSI (the chunk size matching MOVS last letter) to RDI,
;   then increment/decrement (based on DF== 0 or 1) RDI and RSI the same amount
;   as its last letter.
; 4. REP: REPeat (its operant which is an instruction)
;   Implicit Operand: RCX number of repetition to count down from.
;   Explicit Operand: the x64 instruction to repeat
;   CPU internal loop extremely fast to machine gun instructions.
;   After each iteration RCX is decremented ultil zero.
;
; NOTE: Where are the overlapping buffers?
; Source buffer: is considered to be the EditBuff buffer
; Destination buffer: is the addition of EditBuff buffer and TailSpare byte

section .note.GNU-stack noalloc noexec nowrite progbits

section .data
    EditBuff  db 'bcdefghijklmn'
    BUFFLEN   equ $-EditBuff ; length is 1-based
    TailSpare db ' ' ; This could be anything, just need a byte allocated

section .text

global main

main:
    mov rbp, rsp            ; for correct debugging

; Put your experiments between the two nops...
    nop

    std                     ; Set DF for backward memory copy
    mov rbx,EditBuff        ; load source address
    ; LEA loads calculated address without dereferencing
    lea rsi,[rbx+BUFFLEN-1] ; -1 makes length 0-based then pointing at the end
    mov rdi,TailSpare       ; RDI now points to the end of the destination
    mov rcx,BUFFLEN
    rep movsb               ; copies from source tail to destination tail
    mov byte [rbx],61h      ; Insert 'a' at the beginning

; Put your experiments between the two nops...
    nop
