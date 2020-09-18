CC=gcc 
CFLAGS=-Wall -g  -I.
OBJS= smash.o history.o 

all: smash
 
%.o : %.c  
	$(CC) $(CFLAGS) -c $< 

smash: smash.c history.c
	$(CC) $(CFLAGS) -o $@ $^

test: smash 
	valgrind --leak-check=full --show-leak-kinds=all smash

clean:
	rm -f *.o smash
