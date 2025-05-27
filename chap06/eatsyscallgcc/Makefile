# chap06/eatsyscallgcc/Makefile
# CTRL-X + 2: to shift gdb TUI pane
.PHONY: all clean run
.DELETE_ON_ERROR:

CC = gcc
AS = nasm

# -no-pie = don't produce dynamically linked Position Independent Executable
CFLAGS = -m64 -fno-pie -no-pie -Wall
# -f elf64 = .o object modules files is generated for x64 executables
# -g       = include debug information in the .o file
# -F dwarf = debug information is to be in the dwarf format
# ASFLAGS = -f elf64 -g -F dwarf
LDFLAGS = -g
ASFLAGS = $(LDFLAGS) -f elf64
# ASSEMBLY_LISTING =
ASSEMBLY_LISTING = -l $(LISTING)

SOURCES = $(wildcard *.asm)
OBJECTS = $(subst .asm,.o,$(SOURCES))
BINARIES = $(subst .asm,.out,$(SOURCES))
LISTING = $(subst .asm,.lst,$(SOURCES))

all: $(BINARIES)

$(BINARIES): %.out: %.o
	$(CC) $(CFLAGS) $< -o $@

$(OBJECTS): %.o: %.asm
	$(AS) $(ASFLAGS) $< $(ASSEMBLY_LISTING) -o $@

run: $(BINARIES)
	./$(BINARIES)

clean:
	rm -fv *.out *.o *.lst
