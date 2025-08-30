; x64ASM_sbs4/chap07/sandbox/13_reg_slicing.asm

; INFO: This sandbox is to demonstrate that higher bits of 64-bits registers
; are reset to 0 only when the lower 32-bits are touched.
; Yes, you eared that right. When the 16 or 8 lower bits are touched
; the higher 48 or 56 bits keeps their preceding garbage values.
; This applies to all general purpose registers.
; HACK: Why This Matters:
; * It’s a performance optimization: avoids partial register stalls.
; * It simplifies register renaming in out-of-order execution.
; * It’s a semantic guarantee: writing to EAX always clears RAX[63:32].
; This is why compilers often prefer EAX over AX or AL
; when they want to ensure upper bits are clean.

section .note.GNU-stack noalloc noexec nowrite progbits

section .data

section .text
global _start

_start:
	push rbp
	mov rbp, rsp
	and rsp, -16

    nop                     ; Entry fence
    mov rax, 0x1122334455667788
    nop                     ; Observe full rax
    mov al, 0xAA            ; Modify lowest 8 bits
    nop                     ; rax = 0x11223344556677AA
    mov ax, 0xBBBB          ; Modify lowest 16 bits
    nop                     ; rax = 0x112233445566BBBB
    mov eax, 0xCCCCDDDD     ; Modify lowest 32 bits (zeroes upper 32)
    nop                     ; rax = 0x00000000CCCCDDDD
    mov rax, 0xFFFFFFFFFFFFFFFF
    nop                     ; Reset rax to all 1s
    mov eax, 0x12345678     ; Zero upper 32 again
    nop                     ; rax = 0x0000000012345678
    mov rax, 0xDEADBEEFCAFEBABE
    nop                     ; Final rax reset
    mov al, 0x11            ; Only lowest byte
    nop                     ; rax = 0xDEADBEEFCAFEBA11
    mov ax, 0x2222          ; Lowest 2 bytes
    nop                     ; rax = 0xDEADBEEFCAFEB222
    mov eax, 0x33334444     ; Lower 4 bytes, upper zeroed
    nop                     ; rax = 0x0000000033344444

	mov rsp, rbp
	pop rbp

    nop                     ; Exit fence


