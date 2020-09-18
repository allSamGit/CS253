
#include <stdio.h> 
#include <stdlib.h>
#include <string.h>
#include "history.h"


/*
 *Arrays Initialization
 */
history init_history() {
	history init;
	init.size = 1000;
	init.index = 0;
		
	init.history_list = (struct cmd*)malloc(sizeof(struct cmd) * init.size);
	return init;
}
/*
 *Storing History
 */
void add_history(char* cmd, history* histH) {

        (histH -> history_list[histH -> index]).cmd = (char*)malloc(strlen(cmd) + 1);
	strcpy((histH -> history_list[histH -> index]).cmd, cmd);
	(histH -> index)++;
	return;
}
/*
 *Clearing History
 */
void clear_history(history* histH) {
	int i;
	for(i = 0; i < histH->index; i++){
		free(histH->history_list[i].cmd);
	}
	free(histH->history_list);
	return;
}
/*
 *Printing History
 */
void print_history(history* histH) {
	int i;
	for(i = 0; i < histH->index; i++){
		printf("%d %s\n", i, histH->history_list[i].cmd);
        } 
	return;
}
