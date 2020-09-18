CC=gcc 
CFLAGS=-Wall -g  -I
OBJS= sigexe.o 

all: pipe

%.o : %.c 
	$(CC) $(CFLAGS) -c $< 

pipe: pipe.c
	 $(CC) $(CFLAGS) $(OBJS) -o $@ $^
	
clean:
	rm -f *.o pipe 
