asm: asm.s
	nasm -f elf64 asm.s -o asm.o

bin: stream.c asm
	# the -no-pie option is needed to let us use a bss section in asm.s
	gcc -no-pie -lSDL3 stream.c  asm.o -o stream

run: bin
	./stream

clean:
	rm asm.o

