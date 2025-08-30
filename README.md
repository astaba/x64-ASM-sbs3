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

Both `-fno-pie` and `-no-pie` are GCC compiler flags used to control the generation of Position-Independent Executables (PIE), but they work at different stages of the compilation process.

* **`-fno-pie`**: This is a **compiler** flag. It tells the compiler to produce object files (`.o`) that are **not** position-independent. This affects how the code and data within the object file are generated, assuming a fixed memory address.
* **`-no-pie`**: This is a **linker** flag. It tells the linker to produce a final executable that is **not** a PIE. This is the more common and direct way to create a non-PIE executable, as it overrides any position-independent settings that might have been passed to the compiler.

In modern GCC versions, a common flag like `-pie` is actually an alias for `-fpie` (compiler) and `-pie` (linker). Similarly, `-no-pie` is an alias for `-fno-pie` and `-no-pie`, making the distinction less critical for general use, but it's important to understand for fine-grained control over the build process.

Together (`-fno-pie` `-no-pie`, but mostly `-no-pie`): ensures both compilation and linking are **non-PIE**, giving you a classic flat executable with fixed addresses — what you usually want in low-level experiments (like your assembly + GDB work).

Rule of thumb for your assembly + debugging work only if you entrust both compiling and linking to GCC:

```bash
# Always use both:
gcc -no-pie -fno-pie -o prog prog.o
```

So you’re guaranteed predictable addresses (`_start`, `main`, etc.) and breakpoints like `b _start+0x33` will work correctly.

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
| `ADD` | Add values | `ADD dest, src` | `ADD RAX, 5` → RAX += 5 |
| `AND` | Bitwise AND | `AND dest, src` | Clears bits |
| `BT` | Check specific bit | `BT op1, op2` | Copies to CF bit specified by op2 |
| `CALL` | | | |
| `CLC` | Clear carry flag | No operand | CF = 0 |
| `CLD` | | | |
| `CMP` | Compare (like subtract) | `CMP op1, op2` | Sets flags based on (op1 - op2) |
| `DEC` | Decrement | `DEC reg/mem` | Decreases value by 1 |
| `DIV` | Unsigned divide | `DIV src` | Divides RDX\:RAX by `src`, result in RAX, remainder in RDX |
| `INC` | Increment | `INC reg/mem` | Increases value by 1 |
| `LEA` | Load Effective address | `LAE reg, m` | Load effective address calculation, also useful for Math |
| `LOOP` | | | |
| `LOOPNZ` | | | |
| `MOVS/B/W/D/Q` | | | |
| `MOVSX` | Sign-extend | `MOVSX dest, src` | Extends sign bit (e.g. byte → dword) |
| `MOV` | Copy data | `MOV dest, src` | `MOV RAX, RBX` copies RBX into RAX |
| `MUL` | Unsigned multiply | `MUL src` | Implicitly uses RAX; result in RDX\:RAX |
| `NEG` | Negate (two's complement) | `NEG reg/mem` | `NEG RAX` → RAX = -RAX |
| `NOT` | Bitwise NOT | `NOT reg/mem` | Inverts all bits |
| `OR` | Bitwise OR | `OR dest, src` | Sets bits |
| `POPQW` | Pop quadword manually | (Non-standard; maybe macro alias) | `POP rax` is standard |
| `POP` | Pop from stack | `POP reg/mem` | Reads value from \[RSP], increments RSP |
| `PUSHQW` | Push quadword (64-bit) manually | (Non-standard; maybe macro alias) | `PUSH rax` is same |
| `PUSH` | Push to stack | `PUSH reg/mem/imm` | Decrements RSP, writes value |
| `RCL` | Rotate through carry left | `RCL dest, count` | Carry flag used as extra bit |
| `RCR` | Rotate through carry right | `RCR dest, count` | Carry flag used as extra bit |
| `REP` | | | |
| `RET` | | | |
| `ROL` | Rotate bits left | `ROL dest, count` | Bitwise rotation (carry not affected) |
| `ROR` | Rotate bits right | `ROR dest, count` | Bits wrap around |
| `SHL` | Shift left | `SHL dest, count` | Multiply by 2ⁿ |
| `SHR` | Shift right (logical) | `SHR dest, count` | Logical divide by 2ⁿ |
| `STC` | Set carry flag | No operand | CF = 1 |
| `STD` | | | |
| `STOS/B/W/D/Q` | | | |
| `SUB` | Subtract src from dest | `SUB dest, src` | `SUB RAX, 5` → RAX -= 5 |
| `TEST` | Bitwise AND for flags | `TEST op1, op2` | Sets ZF, SF; no result stored |
| `XCHG` | Swap values | `XCHG reg1, reg2` | `XCHG RAX, RBX` |
| `XLAT` | Perform table translation from AL to AL | `XLAT ` | RBX implicit operand holds Table address, while AL implicit operand holds target character |
| `XOR` | Bitwise XOR | `XOR dest, src` | Toggles bits; `XOR RAX, RAX` → zeroing idiom |

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
| `JRCXZ`       | RCX = 0                   | Jump if RCX is null                 |
| `LOOP`        | RCX-- and jump if RCX ≠ 0 | Controlled looping                  |
| `LOOPNZ`      | RCX-- and jump if ZF = 0 and RCX ≠ 0 | Controlled looping       |

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

## OS and .bss liniency

From [showargs2.asm](./chap11/showargs2/showargs2.asm).

> **The issue**:  
> `mov [ArgLens+rbx*8],rdi    ; Put length of arg into table`  
> I did not understand where this instruction would put the legnth for the tenth arguments since RBX is 1-based and only 10 resq were set to define ArgLens and I thougth when RBX==10 and the 0-index array AgrLens is guided by an index of 10 some out of bound phenomenon would occur and crash the code. So I took all that program to gbd and carefully monitored the stack and .bss segment.  
> What I saw blowed my mind. The 10 qword are actually reserved for AgrLens but string length are stored from the second qword while the first remains empty. The mind boggling part is when RBX==10, the tenth arguments string length is stored at the eleventh qword without fault and in total disregard of the fact that only 10 qwords were reserved. So I ran in gdb:  
> `(gdb) x/16xg &ArgLens`  
> And I see a bunch of zero out qword as if waiting to be populated.  
> Ok, then the res/b/w/d/q instruction seems not compelling so what is the point of reserving when the .bss segment seems to be a "Far West free for all" ???  

This is a fascinating observation that gets to a fundamental aspect of how the C runtime and the Linux linker work. Your discovery is a perfect example of a behavior that seems to defy the rules but is actually a side effect of how memory is managed.

### The "Far West" is an Illusion

The behavior you're seeing isn't because `.bss` is a "free for all." It's because the Linux kernel and the linker are more lenient than you might expect. When you declare `ArgLens resq 10`, you're asking for 80 bytes of uninitialized memory. The linker places this variable at a specific location in the `.bss` section. However, the operating system doesn't just allocate the 80 bytes you asked for. It typically allocates memory in larger chunks called **pages**. On x86-64 Linux, a memory page is usually **4096 bytes** long.

When the OS gives your program a memory page for its `.bss` segment, your `ArgLens` variable, which is only 80 bytes, sits at the beginning of that page. Your program then has the full 4096-byte page to work with. Since `ArgLens` is so small, there is a lot of extra space after it within the same page. When your code writes to the 11th quadword (`ArgLens + 10*8`), it's writing to an address that is only 80 bytes away from the start of `ArgLens`—well within the bounds of the larger 4096-byte page.



Because you're not writing to a different memory page or an area with a different security permission (like a read-only code segment), the operation doesn't cause a segmentation fault.

### The Purpose of `resq`

The `resq` instruction is not "compelling" in the sense of a strict boundary check that will halt your program. It's a directive for the assembler and linker. Its purpose is to:

1.  **Reserve Space:** It tells the assembler how much memory to reserve in the `.bss` segment for your variable.
2.  **Symbol Placement:** It creates a symbol (`ArgLens`) that points to the beginning of this reserved block.
3.  **Linker Allocation:** It signals to the linker to place this reserved block in a read/write segment and to size that segment appropriately.

The "out of bounds" crash you expected would only happen if you wrote to an address that falls outside of the memory pages allocated to your program. In this case, you are just writing into the leftover space of the same page that `ArgLens` occupies. **The operating system doesn't know (or care) that your assembly code thinks `ArgLens` is only 80 bytes; it just sees a valid memory write to a valid address.**

Your finding is a perfect demonstration that the "rules" of assembly are often governed by the underlying behavior of the operating system and memory management units. The program works by pure chance—a happy accident of a small allocation request landing in a much larger allocated memory page. In a larger or more complex program, writing past a variable's reserved space would likely cause a crash, as you might overwrite other data or stray into an unallocated page.

## glibc

```asm
;------------------------------------------------------------------------------
;  This routine provides 6 entry points, and returns 6 different "sizes" of
;  pseudorandom numbers based on the value returned by rand. Note first of
;  all that rand pulls a 31-bit value. The high 16 bits are the most "random"  ← Explanation 1
;  so to return numbers in a smaller range, you fetch a 31-bit value and then
;  right-shift it to zero-fill all but the number of bits you want. An 8-bit
;  random value will range from 0-255, a 7-bit value from 0-127, and so on.
;  Respects RBP, RSI, RDI, RBX, and RSP. Returns random value in RAX.          ← Explanation 2

pull31: mov rcx,0       ; For 31 bit random, we don't shift
        jmp pull
pull20: mov rcx,11      ; For 20 bit random, shift by 11 bits
        jmp pull
pull16: mov rcx,15      ; For 16 bit random, shift by 15 bits
        jmp pull
pull8:  mov rcx,23      ; For 8 bit random, shift by 23 bits
        jmp pull
pull7:  mov rcx,24      ; For 7 bit random, shift by 24 bits
        jmp pull
pull6:  mov rcx,25      ; For 6 bit random, shift by 25 bits
        jmp pull
pull4:  mov rcx,27      ; For 4 bit random, shift by 27 bits

pull:
    push rcx            ; rand trashes rcx; save shift value on stack          ← Explanation 3
    call rand           ; Call rand for random value; returned in RAX
    pop rcx             ; Pop stashed shift value back into RCX
    shr rax,cl          ; Shift the random value in RAX by the chosen factor
                        ;  keeping in mind that part we want is in CL
    ret                 ; Go home with random number in RAX
```
1. The statement about the high 16 bits being the most "random" refers to a common characteristic of older pseudo-random number generators (PRNGs), particularly those based on a Linear Congruential Generator (LCG) algorithm. These algorithms often produce a pattern where the **low-order bits** are highly predictable and cycle through a short, repeating pattern. The **high-order bits**, on the other hand, change more unpredictably and have a much longer cycle, making them statistically more "random." So, if you need a truly random value, you'd want to use the high bits.
2. "Respects registers" means that the procedure follows the standard calling convention (the x64 System V ABI) for managing registers. This ensures that the function can be safely used without causing unintended side effects in the calling code. 
    * **Preserved Registers:** These registers are expected to hold their values across a function call. If a function needs to use one of them, it must save the original value to the stack first and restore it before returning. `RBP`, `RSI`, `RDI`, `RBX`, and `RSP` are all in this category. The `push` and `pop` instructions in the `pull` procedure are a prime example of this.
    * **Volatile Registers:** These registers can be freely modified by a function. The calling code should not assume their values will be preserved. `RAX` is a volatile register, often used for return values.
3. The `RCX` register is protected from `rand()` because `rand()` is a C standard library function, and it follows the x64 System V ABI. In this ABI, **`RCX` is a volatile register**. `rand()` is free to use and modify it for its own purposes without saving its original value. The `pull` procedure saves the shift count (which was originally placed in `RCX` by the `pullXX` entry points) by pushing it onto the stack before calling `rand`. After `rand()` returns, the procedure pops the saved value back into `RCX`, ensuring the correct shift count is available for the `shr` instruction.

## `MMX` vs `SSE` (or `XMM`) registers

### MMX Registers

**MMX (Multimedia Extension)** registers were introduced by Intel in 1997. They are a set of eight 64-bit registers (`MM0` to `MM7`). Their purpose was to accelerate multimedia applications, like graphics and audio processing, by allowing a single instruction to operate on multiple pieces of data at once. This is known as **SIMD (Single Instruction, Multiple Data)**. The main limitation of MMX registers is that they are an alias for the old x87 FPU (Floating-Point Unit) registers. This meant you couldn't use MMX and x87 floating-point instructions at the same time without a performance penalty, as you had to switch between modes.

***

### SSE Registers

**SSE (Streaming SIMD Extensions)** registers were introduced in 1999 as the successor to MMX. SSE provides a completely new set of eight 128-bit registers (`XMM0` to `XMM7`) and a dedicated set of instructions. SSE registers are separate from the x87 FPU, which eliminated the performance penalty of switching between modes. This makes them ideal for floating-point calculations, as they can operate on multiple floating-point numbers simultaneously. Later versions of SSE (SSE2, SSE3, etc.) added more instructions and expanded the register count to 16 (`XMM0` to `XMM15`) on 64-bit systems.

***

### XMM Registers

**XMM** is simply the name for the set of registers introduced with SSE. So, when people refer to **XMM registers**, they are talking about the **SSE registers**.
