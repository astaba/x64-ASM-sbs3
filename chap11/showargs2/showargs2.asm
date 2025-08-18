;  Executable   : showargs2 from Listing 11.5
;  Version      : 2.0
;  Created date : 11/3/2022
;  Last update  : 5/11/2023
;  Author       : Jeff Duntemann
;  Description  : A simple program in assembly for Linux, using NASM 2.15.05,
;                 demonstrating the way to access command line arguments on
;                 the stack. This version accesses the stack "nondestructively"
;                 by using memory references calculated from RBP rather than
;                 POP instructions.
;
;    Use this makefile to build:
;    showargs2: showargs2.o
;        ld -o showargs2 -g showargs2.o
;    showargs2.o: showargs2.asm
;        nasm -f elf64 -g -F dwarf showargs2.asm -l showargs2.lst
;

SECTION .data           ; Section containing initialized data

    ErrMsg db "Terminated with error.",10
    ERRLEN equ $-ErrMsg

SECTION .bss            ; Section containing uninitialized data

; This program handles up to MAXARGS command-line arguments. Change the
; value of MAXARGS if you need to handle more arguments than the default 10.
; Argument lengths are stored in a table. Access arg lengths this way:
;     [ArgLens + <index reg>*8]
; Note that when the argument lengths are calculated, an EOL char (10h) is
; stored into each string where the terminating null was originally. This
; makes it easy to print out an argument using sys_write.

    MAXARGS   equ  10       ; Maximum # of args we support
    ArgLens:  resq MAXARGS	; Table of argument lengths

SECTION .text       ; Section containing code

global  _start      ; Linker needs this to find the entry point!

_start:

; INFO: Standard prolog:
; This entire block is a standard way to set up a "stack frame."
; It's common in C compiler output and good practice for assembly
; functions to make them compatible with other code.
    push rbp        ; save the caller RBP before using it
    mov rbp, rsp    ; make RBP a fixed reference for variable access in the current stack frame
    and rsp,-16     ; Mask RSP with ...FFF0h insure stack is 16-bit aligned as required by System V ABI


; Copy the command line argument count from the stack and validate it:
    mov r13,[rbp+8]         ; Copy argument count from the stack
    cmp qword r13,MAXARGS   ; See if the arg count exceeds MAXARGS
    ja Error                ; If so, exit with an error message

; Here we calculate argument lengths and store lengths in table ArgLens:
    mov rbx,1               ; Stack address offset starts at RBX*8

ScanOne:
    xor rax,rax     ; Searching for 0, so clear AL to 0
    mov rcx,0000ffh ; Limit search to 255 bytes max
    mov rdi,[rbp+8+rbx*8] ; Put address of string to search in RDI
    mov rdx,rdi     ; Copy starting address into RDX

    cld	            ; Set search direction to up-memory
    repne scasb     ; Search for null (binary 0) in string at RDI
    jnz Error       ; REPNE SCASB ended without finding AL

    mov byte [rdi-1],10	; Store an EOL where the null used to be
    sub rdi,rdx     ; Subtract position of 0 from start address
; WARNING: CLEVER and BOLD DESIGN CHOICE while BAD PRACTICE:
; RBX is 1-based and comes handy to skip stack bumping from the alignment
; prolog and rightly index RBP. While ArgLens is 0-based indexable, choosing to
; index it with RBX squarely ignore ArgLens[0] slot and in case of argc==10,
; the 10th length is located in an out of bound slot right after ArgLens[9].
; Although it's a smart design simplication it's BAD PRATICE. The only reason
; why it works: 1) OS allocates segments space by page, so, when you reserve
; 10*qword the OS provides one 4096-byte page at runtime. Going beyond 10-qword
; ArgLens lands on a virgin .bss slot. Had the assembly code reserved another
; variable right after ArgLens, that variable would have been corrupted for
; good at runtime. 2) The OS writes out of the bound because it doesn't care
; the assembly reserved only 10-qword, it only cares about available spaces
; within segment boundaries. It is a BAD PRACTICE.
; If any, refrain from writting beyond reserved spaces!
    mov [ArgLens+rbx*8],rdi    ; Put length of arg into table
    inc rbx         ; Add 1 to argument counter
    cmp rbx,r13     ; See if arg counter exceeds argument count
    jbe ScanOne     ; If not, loop back and scan another one

; Display all arguments to stdout:
    mov rbx,1 ; Start (for stack addressing reasons) at 1
Showem:
    mov rax,1       ; Specify sys_write call
    mov rdi,1       ; Specify File Descriptor 1: Standard Output
    mov rsi,[rbp+8+rbx*8]   ; Pass offset of the argument
    mov rdx,[ArgLens+rbx*8] ; Pass the length of the argument
    syscall         ; Make kernel call
    inc rbx         ; Increment the argument counter
    cmp rbx,r13     ; See if we've displayed all the arguments
    jbe Showem      ; If not, loop back and do another
    jmp Exit        ; We're done! Let's pack it in!

Error:
    mov rax,1       ; Specify sys_write call
    mov rdi,2       ; Specify File Descriptor 2: Standard Error
    mov rsi,ErrMsg  ; Pass offset of the error message
    mov rdx,ERRLEN  ; Pass the length of the message
    syscall         ; Make kernel call

Exit:
    mov rsp,rbp
    pop rbp

    mov rax,60      ; Code for Exit Syscall
    mov rdi,0       ; Return a code of zero
    syscall         ; Make kernel call
