# x64ASM_sbs4/chap08/eastsyscall/Makefile
# CTRL-X + 2: to shift gdb TUI pane

.PHONY: all clean
.DELETE_ON_ERROR:

# CC = gcc
# AS = nasm

CFLAGS = -m64 -fno-pie -no-pie -Wall
# CFLAGS = -Wall
# LDFLAGS = -g
# ASFLAGS = -f elf64 -F dwarf

SOURCES = $(wildcard *.asm)
OBJECTS = $(subst .asm,.o,$(SOURCES))
BINARIES = $(subst .asm,.out,$(SOURCES))

all: $(BINARIES)

# $(BINARIES): %.out: %.o
# 	gcc $(CFLAGS) $< -o $@
$(BINARIES): %.out: %.o
	ld $< -o $@

$(OBJECTS): %.o: %.asm
	nasm -g -f elf64 -F dwarf $< -l $(basename $(@F)).lst

clean:
	@rm -fv *.out *.o *.lst

# eatsyscall: eatsyscall.o
# 	ld -o eatsyscall eatsyscall.o
# eatsyscall.o: eatsyscall.asm
# 	nasm -f elf64 -g -F dwarf eatsyscall.asm -l eatsyscall.lst
