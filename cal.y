%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <math.h>
    #include <string.h>
    #include <stdbool.h>    
    int yylex(void);
    void yyerror(char *);
    void lexerror(int code);
    //int a[26] = {-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1}; //in case it's not work
    int a[26] = {[0 ... 25] = -1};
    int var[26];
    int label = 0;
    int labelLoop = 0;
    char *llb;
    char msgfromlex[50][256];
    int msglabel = 0;

    FILE *fp, *fpHead, *fpAll;

    int size;
    char *txt;


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

%}


%union 
{
        int number;
        char *str;
}

%token<number> VAR DEC HEC
%token<number> ADD SUB MUL DIV MOD POW
%token<number> EOL OP CP AND OR NOT EQL DOUEQL COLON PRINTDEC PRINTHEX PRINT 
%token<number> VAR_IND IF ENDIF LOOP ENDLOOP
%token<str> MSG
%left ADD SUB 
%left MUL DIV MOD
%type<number> caler line statement statements ifstatement loopstatement inloopstatement statementInInLoops statementInInLoop conditionIf conditionLoop expr number print var statementInif statementInifs statementInLoops statementInLoop

%%

caler:
        caler line
        | 
        ;

line:   EOL
        | ifstatement                           
        | loopstatement                        
        | statements
        ;

statement:      VAR EQL expr                            {       
                                                                fprintf(fp, "\tpop %%rax\n\tmov %%rax, -%d(%%rbp)\n\n", ($1+1)*8); 
                                                                a[$1] = -(($1+1)*8);
                                                                var[$1] = $3;
                                                        }
                | print
                ;


statements:     statement EOL
                | statement EOL statements
                ;

ifstatement:    IF conditionIf EOL
                statementInifs
                ENDIF EOL                       { fprintf(fp, "\nLI%d:\n", label); label+=1; }
                ;

statementInif: statement EOL
                | loopstatement
                | ifstatement              
                ;
                
statementInifs:         statementInif
                        | statementInif statementInifs
                ;
        
loopstatement:  LOOP conditionLoop EOL            
                statementInLoops
                ENDLOOP EOL                     { looplabel = pop(looplabel, &llb); int int_llb = atoi(llb); fprintf(fp, "\tpop %%rcx\n\tdec %%rcx\n\tpop %%rbx\n\tcmp %%rbx, %%rcx\n\tjnz L%d\nEL%d:\n", int_llb, int_llb); }

                ;

inloopstatement:        LOOP conditionLoop EOL
                        statementInInLoops
                        ENDLOOP EOL             { looplabel = pop(looplabel, &llb); int int_llb = atoi(llb); fprintf(fp, "\tpop %%rcx\n\tdec %%rcx\n\tpop %%rbx\n\tcmp %%rbx, %%rcx\n\tjnz L%d\nEL%d:\n", int_llb, int_llb); }
                        ;

statementInInLoops:     statementInInLoop
                        | statementInInLoop statementInInLoops
                        ;

statementInInLoop:      statement EOL     
                        | ifstatement
                        ;

statementInLoops:       statementInLoop
                        | statementInLoop statementInLoops
                        ;

statementInLoop:        statement EOL     
                        | ifstatement
                        | inloopstatement
                        ;

conditionIf:      expr DOUEQL expr                  { fprintf(fp, "\tpop %%rbx\n\tpop %%rax\n\tcmp %%rax, %%rbx\n\tjnz LI%d\n\n", label); }
                ;

conditionLoop:  expr COLON expr                 {
                                                        if($1 > $3){
                                                                lexerror(1);
                                                        } 
                                                        fprintf(fp, "\tpop %%rcx\n\tpop %%rbx\n\tcmp %%rbx, %%rcx\n\tje EL%d\n\nL%d:\n\tpush %%rbx\n\tpush %%rcx\n", labelLoop, labelLoop);  
                                                        char tmp[20]; sprintf(tmp, "%d", labelLoop); 
                                                        looplabel = push(looplabel, tmp); 
                                                        labelLoop+=1; 
                                                }
                ;

expr:
        number                      { $$ = $1; /*fprintf(fp, "\tmov $%d, %%rax\n\tpush %%rax\n\n", $1);*/ }
        | VAR                       { $$ = var[$1]; fprintf(fp, "\tmov -%d(%%rbp), %%rax\n\tpush %%rax\n\n", ($1+1)*8); a[$1] = -(($1+1)*8); }                 
        
        | expr ADD expr             { $$ = $1 + $3; fprintf(fp, "\tpop %%rbx\n\tpop %%rax\n\tadd %%rbx, %%rax\n\tpush %%rax\n\n"); }
        | expr SUB expr             { $$ = $1 - $3; fprintf(fp, "\tpop %%rbx\n\tpop %%rax\n\tsub %%rbx, %%rax\n\tpush %%rax\n\n"); }
        | expr MUL expr             { $$ = $1 * $3; fprintf(fp, "\tpop %%rbx\n\tpop %%rax\n\tmul %%rbx\n\tpush %%rax\n\n"); }
	| expr MOD expr             { $$ = $1%$3; fprintf(fp, "\tpop %%rbx\n\tpop %%rax\n\txor %%rdx, %%rdx\n\tidiv %%rbx\n\tpush %%rdx\n\n"); }
        | expr DIV expr             { $$ = $1 / $3; fprintf(fp, "\tpop %%rbx\n\tpop %%rax\n\txor %%rdx, %%rdx\n\tidiv %%rbx\n\tpush %%rax\n\n"); }

	| OP expr CP                { $$ = $2; }
	| SUB number                { $$ = -$2; fprintf(fp, "\tpop %%rax\n\txor %%rbx, %%rbx\n\tsub %%rax, %%rbx\n\tpush %%rbx\n\n"); }
        | SUB var                   { $$ = -$2; fprintf(fp, "\tpop %%rax\n\txor %%rbx, %%rbx\n\tsub %%rax, %%rbx\n\tpush %%rbx\n\n"); a[$2] = -(($2+1)*8); }
        ;

number: DEC                         { $$ = $1; fprintf(fp, "\tmov $%d, %%rax\n\tpush %%rax\n\n", $1);}
        | HEC                       { $$ = $1; fprintf(fp, "\tmov $%d, %%rax\n\tpush %%rax\n\n", $1);}
        ;

var:    VAR                         { $$ = var[$1]; fprintf(fp, "\tmov -%d(%%rbp), %%rax\n\tpush %%rax\n\n", ($1+1)*8); a[$1] = -(($1+1)*8);}
        ;

print:  PRINTDEC VAR                { 
                                        fprintf(fp, "\tpush %%rax\n\tpush %%rbx\n\tpush %%rcx\n\tmov $printD, %%rdi\n\tmov -%d(%%rbp), %%rax\n\tmov %%rax, %%rsi\n\txor %%rax, %%rax\n\tcall printf\n\tpop %%rcx\n\tpop %%rbx\n\tpop %%rax\n\n", ($2+1)*8); a[$2] = -(($2+1)*8);
                                    }
        | PRINTHEX VAR              {
                                        fprintf(fp, "\tpush %%rax\n\tpush %%rbx\n\tpush %%rcx\n\tmov $printH, %%rdi\n\tmov -%d(%%rbp), %%rax\n\tmov %%rax, %%rsi\n\txor %%rax, %%rax\n\tcall printf\n\tpop %%rcx\n\tpop %%rbx\n\tpop %%rax\n\n", ($2+1)*8); a[$2] = -(($2+1)*8);
                                    }
        | PRINT MSG                 {
                                        char tmp1[256];
                                        char tmp2[256] = "";
                                        strcpy(tmp1, $2);
                                        int i;
                                        int x=0;
                                        for(i=1; i<strlen(tmp1)-1; i++){
                                                tmp2[x] = tmp1[i];
                                                x+=1;
                                        }
                                        strcpy(msgfromlex[msglabel], tmp2);
                                        fprintf(fp, "\tpush %%rax\n\tpush %%rbx\n\tpush %%rcx\n\tmov $fmt, %%rdi\n\tmov $msg%d, %%rax\n\tmov %%rax, %%rsi\n\txor %%rax, %%rax\n\tcall printf\n\tpop %%rcx\n\tpop %%rbx\n\tpop %%rax\n\n", msglabel);
                                        msglabel += 1;
                                    }
        ;

 
%%

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
    remove("asm.s");
}

int main()
{
        init(reg);
        init(looplabel);
        size = 0;

        fp = fopen("asmBody.s", "w+");
        fpHead = fopen("asmHead.s", "w+");
        fpAll = fopen("asm.s", "w");

        fprintf(fpHead, "\t.global main\n");
        fprintf(fpHead, "\t.text\n");
        fprintf(fpHead, "main:\n");
        fprintf(fpHead, "\tmov %%rsp, %%rbp\n");
        fprintf(fpHead, "\tsub $208, %%rsp\n\n");

        yyparse();

        int count;
        for(count=0; count<26; count++){
                if(a[count] != -1){
                      fprintf(fpHead, "\txor %%rax, %%rax\n\tmov %%rax, %d(%%rbp)\n\n", a[count]);  
                }
        }

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

        //set file pointer to beginning
        rewind(fp);
        rewind(fpHead);

        char c; 

        while( ( c = fgetc(fpHead) ) != EOF )
                fputc(c, fpAll);

        while( ( c = fgetc(fp) ) != EOF )
                fputc(c, fpAll);


        int fclose( FILE *fp );
        int fclose( FILE *fpHead );
        int fclose( FILE *fpAll );

        remove("asmHead.s");
        remove("asmBody.s");

}

void lexerror(int code){
  switch(code){
    case 1:
      printf("!Ending Value less than intial value \n");
      remove("asm.s");
      break;
    default:
      printf("!ERROR \n");
      remove("asm.s");
      break;
  }
  return;
}

