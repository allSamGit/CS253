#-------Define names of all the object files in this project
OBJ = main.o f1.o f2.o f3.o
#-------Define the name of the resulting released product
EXE = myprog
#-------Define options passed by make to the compiler
CFLAGS=-Wall
#-------Define the name of the compiler to be used
CC = gcc
#-------Dependency check
DEPS = main.c myHeader.h 

#-------Define target "all" for building the executable(s)

all: $(EXE)

#-------Rule for linking the executable product

$(EXE): $(OBJ)  
	$(CC) $(CFLAGS) $^ -o $@

main:  $(OBJ)
	gcc -o $@ $^ $(CFLAGS)

clean: 
	rm -f *.o $(EXE)

%.o: %.c $(DEPS) 
	$(CC) -c -o $@ $< $(CFLAGS)



