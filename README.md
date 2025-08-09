# Assembly Language

x64 Assembly Language Step-by-Step 4TH Edition by Jeff Duntemann

## Building

The variable names `CFLAGS`, `ASFLAGS`, and `LDFLAGS` are a common convention used to organize flags for the C compiler, assembler, and linker, respectively.

Here's a breakdown of which flags go to which actor, with a special focus on the `-g` flag:

-----

### C Compiler (GCC)

  * **`CFLAGS = -m64 -fno-pie -no-pie -Wall`**: These flags are sent to `gcc` when it compiles C source code. In your `Makefile`, `gcc` is only used to link the object file, so these flags aren't directly applied to a compile step. However, if you had C code, they would be used.
      * `-m64`: Generates code for a 64-bit target.
      * `-fno-pie`, `-no-pie`: Disable Position Independent Executable, which is important for certain types of assembly code.
      * `-Wall`: Turns on all standard compiler warnings.

-----

### Assembler (NASM)

  * **`ASFLAGS = -f elf64 -F dwarf`**: These are flags for `nasm`.
      * `-f elf64`: Specifies the output format as 64-bit ELF, which is the standard format for Linux executables.
      * `-F dwarf`: Specifies the debug information format. DWARF is a standard format for debuggers. This flag is directly related to the `-g` flag's purpose.

-----

### Linker (GCC and `ld` under the hood)

  * **`LDFLAGS = -g`**: This is a flag for the **linker**, which, in your `Makefile`, is invoked by `gcc`. When you run `gcc` to link object files, it automatically calls the linker (`ld`) behind the scenes.
      * **`-g`**: This flag tells the linker to embed debugging symbols and information into the final executable. These symbols are essential for using a debugger like `gdb` to inspect variables, set breakpoints, and step through your code. It works in conjunction with the `-F dwarf` flag you passed to `nasm`, as `nasm` generates the raw debugging data in the object file, and the linker incorporates that data into the final executable.

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

## The Standard Rules (x64 Linux System V ABI)

The operating system defines a contract for how functions should handle registers. This contract is called the Application Binary Interface (ABI). Registers are divided into two categories:

1.  **Caller-Saved (Volatile):** `RAX`, `RCX`, `RDX`, `RSI`, `RDI`, `R8`-`R11`.
    * A function is **free to use and change** these registers without saving them.
    * If the **calling routine** needs the values in these registers after the function returns, it **must save them itself** (e.g., `push rax`).

2.  **Callee-Saved (Non-Volatile):** `RBX`, `RBP`, `RSP`, `R12`-`R15`.
    * A function **must preserve** these registers.
    * If the **called function** wants to use one of these, it **must save the original value** (e.g., `push rbx`) at the beginning and restore it (`pop rbx`) before it returns.

### The Rationale for This Code's Choices

Your observation is correct: many of the `push` and `pop` instructions in this code are technically unnecessary according to the ABI.

* **`ClearLine`**, **`PrintLine`**, and **`LoadBuff`** are all saving and restoring caller-saved registers (`RAX`, `RCX`, `RDX`, `RSI`, `RDI`).
* The `syscall` instruction is a special case that can clobber many registers, which might explain the cautiousness in `PrintLine` and `LoadBuff`.

The programmer's rational is likely: **"I will save and restore every register my function touches, regardless of the ABI rules."** This is a simple, robust rule that guarantees no accidental side effects, but it comes at a cost.

### The Trade-off: Correctness vs. Performance

* **Pros of this approach:** The code is very safe. You never have to worry about a register's value being unexpectedly changed by a function call. It's easy to read and debug.
* **Cons of this approach:** It is **less efficient**. Each `push` and `pop` is a memory access to the stack, which is slower than using a register. The `syscall` itself is slow, but adding extra `push` and `pop` operations unnecessarily increases the overhead of the entire program.

### Conclusion

The code works and is correct, but it is not optimized for performance. A more efficient and standard approach would be to:

* **Only save callee-saved registers** (`RBX`, `RBP`, etc.) that are used in a function.
* Let the **calling function** be responsible for saving any caller-saved registers it needs to preserve across a function call.

Your critical eye has identified a key point of discussion for any assembly programmer: striking a balance between code correctness, readability, and performance

## Embedding data in the .code segment

From [newlinestest.asm](./chap10/newlines/newlinestest.asm).

Advanced concept in assembly: **embedding data directly within the code section**. This is indeed a departure from typical C programming habits where data is clearly separated into `.data` or `.rodata` sections.

Let's break down the concept of "constant" in this context and where `EOLs` is located.

### The Concept of "Constant" in this Procedure

In C, when you declare a `const` variable, it means its *value* cannot change after initialization. In assembly, "constant data" often refers to data whose value is known at assembly time and doesn't change during program execution.

The key here is *where* that constant data is stored:

* **Traditional C/Assembly:** Constants are typically put in the `.data` section (if mutable, though `const` in C would typically go to `.rodata` for read-only data). This separates data from instructions.
* **This Assembly Example:** The `EOLs` data is placed directly after the `ret` instruction within the `.text` (code) section.

The comment "This procedure demonstrates placing constant data in the procedure definition itself, rather than in the .data or .bss sections" is the crucial part. It's a technique, not a standard practice for all constant data.

### Where is `EOLs` Located at Runtime?

You are correct that `EOLs` is defined "out of any segment" in the sense that it's not explicitly in `.data` or `.bss`. However, when the assembler processes this code, it will place `EOLs` directly into the **`.text` segment** (the code segment) of the final executable.

Here's why and what happens:

1.  **Assembler's Job:** The assembler reads your `.asm` file. When it encounters `db 10,10,...`, it simply converts those values into bytes and places them sequentially in the output file wherever it is currently building the `.text` segment.
2.  **`ret` Instruction:** The `ret` instruction pops the return address from the stack and jumps to it. It does *not* know or care what bytes immediately follow it in memory.
3.  **Execution Flow:**
    * The `newlines` function is called.
    * It executes its instructions (`cmp`, `ja`, `mov`, `syscall`).
    * It hits `ret`. The CPU pops the return address and jumps *back to the caller*.
    * The CPU **never executes the `EOLs` bytes as instructions** because the `ret` instruction diverts the program flow.

### Why Do This? (Pros and Cons)

**Pros:**

* **Locality/Cache:** For very small, frequently accessed lookup tables or strings, placing them directly after the code that uses them can sometimes improve cache performance (though this is often negligible for such small data).
* **Self-Contained Code:** It makes a function truly self-contained, as its data is right there with its instructions. This can be useful for position-independent code (PIC) or very specialized embedded systems.
* **Short Jumps:** Sometimes, it can allow for smaller, more efficient relative addressing if the data is very close to the instructions.

**Cons (and why it's generally discouraged for larger data):**

* **Readability:** It makes the code harder to read and maintain, as data is mixed with instructions.
* **Security (Executable Stack/Data):** Modern operating systems enforce **W^X (Write XOR Execute)**. This means memory pages are either writable OR executable, but not both.
    * The `.text` segment is typically marked **executable (X)** but **read-only (R)** and **non-writable (W)**.
    * The `.data` and `.bss` segments are typically marked **readable (R)** and **writable (W)** but **non-executable (X)**.
    * If `EOLs` is in the `.text` segment, it will be read-only. If your code ever tried to modify `EOLs` (which it doesn't here), it would cause a segmentation fault.
    * More importantly, if `EOLs` were ever accidentally executed as code (e.g., if a `jmp` or `call` instruction landed on it due to a bug), it would likely crash the program.
* **Debugging:** It can make debugging more confusing, as a debugger might try to disassemble the data as if it were instructions.

### Your Specific Questions:

* **"Constant" concept:** In this case, "constant" means the data (`EOLs`) is fixed at compile time and is placed directly into the executable's code section. It's not meant to be changed during runtime.
* **`EOLs` location:** At runtime, `EOLs` is located in the **`.text` segment** (the code segment) of your program's memory space.

This technique is a valid, though often niche, way to organize data in assembly. It's good that you questioned it, as it's not the most common or generally recommended practice for larger data sets due to the security and maintenance implications.


## GLOBAL declarations location

From [textlib.asm](./chap10/06textlib/textlib.asm).

```asm
; Exported data items and procedures:
GLOBAL  Buff, DumpLine, ASCLine, HexDigits, BinDigits
GLOBAL  ClearLine, DumpChar, NewLines, PrintLine, LoadBuff
```

The code example you've provided does indeed seem to contradict the rule stated in the book (page 350 line -7). This kind of discrepancy can be quite confusing, but it highlights a key difference between theoretical rules and practical compiler/assembler behavior.

The rule from the book is a best practice for clarity and portability, but it's not a strict requirement for most modern assemblers, including NASM (which is commonly used for x64 assembly).

The reason the provided example works despite not placing the `GLOBAL` directive at the very top of the `.data` or `.text` sections is due to how the assembler and linker process the code.

---

### How Assemblers and Linkers Handle `GLOBAL`

* **The Assembler's Role**: The assembler's primary job is to convert your human-readable assembly code into machine code and object files (`.o` files). When it encounters a label like `Buff` or `ClearLine`, it records its location (its offset from the beginning of its section). When it sees the `GLOBAL` directive, it doesn't need to know the label's address immediately; it just flags that label as a **public symbol**. It saves this information in the object file's symbol table.

* **The Linker's Role**: The linker's job is to combine multiple object files and libraries into a final executable. It reads the symbol tables from all the object files. When it sees a public symbol (like `GLOBAL Buff`), it knows that this symbol is meant to be visible to other files. When another file needs to refer to `Buff`, the linker finds `Buff`'s address in the correct object file and "patches" the calling code with that address.

Because the assembler and linker work in two passes, the assembler doesn't need the `GLOBAL` directive to be physically located before the label is defined. It's smart enough to read the entire file, gather all label definitions and `GLOBAL` directives, and then build the symbol table for the linker.

The book's advice is a "rule of thumb" for organization. It's good practice to declare global symbols early because:
1.  **Readability**: It makes it immediately clear which symbols are meant to be used by other parts of the program or other files.
2.  **Portability**: Some older or more rigid assemblers might require a specific order, so following this rule ensures the code is compatible with a wider range of tools.

In your example, the assembler sees the label `DumpLine`, then later sees `GLOBAL DumpLine`. It has all the information it needs to correctly create the object file, so there is no error. The final `DotXlat` label also defines an item in the `.data` section, even though the `GLOBAL` directives were placed before it. This works because the assembler reads the whole section to determine the final offsets for everything.

## Equates: EQU

From [textlib.asm](./chap10/06textlib/textlib.asm).

```asm
DumpLine:   db " 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
DUMPLEN     EQU $-DumpLine
ASCLine:    db "|................|",10
ASCLEN      EQU $-ASCLine
FULLLEN     EQU $-DumpLine

; The equates shown above must be applied to variables to be exported:
DumpLength: dq DUMPLEN
ASCLength:  dq ASCLEN
FullLength: dq FULLLEN
BuffLength: dq BUFFLEN
```

The confusion here lies in the dual use of the term "equates" and the distinction between an immediate value and a memory-based variable.

In the context of the assembly code snippet, the "equates" are the lines that use the `EQU` directive. They define a symbol (a name) that represents a specific, constant value.

```assembly
BUFFLEN EQU 10h
DUMPLEN EQU $-DumpLine
```

  * **`BUFFLEN`** is a name for the constant value `10h` (16 in decimal).
  * **`DUMPLEN`** is a name for the constant value calculated by `$-DumpLine`. The `$` symbol means "current address," so this `EQU` calculates the length of the `DumpLine` string by subtracting its starting address from the current address.

Equates are handled by the assembler during the assembly process. By the time the code is converted into a machine-readable format, every instance of `BUFFLEN` is replaced with the value `16`. They do not exist as variables in the final program's memory. They are just a convenience for the programmer, like `#define` in C.

-----

### Why the Book Recommends Storing Equates in Variables

The book's author correctly points out that while some modern assemblers (like NASM) can export equates, it's not a universal feature. To ensure the value is available to other modules, it's safer and more portable to store the value in a named variable in a memory section like `.data`.

This is what the example lines you quoted are doing:

```assembly
DumpLength: dq DUMPLEN
ASCLength: dq ASCLEN
FullLength: dq FULLLEN
BuffLength: dq BUFFLEN
```

  * **`DumpLength: dq DUMPLEN`**: This line creates a variable in the `.data` section called `DumpLength`. It reserves a 64-bit quadword (`dq`) of memory and initializes it with the **constant value** defined by the `DUMPLEN` equate.

The assembler first calculates the value of `DUMPLEN` (a number), then places that number into the memory reserved for the `DumpLength` variable. Now, `DumpLength` is a real, tangible piece of data in your program's memory that can be exported globally and accessed by other parts of your code. You can load its value into a register, modify it, or perform other operations that are not possible with a simple equate.
