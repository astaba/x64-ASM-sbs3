.PHONY: clean

textfile.out: textfile.o linlib.o
	gcc textfile.o linlib.o -o textfile.out -no-pie
textfile.o: textfile.asm
	nasm -f elf64 -g -F dwarf textfile.asm
linlib.o: linlib.asm
	nasm -f elf64 -g -F dwarf linlib.asm
clean:
	rm -fv *.o *.out
