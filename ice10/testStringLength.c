//-----------------------------------------------------------------------------
// NAME
//  testStringLength -- Test the stringLength function
//
// DESCRIPTION
//  This souce file exercises the stringLength function.  The test cases
//  include:  A simple string (happy path), a one character string, a very
//  long string, an empty string, and a null pointer.
//
//  All strings (excepting the null pointer) are properly NUL terminated
//
// AUTHORS
//  02/11/18 Epoch..........................................................jrc
//-----------------------------------------------------------------------------

#include <stdio.h>
#include "myStrings.h"

//Define the length of the long string (sans NUL terminator)
#define LONGSTRING 256000  

int main(void) {

  int n;               //Just an int

  //Build test strings
  char s1[] = "ABC";
  char s2[] = "X";
  char s3[LONGSTRING+1];//Will initialize this later
  char s4[] = "";       //A NUL-terminated, empty string
  char* s5 = NULL;      //A null string

  //Initialize the long string
  for(int i=0;i<LONGSTRING;i++) s3[i]='L';
  s3[LONGSTRING] = NUL; //Don't forget the NUL-terminator

  //Test simple string
  n = stringLength(s1);
  printf("stringLength(s1)=%d\n", n);

  //Test one character string
  n = stringLength(s2);
  printf("stringLength(s2)=%d\n", n);

  //Test long string
  n = stringLength(s3);
  printf("stringLength(s3)=%d\n", n);

  //Test an empty string
  n = stringLength(s4);
  printf("stringLength(s4)=%d\n", n);

  //Test a null string
  n = stringLength(s5);
  printf("stringLength(s5)=%d\n", n);

  return 0;
}
  
