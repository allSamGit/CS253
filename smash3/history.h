#ifndef HISTORY_H
#define HISTORY_H

/*
 *Struct holding command line
 */
struct cmd{
	char* cmd;		
};

typedef struct history_struct{
	int size;
	int index;
	
	struct cmd* history_list;

}history;

 	history init_history(void);
	
	void add_history(char* cmd,history* histH);

	void clear_history(history* histH);

	void print_history(history* histH);

#endif
