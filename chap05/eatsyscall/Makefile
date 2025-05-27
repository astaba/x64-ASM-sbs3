# x64ASM_sbs3/chap05/eatsyscall/Makefile
# FIX: Nerver PATH, instead: VPATH

.PHONY: all clean
.DELETE_ON_ERROR:

AS = nasm
# -f elf64 = .o object modules files is generated for x64 executables
# -g       = include debug information in the .o file
# -F dwarf = debug information is to be in the dwarf format
ASFLAGS = -f elf64 -g -F dwarf
ASSEMBLY_LISTING =

SOURCES = \
		  eatsyscall.asm
OBJECTS = $(subst .asm,.o,$(SOURCES))
BINARIES = $(subst .asm,.out,$(SOURCES))

all: $(BINARIES)

$(BINARIES): %.out: %.o
	ld $< -o $@

# $(word 1,$(OBJECTS)): ASSEMBLY_LISTING = -l eatsyscall.lst
$(OBJECTS): %.o: %.asm
	$(AS) $(ASFLAGS) $< $(ASSEMBLY_LISTING) -o $@

clean:
	rm -fv *.out *.o *.lst eatsyscall
