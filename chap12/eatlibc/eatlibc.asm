; Executable name : eatlibc from Listing 12.1
; Version         : 3.0
; Created date    : 11/12/2022
; Last update     : 5/24/2023
; Author          : Jeff Duntemann
; Description     : Demonstrates calls made into libc, using NASM 2.14.02
;                   to send a short text string to stdout with puts().
;
; Build using these commands:
; nasm -f elf64 -g -F dwarf eatlibc.asm
; gcc eatlibc.o -o eatlibc -no-pie

SECTION .note.GNU-stack

SECTION .data              ; Section containing initialized data
EatMsg: db "Eat at Joe's!",0

SECTION .bss               ; Section containing uninitialized data

SECTION .text              ; Section containing code

extern puts                ; The simple "put string" routine from libc
global main                ; Required for the linker to find the entry point

main:
    push rbp               ; Prolog sets up stack frame
    mov rbp,rsp
;; Everything before this is boilerplate; use it for all ordinary apps!

    mov rdi,EatMsg         ; Put address of string into rdi
    call puts              ; Call libc function for displaying strings
    xor rax,rax            ; Pass a 0 as the program's return value.

;; Everything after this is boilerplate; use it for all ordinary apps!
    pop rbp                ; Destroy stack frame before returning
    ret                    ; Return control to Linux
