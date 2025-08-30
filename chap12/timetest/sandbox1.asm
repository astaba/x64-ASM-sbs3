; x64ASM_sbs4/chap12/timetest/sandbox1.asm
;===============================================================================
; Created date: Tue Aug 19 23:47:53 +01 2025
; Program     : Time and Clock Demonstration in x86-64 NASM (Linux, SysV ABI)
; Author      :  [You]
; Purpose     : Showcase usage of libc time-related functions (time, localtime,
;               ctime, asctime, strftime, difftime, clock) with formatted output.
;===============================================================================
; Build using these commands:
; nasm -f elf64 -g -F stabs source_code.asm
; gcc source_code.o -o source_code.out -no-pie
;===============================================================================
; TODO: Reseach:
; 1. x87 FPU (Floating-Point Unit) or SSE (Streaming SIMD Extensions) instructions.
; 2. The proper way to set RAX before calling printf()
;===============================================================================

[SECTION .data]
    ;--- Format strings for strftime() ---
    Fstr_1 db "%a %b %d %H:%M:%S %G",0           ; abbreviated weekday, month, day, time, ISO year
    Fstr_2 db "This is week %U of the year %Y",0 ; week number and year
    Fstr_3 db "Today is %A; %x",0                ; full weekday name and locale date
    Fstr_4 db "It is %M minutes past hour %I.",0 ; minute + 12-hour clock
    ;--- Format strings for printf() ---
    Durastr db "Program execution time using time() = %g seconds.",0Ah,0
    ClockValueStr db "On this System CLOCKS_PER_SEC = %ld",0Ah,0
    TickStr db "CPU time using clock() = %lf seconds.",0Ah,0

    CLOCKS_PER_SEC dq 1000000     ; typical POSIX definition (1e6 ticks per sec)

[SECTION .bss]
    ;--- Variables ---
    Start   resq 1                ; time_t at program start
    Now     resq 1                ; current time_t (for conversion/printing)
    End     resq 1                ; time_t at program end

    TM_FIELDS equ 9               ; struct tm has 9 integer fields
    Local    resd TM_FIELDS       ; buffer to hold struct tm (int[9])
    Buffer   resb 80              ; buffer for strftime()
    Duration resq 1               ; holds difftime() result (double)
    CalcBuf  resq 1               ; holds clock() / CLOCKS_PER_SEC (double)

[SECTION .text]
extern time, localtime, ctime, asctime, puts, strftime, difftime, printf, getchar, clock
global main

; =============================================================================
; Procedure: Format_time
; Purpose  : Formats the current time into a buffer using strftime() and
;            calls puts() to send the string to stdout.
; Arguments: RDX = format string (char *) strftime() arg_03
; =============================================================================
Format_time:
    push rdi
    push rsi
    push rcx
    mov rdi, Buffer       ; arg_01: dest buffer
    mov rsi, 80           ; arg_02: buffer size
    mov rcx, Local        ; arg_04: struct tm
    call strftime
    mov rdi, Buffer       ; arg_01: source buffer
    call puts
    pop rcx
    pop rsi
    pop rdi
    ret

; =============================================================================
; Procedure: Pause
; Purpose  : wait for user to press ENTER (for demonstration pacing)
; =============================================================================
Pause:
    push rax              ; save RAX (scratch register)
    call getchar          ; getchar() blocks until ENTER pressed
    pop rax               ; restore RAX
    ret

; =============================================================================
; main: program entry point
; =============================================================================
main:
    push rbp
    mov rbp, rsp

    ;--- Capture initial time (Start and Now) ---
    xor rdi, rdi          ; arg_01: time_t* = NULL (time() returns in RAX)
    call time             ; RAX = current epoch seconds
    mov [Start], rax      ; store start time

    xor rdi, rdi
    call time
    mov [Now], rax        ; store current time for conversion

    ;--- Create struct tm using localtime() ---
    mov rdi, Now          ; arg_01: pointer to time_t Now
    call localtime        ; RAX = pointer to static struct tm

    ; Copy returned struct tm into our own Local buffer
    mov rsi, rax          ; RSI = source (struct tm pointer)
    mov rdi, Local        ; RDI = destination (our buffer)
    mov rcx, TM_FIELDS    ; RCX = count (9 dwords)
    cld                   ; clear DF (forward copy)
    rep movsd             ; copy struct tm (36 bytes)

    ;--- Display formatted time using ctime() ---
    mov rdi, Now          ; arg_01: &Now
    call ctime            ; RAX = pointer to string
    mov rdi, rax          ; arg_01: string ptr
    call puts             ; print
    call Pause            ; wait for ENTER

    ;--- Display formatted time using asctime() ---
    mov rdi, Local        ; arg_01: pointer to struct tm buffer
    call asctime          ; RAX = pointer to string
    mov rdi, rax
    call puts
    call Pause

    ;--- strftime() examples ---
    ; strftime(buf, size, format, struct_tm)
    ; Example 1
    mov rdx, Fstr_1       ; arg_03: format string
    call Format_time
    call Pause
    ; Example 2
    mov rdx, Fstr_2
    call Format_time
    call Pause
    ; Example 3
    mov rdx, Fstr_3
    call Format_time
    call Pause
    ; Example 4
    mov rdx, Fstr_4
    call Format_time
    call Pause

    ;--- Compute duration using difftime() ---
    xor rdi, rdi
    call time             ; RAX = current epoch seconds
    mov [End], rax

    mov rdi, [End]        ; arg_01: End time_t
    mov rsi, [Start]      ; arg_02: Start time_t
    call difftime         ; RAX = double result (in XMM0 actually, but returned in FP regs)
    mov [Duration], rax   ; store duration (low 8 bytes of double)

    mov rdi, Durastr      ; arg_01: format string
    mov rsi, [Duration]   ; arg_02: duration double (passed in integer reg due to %g promotion)
    call printf

    ;--- Print CLOCKS_PER_SEC constant ---
    mov rdi, ClockValueStr
    mov rsi, [CLOCKS_PER_SEC]
    call printf

;-------------------------------------------------------------------------------
; Compute CPU clock ticks with clock()
;-------------------------------------------------------------------------------
    call clock                     ; RAX ← number of clock ticks since program start
                                   ; (integer of type clock_t)
    ; Convert integer clock ticks (RAX) into double precision float (XMM0)
    cvtsi2sd xmm0, rax             ; XMM0 ← (double) RAX
    ; Convert CLOCKS_PER_SEC (integer in memory) into double precision float (XMM1)
    mov rdx, [CLOCKS_PER_SEC]      ; RDX ← CLOCKS_PER_SEC
    cvtsi2sd xmm1, rdx             ; XMM1 ← (double) RDX
    ; Divide ticks by CLOCKS_PER_SEC to compute elapsed seconds
    divsd xmm0, xmm1               ; XMM0 ← XMM0 / XMM1
    ; Store result temporarily into memory
    movsd [CalcBuf], xmm0          ; CalcBuf ← elapsed time (double)
    ; Print elapsed time using printf
    mov rdi, TickStr               ; printf(format = TickStr)
    movsd xmm0, [CalcBuf]          ; printf(argument in XMM0 = elapsed seconds)
    mov rax, 1                     ; Tell printf: 1 floating-point argument in XMM0
    call printf
;-------------------------------------------------------------------------------

    xor rax,rax                    ; return 0 from main
    pop rbp                        ; restore base pointer
    ret                            ; return to libc entry point

[SECTION .note.GNU-stack]
