# Assembly Language

x64 Assembly Language Step-by-Step, Programming with Linux® 4TH Edition by Jeff Duntemann

## Partial x64 Instruction Reference

### AND: Logical AND

#### **Flags Affected**

| | | |
|-|-|-|
| `OF`: **Overflow flag** | `TF`: **Trap flag** | `AF`: **Aux carry** |
| `DF`: **Direction flag** | `SF`: **Sign flag** | `PF`: **Parity flag** |
| `IF`: **Interrupt flag** | `ZF`: **Zero flag** | `CF`: **Carry flag** |

| 11 | 10 | 9 | 8 | 7 | 6 | 4 | 2 | 0 |
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| `OF` | `DF` | `IF` | `TF` | `SF` | `ZF` | `AF` | `PF` | `CF` |
| **✓** |   |    |   | **✓** | **✓** | **?** | **✓** | **✓** |

#### **Legal Forms**

```code
AND r/m8,i8
AND r/m16,i16
AND r/m32,i32  386+
AND r/m64,i32  x64+ NOTE: AND r/m64,i64 is NOT valid!
AND r/m16,i8
AND r/m32,i8   386+
AND r/m64,i8   x64+
AND r/m8,r8
AND r/m16,r16
AND r/m32,r32  386+
AND r/m64,r64  x64+
AND r8,r/m8
AND r16,r/m16
AND r32,r/m32  386+
AND r64,r/m64  x64+
AND AL,i8
AND AX,i16
AND EAX,i32    386+
AND RAX,i32    x64+ NOTE: AND RAX,i64 is NOT valid!
```

#### **Examples**

```asm
AND BX,DI
AND EAX,5
AND AX,0FFFFH
AND AL,42H
AND [BP+SI],DX
AND QWORD [RDI],42
AND QWORD [RBX],0B80000H
```

#### **Notes**

`AND` performs the AND logical operation on its two operands. Once the operation is complete, the result replaces the destination operand. AND is performed on a bit-by-bit basis, such that bit 0 of the source is ANDed with bit 0 of the destination, bit 1 of the source is ANDed with bit 1 of the destination, and so on. The AND operation yields a 1 if both of the operands are 1; and a 0 only if either operand is 0. Note that the operation makes the Auxiliary carry flag undefined. CF and OF are cleared to 0, and the other affected flags are set according to the operation’s results.

m8  = 8-bit  memory data  
m16 = 16-bit memory data  
m32 = 32-bit memory data  
m64 = 64-bit memory data  
i8  = 8-bit  immediate data  
i16 = 16-bit immediate data  
i32 = 32-bit immediate data  
i64 = 64-bit immediate data  
d8  = 8-bit  signed displacement  
d16 = 16-bit signed displacement  
d32 = 32-bit unsigned displacement  
NOTE: There is no 64-bit displacement  
r8  = AL AH BL BH CL CH DL DH  
r16 = AX BX CX DX BP SP SI DI  
r32 = EAX EBX ECX EDX EBP ESP ESI EDI  
r64 = RAX RBX RCX RDX RBP RSP RSI RDI R8 R9 R10 R11 R12 R13 R14 R15  

### 🧾 **Core Instruction Summary Table**

| Instruction | Purpose | Effect / Operands | Notes / Example |
| ----------- | ------- | ----------------- | --------------- |
| `MOV` | Copy data | `MOV dest, src` | `MOV RAX, RBX` copies RBX into RAX |
| `ADD` | Add values | `ADD dest, src` | `ADD RAX, 5` → RAX += 5 |
| `SUB` | Subtract src from dest | `SUB dest, src` | `SUB RAX, 5` → RAX -= 5 |
| `XCHG` | Swap values | `XCHG reg1, reg2` | `XCHG RAX, RBX` |
| `INC` | Increment | `INC reg/mem` | Increases value by 1 |
| `DEC` | Decrement | `DEC reg/mem` | Decreases value by 1 |
| `NEG` | Negate (two's complement) | `NEG reg/mem` | `NEG RAX` → RAX = -RAX |
| `MOVSX` | Sign-extend | `MOVSX dest, src` | Extends sign bit (e.g. byte → dword) |
| `MUL` | Unsigned multiply | `MUL src` | Implicitly uses RAX; result in RDX\:RAX |
| `DIV` | Unsigned divide | `DIV src` | Divides RDX\:RAX by `src`, result in RAX, remainder in RDX |
| `PUSH` | Push to stack | `PUSH reg/mem/imm` | Decrements RSP, writes value |
| `PUSHQW` | Push quadword (64-bit) manually | (Non-standard; maybe macro alias) | `PUSH rax` is same |
| `POP` | Pop from stack | `POP reg/mem` | Reads value from \[RSP], increments RSP |
| `POPQW` | Pop quadword manually | (Non-standard; maybe macro alias) | `POP rax` is standard |
| `AND` | Bitwise AND | `AND dest, src` | Clears bits |
| `OR` | Bitwise OR | `OR dest, src` | Sets bits |
| `XOR` | Bitwise XOR | `XOR dest, src` | Toggles bits; `XOR RAX, RAX` → zeroing idiom |
| `NOT` | Bitwise NOT | `NOT reg/mem` | Inverts all bits |
| `SHL` | Shift left | `SHL dest, count` | Multiply by 2ⁿ |
| `SHR` | Shift right (logical) | `SHR dest, count` | Logical divide by 2ⁿ |
| `ROL` | Rotate bits left | `ROL dest, count` | Bitwise rotation (carry not affected) |
| `ROR` | Rotate bits right | `ROR dest, count` | Bits wrap around |
| `RCL` | Rotate through carry left | `RCL dest, count` | Carry flag used as extra bit |
| `RCR` | Rotate through carry right | `RCR dest, count` | Carry flag used as extra bit |
| `CLC` | Clear carry flag | No operand | CF = 0 |
| `STC` | Set carry flag | No operand | CF = 1 |
| `CMP` | Compare (like subtract) | `CMP op1, op2` | Sets flags based on (op1 - op2) |
| `TEST` | Bitwise AND for flags | `TEST op1, op2` | Sets ZF, SF; no result stored |
| `BT` | Check specific bit | `BT op1, op2` | Copies to CF bit specified by op2 |
| `LEA` | Load Effective address | `LAE reg, m` | Load effective address calculation, also useful for Math |
| `XLAT` | Perform table translation from AL to AL | `XLAT ` | RBX implicit operand holds Table address, while AL implicit operand holds target character |

---

### 🔀 **Jump Instructions (J?? Family)**

| Instruction   | Condition Checked         | Meaning                             |
| ------------- | ------------------------- | ----------------------------------- |
| `JMP`         | Unconditional             | Always jump                         |
| `JE` / `JZ`   | ZF = 1                    | Jump if equal / zero                |
| `JNE` / `JNZ` | ZF = 0                    | Jump if not equal / not zero        |
| `JA`          | CF = 0 and ZF = 0         | Jump if above (unsigned >)          |
| `JAE`         | CF = 0                    | Jump if above or equal (unsigned ≥) |
| `JB`          | CF = 1                    | Jump if below (unsigned <)          |
| `JBE`         | CF = 1 or ZF = 1          | Jump if below or equal (unsigned ≤) |
| `JG`          | ZF = 0 and SF = OF        | Jump if greater (signed >)          |
| `JGE`         | SF = OF                   | Jump if greater or equal (signed ≥) |
| `JL`          | SF ≠ OF                   | Jump if less (signed <)             |
| `JLE`         | ZF = 1 or SF ≠ OF         | Jump if less or equal (signed ≤)    |
| `JC`          | CF = 1                    | Jump if carry                       |
| `JNC`         | CF = 0                    | Jump if no carry                    |
| `JO`          | OF = 1                    | Jump if overflow                    |
| `JNO`         | OF = 0                    | Jump if no overflow                 |
| `JS`          | SF = 1                    | Jump if sign (negative)             |
| `JNS`         | SF = 0                    | Jump if not sign                    |
| `JP` / `JPE`  | PF = 1                    | Jump if parity even                 |
| `JNP`/`JPO`   | PF = 0                    | Jump if parity odd                  |
| `LOOP`        | RCX-- and jump if RCX ≠ 0 | Controlled looping                  |

> 🔔 Note: All conditional jumps rely on **flags** set by instructions like `CMP`, `TEST`, `SUB`, `ADD`, etc.

---

## False optimisation

From [xlat1gcc.asm](./chap09/xlat1gcc/xlat1gcc.asm)

On a modern, deeply pipelined CPU, conditional branching like this can be a performance killer if the branch predictor makes the wrong guess.

* The CPU tries to predict whether the `jb` or `ja` instruction will jump. If it predicts incorrectly, it has to discard all the work it has done speculatively, and the pipeline stalls while it fetches the correct instructions.
* If your input file is a mix of uppercase and lowercase, the branch predictor might get it wrong frequently, leading to significant performance penalties.

By eliminating the branching, you create a more predictable and streamlined code path for the CPU. The `xlat` instruction is a single, highly optimized instruction for this purpose, and the cost of an occasional `xlat` that translates a character to itself is far less than the potential cost of branch mispredictions on every loop iteration.

```asm
    ;.
    ;.
    ;.
Scan:
    xor rax, rax
    mov al, byte [rsi+rcx] ; Get character
; Skip uppercase characters
    cmp al, 41h   ; Test against 'A'
    jb Translate  ; if < 'A', must be something else, translate it
    cmp al, 5Ah   ; Test against 'Z'
    ja Translate  ; if > 'Z', must be something else, translate it
    jmp Next      ; if it's A-Z, skip translation
Translate:
    xlat
    mov byte [rsi+rcx], al
Next:
    inc rcx       ; Update loop counter
    cmp rcx, r12
    jb Scan       ; If RCX < R12 then Scan loop again
    ;.
    ;.
    ;.
```
