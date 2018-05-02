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
    char msgfromlex[50][256];
    int msglabel = 0;

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
%token<number> EOL OP CP AND OR NOT EQL DOUEQL COLON PRINTDEC PRINTHEX PRINT 
%token<str>   VAR_IND IF ENDIF LOOP ENDLOOP
%token<str> MSG
%left NEG
%type<number> caler line statement statements ifstatement loopstatement condition expr number print

%%

caler:
        caler line                              { }
        | 
        ;

line:   EOL
        | ifstatement                           { 

                                                }
        | loopstatement                         { 

                                                }

        | statements                            { 

                                                }
        ;

statement:      VAR_IND VAR EQL expr                    {    
                                                                $$ = fprintf(fp, "var %d = %d\n", $2, $4); 

                                                        }
                | VAR EQL expr                          {       
                                                                $$ = fprintf(fp, "\tpop %%rax\n\tmov %%rax, -%d(%%rbp)\n\n", ($1+1)*8);  
                                                                printf("\tpop %%rax\n\tmov %%rax, -%d(%%rbp)\n\n", ($1+1)*8);
                                                        }

                | print                                 {

                                                        }

                ;

statements:     statement EOL
                | statement EOL statements
                ;

ifstatement:    IF condition EOL
                statements
                ENDIF EOL                       { $$ = fprintf(fp, "\nLI%d:\n", label); printf("\nLI%d:\n", label); label+=1; }
                ;
        
loopstatement:  LOOP conditionLoop EOL            
                statements
                ENDLOOP EOL                     { looplabel = pop(looplabel, &llb); int int_llb = atoi(llb); fprintf(fp, "\tpop %%rcx\n\tdec %%rcx\n\tpop %%rbx\n\tcmp %%rbx, %%rcx\n\tjnz L%d\nEL%d:\n", int_llb, int_llb); printf("\tpop %%rcx\n\tdec %%rcx\n\tpop %%rbx\n\tcmp %%rbx, %%rcx\n\tjnz L%d\nEL%d:\n", int_llb, int_llb); /*$$ = fprintf(fp, "\tpop %%rcx\n\tloop L%d\n\n", int_llb); printf("\tpop %%rcx\n\tloop L%d\n\n", int_llb);*/ }
                | LOOP conditionLoop EOL
                  statements
                  inloopstatement
                  ENDLOOP EOL                   { looplabel = pop(looplabel, &llb); int int_llb = atoi(llb); fprintf(fp, "\tpop %%rcx\n\tdec %%rcx\n\tpop %%rbx\n\tcmp %%rbx, %%rcx\n\tjnz L%d\nEL%d:\n", int_llb, int_llb); printf("\tpop %%rcx\n\tdec %%rcx\n\tpop %%rbx\n\tcmp %%rbx, %%rcx\n\tjnz L%d\nEL%d:\n", int_llb, int_llb);/*$$ = fprintf(fp, "\tpop %%rcx\n\tloop L%d\n\n", int_llb); printf("\tpop %%rcx\n\tloop L%d\n\n", int_llb);*/ }
                | LOOP conditionLoop EOL
                  inloopstatement
                  statements             
                  ENDLOOP EOL                   { looplabel = pop(looplabel, &llb); int int_llb = atoi(llb); fprintf(fp, "\tpop %%rcx\n\tdec %%rcx\n\tpop %%rbx\n\tcmp %%rbx, %%rcx\n\tjnz L%d\nEL%d:\n", int_llb, int_llb); printf("\tpop %%rcx\n\tdec %%rcx\n\tpop %%rbx\n\tcmp %%rbx, %%rcx\n\tjnz L%d\nEL%d:\n", int_llb, int_llb);/*$$ = fprintf(fp, "\tpop %%rcx\n\tloop L%d\n\n", int_llb); printf("\tpop %%rcx\n\tloop L%d\n\n", int_llb);*/ }
                | LOOP conditionLoop EOL
                  statements
                  inloopstatement
                  statements
                  ENDLOOP EOL                   { looplabel = pop(looplabel, &llb); int int_llb = atoi(llb); fprintf(fp, "\tpop %%rcx\n\tdec %%rcx\n\tpop %%rbx\n\tcmp %%rbx, %%rcx\n\tjnz L%d\nEL%d:\n", int_llb, int_llb); printf("\tpop %%rcx\n\tdec %%rcx\n\tpop %%rbx\n\tcmp %%rbx, %%rcx\n\tjnz L%d\nEL%d:\n", int_llb, int_llb);/*$$ = fprintf(fp, "\tpop %%rcx\n\tloop L%d\n\n", int_llb); printf("\tpop %%rcx\n\tloop L%d\n\n", int_llb);*/ }

                ;

inloopstatement:        LOOP conditionLoop EOL
                        statements
                        ENDLOOP EOL             { looplabel = pop(looplabel, &llb); int int_llb = atoi(llb); fprintf(fp, "\tpop %%rcx\n\tdec %%rcx\n\tpop %%rbx\n\tcmp %%rbx, %%rcx\n\tjnz L%d\nEL%d:\n", int_llb, int_llb); printf("\tpop %%rcx\n\tdec %%rcx\n\tpop %%rbx\n\tcmp %%rbx, %%rcx\n\tjnz L%d\nEL%d:\n", int_llb, int_llb);/*fprintf(fp, "\tpop %%rcx\n\tloop L%d\n\n", int_llb); printf("\tpop %%rcx\n\tloop L%d\n\n", int_llb);*/ }

condition:      expr DOUEQL expr                  { $$ = fprintf(fp, "\tpop %%rbx\n\tpop %%rax\n\tcmp %%rax, %%rbx\n\tjnz LI%d\n\n", label); printf("\tpop %%rbx\n\tpop %%rax\n\tcmp %%rax, %%rbx\n\tjnz LI%d\n\n", label); }
                
                ;

conditionLoop:  expr COLON expr            { 
                                                        fprintf(fp, "\tpop %%rcx\n\tpop %%rbx\n\tcmp %%rbx, %%rcx\n\tje EL%d\n\nL%d:\n\tpush %%rbx\n\tpush %%rcx\n", labelLoop, labelLoop); 
                                                        printf("\tpop %%rcx\n\tpop %%rbx\n\tcmp %%rbx, %%rcx\n\tje EL%d\n\nL%d:\n\tpush %%rbx\n\tpush %%rcx\n", labelLoop, labelLoop); 
                                                        // fprintf(fp, "\tpop %%rcx\n\tpush %%rcx\nL%d:\n", labelLoop); 
                                                        // printf("\tpop %%rcx\n\tpush %%rcx\nL%d:\n", labelLoop); 
                                                        char tmp[20]; sprintf(tmp, "%d", labelLoop); 
                                                        looplabel = push(looplabel, tmp); 
                                                        labelLoop+=1; 
                                                }
                ;

expr:
        number                      { $$ = $1; fprintf(fp, "\tmov $%d, %%rax\n\tpush %%rax\n\n", $1); printf("\tmov $%d, %%rax\n\tpush %%rax\n\n", $1); }
        | VAR                       { $$ = var[$1]; fprintf(fp, "\tmov -%d(%%rbp), %%rax\n\tpush %%rax\n\n", ($1+1)*8); printf("\tmov -%d(%%rbp), %%rax\n\tpush %%rax\n\n", ($1+1)*8); }                 
        
        | expr ADD expr             { $$ = $1 + $3; fprintf(fp, "\tpop %%rbx\n\tpop %%rax\n\tadd %%rbx, %%rax\n\tpush %%rax\n\n"); printf("\tpop %%rbx\n\tpop %%rax\n\tadd %%rbx, %%rax\n\tpush %%rax\n\n"); }
        | expr SUB expr             { $$ = $1 - $3; fprintf(fp, "\tpop %%rbx\n\tpop %%rax\n\tsub %%rbx, %%rax\n\tpush %%rax\n\n"); printf("\tpop %%rbx\n\tpop %%rax\n\tsub %%rbx, %%rax\n\tpush %%rax\n\n"); }
        | expr MUL expr             { $$ = $1 * $3; fprintf(fp, "\tpop %%rbx\n\tpop %%rax\n\tmul %%rbx\n\tpush %%rax\n\n"); printf("\tpop %%rbx\n\tpop %%rax\n\tmul %%rbx\n\tpush %%rax\n\n");}
	| expr MOD expr             { $$ = $1-($1/$3*$3); fprintf(fp, "\tpop %%rbx\n\tpop %%rax\n\txor %%rdx, %%rdx\n\tidiv %%rbx\n\tpush %%rdx\n\n"); printf("\tpop %%rbx\n\tpop %%rax\n\txor %%rdx, %%rdx\n\tidiv %%rbx\n\tpush %%rdx\n\n"); }
        | expr DIV expr             { $$ = $1 / $3; fprintf(fp, "\tpop %%rbx\n\tpop %%rax\n\txor %%rdx, %%rdx\n\tidiv %%rbx\n\tpush %%rax\n\n"); printf("\tpop %%rbx\n\tpop %%rax\n\txor %%rdx, %%rdx\n\tidiv %%rbx\n\tpush %%rax\n\n"); }

	| OP expr CP                { $$ = $2; }
	| SUB expr %prec NEG        { $$ = -$2; fprintf(fp, "\tpop %%rax\n\txor %%rbx, %%rbx\n\tsub %%rax, %%rbx\n\tpush %%rbx\n\n"); printf("\tpop %%rax\n\txor %%rbx, %%rbx\n\tsub %%rax, %%rbx\n\tpush %%rbx\n\n");}
        ;

number: DEC                         { $$ = $1; }
        | HEC                       { $$ = $1; }
        ;

print:  PRINTDEC VAR                { 
                                        $$ = fprintf(fp, "\tpush %%rax\n\tpush %%rbx\n\tpush %%rcx\n\tmov $printD, %%rdi\n\tmov -%d(%%rbp), %%rax\n\tmov %%rax, %%rsi\n\txor %%rax, %%rax\n\tcall printf\n\tpop %%rcx\n\tpop %%rbx\n\tpop %%rax\n\n", ($2+1)*8);
                                        printf("\tpush %%rax\n\tpush %%rbx\n\tpush %%rcx\n\tmov $printD, %%rdi\n\tmov -%d(%%rbp), %%rax\n\tmov %%rax, %%rsi\n\txor %%rax, %%rax\n\tcall printf\n\tpop %%rcx\n\tpop %%rbx\n\tpop %%rax\n\n", ($2+1)*8);
                                    }
        | PRINTHEX VAR              {
                                        $$ = fprintf(fp, "\tpush %%rax\n\tpush %%rbx\n\tpush %%rcx\n\tmov $printH, %%rdi\n\tmov -%d(%%rbp), %%rax\n\tmov %%rax, %%rsi\n\txor %%rax, %%rax\n\tcall printf\n\tpop %%rcx\n\tpop %%rbx\n\tpop %%rax\n\n", ($2+1)*8);
                                        printf("\tpush %%rax\n\tpush %%rbx\n\tpush %%rcx\n\tmov $printH, %%rdi\n\tmov -%d(%%rbp), %%rax\n\tmov %%rax, %%rsi\n\txor %%rax, %%rax\n\tcall printf\n\tpop %%rcx\n\tpop %%rbx\n\tpop %%rax\n\n", ($2+1)*8);
                                    }
        | PRINT MSG                 {
                                        char tmp1[256];
                                        char tmp2[256] = "";
                                        char tmp3;
                                        strcpy(tmp1, $2);
                                        int i;
                                        int x=0;
                                        printf("%ld\n", strlen(tmp1));
                                        for(i=1; i<strlen(tmp1)-1; i++){
                                                tmp2[x] = tmp1[i];
                                                x+=1;
                                        }
                                        printf("%s\n", tmp2);

                                        strcpy(msgfromlex[msglabel], tmp2);
                                        fprintf(fp, "\tpush %%rax\n\tpush %%rbx\n\tpush %%rcx\n\tmov $fmt, %%rdi\n\tmov $msg%d, %%rax\n\tmov %%rax, %%rsi\n\txor %%rax, %%rax\n\tcall printf\n\tpop %%rcx\n\tpop %%rbx\n\tpop %%rax\n\n", msglabel);
                                        printf("\tpush %%rax\n\tpush %%rbx\n\tpush %%rcx\n\tmov $fmt, %%rdi\n\tmov $msg%d, %%rax\n\tmov %%rax, %%rsi\n\txor %%rax, %%rax\n\tcall printf\n\tpop %%rcx\n\tpop %%rbx\n\tpop %%rax\n\n", msglabel);
                                        msglabel += 1;
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
        fprintf(fp, "\tmov %%rsp, %%rbp\n");
        fprintf(fp, "\tsub $208, %%rsp\n\n");

        yyparse();


        fprintf(fp, "\n\tadd $208, %%rsp\n");
        fprintf(fp, "\tret\n\n");
        fprintf(fp, "printD:\n");
        fprintf(fp, "\t.asciz \"%%ld\\n\"\n");
        fprintf(fp, "printH:\n");
        fprintf(fp, "\t.asciz \"0x%%lx\\n\"\n");
        fprintf(fp, "fmt:\n");
        fprintf(fp, "\t.asciz \"%%s\\n\"\n");
        
        int i=0;
        while(i <= msglabel-1){
               fprintf(fp, "msg%d:\n", i);
               fprintf(fp, "\t.asciz \"%s\"\n", msgfromlex[i]); 
               i+=1;
        }

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

