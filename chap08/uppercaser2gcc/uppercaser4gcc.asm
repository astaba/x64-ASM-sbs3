; ------------------------------------------------------------------------------
; Source file   : x64ASM_sbs4/chap08/uppercaser2gcc/uppercaser4gcc.asm
; Version       : 4.0
; Description   : demonstrating simple text file I/O (through redirection) for
;                 reading an input file to a buffer in blocks, forcing lowercase
;                 characters to uppercase, and writing the modified buffer to an
;                 output file.
; Usage         : uppercaser2 > (output file) < (input file)
; Build commands: nasm -f elf64 -g -F stabs eatsyscall.asm
; NOTE: Improvement:
; * Process input by 0x80-byte blocks.
; * Handle sys_call errors.
; * Scan all characters upward, from low memory address to higher.
; This version is better for debugging because it's often easier to read buffer
; memory during execution since it reflects the "natural" byte layout in memory
; (Buffer[0], Buffer[1], ...).
; ------------------------------------------------------------------------------

section .note.GNU-stack           ; Mark stack non-executable (security)

section .data
	errmsg_read: db "Error: unable to read file!", 0x0A
	errmsg_read_len: equ $ - errmsg_read
	errmsg_write: db "Error: unable to write file!", 0x0A
	errmsg_write_len: equ $ - errmsg_write

section .bss
	BUFFLEN: equ 0x80             ; Buffer length
	Buffer: resb BUFFLEN          ; Reserve 128 bytes buffer

section .text
	global main                   ; Make main symbol visible to the linker

main:
	mov rbp, rsp                  ; Set up base pointer (for debugging purposes)

Read:
    ; read(0, &Buffer, BUFFLEN)
	mov rax, 0                    ; syscall ID: 0 (sys_read)
	mov rdi, 0                    ; arg_01: 0 (stdin file descriptor)
	mov rsi, Buffer               ; arg_02: Buff (address of buffer)
	mov rdx, BUFFLEN              ; arg_03: 1 (read 1 byte)
	syscall                       ; invoke kernel
    ; if (rax == -1) goto Error_read;
	test rax, rax                 ; Performs a non-modifying bit AND and check
	js Error_read                 ; SF(sign flag) is set: rax < 0 meaning error

	mov r12, rax                  ; Save read char num for latter sys_write
    ; if (rax == 0) goto Exit;
	cmp rax, 0                    ; check if EOF (syscall returned 0)
	je Exit                       ; if so, exit program

	xor rbx, rbx                  ; Clear rbx
	mov r13, Buffer               ; Save buffer starting point

Scan:
    ; if (Buffer < 'a') goto Next;
	cmp byte [r13 + rbx], 0x61    ; Test input char against lowercase 'a'
	jb Next                       ; If below 'a' in ASCII chart, not lowercase
	; if (Buffer > 'z') goto Next;
	cmp byte [r13 + rbx], 0x7A    ; Test input char against lowercase 'z'
	ja Next                       ; If above 'z' in ASCII chart, not lowercase
	; Buffer = Buffer - 0x20;
	sub byte [r13 + rbx], 0x20    ; convert ASCII lowercase to uppercase

Next:
    ; if (rbx == r12) goto Write;
	inc rbx                       ; Increment rbx
	cmp r12, rbx
	jnz Scan                      ; Loop back until all buffer is scanned

    ; write(1, &Buffer, r12)
	mov rax, 1                    ; syscall ID: 1 (sys_write)
	mov rdi, 1                    ; arg_01: 1 (stdout file descriptor)
	mov rsi, Buffer               ; arg_02: Buff (address of character to write)
	mov rdx, r12                  ; arg_03: write byte num return by sys_read
	syscall                       ; invoke kernel

	cmp rax, r12                  ; make sure num_written matches num_read
	jnz Error_write               ; If not equal, error

	jmp Read                      ; Look back until input is depleted

Exit:
    ; exit(EXIT_SUCCESS)
	mov rax, 60                   ; syscall ID: 60 (sys_exit)
	mov rdi, 0                    ; arg_01: 0
	syscall                       ; invoke kernel

Error_read:
    ; write(2, &errmsg_read, errmsg_read_len)
	mov rax, 1                    ; syscall ID: 1 (sys_write)
	mov rdi, 2                    ; arg_01: 2 (stderr file descriptor)
	mov rsi, errmsg_read          ; arg_02: address of character to write
	mov rdx, errmsg_read_len      ; arg_03: write string length byte
	syscall                       ; invoke kernel

	jmp Failure

Error_write:
    ; write(2, &errmsg_write, errmsg_write_len)
	mov rax, 1                    ; syscall ID: 1 (sys_write)
	mov rdi, 2                    ; arg_01: 2 (stderr file descriptor)
	mov rsi, errmsg_write         ; arg_02: address of character to write
	mov rdx, errmsg_write_len     ; arg_03: write string length byte
	syscall                       ; invoke kernel

	jmp Failure

Failure:
    ; exit(EXIT_FAILURE)
	mov rax, 60                   ; syscall ID: 60 (sys_exit)
	mov rdi, 1                    ; arg_01: 1
	syscall                       ; invoke kernel
