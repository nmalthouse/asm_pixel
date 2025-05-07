asm: asm.s
	nasm -f elf64 asm.s -o asm.o

bin: stream.c asm
	gcc -lSDL3 stream.c asm.o -o stream

run: bin
	./stream

clean:
	rm asm.o

