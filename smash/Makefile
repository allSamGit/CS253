CC=gcc
CFLAGS=-Wall -g -I. 

all: smash 

smash: smash.o 
	$(CC) $(CFLAGS) -o $@ $^
	
clean:
	rm -f *.o smash
