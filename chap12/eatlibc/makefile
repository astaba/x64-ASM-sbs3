# x64ASM_sbs4/chap12/eatlibc/makefile

.PHONY: all clean
.DELETE_ON_ERROR:

CC       = gcc
AS       = nasm
CFLAGS   = -m64 -fno-pie -no-pie -Wall
LDFLAGS  = -g
ASFLAGS  = -f elf64 -g -F dwarf

SOURCES  = $(wildcard *.asm)
OBJECTS  = $(subst .asm,.o,$(SOURCES))
BINARIES = $(subst .asm,.out,$(SOURCES))

all: $(BINARIES)

$(BINARIES): %.out: %.o
	$(CC) $(CFLAGS) $(LDFLAGS) $< -o $@

$(OBJECTS): %.o: %.asm
	$(AS) $(ASFLAGS) $< -l $(basename $(@F)).lst -o $@

clean:
	rm -fv *.out *.o *.lst
