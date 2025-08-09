# x64ASM_sbs4/chap10/05hexdump3/makefile

.PHONY: clean

hexdump3.out: hexdump3.o
	ld -o hexdump3 hexdump3.o ../06textlib/textlib.o

hexdump3.o: hexdump3.asm
	nasm -f elf64 -g -F dwarf hexdump3.asm

clean:
	rm -fv *.o *.out
