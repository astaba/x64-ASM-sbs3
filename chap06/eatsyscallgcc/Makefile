# x64ASM_sbs3/chap06/eatsyscallgcc/Makefile
# INFO:
# -fno-pie: compiling flag passed donw from gcc to affect gas compiling
#           by preventing compilation PIE friendly relocatable object file.
#           In the present setup it is irrelevant since NASM is compiling.
# -no-pie : linking flag passed down from gcc to prevent ld from linking a
#			PIE executable. Most importantly it trumps the status of PIC
#			(-fno-pie) whether set or not at the compiling stage.
#

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
