* Saman Rastgar *
* CS253-Jim Conrad*
* Date:04/08/18 *

NAME

smash (3),bash shell

* SYNOPSIS

int execvp(const char *file, char *const argv[]);

pid_t fork(void);

char *getenv(const char *name);

pid_t waitpid(pid_t pid, int *status, int options);


* DESCRIPTION 

In this version of smash we will be adding another feature which will be controlling processes.
We assume that we have random processes going on and we just want 75% of processes be able to execute.
So we define random number using rand() functon to get a random process 
srand function will be used to determines the seed for pseudorandom generating.
We then check if the path existed or we pass 75% of time then get the process using fork.
fork() function return 0 means we are in child process and other condition is pid<0 which means there is 
an error in process or if we have a value bigger than zero means that we are waiting for child process to be finished.



some function used in this program:

srand()- The  srand()  function  sets  its argument as the seed for a new sequence of pseudo-random integers to be returned by rand().  These sequences are
repeatable by calling srand() with the same seed value.
we passed time(NULL) as the seed for srand()

getenv() - This function  searches  the  environment  list  to find the environment variable name, and returns a pointer to the corresponding value string.

fork() - creates a new process by duplicating the calling process.


waitpid() -The waitpid() system call suspends execution of the calling process until a child specified by pid argument has changed state.

execvp()-From family of exec function,It determines if any error has occured in processes



* AUTHOR

Written by Saman Rastgar

