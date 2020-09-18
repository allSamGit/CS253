#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <wait.h>
#include <time.h>
#include "history.h"
#define MAXLINE 4096

/*
 * Reading the input from user, and splitting buff(string) into tokens
 */
void tokenizer(char*  buff_copyall, char* delimiter, char** tokensall_tok){
	char* token;
	token = strtok(buff_copyall, " ");
	
	//This loop helps to get all tokens (words) until end of command line
	int i = 0;
	while(token != NULL){
	tokensall_tok[i] = token;
		i++;
		token = strtok(NULL, " ");
		}
	return;
}

/*
 *exiting smash shell
 */
void exit_smash(char**  tokensall_exit, char* buff_copyexit, history* histH){
	free(tokensall_exit);
	free(buff_copyexit);

	// calling clear history function
	clear_history(histH); 
	exit(0);
	return ;
}
/*
 *Changing directory in smash shell
 */
void change_my_dir(char* dir){
	char* currentPath;
	if(chdir(dir) != 0){
		printf("error: %s does not exist\n", dir);	
	}else{
		currentPath = getcwd(NULL, MAXLINE);
		if(currentPath == NULL){
			printf("getcwd() does have error");
		}else {
			printf("%s\n", currentPath);
		}
		free(currentPath);
  	     }
	return;		
}
/*
 * Main method
 */
int main(int argc, char **argv){
	
	// Creating random number
	srand(time(NULL));
	
	// Retrieving environment variable
	const char* s = getenv("PATH");

	history init_hist = init_history(); // calling function
	char buff[MAXLINE];
	char** tokensall = (char**)malloc(sizeof(char*) * 1024);
	
	int j;	
	fprintf(stderr, "$ ");
	while(fgets(buff, MAXLINE, stdin) != NULL){
		buff[strlen(buff) - 1] = '\0';

                // Calling add history function
		add_history(buff, &init_hist); 
		
		// Allocating buff_copy
		char* buff_copy =  (char*)malloc(sizeof(char)*(strlen(buff) + 1));
		strcpy(buff_copy, buff);
		 
		// Setting tokensall to NULL
		for(j = 0; j < 1024; j++){
			tokensall[j] = NULL;
		}

		// Calling tokenizer function
		tokenizer(buff_copy, " ", tokensall);

		if(strcmp(tokensall[0], "cd") == 0){
			char* dir = buff + 3;
			// Calling change my directory function	
			change_my_dir(dir); 	
		}
		else if(strcmp(buff, "exit") == 0){
			exit_smash(tokensall, buff_copy, &init_hist);	
	        }
		else if(strcmp(buff, "history") == 0){
			// Calling cmd.. history function
			print_history(&init_hist);
		}else{
			int random = (rand() % 100) + 1 ; // random number from 1 to 100
			if(s || (random < 75)){   				
				int status;
				pid_t  pid;
				pid = fork();
				if(pid == 0){ // child process
					execvp(tokensall[0], tokensall);
					printf("command %s not found",tokensall[0]);
					perror(tokensall[0]);
					
					exit(0);
				}else if(pid < 0){ // parent process
					perror(tokensall[0]);
	               		}else{
					waitpid(pid, &status, 0);
				}
	        	 }	
		}		
		free(buff_copy);		
		fprintf(stderr, "$ ");
	}
	exit_smash(tokensall,NULL, &init_hist); // exiting without buff_copy
	return 0;
}

