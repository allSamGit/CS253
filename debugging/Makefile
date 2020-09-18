CFLAGS = -g -O0 -Wall -std=c99

codeWreck: codeWreck.o
	gcc -o $@ $(CFLAGS) $^
	
test: codeWreck
	valgrind --leak-check=full --show-leak-kinds=all codeWreck

clean:
	rm -f codeWreck *.o *~

