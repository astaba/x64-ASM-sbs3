; x64ASM_sbs4/chap12/randtest/sandbox.asm
; Created date : Thu Aug 21 22:10:47 +01 2025
; Description  : Demonstrates random number generation and formatting
;                in x86-64 NASM.
; Program flow:
; 1. Seed the random generator with the current time.
; 2. Generate and display tables of random numbers with various bit widths.
; 3. Generate a random string using a lookup table of characters.
;
; Build using these commands:
; nasm -f elf64 -g -F dwarf eatlibc.asm
; gcc eatlibc.o -o eatlibc -no-pie
;
; Table bit widths:
; 31-bit:	2^31	=> [0, 214_7483_647]
; 20-bit:	2^20	=> [0, 1_048_575]
; 16-bit:	2^16	=> [0, 65_535]
;  7-bit:	 2^7	=> [0, 127]
;  6-bit:	 2^6	=> [0, 63]
;  4-bit:	 2^4	=> [0, 15]
;
;===============================================================================
; CONSTANTS

RANDBITS   equ 31            ; Maximum number of random bits (from rand())
TABLESIZE  equ 36            ; How many integers to generate in each batch
; STRINGSIZE equ 64            ; Length of random string to generate
STRINGSIZE equ 12            ; Length of password

;===============================================================================
[SECTION .data]              ; Initialized data

Str_Subtitle db 0Ah,"Here is a table of 36 %d-bit integers (0..%d):",0Ah,0
    ; Format string for announcing which bit-size random integers we’re printing
    ; "%d" is substituted with the current bit width
Str_Tblrow db "%14d%14d%14d%14d%14d%14d",0Ah,0
    ; Format string for one row of six integers (10-wide, tab-separated, newline)
; LookupTbl db "0123456789@ABCDEFGHIJKLMNOPQRSTUVWXYZ?abcdefghijklmnopqrstuvwxyz"
LookupTbl db "0123456789!@#$%&*-_=+?ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz~"
LOOKUPTBLLEN equ $-LookupTbl
    ; Lookup table for xlat instruction (used to generate random printable string)
NullTerminator db 0
    ; Just to feed puts() with a char pointer to a 0-length string
Str_Password db 0Ah,"Randomly generated %d-character password:",0Ah,0

;===============================================================================
[SECTION .bss]               ; Uninitialized data

RandBuf resd TABLESIZE       ; Buffer for TABLESIZE random integers (each 4 bytes)
RandStr resb STRINGSIZE+1    ; Buffer for generated random string (+NUL)

;===============================================================================
[SECTION .text]              ; Code section

extern time, srand, rand, printf, puts
global main

;===============================================================================
; RANDOM NUMBER GENERATORS (with different bit widths)
;-------------------------------------------------------------------------------
; Each of these entry point prepares rcx = number of bits to shift away (31-n)
; then jumps into the shared "random" routine.
;-------------------------------------------------------------------------------
random31: mov rcx, RANDBITS-31
          jmp random
random20: mov rcx, RANDBITS-20
          jmp random
random16: mov rcx, RANDBITS-16
          jmp random
random7:  mov rcx, RANDBITS-7
          jmp random
random6:  mov rcx, RANDBITS-6
          jmp random
random4:  mov rcx, RANDBITS-4
          jmp random
;-------------------------------------------------------------------------------
; Shared random generator routine. rcx = shift amount (so result is N-bit)
random:
    mov r15, rcx           ; Save shift count across rand() call
    call rand              ; rand() returns 31-bit integer in eax/rax
	mov rcx, r15           ; Restore shift count
    shr rax, cl            ; Shift right by cl → keeps top (31 - cl) bits
    ret

;===============================================================================
; genrand: Fill RandBuf with TABLESIZE random integers
; r13 must hold pointer to one of the randomN routines
;-------------------------------------------------------------------------------
genrand:
    xor r12, r12           ; r12 = index counter
.loop:
    call r13               ; generate random value into rax
    mov [RandBuf+r12*4], eax  ; store 32-bit random number in buffer
    inc r12
    cmp r12, TABLESIZE
    jb .loop               ; loop until 36 numbers filled
    ret

;===============================================================================
; showcase: Print RandBuf contents in rows of 6
;-------------------------------------------------------------------------------
showcase:
    xor r12, r12           ; row index
.loop:
    mov rdi, Str_Tblrow    ; printf format string
    mov esi, [RandBuf+r12*4]      ; 1st int → rsi
    mov edx, [RandBuf+r12*4+4]    ; 2nd int → rdx
    mov ecx, [RandBuf+r12*4+8]    ; 3rd int → rcx
    mov r8d, [RandBuf+r12*4+12]   ; 4th int → r8d
    mov r9d, [RandBuf+r12*4+16]   ; 5th int → r9d
    mov r13d, [RandBuf+r12*4+20]  ; 6th int → r13d (not passed in regs)
;-------------------------------------------------------------------------------
; NOTE: This is correct.
;   - mov r13d loads only 4 bytes into r13’s low dword.
;   - push r13 writes that value (zero-extended to 64 bits) onto the stack.
;   No overflow or invalid access.
; WARN: As the System V ABI ditates the stack must grow by 16-byte chunks
; In the event you intent to push only one parameter and since all passed
; parameters must stick out on top of the stack, precede it first with
; an 8-byte dummy padding
;-------------------------------------------------------------------------------
	push rax               ; dummy padding for stack alignment
    push r13               ; push 6th arg on stack (SysV ABI requires this)
	xor rax, rax           ; Tell printf no vector argument is coming
    call printf            ; call printf with 6 args (5 in regs, 1 on stack)
    add rsp, 16            ; clean up stack (pop back 8 bytes)

    add r12b, 6            ; advance by 6 numbers
    cmp r12b, TABLESIZE
    jb .loop
    ret

;===============================================================================
; main: Orchestration
;-------------------------------------------------------------------------------
main:
    push rbp
    mov rbp, rsp           ; standard prolog

    ;---------------------------------------
    ; Seed PRNG
    xor rdi, rdi
    call time              ; time(NULL)
    mov rdi, rax
    call srand             ; srand(time(NULL))
; WARN: Since srand() is passed time() result, unless one second elapses
; between two rand() calls, they will yield the same random sequence.

    ;---------------------------------------
    ; Generate and show tables of various widths
    ; (Each block does: genrand → announce → showcase)
    ;---------------------------------------

    mov r13, random31
    call genrand
    mov rdi, Str_Subtitle
    mov rsi, 31
	mov rdx, 2147483647
	xor rax, rax           ; Tell printf no vector argument is coming
    call printf
    call showcase

    mov r13, random20
    call genrand
    mov rdi, Str_Subtitle
    mov rsi, 20
	mov rdx, 1048575
	xor rax, rax           ; Tell printf no vector argument is coming
    call printf
    call showcase

    mov r13, random16
    call genrand
    mov rdi, Str_Subtitle
    mov rsi, 16
	mov rdx, 65535
	xor rax, rax           ; Tell printf no vector argument is coming
    call printf
    call showcase

    mov r13, random7
    call genrand
    mov rdi, Str_Subtitle
    mov rsi, 7
	mov rdx, 127
	xor rax, rax           ; Tell printf no vector argument is coming
    call printf
    call showcase

    mov r13, random6
    call genrand
    mov rdi, Str_Subtitle
    mov rsi, 6
	mov rdx, 63
	xor rax, rax           ; Tell printf no vector argument is coming
    call printf
    call showcase

    mov r13, random4
    call genrand
    mov rdi, Str_Subtitle
    mov rsi, 4
	mov rdx, 15
	xor rax, rax           ; Tell printf no vector argument is coming
    call printf
    call showcase

    ;---------------------------------------
    ; Generate random string (using lookup table)
    ;---------------------------------------

    ; Clear RandStr buffer with zeros
    xor rax, rax           ; init STOSB implicit source operand
    mov rdi, RandStr       ; init STOSB implicit destination operand
    mov rcx, STRINGSIZE+1  ; init REP implicit operand
    cld                    ; clear DF for memory-up STOSB
    rep stosb

;     ; Knit string
;     xor r12, r12           ; init loop counter
; .loopStr:
;     call random6           ; 6-bit random value in rax
;     mov rbx, LookupTbl     ; init XLAT implicit operand
;     xlat                   ; al = LookupTbl[al]
;     mov [RandStr+r12], al  ; store char
;     inc r12
;     cmp r12, STRINGSIZE
;     jb .loopStr
;
;     ; Print random string
;     mov rdi, NullTerminator
;     call puts
;     mov rdi, RandStr
;     call puts
;     mov rdi, NullTerminator
;     call puts

    ; Knit password
    xor r12, r12           ; init loop counter
.loopStr:
    call random7           ; 7-bit random value in rax
	; make sure RAX is within table index range
	xor rdx, rdx
	mov r13, LOOKUPTBLLEN
	div r13
	; INFO: Mock modulo indexing the lookup table with the remainder
	; of unsigned integer division by the length ot the lookup table.
    mov al, [LookupTbl+rdx]     ; lookup table
    mov [RandStr+r12], al       ; store char
    inc r12
    cmp r12, STRINGSIZE
    jb .loopStr

    ; Print random password
	mov rdi, Str_Password
	mov rsi, STRINGSIZE
	xor rax, rax           ; Tell printf no vector argument is coming
	call printf
    mov rdi, RandStr
    call puts
    mov rdi, NullTerminator
    call puts

    ;---------------------------------------
    ; Exit main with return 0
    xor rax, rax
    mov rsp, rbp
    pop rbp
    ret

;===============================================================================
[SECTION .note.GNU-stack]    ; Marker for non-executable stack
