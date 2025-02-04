# Compiler and linker flags
# FIX: Nerver PATH, instead: VPATH
AS = nasm
ASFLAGS = -f elf64 -g -F dwarf
# Paths and filenames
EXEC = eatsyscall.out

.PHONY: all clean run

# Default target
all: $(EXEC)

# Ensure the bin directory exists
$(EXEC): eatsyscall.o
	ld -o $@ $^

eatsyscall.o: eatsyscall.asm
	$(AS) $(ASFLAGS) $< -l eatsyscall.lst

run: $(EXEC)
	./$(EXEC)

clean:
	rm -fv $(EXEC) eatsyscall.o eatsyscall.lst
