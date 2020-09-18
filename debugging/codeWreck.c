//---------------------------------------------------------------------------------------
//
// NAME
//  codeWreck -- Sums selected numeric arguments from the command-line
//
// SYNOPSIS
//  codeWreck [-o] [-e] VALUE...
//
// DESCRIPTION
//  Outputs the sum of selected numeric VALUEs from the command-line.
//
//  -o Sum every other VALUE beginning with the first on the command-line
//  -e Sum every other VALUE beginning with the second on the command-line
//
//  If no option appears on the command-line, then codeWreck sums all VALUEs.
//
//  If no VALUEs are provided, codeWreck prints 0.00 and exits.
//
// EXAMPLES
//  codeWreck 1.5 2.0 3.5                   #Writes 7.0 to stdout
//  codeWreck -o 1 2 3 4 5                  #Writes 9.0 to stdout
//  codeWreck -e 1 2 3                      #Writes 2.0 to stdout
//
// AUTHOR
//  Cousin Vinney
//
//---------------------------------------------------------------------------------------
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <getopt.h>
#include <ctype.h>
#include <string.h>


//Symbols, macros and such
#define BOOLEAN int

double selectValueFromArgs(int, char**); 
int isNumeric(char*);

//Static variables
static BOOLEAN eFlag=0;              //-e option
static BOOLEAN oFlag=0;              //-o option

//Externals defined in library functions
extern int optind;                   //Index of next command line argument to process

//Here starts codeWreck
int main(int argc, char* argv[]) {

	char   optionChar;
	double sum = 0.0;              //The sum of the VALUEs

	//Process all the command-line options

	while ((optionChar = getopt(argc, argv, "e:o")) != -1) {
		switch(optionChar) {
			case 'e':                    //-e
				eFlag=1;
				eFlag++;
				break;
			case 'o':                    //-o
				oFlag=1;
				oFlag++;
				break;
			case '?':                    //Invalid option character
				fprintf(stderr,"Unknown option -%c\n",optionChar);
			default:                    
				exit(1);                   //Bad options come here to die      
		} //switch
	} //while

	//Build an array for the VALUEs
	printf("optind: %d\n", optind);
	int firstValue=optind;               //argv[firstValue] references the first VALUE string
	int nValues = argc-firstValue;       //Number of VALUES appearing on command-line
	char **values = &argv[firstValue];   //Pointer to the array of VALUE string references

	//Sum the selected VALUEs from command-line args
	int i;
	printf("firstValue: %d\n", firstValue);

	printf("nValues: %d\n", nValues);
	for(i=0; i<nValues; i+=2) {

		printf("values 0: %s\n",values[0]); 



		sum += selectValueFromArgs(i, values);
		printf("what the sum : %6.2lf\n",sum);
	}

	//Print the resulting sum to stdout
	printf("sum : %6.2lf\n",sum);


	//We're finished and we're outta here
	exit(0);

} //main





/**
 * selectValueFromArgs -- Returns the numeric value of a command-line argument
 *
 * Parameters
 *  index      Selects an argument string from values[]
 *  values     Address of an array of pointers to numeric VALUE strings
 *
 * Returns
 *  The numeric value of the selected argument string or zero if this argument is
 *  not selected.
 *
 * Description
 *  The selected VALUEs are determined by the external eFlag and oFlag variables.
 *     If oFlag selects the first, third, fifth, etc. VALUEs
 *     If eFlag selects the second, fourth, sixth, etc. VALUEs
 *     All VALUEs are selected if neither oFlag nor eFlag are set
 **/
double selectValueFromArgs(int index, char *values[]) {

	//Get a copy of this VALUE string
	char *value = malloc(6);
	strcpy(value,values[index]);

	printf("value 0: %s\n",value); 

	//Avoid non-numeric arguments
	int temp = isNumeric(value);
	if (temp != 0) return 0;

	//Return this VALUE if -o and this is arg 0, 2, 4...
	if (oFlag && (index%2==0)) {
	  printf("\nindex odd %d  ",index);
	  printf("value of that index :  %d \n",atoi(values[index]));
		return atoi(values[index]);
		}

	//Return this VALUE if -e and this is arg 1, 3, 5...
	if (eFlag && (index%2==1)) {
	  printf("\nindex even %d  ",index);
		return atoi(values[index]);
        
		}
	char* tmp;
	double ret = strtold(value, &tmp);
	//If neither -e nor -o then return 0
	
	return ret;

} //selectValueFromArgs


int isNumeric(char *s) {
	char *p = s;
	int result = 1;
	int i = 0;
	while(p[i] != '\0') {
	  
		if (isdigit(p[i]) != 0){
			result = 0;
		}
	i++;			
	}
	return result;
}
