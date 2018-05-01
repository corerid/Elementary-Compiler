%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <math.h>
    #include <string.h>
    #include <stdbool.h>    
    #define VAR_BUF_SIZE 16
    //extern int yylex();
    void lexerror(int code);
    int yylex(void);
    void yyerror(char *);
    void makeVar(char *txt, int val);
    void printVar(char *txt);
    int getDataFromVar(char *txt);
    void assignVar(char *txt, int val);
    float acc = 0;
    int var[26];
    int label = 0;
    int labelLoop = 0;
    char *llb;

    FILE *fp;

int size;
char *txt;
char *txt2;

struct node   /* structure of stack */
{
    int data;
    char *msg;
    struct node* next;
};

void init(struct node* head)  /*create a stack*/
{
    head = NULL;
}

struct node* push(struct node* head,char *msg) /* push data to stack */
{

    struct node* tmp = (struct node*)malloc(sizeof(struct node));
    if(tmp == NULL) /*if create node fail */
    {
        exit(0);
    }
    tmp->msg = strdup(msg);
    tmp->next = head;
    head = tmp;
    size += 1;
    return head;
}

struct node* pop(struct node *head, char **txt) /* pop stack */
{
    if(head == NULL){ /* if stack is Empty */
        printf("Empty Stack!\n");
        *txt = "";
        return NULL;
    }
    else{
        struct node* tmp = head;
        *txt = tmp->msg;
        head = head->next;
        free(tmp);
        size -= 1;
    }
        return head;
}

bool isEmpty(struct node *head){
        return head == NULL;
}

struct node* reg = NULL; /* create frist node */
struct node* looplabel = NULL; /* create frist node */ 

        typedef struct variable_t{
                char name[256];
                int val;
                int status;
        }variable_t;
        variable_t variable[VAR_BUF_SIZE];
%}


%union 
{
        int number;
        char *str;
}

%token<number> VAR DEC HEC
%token<number> ADD SUB MUL DIV MOD POW
%token<number> EOL OP CP AND OR NOT EQL DOUEQL COLON PRINTDEC PRINTHEX 
%token<str>   VAR_IND IF ENDIF LOOP ENDLOOP
%left NEG
%type<number> caler line statement statements ifstatement loopstatement condition expr number print

%%

caler:
        caler line                              { }
        | 
        ;

line:   EOL
        | ifstatement                           { 
                                                        // printf("ifstm\n");
                                                        // char a[500][500];
                                                        // int i=0;
                                                        // int tmp_size = 0;
                                                        // while (size > 1){
                                                        //         reg = pop(reg, &txt);
                                                        //         strcpy(a[i], txt);
                                                        //         tmp_size++;
                                                        //         i++;
                                                        // } 

                                                        // reg = pop(reg, &txt);
                                                        // printf("%s\n", txt);

                                                        // int y=tmp_size-1;
                                                        // for(int x=0; x<tmp_size; x++){
                                                        //         reg = push(reg, a[y]);
                                                        //         y--;
                                                        // }
                                                        
                                                        // while (!isEmpty(reg)){
                                                        //         reg = pop(reg, &txt);
                                                        //         printf("%s\n", txt);  
                                                        // }
                                                }
        | loopstatement                         { 
                                                        // printf("looptme\n");
                                                        // while (!isEmpty(reg)){
                                                        //       reg = pop(reg, &txt);
                                                        //       printf("%s\n", txt);  
                                                        // }
                                                }

        | statement                             { 
                                                        // printf("stm\n");
                                                        // int i=0;
                                                        // while (!isEmpty(reg)){
                                                        //       reg = pop(reg, &txt);
                                                        //       printf("%s\n", txt);
                                                        //       i++;  
                                                        // }
                                                }
        ;

statement:      VAR_IND VAR EQL expr EOL           {    
                                                        printf("HAYY\n"); 
                                                        $$ = fprintf(fp, "var %d = %d\n", $2, $4); 
                                                        char msg[256];
                                                        sprintf(msg, "var %d = %d", $2, $4);
                                                        //reg = push(reg, msg); 
                                                   }
                | VAR EQL expr EOL                      {       
                                                                printf("\tpop %%rax\n\tmov %%rax, -%d(%%rbp)\n\n", ($1+1)*8); 
                                                                $$ = fprintf(fp, "%d = %d\n", $1, $3);  
                                                                char msg[256];
                                                                sprintf(msg, "%d = %d", $1, $3);
                                                                //reg = push(reg, msg); 
                                                        }
                | VAR EQL expr EOL statement            { 
                                                                printf("\tpop %%rax\n\tmov %%rax, -%d(%%rbp)\n\n", ($1+1)*8); 
                                                                $$ = fprintf(fp, "%d = %d\n", $1, $3); 
                                                                char msg[256];
                                                                sprintf(msg, "%d = %d", $1, $3);
                                                                //reg = push(reg, msg);
                                                        }
                | VAR_IND VAR EQL expr EOL statement    { 
                                                                printf("PPPP\n"); 
                                                                $$ = fprintf(fp, "var %d = %d\n", $2, $4); 
                                                                char msg[256];
                                                                sprintf(msg, "var %d = %d", $2, $4);
                                                                //reg = push(reg, msg);
                                                        }

                | print EOL                             {
                                                                // while (!isEmpty(reg)){
                                                                //         reg = pop(reg, &txt);
                                                                //         printf("%s\n", txt);  
                                                                // }
                                                        }
                | print EOL statement                   {
                                                                // while (!isEmpty(reg)){
                                                                //         reg = pop(reg, &txt);
                                                                //         printf("%s\n", txt);  
                                                                // }
                                                        }
                ;

statements:     statement EOL
                | statement EOL statements
                ;

ifstatement:    IF condition EOL
                statement
                ENDIF EOL                       { $$ = fprintf(fp, "IF\nENDIF\n"); printf("\nLI%d:\n", label); label+=1; }
                ;
        
loopstatement:  LOOP conditionLoop EOL            
                statement
                ENDLOOP EOL                     { $$ = fprintf(fp, "LOOP\n"); looplabel = pop(looplabel, &llb); int int_llb = atoi(llb); printf("\tpop %%rcx\n\tloop L%d\n\n", int_llb);}
                | LOOP conditionLoop EOL
                  statement
                  inloopstatement
                  ENDLOOP EOL                   { $$ = fprintf(fp, "LOOP\n"); looplabel = pop(looplabel, &llb); int int_llb = atoi(llb); printf("\tpop %%rcx\n\tloop L%d\n\n", int_llb);}
                | LOOP conditionLoop EOL
                  inloopstatement
                  statement             
                  ENDLOOP EOL                   { $$ = fprintf(fp, "LOOP\n"); looplabel = pop(looplabel, &llb); int int_llb = atoi(llb); printf("\tpop %%rcx\n\tloop L%d\n\n", int_llb);}
                | LOOP conditionLoop EOL
                  statement
                  inloopstatement
                  statement
                  ENDLOOP EOL                   { $$ = fprintf(fp, "LOOP\n"); looplabel = pop(looplabel, &llb); int int_llb = atoi(llb); printf("\tpop %%rcx\n\tloop L%d\n\n", int_llb);}

                ;

inloopstatement:        LOOP conditionLoop EOL
                        statement
                        ENDLOOP EOL             { labelLoop-=1; looplabel = pop(looplabel, &llb); int int_llb = atoi(llb); printf("\tpop %%rcx\n\tloop L%d\n\n", int_llb);}

condition:      expr DOUEQL expr                  { $$ = fprintf(fp, "%d == %d\n", $1, $3); printf("\tpop %%rbx\n\tpop %%rax\n\tcmp %%rax, %%rbx\n\tjnz LI%d:\n\n", label); }
                
                ;

conditionLoop:  expr             { printf("\tpop %%rcx\n\tpush %%rcx\nL%d:\n", labelLoop); char tmp[20]; sprintf(tmp, "%d", labelLoop); looplabel = push(looplabel, tmp); labelLoop+=1; /*printf("\tpop %%rcx\n\txor %%rax, %%rax\n\tcmp %%rax, %%rcx\n\tje EL%d\nL%d:\n\n", labelLoop, labelLoop);*/ }
                ;

expr:
        number                      { $$ = $1; printf("\tmov $%d, %%rax\n\tpush %%rax\n\n", $1); }
        | VAR                       { $$ = var[$1]; printf("\tmov -%d(%%rbp), %%rax\n\tpush %%rax\n\n", ($1+1)*8); }                 
        
        | expr ADD expr             { $$ = $1 + $3; printf("\tpop %%rbx\n\tpop %%rax\n\tadd %%rbx, %%rax\n\tpush %%rax\n\n"); }
        | expr SUB expr             { $$ = $1 - $3; printf("\tpop %%rbx\n\tpop %%rax\n\tsub %%rbx, %%rax\n\tpush %%rax\n\n"); }
        | expr MUL expr             { $$ = $1 * $3; printf("\tpop %%rbx\n\tpop %%rax\n\tmul %%rbx\n\tpush %%rax\n\n");}
	| expr MOD expr             { $$ = $1-($1/$3*$3);printf("\tpop %%rbx\n\tpop %%rax\n\txor %%rdx, %%rdx\n\tidiv %%rbx\n\tpush %%rdx\n\n"); }
        | expr DIV expr             { $$ = $1 / $3; printf("\tpop %%rbx\n\tpop %%rax\n\txor %%rdx, %%rdx\n\tidiv %%rbx\n\tpush %%rax\n\n"); }

	| OP expr CP                { $$ = $2; }
	| SUB expr %prec NEG        { $$ = -$2; printf("\tpop %%rax\n\txor %%rbx, %%rbx\n\tsub %%rax, %%rbx\n\tpush %%rbx\n\n");}
        ;

number: DEC                         { $$ = $1; }
        | HEC                       { $$ = $1; }
        ;

print:  PRINTDEC VAR                { 
                                        $$ = fprintf(fp, "%d\n", $2);
                                        char msg[256];
                                        sprintf(msg, "\tpush %%rax\n\tpush %%rbx\n\tpush %%rcx\n\tmov $printD, %%rdi\n\tmov %d(%%rbp), %%rax\n\tmov %%rax, %%rsi\n\txor %%rax, %%rax\n\tcall printf\n\tpop %%rcx\n\tpop %%rbx\n\tpop %%rax\n", -(($2+1)*8));
                                        //reg = push(reg, msg);
                                        printf("\tpush %%rax\n\tpush %%rbx\n\tpush %%rcx\n\tmov $printD, %%rdi\n\tmov -%d(%%rbp), %%rax\n\tmov %%rax, %%rsi\n\txor %%rax, %%rax\n\tcall printf\n\tpop %%rcx\n\tpop %%rbx\n\tpop %%rax\n\n", ($2+1)*8);
                                    }
        | PRINTHEX VAR              {
                                        $$ = fprintf(fp, "%d\n", $2);
                                        char msg[256];
                                        sprintf(msg, "\tpush %%rax\n\tpush %%rbx\n\tpush %%rcx\n\tmov $printH, %%rdi\n\tmov %d(%%rbp), %%rax\n\tmov %%rax, %%rsi\n\txor %%rax, %%rax\n\tcall printf\n\tpop %%rcx\n\tpop %%rbx\n\tpop %%rax\n", -(($2+1)*8));
                                        //reg = push(reg, msg);
                                        printf("\tpush %%rax\n\tpush %%rbx\n\tpush %%rcx\n\tmov $printH, %%rdi\n\tmov -%d(%%rbp), %%rax\n\tmov %%rax, %%rsi\n\txor %%rax, %%rax\n\tcall printf\n\tpop %%rcx\n\tpop %%rbx\n\tpop %%rax\n\n", ($2+1)*8);
                                    }
        ;

 
%%

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}

int main()
{
        init(reg);
        init(looplabel);
        size = 0;

        fp = fopen("asm.s", "w");
        fprintf(fp, "\t.global main\n");
        fprintf(fp, "\t.text\n");
        fprintf(fp, "main:\n");

        yyparse();


        int fclose( FILE *fp );
}

void lexerror(int code){
  switch(code){
    case 1:
      printf("!ERROR \n");
      break;
    default:
      printf("!ERROR \n");
      break;
  }
  return;
}

void makeVar(char *txt, int val){
        int check = -1;
        for(int i=0; i<VAR_BUF_SIZE; i++){
                if (strcmp(txt, variable[i].name) == 0){
                        printf("Redeclair variable\n");
                        check = 1;
                        break;
                }
        }
        if (check == -1){
                for(int i=0; i<VAR_BUF_SIZE; i++){
                        if( variable[i].status == 0){
                                strcpy(variable[i].name, txt);
                                variable[i].val = val;
                                variable[i].status = 1;
                                break;
                        }
                }
        }
}

void printVar(char *txt){
        int check = -1;
        for(int i=0; i<VAR_BUF_SIZE; i++){
                if (strcmp(txt, variable[i].name) == 0){
                        printf("%d\n", variable[i].val);
                        check = 1;
                        break;
                }
        }
        if (check == -1){
                printf("This Variable does not exit!\n");
        }
}

int getDataFromVar(char *txt){
        int check = -1;
        for(int i=0; i<VAR_BUF_SIZE; i++){
                if (strcmp(txt, variable[i].name) == 0){
                        //printf("%d", variable[i].val);
                        return variable[i].val;
                }
        }
        if (check == -1){
                printf("This Variable does not exit!\n");
                return 0;
        }
}

void assignVar(char *txt, int val){
        int check = -1;
        for(int i=0; i<VAR_BUF_SIZE; i++){
                if (strcmp(txt, variable[i].name) == 0){
                        variable[i].val = val;
                        check = 1;
                }
        }
        if (check == -1){
                printf("This Variable does not exit!\n");
        }
}
