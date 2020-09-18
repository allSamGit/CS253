

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#define IN 1
#define OUT 0

int main(int argc, char **argv)
{
	/*
	   Put your code here. You should create as many functions 
	   as necessary to create a modular program. We should not 
	   see ALL your code in the main function! 
	   */


	//Part 1: Command line Arguments 
	
	int hflag;
	int c;
	char *testWord = NULL;
	int testWord_size = 0;
	 
	int idx=0;

	opterr = 0;

	while ((c = getopt (argc, argv, "hm:")) != -1){
	  
	
		switch (c)
		{
		case 'm':
				testWord = optarg;
				break;
				
		case 'h':
				hflag = 1;		
				break;
		case '?':
			if (optopt == 'm'){
				fprintf (stderr, "./wc-match: option requires an argument -- 'm'\n");
				fprintf (stderr, "Option -%c requires an argument.\n", optopt);
			}else if (isprint (optopt)){
				fprintf (stderr, "Unknown option `-%c'.\n", optopt);
				
			}else{
				fprintf (stderr, "Unknown option c `\\x%x'.\n", optopt);		
			} 

			default:
				return 1; 
		}
	  
	}
	 if(hflag == 1){
		printf("-m <match> \n -h\n");
		exit(0);
		
	}
	

	if(testWord != NULL){
		testWord_size = strlen(testWord) ; // calculating length of word test
	}

	//Part 2: Word Counting in C 
	int numChars      = 0;
	int numLines      = 0;
	int numWords      = 0;	
	int numMatched    = 0;
	int numDigits[10];
	

	  for(idx=0;idx<10;idx++)
      
	    numDigits[idx]=0;
	  
	  

	//Reference: From C-example provided in CS253-resources
	char ch;
	int state=IN;
	int indexMatching = 0;
	
	ch = getchar();
	while(ch != EOF){

		//check for digits
		if(ch >= '0' && ch <= '9'){
			numDigits[ch - '0']++;
		}

		
		//check for wordcount
		if(ch == ' ' || ch == '\t' || ch == '\n'){			
			state = IN;
		} else if(state == IN) {
			state = OUT;
			numWords++;
		}

		//check for new line
		if(ch == '\n'){
			numLines++;
		}
		numChars++;//characters counting

		//Part 3: Simple word matching
		
		if(testWord != NULL){	
			if(ch == testWord[indexMatching]){
				indexMatching++;
				if(indexMatching == testWord_size) {
					numMatched++;
					indexMatching = 0;
				}			
			} else if(indexMatching == 1 && ch == testWord[indexMatching - 1]){
				indexMatching = 1;
			}	
			else{
				indexMatching = 0;
			}
		}				
		ch = getchar();
	}
	// Displaying 
	printf("words: %d\n", numWords);
	printf("chars: %d\n", numChars);
	printf("lines: %d\n", numLines);
	
	
	for(idx=0;idx<=10;idx++)
	  {
	printf("digit%d%d\n :",idx,numDigits[idx]);
	  } 
 
	if(testWord != NULL){
		printf("matched %s: %d\n", testWord , numMatched);
	}else{
		printf("matched: %d\n", numMatched);
	}

	return 0;
}
