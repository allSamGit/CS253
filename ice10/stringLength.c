//-----------------------------------------------------------------------------
// NAME
//  stringLength -- Calculate the length of a string
//
// SYNOPSIS
//  #include "myStrings.h"
//
//  int stringLength( char* s )
//
// DESCRIPTION
//  The stringLength function calculates the length of the specified string, s.
//
//  If an error arises, stringLength returns -1.
//
//-----------------------------------------------------------------------------

#include <stdio.h>
#include <string.h>
#include "myStrings.h"

int stringLength( char* s ) {
  
  
   if(s==NULL){
    
    return -1;
    
  }
  int stringLength=0;

  //Craft code here to calculate the length of the string referenced by s
   
  

  //Return the length of the string
  stringLength=strlen(s);
  

 
  
  return stringLength;  
  
  
  
}
