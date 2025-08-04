# x64ASM_sbs4/chap09/xlat1gcc/Makefile
# CTRL-X + 2: to shift gdb TUI pane

.PHONY: all clean
.DELETE_ON_ERROR:

CC = gcc
AS = nasm

CFLAGS = -m64 -fno-pie -no-pie -Wall
# CFLAGS = -Wall
LDFLAGS = -g
ASFLAGS = -f elf64 -F dwarf

SOURCES = $(wildcard *.asm)
OBJECTS = $(subst .asm,.o,$(SOURCES))
BINARIES = $(subst .asm,.out,$(SOURCES))

all: $(BINARIES)

$(BINARIES): %.out: %.o
	$(CC) $(CFLAGS) $(LDFLAGS) $< -o $@

$(OBJECTS): %.o: %.asm
	$(AS) $(LDFLAGS) $(ASFLAGS) $< -l $(basename $(@F)).lst -o $@

clean:
	@rm -fv *.out *.o *.lst
