;  Executable name : textfile Listing 12.8
;  Version         : 3.0
;  Created date    : 11/21/1999
;  Last update     : 7/18/2023
;  Author          : Jeff Duntemann
;  Description     : A text file I/O demo for Linux, using NASM 2.14.02
;
;  Build executable using these commands:
;    nasm -f elf64 -g -F dwarf textfile.asm
;    nasm -f elf64 -g -F dwarf linlib.asm
;    gcc textfile.o linlib.o -o textfile -no-pie
;
;  Note that the textfile program requires several procedures
;  in an external library named LINLIB.ASM.

[SECTION .data]     ; Section containing initialized data

IntFormat   dq '%d',0
WriteBase   db 'Line # %d: %s',10,0
NewFilename db 'testeroo.txt',0
DiskHelpNm  db 'helptextfile.txt',0
WriteCode   db 'w',0
OpenCode    db 'r',0
CharTbl     db '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-@'
Err1        db 'ERROR: The first command line argument must be an integer!',10,0
; INFO: this message is specifically defined to be recursively printf()
; by the memhelp routine every HELPSIZE chunk until the HelpEnd address.
HelpMsg     db 'TEXTTEST: Generates a test file.  Arg(1) should be the # of ',10,0
HELPSIZE    EQU $-HelpMsg
            db 'lines to write to the file.  All other args are concatenated',10,0
            db 'into a single line and written to the file.  If no text args',10,0
            db 'are entered, random text is written to the file.  This msg  ',10,0
            db 'appears only if the file HELPTEXTFILE.TXT cannot be opened. ',10,0
HelpEnd     dq 0

[SECTION .bss]             ; Section containing uninitialized data

LineCount   resq 1         ; Reserve integer to hold line count
IntBuffer   resq 1         ; Reserve integer for sscanf's return value
HELPLEN     EQU 72         ; Define length of a line of help text data
HelpLine    resb HELPLEN   ; Reserve space for disk-based help text line
BUFSIZE     EQU 64         ; Define length of text line buffer buff
Buff        resb BUFSIZE+5 ; Reserve space for a line of text

[SECTION .text]            ; Section containing code

;; These externals are all from the glibc standard C library:
extern fopen, fclose, fgets ,fprintf, printf ,sscanf, time
;; These externals are from the associated library linlib.asm:
extern seedit           ; Seeds the random number generator
extern pull6            ; Generates a 6-bit random number from 0-63

global main             ; Required so linker can find entry point

main:
    push rbp            ; Prolog: Set up stack frame
    mov rbp,rsp
    and rsp,-16

    mov r12,rdi         ; Save the argument count in r12
    mov r13,rsi         ; Save the argument pointer table to r13

    call seedit         ; Seed the random number generator

    ;; First test is to see if there are command-line arguments at all.
    ;; If there are none, we show the help info as several lines.  Don't
    ;; forget that the first arg is always the program name, so there's
    ;; always at least 1 command-line argument, even if we don't use it!
    cmp r12,1           ; If count in r12 is 1, there are no arguments
    ja chkarg2          ; Continue if arg count is > 1
	; FIX: RXB is not used as DiskHelpNm in diskhelp routine
    ; mov rbx,DiskHelpNm  ; Put address of help file name in rbx
    call diskhelp       ; If only 1 arg, show help info...
    jmp gohome          ; ...and exit the program

	;; Now we have more than the invocation text argument
    ;; After the invocation text we check for a numeric command line argument 1:

chkarg2:
	; First load sscanf arguments and notify it no vector argument is coming
	; int sscanf(const char *restrict str, const char *restrict format, ...);
    mov rdi,qword [r13+8] ; Pass address of an argument in rdi
    mov rsi,IntFormat   ; Pass address of integer format code in rsi
    mov rdx,IntBuffer   ; Pass address of integer buffer for sscanf output
    xor rax,rax         ; 0 says there will be no vector parameters
    call sscanf         ; Convert string arg to number with sscanf()
    cmp rax,1           ; Return value of 1 says we got a number
    je chkdata          ; If we got a number, go on; else abort
	; argv[1] not a number. Display specific error message and exit program
    mov rdi,Err1        ; Pass address of error 1-line message in rdi
    xor rax,rax         ; 0 says there will be no vector parameters
    call printf         ; Show the error message
    jmp gohome          ; Exit the program

	;; Now we check for more arguments after the invocation text and
	;; the numeric arg#1. If there are, we concatenate them into a single
	;; string no more than BUFSIZE chars in size.
	;; (Yes, I DO know this does what strncat does...)
	;; If the are no more we go to generate a random line
chkdata:
    mov r15,[IntBuffer] ; Store the # of lines to write in r15
    cmp r12,3           ; Is there a second argument?
    jae Init_ArgsLineLoop ; If so, we have text to fill a file with
    call randline       ; If not, generate a line of random text for file
                        ; Note that randline returns ptr to line in rsi
    jmp genfile         ; Go on to create the file

; INFO: ArgsLineLoop: Loop to knit the arguments string line into the buffer.
; After text invocatoin (argv[0]) and number of lines to print (argv[1])
; ArgsLineLoop copy each remaining arguments appends a space and paste it to
; a line in Buff. This loop needs three initial variables:
; 1. The destination address (RDI) for the string line.
; 2. Break condition 1: 2-based number of arguments count (R14) to process
; 3. Break condition 2: 0-based used bytes (RAX) within destinatin buffer size
; TRICK: To use MOVSB in a way that concatecates RSI single argument source
; to RDI buffer line destination, ArgsLineLoop reset RSI at each iteration
; while RDI is set once at the beginning.
Init_ArgsLineLoop:
    mov r14,2           ; We know we have at least arg(2), start there
    mov rdi,Buff        ; Destination pointer for MOVSB
    xor rax,rax         ; Clear rax to 0 to keep tally of Buff bytes
    cld                 ; Clear direction flag for up-memory MOVSB
ArgsLineLoop:
    mov rsi,qword [r13+r14*8] ; Iteratively re-init source pointer for MOVSB

; INFO: This inner loop copies individual argument until 0-terminator (excluded)
; First instruction is for Housekeeping. MOVSB instructin is the loop engine.
; Then before unconditinally looping back, destination buffer byte count and
; boundary check is performed.
.ArgStringLoop:
    cmp byte [rsi],0    ; Dereference string byte to check null-terminator
    je .next            ; If so, bounce to the next arg
    movsb               ; Copy char from [rsi] to [rdi]; inc rdi & rsi
    inc rax             ; Increment total character count
    cmp rax,BUFSIZE     ; See if we've filled the buffer to max count
    je NullTermArgsLine ; If so, go add a null to Buff & we're done
    jmp .ArgStringLoop

; INFO: ArgsLineLoop Housekeeping
; Now RSI points to the null-terminator of the current argument
; As far as ArgsLineLoop is concerned RAX updates occurs in ArgStringLoop
.next:
    inc r14              ; Keep tally for one more processed arguments
	; --------------------------------------------------------------------------
    mov byte [rdi],' '   ; Make sure buffer string words are space-separated
	inc rdi              ; Increment destination pointer after the space
    inc rax              ; Account for added space in destination byte count
    cmp rax,BUFSIZE      ; Check destinatin buffer boundary
    je NullTermArgsLine  ; If destination buffer full: kill loop
	; --------------------------------------------------------------------------
	; In stack directory nomenclature argv table is terminated by a 0 qword
	; This makes sure the loop stops right at argv last pointer element
    cmp r14,r12          ; Compare against argument count in r12
    jae NullTermArgsLine ; If all arguments processed: kill loop
    jmp ArgsLineLoop     ; Otherwise, jump to next argument

; ArgsLineLoop has been killed because: full buffer or all args processed.
; Now we can make sure the buffer line is null-terminator.
NullTermArgsLine:
    mov byte [rdi],0     ; Tack a null on the end of Buff
	; FIX: What!?! RSI is overwritten before being used!
    ; mov rsi,Buff       ; File write code expects ptr to text in rsi

    ;; Now we create a file to fill with the text we have:
genfile:
	; FILE *fopen(const char *restrict pathname, const char *restrict mode);
    mov rdi,NewFilename ; Pass filename to fopen in RDI
    mov rsi,WriteCode   ; Pass pointer to write/create code ('w') in rsi
    call fopen          ; Create/open file
    mov rbx,rax         ; rax contains the file handle; save in rbx
	; FIX: fopen() return value is not checked

    ;; File is open.  Now let's fill it with text:
    mov r14,1           ; R14 now holds the line # in the text file
.writeline:
    cmp qword r15,0     ; Has the line count (argv[1]) gone to 0?
    je .closeit         ; If so, close the file and exit
	; int fprintf(FILE *restrict stream, const char *restrict format, ...);
    mov rdi,rbx         ; Pass the file handle in rdi
    mov rsi,WriteBase   ; Pass the base string in rsi
    mov rdx,r14         ; Pass the line number in rdx
    mov rcx,Buff        ; Pass the pointer to the text buffer in rcx
    xor rax,rax         ; 0 says there will be no vector parameters
    call fprintf        ; Write the text line to the file
	; Housekeeping
    dec r15             ; Decrement the count of lines to be written
    inc r14             ; Increment the line number
    jmp .writeline       ; Loop back and do it again

    ;; We're done writing text; now let's close the file:
.closeit:
	; int fclose(FILE *stream);
	mov rdi,rbx         ; Pass the handle of the file to be closed in rdi
    call fclose         ; Closes the file

gohome:	                ; End program execution
	mov rsp,rbp         ; Epilog: Destroy stack frame before returning
	pop rbp
	ret                 ; Return control to the C shutdown code


;;; SUBROUTINES================================================================

;------------------------------------------------------------------------------
;  diskhelp: Disk-based mini-help subroutine  --  Last update 12/16/2022
;
;  This routine reads text from a text file, the name of which is passed by
;  way of a pointer to the name string in EBX. The routine opens the text file,
;  reads the text from it, and displays it to standard output.  If the file
;  cannot be opened, a very short memory-based message is displayed instead.
;  FIX: This EBX is never used to convey this pointer but the pointer is
;  directly reloaded into RDI from the get go.
;------------------------------------------------------------------------------
diskhelp:
	; First, try opening the stream file in reading mode and check the returned
	; value, it fails?! call the routine to display default help paragraph
	; FILE *fopen(const char *restrict pathname, const char *restrict mode);
    mov rdi,DiskHelpNm  ; Pointer to name of help file is passed in rdi
    mov rsi,OpenCode    ; Pointer to open-for-read code "r" gpes in rsi
    call fopen          ; Attempt to open the file for reading
    cmp rax,0           ; fopen returns null if attempted open failed
    jne .disk           ; Read help info from disk, else from memory
    call memhelp
    ret
	; Stream file successfully opened in reading mode
.disk:
    mov rbx,rax         ; Save handle since RAX is required for calling printf
.rdln:
	; Recursively fgets() stream file to buffer and display buffer with printf
	; until fgets() signal stream depletion then close stream and exit program
	; char *fgets(char s[restrict .size], int size, FILE *restrict stream);
    mov rdi,HelpLine    ; Pass pointer to buffer in rdi
    mov rsi,HELPLEN     ; Pass buffer size in rsi
    mov rdx,rbx         ; Pass file handle to fgets in rdx
    call fgets          ; Read a line of text from the file
    cmp rax,0           ; A returned null indicates error or EOF
    jle .done           ; If we get 0 in rax, close up & return
	; int printf(const char *restrict format, ...);
    mov rdi,HelpLine    ; Pass address of help line in rdi
    xor rax,rax         ; Passs 0 to tell there will be no vector arguments
    call printf         ; Call printf to display help line
    jmp .rdln
.done:
    mov rdi,rbx         ; Pass the handle of the file to be closed in rdi
    call fclose         ; Close the file
    jmp gohome          ; Go home

;------------------------------------------------------------------------------
; memhelp: This routines reursively printf() each line of the default help paragraph
;------------------------------------------------------------------------------
memhelp:
	; FIX: RAX overwritten before loaded 5 is used
    ; mov rax,5           ; rax contains the number of newlines we want
    mov rbx,HelpMsg     ; Load address of help text into rbx
.chkln:
    cmp qword [rbx],0   ; Does help msg pointer point to a null?
    jne .show           ; If not, show the help lines
    ret                 ; If yes, go home
.show:
    mov rdi,rbx         ; Pass address of help line in rdi
    xor rax,rax         ; 0 in RAX says there will be no vector parameters
    call printf         ; Display the line
    add rbx,HELPSIZE    ; Increment address by length of help line
    jmp .chkln          ; Loop back and check to see if we're done yet

; FIX: This branch is never accessed
showerr:
    mov rdi,rax         ; On entry, rax contains address of error message
    xor rax,rax         ; 0 in RAX says there will be no vector parameters
    call printf         ; Show the error message
    ret                 ; Pass control to shutdown code; no returned values

; -----------------------------------------------------------------------------
; randline: This routine generates a BUFSIZE-length string of random characters.
; It returns a pointer the generated string in RSI
randline:
    mov rbx,BUFSIZE     ; BUFSIZE tells us how many chars to pull
	; NOTE: that is not the idiomatic way of appending null terminator at the
	; end of a char buffer, it only works because Buff is casually defined with
	; a size of BUFSIZE+5
    mov byte [Buff+BUFSIZE+1],0 ; Put a null at the end of the buffer first
.loopback:
    dec rbx             ; BUFSIZE is 1-based, so decrement
    call pull6          ; Go get a random number from 0-63
    mov cl,[CharTbl+rax]  ; Use random # in rax as offset into char table
                          ;  and copy character from table into cl
    mov [Buff+rbx],cl   ; Copy char from cl to character buffer
    cmp rbx,0           ; Are we done having fun yet?
    jne .loopback       ; If not, go back and pull another
	; FIX: The return pointer doesn't seem to be useful for caller stack frames
    ; mov rsi,Buff        ; Copy address of the buffer into rsi
    ret                 ;   and go home

;------------------------------------------------------------------------------
[SECTION .note.GNU-stack]
