%.o: %.c myStrings.h
	gcc -c -Wall -std=c99 $< -o $@

all:	testStringLength

testStringLength: testStringLength.o stringLength.o
	gcc -Wall testStringLength.o stringLength.o -o testStringLength

clean:
	rm -f *.o testStringLength *~
