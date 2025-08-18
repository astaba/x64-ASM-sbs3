;  Executable name : showargs1gcc from Listing 11.4
;  Version         : 2.0
;  Created date    : 10/17/2022
;  Last update     : 7/18/2023
;  Author          : Jeff Duntemann
;  Description     : A simple program in assembly for Linux, using NASM 2.14.02,
;                    demonstrating how to access command line arguments from
;                    programs written/built in SASM.
;
;  Build using SASM standard x64 build setup
;  Link:      gcc source.o -o source.out
;  Compile:   nasm -f elf64 -g -F dwarf source.asm -l source.lst
;
; INFO: SCASB: Scan String Byte
; needs the data address be loaded in RDI and the value to
; compare against be in AL (or any one of RAX and its sub-registers
; corresponding to SCAS/B/W/D/Q last letter character). Then it dereference RDI,
; compare its value with AL, update the address in RDI incrementing or
; decrementing according to the DF direction flag status and in the same
; amount SCAS/B/W/D/Q last letter character, then updates the EFLAGS register.
; INFO: REPNE: Repeat if Non Equal (a REP that checks if ZF is set)
; needs RCX to hold the number of iterations to count down from.
; It keeps machine gunning its instruction operand while ZF == 0 (unset)
; and RCX != 0, and it decrements RCX.
;
SECTION .data                   ; Section containing initialised data

    ErrMsg db "Terminated with error.",10
    ERRLEN equ $-ErrMsg

    MAXARGS equ 5               ; More than 5 arguments triggers an error

SECTION .bss                    ; Section containing uninitialized data

SECTION .text                   ; Section containing code

global 	main                    ; Linker needs this to find the entry point!

main:
    mov rbp, rsp            ; for correct SASM debugging
    nop                     ; This no-op keeps gdb happy...
    ; INFO: Courtesy of glibc init routines entailed by the main function
    mov r14,rsi             ; Put offset of argv table in r14 a (a pointer to pointer address)
    mov r15,rdi             ; Put argument count in r15

    cmp qword r15,MAXARGS   ; Test for too many arguments
    ja Error                ; Show error message if too many args & quit

; Use SCASB to find the 0 at the end of the single argument
    ; init retrieve-arguments loop counter and 0-based index reference
    xor rbx,rbx            ; within the address table (the array of pointers)
Scan1:
    ; NOTE: initialise SCASB implicit operand compare RDI pointed to value
    xor rax,rax             ; Searching for string-termination 0, so clear AL to 0
    ; NOTE: initialise REPNE implicit operand to count down iterations.
    ; In the current application limits the size of memory data to scan
    mov rcx,0000ffffh       ; Limit search to 65535 bytes max
    ; NOTE: When the MOV instruction is used with the effective address
    ; calculation syntax [] it tells the CPU to compute the address and
    ; dereference it and load to operand#1 the byte pointed to. Since
    ; R14 hold a memory address of pointer (which are 8 bytes on x64 systems)
    ; the assembler requires the size of the data be specified.
    ; WARNING: Don't forget that after glibc init routines RDI holds
    ; the address of a memory string of addresses. That is why even after
    ; dereferencing and retrieving the 8 bytes we still have only an address
    ; that in turn will be dereferenced internally by SCASB to compare only
    ; one byte in the data with AL according the "B" in SCASB.
    mov rdi,qword [r14+rbx*8] ; Put address of string to search in RDI, for SCASB
    ; NOTE: To compute future string length stash the head before SCASB takes
    ; RDI to the other end.
    mov rdx,rdi             ; Copy string address into RDX for subtraction

    cld                     ; Set search direction to up-memory
    repne scasb             ; Search for null (0) in string at RDI
    ; WARNING: make sure in the event REPNE stopped because of RCX == 0
    ; it coincides with the very iteration SCASB compared AL with the
    ; researched '\0'. Otherwise something is broken with those arguments
    ; on the stack.
    jnz Error               ; Jump to error message display if null not found.
    ; NOTE: Just before REPNE checks the ZF(zero flag) and breaks, SCASB has
    ; already updated RDI 1 time too many just beyond the finally found '\0',
    ; thus to properly substitute EOL for '\0' like in the C fgets(){},
    ; RDI must be reset 1 step back.
    mov byte [rdi-1],10     ; Store an EOL where the null used to be
    ; NOTE: string-tail - string-head does not give the string length but only
    ; the distance from head to tail. To have the full length the very quantity
    ; at string-head must be accounted for which is not the way substraction
    ; works. This is why going one byte to many beyond the tail with RDI copes
    ; for that missing quantity at the head and RDI - RDX accurately computes
    ; the string length.
    sub rdi,rdx             ; Subtract position of 0 in RDI from start address in RDX
    mov r13,rdi             ; Put calculated arg length into R13

; Display the argument to stdout:
    mov rax,1               ; Specify sys_write call
    mov rdi,1               ; Specify File Descriptor 1: Standard Output
    mov rsi,rdx             ; Pass offset of the arg in RSI
    mov rdx,r13             ; Pass length of arg in RDX
    syscall                 ; Make kernel call

    inc rbx                 ; Increment the argument counter
    cmp rbx,r15             ; See if we've displayed all the arguments
    jb Scan1                ; If not, loop back and do another
    jmp Exit                ; We're done! Let's pack it in!

Error:
    mov rax,1               ; Specify sys_write call
    mov rdi,1               ; Specify File Descriptor 2: Standard Error
    mov rsi,ErrMsg          ; Pass offset of the error message
    mov rdx,ERRLEN          ; Pass the length of the message
    syscall                 ; Make kernel call

Exit:
    ret

