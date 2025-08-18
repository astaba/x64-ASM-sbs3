# x64ASM_sbs4/chap11/vidbuff1/makefile

.PHONY: all clean
.DELETE_ON_ERROR:

AS       = nasm
ASFLAGS  = -f elf64 -g -F dwarf

SOURCES  = $(wildcard *.asm)
OBJECTS  = $(subst .asm,.o,$(SOURCES))
BINARIES = $(subst .asm,.out,$(SOURCES))

all: $(BINARIES)

$(BINARIES): %.out: %.o
	ld $< -o $@

$(OBJECTS): %.o: %.asm
	$(AS) $(ASFLAGS) $< -l $(basename $(@F)).lst

clean:
	rm -fv *.out *.o *.lst
