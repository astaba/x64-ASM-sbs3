;  Executable name : hexdump1gcc
;  Version         : 2.0
;  Created date    : 5/9/2022
;  Last update     : 5/8/2023
;  Author          : Jeff Duntemann
;  Description     : A simple program in assembly for Linux, using NASM 2.15
;    under the SASM IDE, demonstrating the conversion of binary values to
;    hexadecimal strings. It acts as a very simple hex dump utility for files,
;    without the ASCII equivalent column.
;
;  Run it this way:
;    hexdump1gcc < (input file)
;
;  Build using SASM's default build setup for x64
; WARNING: Big take away from the bug: When you test filter programs like this
; one always filter big files with lots of characters then diff output files.
; Keep little strings for difficult but insightful debugging sessions.

SECTION .bss              ; Section containing uninitialized data

    BUFFLEN equ 16        ; We read the file 16 bytes at a time
    Buff:   resb BUFFLEN  ; Text buffer itself, reserve 16 bytes

SECTION .data             ; Section containing initialised data

    HexStr: db " 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00",10
    HEXLEN equ $-HexStr

    Digits: db "0123456789ABCDEF"

SECTION .text             ; Section containing code

global  main              ; Linker needs this to find the entry point!

main:
    mov rbp,rsp       ; SASM Needs this for debugging

; Read a buffer full of text from stdin:
Read:
    mov rax,0             ; Specify sys_read call 0
    mov rdi,0             ; Specify File Descriptor 0: Standard Input
    mov rsi,Buff          ; Pass offset of the buffer to read to
    mov rdx,BUFFLEN       ; Pass number of bytes to read at one pass
    syscall               ; Call sys_read to fill the buffer
    mov r15,rax           ; Save # of bytes read from file for later
    cmp rax,0             ; If rax=0, sys_read reached EOF on stdin
    je Done               ; Jump If Equal (to 0, from compare)

; Set up the registers for the process buffer step:parm
    ; WARNING: According to System V ABI for linux both RSI and RDI are
    ; callee-clobbered registers, meaning sys_read is free to modify them.
    ; Therefore re-initializing them is good practice for correctness and
    ; portability. However since RDI is never used in the Scan loop, its
    ; code line is redundant and unnecessary.
    mov rsi,Buff          ; Place address of file buffer into esi
    mov rdi,HexStr        ; Place address of line string into edi

    xor rcx,rcx           ; Clear line string pointer to 0

; Go through the buffer and convert binary values to hex digits:
Scan:
    xor rax,rax           ; Clear rax to 0

; Here we calculate the offset into the line string, which is rcx X 3
    mov rdx,rcx               ; Copy the pointer into line string into rdx
;   shl rdx,1                 ; Multiply pointer by 2 using left shift
;   add rdx,rcx               ; Complete the multiplication X3
    lea rdx,[rdx*2+rdx]       ; This does what the above 2 lines do!
                              ; See discussion of LEA later in Ch. 9

; Get a character from the buffer and put it in both rax and rbx:
    mov al,byte [rsi+rcx]     ; Put a byte from the input buffer into al
    mov rbx,rax               ; Duplicate byte in bl for second nybble

; Look up low nybble character and insert it into the string:
    and al,0Fh                   ; Mask out all but the low nybble
    mov al,byte [Digits+rax]     ; Look up the char equivalent of nybble
    mov byte [HexStr+rdx+2],al   ; Write the char equivalent to line string

; Look up high nybble character and insert it into the string:
    shr bl,4                     ; Shift high 4 bits of char into low 4 bits
    mov bl,byte [Digits+rbx]     ; Look up char equivalent of nybble
    mov byte [HexStr+rdx+1],bl   ; Write the char equivalent to line string

; Bump the buffer pointer to the next character and see if we're done:
    inc rcx         ; Increment line string pointer
    cmp rcx,r15     ; Compare to the number of characters in the buffer
    ; BUG: NASTY VICIOUS BUG.
    ; jna allows for one iteration too many, skipping the EOL (Ox0A) and
    ; encroaching two bytes deep on the next memory data which is Digits.
    ; The two first bytes (0 and 1) are crushed into the unknown by what ever
    ; out-of-bound data is right beyond Buff size. As a result all hexadecimal
    ; translation requiring 0 and 1 are reliable only for the 16 bytes in the
    ; first iteration. Thereafter those zeros and ones rely on luck,
    ; an invitation to desaster.
    jna Scan      ; Loop back if rcx is <= number of chars in buffer

; Write the line of hexadecimal values to stdout:
    mov rax,1       ; Specify syscall call 1: sys_write
    mov rdi,1       ; Specify File Descriptor 1: Standard output
    mov rsi,HexStr  ; Pass address of line string in rsi
    mov rdx,HEXLEN  ; Pass size of the line string in rdx
    syscall         ; Make kernel call to display line string
    jmp Read        ; Loop back and load file buffer again

; All done! Let's end this party:
Done:
    ret             ; Return to the glibc shutdown code

