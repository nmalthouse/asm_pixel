asm: asm.s snake.s
	nasm -f elf64 asm.s -o asm.o
	nasm -f elf64 snake.s -o snake.o

bin: stream.c asm
	# the -no-pie option is needed to let us use a bss section in asm.s
	gcc -no-pie -lSDL3 stream.c  asm.o -o stream


snake: stream.c asm
	gcc -no-pie -lSDL3 stream.c snake.o -o snake
	./snake

run: bin
	./stream

clean:
	rm asm.o

