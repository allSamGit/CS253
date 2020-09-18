CC=gcc 
CFLAGS=-Wall -g  -I
OBJS= sigexe.o 

all: sigexe

%.o : %.c 
	$(CC) $(CFLAGS) -c $< 

sigexe: sigexe.c
	 $(CC) $(CFLAGS) $(OBJS) -o $@ $^
	
clean:
	rm -f *.o sigexe
	
	
