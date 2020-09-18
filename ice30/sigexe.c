#include <signal.h>
#include <stdio.h>
#include <wait.h>


void myHandler(int);

int main(int argc, char *argv[]) {

    pid_t pid;
    signal(SIGUSR1,myHandler);



    if( signal( SIGUSR1, myHandler) == myHandler  )
    {
        printf("SIGUSR1 has been created\n");
    }

        printf( "Process ID = %d\n", getpid() );

     kill(pid, SIGUSR1);

    return 0;
}

void myHandler(int signum)
{
pid_t pid;

if(signum==SIGUSR1){
    perror("SIGUSR1 caught");
}
  
}