#include <stdio.h>
#include <string.h>

#define NUM_TAREAS 128
#define LONG_TAREA 32

char tareas[NUM_TAREAS][LONG_TAREA];
int num_tareas = 0;

void waitkey() {
  char c;
  printf("PRESS SPACE TO CONTINUE\n");
  do { c = getchar(); } while (c != ' ');
}

void clrscr() {
/*unsigned char clearch=0x70;*/
/*waitkey();*/
/*printf("%c\n", clearch);*/
}

void assign_general_task() {
  char linea[128];

  if (num_tareas > NUM_TAREAS - 1) {
    printf("MAX NUMBER OF TASKS!");
    return;
  }

  gets(linea);

  strcpy(tareas[num_tareas], "GENERAL ");

  printf("ENTER DATE(DDMM): ");

  scanf("%s", linea);

  strcat(tareas[num_tareas], linea);
  strcat(tareas[num_tareas], " ");

  strcat(tareas[num_tareas], "-----");
  strcat(tareas[num_tareas], " ");

  printf("ENTER DESCRIPTION: ");
  scanf("%s", linea);
  strcat(tareas[num_tareas], linea);

/*printf("num_tareas = %d\n", num_tareas);
  printf("tarea = '%s'\n", tareas[num_tareas]);
*/

  printf("GENERAL TASK ASSIGNED\n");

  num_tareas++;

/*waitkey();*/
}

void assign_specific_task() {
  char linea[128];

  if (num_tareas > NUM_TAREAS - 1) {
    printf("MAX NUMBER OF TASKS!");
    return;
  }

  gets(linea);

  strcpy(tareas[num_tareas], "SPECIFIC ");

  printf("ENTER DATE(DDMM): ");
  scanf("%s", linea);
  strcat(tareas[num_tareas], linea);
  strcat(tareas[num_tareas], " ");

  printf("ENTER NAME:");
  scanf("%s", linea);
  strcat(tareas[num_tareas], linea);
  strcat(tareas[num_tareas], " ");

  printf("ENTER DESCRIPTION: ");
  scanf("%s", linea);
  strcat(tareas[num_tareas], linea);
/*
  printf("num_tareas = %d\n", num_tareas);
  printf("tarea = '%s'\n", tareas[num_tareas]);
*/

  printf("SPECIFIC TASK ASSIGNED\n");

  num_tareas++;
}

void assign_tasks() {
  int op;
  do {
    clrscr();
    printf(" ASSIGN TASKS\n");
    printf(" 1. GENERAL TASK  2.SPECIFIC TASK  3. MAIN MENU\n");

    printf("OPTION: ");
    scanf("%d", &op);
    switch(op) {
      case 1: assign_general_task(); break;
      case 2: assign_specific_task(); break;
    }
  } while(op != 3);
}

void view_task(char *tipo) {
  int i;

  for(i = 0; i < num_tareas; i++) {
    if (strstr(tareas[i], tipo) != NULL) {
      printf("TASK %d: %s\n", i, tareas[i]);
    }
  }
  printf("TOTAL TASK\n");
}

void view_tasks() {
  int op;

  do {
    clrscr();
    printf(" VIEW TASKS\n");
    printf(" 1. GENERAL TASK  2.SPECIFIC TASK  3. MAIN MENU\n");

    printf("OPTION: ");
    scanf("%d", &op);
    switch(op) {
      case 1: view_task("GENERAL"); break;
      case 2: view_task("SPECIFIC"); break;
    }
  } while(op != 3);
}

int main(void) {
  int op;

  while(1) {
    clrscr();
    printf(" MENU PRINCIPAL\n");
    printf(" 1.ASSIGN TASKS  2.VIEW TASKS  3.EXIT\n");

    printf("OPTION: ");
    scanf("%d", &op);
    switch(op) {
      case 1: assign_tasks(); break;
      case 2: view_tasks(); break;
      case 3: return 0;
    }
  }
}