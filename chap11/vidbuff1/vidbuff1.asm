;  Executable name : vidbuff1 from Listing 11.1
;  Version         : 2.0
;  Created date    : 10/12/2022
;  Last update     : 7/18/2023
;  Author          : Jeff Duntemann
;  Description     : A simple program in assembly for Linux, using NASM 2.14.02,
;                  : demonstrating string instruction operation by "faking"
;                  : full-screen memory-mapped text I/O.
;
;    Note that the output to the console from this program will NOT display
;    correctly unless you have enabled the "Code page 437" character encoding
;    in the terminal program being used to display the console!
;
;    Link:      ld source.o -o source.out
;    Compile:   nasm -f elf64 -g -F dwarf source.asm -l source.lst
;
; INFO: New Instructions:
; 1. CLD and STD: CLear and SeT Direction flag
;   Operand: none
;   CLD makes DF==0, instructions process data memory up
;   STD makes DF==1, instructions process data memory down
; 2. STOSB, STOSW, STOSD and STOSQ: STOre String Byte/W/D/Qword
;   Implicit Operand: RAX single data to copy, RDI destination address
;   Copy the data in RAX (or the sub-register matching STOS last letter)
;   to RDI, then increment/decrement (based on DF== 0 or 1) RDI the same amount
;   as its last letter.
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
; 5. LOOP: loop simplifiation
;   Implicit Operand: RCX number of repetition to count down from.
;   Explicit Operand: label
;   THis instruction is logistically identical to:
;     dec RCX
;     cmp RCX,0
;     jz <label>
;

SECTION .data           ; Section containing initialized data
    EOL     equ 10      ; Linux end-of-line character
    FILLCHR equ 32      ; ASCII space character
    ; HBARCHR equ 196     ; Use dash char if this won't display
    HBARCHR equ 45      ; ASCII dash character
    STRTROW equ 2       ; Row where the graph begins

; WARN: Only RulerString is used
; We use this to display a ruler across the screen.
    TenDigits   db 31,32,33,34,35,36,37,38,39,30
    DigitCount  db 10
    RulerString db "12345678901234567890123456789012345678901234567890123456789012345678901234567890"
    RULERLEN    equ $-RulerString

; The dataset is just a table of byte-length numbers:
    Dataset db 9,17,71,52,55,18,29,36,18,68,77,63,58,44,0
    Message db "Data current as of 5/13/2023"
    MSGLEN  equ $-Message

; This escape sequence will clear the console terminal and place the
; text cursor to the origin (1,1) on virtually all Linux consoles:
    ClrHome db 27,"[2J",27,"[01;01H"
    CLRLEN  equ $-ClrHome   ; Length of term clear string

SECTION .bss            ; Section containing uninitialized data

    COLS    equ 81          ; Line length + 1 char for EOL
    ROWS    equ 25          ; Number of lines in display
    VidBuff resb COLS*ROWS  ; Buffer size adapts to ROWS & COLS

SECTION .text           ; Section containing code

global  _start          ; Linker needs this to find the entry point!

;-------------------------------------------------------------------------
; Local Call: 1 (_start)
;-------------------------------------------------------------------------
ClearTerminal:
    push rax            ; Save all modified registers
    push rdx
    push rsi
    push rdi
    push rcx            ; syscall stores the return address in RCX
    push r11            ; syscall stores RFlags in R11

    mov rax,1           ; Specify sys_write call
    mov rdi,1           ; Specify File Descriptor 1: Standard Output
    mov rsi,ClrHome     ; Pass address of the escape sequence
    mov rdx,CLRLEN      ; Pass the length of the escape sequence
    syscall             ; Make system call

    pop r11             ; Restore all modified registers
    pop rcx
    pop rdi
    pop rsi
    pop rdx
    pop rax
    ret

;-------------------------------------------------------------------------
; Local Call: 1 (_start)
;-------------------------------------------------------------------------
; ClrVid:       Clears a buffer to spaces and replaces overwritten EOLs
; UPDATED:      5/10/2023
; IN:           Nothing
; RETURNS:      Nothing
; MODIFIES:     VidBuff, DF
; CALLS:        Nothing
; DESCRIPTION:  Fills the buffer VidBuff with a predefined character
;               (FILLCHR) and then places an EOL character at the end
;               of every line, where a line ends every COLS bytes in
;               VidBuff.

ClrVid:
    push rax            ; Save registers that we change
    push rcx
    push rdi

    cld                 ; Clear DF; we're counting up-memory
    mov al,FILLCHR      ; Put the buffer filler char in AL
    mov rdi,VidBuff     ; Point destination index at buffer
    mov rcx,COLS*ROWS   ; Put count of chars stored into RCX
    rep stosb           ; Blast byte-length chars at the buffer
; Buffer is cleared; now we need to re-insert the EOL char after each line:
    mov rdi,VidBuff     ; Point destination at buffer again
    dec rdi             ; Start EOL position count at VidBuff char 0
    mov rcx,ROWS        ; Put number of rows in count register
.PtEOL:
    add rdi,COLS        ; Add column count to RDI
    mov byte [rdi],EOL  ; Store EOL char at end of row
    loop .PtEOL         ; Loop back if still more lines

    pop rdi             ; Restore caller's registers
    pop rcx
    pop rax
    ret                 ; and go home!

;-------------------------------------------------------------------------
; Local Call: 2 (_start)
;-------------------------------------------------------------------------
; Ruler:        Generates a "1234567890"-style ruler at X,Y in text buffer
; UPDATED:      5/10/2023
; IN:           The 1-based X position (row #) is passed in RBX
;               The 1-based Y position (column #) is passed in RAX
;               The length of the ruler in chars is passed in RCX
; RETURNS:      Nothing
; MODIFIES:     VidBuff
; CALLS:        Nothing
; DESCRIPTION:  Writes a ruler to the video buffer VidBuff, at the 1-based
;               X,Y position passed in RBX,RAX. The ruler consists of a
;               repeating sequence of the digits 1 through 0. The ruler
;               will wrap to subsequent lines and overwrite whatever EOL
;               characters fall within its length, if it will not fit
;               entirely on the line where it begins. Note that the Show
;               procedure must be called after Ruler to display the ruler
;               on the console.
; HACK:
; Remember: cursor position on the screen (X,Y) is 1-based while buffer index
; is 0-based, as a result to convert cursor position to buffer index never
; forget to decrement by one all (X,Y) coordinates.
; Remember: the algorithm to convert (X,Y) coordinates to buffer index is
; buffer_index = Y * number_of_columns + X

Ruler:
    push rax         ; Save the registers we change
    push rbx
    push rcx
    push rdx
    push rdi

    mov rdi,VidBuff  ; Load video buffer address to RDI
    dec rax          ; Adjust Y value down by 1 for address calculation
    dec rbx          ; Adjust X value down by 1 for address calculation
; TEST: Treating AH as a signed value with signed multiplication IMUL
; would do no harm to the program with the current value of COLS.
; However, bumping the 8-bit AH value beyond 127 would result in IMUL
; returning a negative value, treated as unsigned value by subsequent
; instructions its actual value would be huge enough to crash the program
; by segmentation fault.
    ; mov ah, 128
    ; imul ah
    mov ah,COLS      ; Move screen width to AH
    mul ah           ; Do 8-bit multiply AL*AH to AX
    add rdi,rax      ; Add Y offset into vidbuff to RDI
    add rdi,rbx      ; Add X offset into vidbuf to RDI
; RDI now contains the memory address in the buffer where the ruler
; is to begin. Now we display the ruler, starting at that position:
    mov rdx,RulerString ; Load address of ruler string into RDX
DoRule:
    mov al,[rdx] ; Load first digit in the ruler to AL
    stosb             ; Store 1 char; note that there's no REP prefix!
    inc rdx           ; Increment RDX to point to next char in ruler string
    loop DoRule       ; Decrement RCX & Go back for another char until RCX=0

    pop rdi           ; Restore the registers we changed
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret               ; And go home!

;-------------------------------------------------------------------------
; Local Call: 1 (_start)
;-------------------------------------------------------------------------
; WrtLn:        Writes a string to a text buffer at a 1-based X,Y position
; UPDATED:      5/10/2023
; IN:           The address of the string is passed in RSI
;               The 1-based X position (row #) is passed in RBX
;               The 1-based Y position (column #) is passed in RAX
;               The length of the string in chars is passed in RCX
; RETURNS:      Nothing
; MODIFIES:     VidBuff, RDI, DF
; CALLS:        Nothing
; DESCRIPTION:  Uses REP MOVSB to copy a string from the address in RSI
;               to an X,Y location in the text buffer VidBuff.

WrtLn:
    push rax        ; Save registers we will change
    push rbx
    push rcx
    push rdi

    cld             ; Clear DF for up-memory write
    mov rdi,VidBuff ; Load destination index with buffer address
    ; Make sure RDI stays within VidBuff formatting when added COLS and margins
    dec rax         ; Adjust Y value down by 1 for address calculation
    dec rbx         ; Adjust X value down by 1 for address calculation
    ; Compute the Y offset if RDI
    mov ah,COLS     ; Move screen width to AH
    mul ah          ; Do 8-bit multiply AL*AH to AX
    add rdi,rax     ; Add Y offset into vidbuff to RDI
    ; Compute X offset (left margin) of RDI
    add rdi,rbx     ; Add X offset into vidbuf to RDI
    ; Machine gun Message to the specific position in VidBuff
    rep movsb       ; Blast the string into the buffer

    pop rdi         ; Restore registers we changed
    pop rcx
    pop rbx
    pop rax
    ret             ; and go home!

;-------------------------------------------------------------------------
; Local Call: 1 (_start)
;-------------------------------------------------------------------------
; WrtHB:        Generates a horizontal line bar at X,Y in text buffer
; UPDATED:      5/10/2023
; IN:           The 1-based X position (row #) is passed in RBX
;               The 1-based Y position (column #) is passed in RAX
;               The length of the bar in chars is passed in RCX
; RETURNS:      Nothing
; MODIFIES:     VidBuff, DF
; CALLS:        Nothing
; DESCRIPTION:  Writes a horizontal bar to the video buffer VidBuff,
;               at th1e 1-based X,Y values passed in RBX,RAX. The bar is
;               "made of" the character in the equate HBARCHR. The
;               default is character 196; if your terminal won't display
;               that (you need the IBM 850 character set) change the
;               value in HBARCHR to ASCII dash or something else supported
;               in your terminal.

WrtHB:
    push rax         ; Save registers we change
    push rbx
    push rcx
    push rdi

    cld              ; Clear DF for up-memory write
    mov rdi,VidBuff  ; Put buffer address in destination register
    dec rax          ; Adjust Y value down by 1 for address calculation
    dec rbx          ; Adjust X value down by 1 for address calculation
    mov ah,COLS      ; Move screen width to AH
    mul ah           ; Do 8-bit multiply AL*AH to AX
    add rdi,rax      ; Add Y offset into vidbuff to EDI
    add rdi,rbx      ; Add X offset into vidbuf to EDI
    mov al,HBARCHR   ; Put the char to use for the bar in AL
    rep stosb        ; Blast the bar char into the buffer

    pop rdi          ; Restore registers we changed
    pop rcx
    pop rbx
    pop rax
    ret              ; And go home!

;-------------------------------------------------------------------------
; Local Call: 1 (_start)
;-------------------------------------------------------------------------
; Show:         Display a text buffer to the Linux console
; UPDATED:      5/10/2023
; IN:           Nothing
; RETURNS:      Nothing
; MODIFIES:     Nothing
; CALLS:        Linux sys_write
; DESCRIPTION:  Sends the buffer VidBuff to the Linux console via sys_write.
;               The number of bytes sent to the console is calculated by
;               multiplying the COLS equate by the ROWS equate.

Show:
    push r11           ; Save all registers we're going to change
    push rax
    push rcx
    push rdx
    push rsi
    push rdi

    mov rax,1          ; Specify sys_write call
    mov rdi,1          ; Specify File Descriptor 1: Standard Output
    mov rsi,VidBuff    ; Pass address of the buffer
    mov rdx,COLS*ROWS  ; Pass the length of the buffer
    syscall            ; Make system call

    pop rdi            ; Restore all modified registers
    pop rsi
    pop rdx
    pop rcx
    pop rax
    pop r11
    ret

;-------------------------------------------------------------------------
; MAIN PROGRAM:

_start:
; INFO: Stack alignment prolog:
; 1. save on the stak the base pointer reference to the calling stack frame
; 2. Initialise a base pointer reference for the current stack frame used
; to access arguments down on the stack (memory up)
; 3. Zero out last 4 bits of stack pointer address, advancing the RSP down
; memory on clean slot coinciding with the 16-byte-apart memory unit used
; as segment boundary references
    push rbp
    mov rbp,rsp
    and rsp,-16

; Send to the console a shell-interpreted escape sequence to clear it and
    call ClearTerminal ; set the cursor to position (1, 1)

; From 1 to 5 Populate the buffer:
; 1) Populate the entire width of each line in the buffer space characters
    call ClrVid        ; and terminate each line with EOL
; 2) Print the RulerString as first line in the buffer
    mov rax,1        ; Load Y position to AL
    mov rbx,1        ; Load X position to BL
    mov rcx,COLS-1   ; Load ruler length to RCX
    call Ruler       ; Write the ruler to the buffer
; 3) Print an informative message centered near the bottom of the buffer
    mov rsi,Message  ; Load the address of the message to RSI
    mov rcx,MSGLEN   ; and its length to RCX
    ; Calc left margin to center message: (column# - msg_len) / 2
    mov rbx,COLS     ; and the screen width to RBX
    sub rbx,rcx      ; Calc diff of message length and screen width
    shr rbx,1        ; Divide difference by 2 for X value
    ; Hard code top margin to 20
    mov rax,20       ; Set message row to Line 24
    call WrtLn       ; Display the centered message
; 4) Get back to the buffer 2nd line to print many dashed lines
    mov rsi,Dataset  ; Put the address of the dataset in RSI
    mov rbx,1        ; Start all bars at left margin (X=1)
    mov r15,0        ; Dataset element index starts at 0
.blast:
    mov rax,r15      ; Add dataset number to element index
    add rax,STRTROW  ; Bias row value by row # of first bar
    mov cl,byte [rsi+r15]   ; Put dataset value in lowest byte of RCX
    cmp rcx,0        ; See if we pulled a 0 from the dataset
    je .rule2        ; If we pulled a 0 from the dataset, we're done
    call WrtHB       ; Graph the data as a horizontal bar
    inc r15          ; Increment the dataset element index
    jmp .blast       ; Go back and do another bar
; 5) Print another RulerString in the buffer right after the dashed lines
.rule2:
    mov rax,r15      ; Use the dataset counter to set the ruler row
    add rax,STRTROW  ; Bias down by the row # of the first bar
    mov rbx,1        ; Load X position to BL
    mov rcx,COLS-1   ; Load ruler length to RCX
    call Ruler       ; Write the ruler to the buffer

; Send the populated buffer to stdout:
    call Show        ; Refresh the buffer to the console

; And return control to Linux:
Exit:
    mov rsp,rbp
    pop rbp

    mov rax,60       ; End program via Exit Syscall
    mov rdi,0        ; Return a code of zero
    syscall          ; Return to Linux

