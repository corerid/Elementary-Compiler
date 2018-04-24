%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <math.h>
    #include <string.h>
    #define VAR_BUF_SIZE 26
    int yylex(void);
    void yyerror(char *);
    int reg[29]={0};
    void makeVar(char *txt, int val);
    void printVar(char *txt);
    int getDataFromVar(char *txt);


    // /*** link list ***/
    // struct node{
    //     int val;
    //     struct node *next;
    // };
    // typedef struct node node;

    // node *h,*t;
    // int status = 0;

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

%token<number> DEC HEC
%token<number> ADD SUB MUL DIV MOD POW
%token<number> EOL OP CP AND OR NOT EQL
%token<str> VAR_IND PRINT IF ELSE LOOP VAR
%type<number> caler expr number

%%

caler:
        caler expr EOL                
        | 
        ;

expr:
        number  
        | VAR                       { $$ = getDataFromVar($1); }                 
        
        | expr ADD expr             { reg[26] = $1 + $3;  $$ = $1 + $3; }
        | expr SUB expr             { reg[26] = $1 - $3; $$ = $1 - $3; }
        | expr MUL expr             { reg[26] = $1 * $3; $$ = $1 * $3; }
	| expr MOD expr             { reg[26] = $1 - ($1/$3*$3); $$ = $1-($1/$3*$3);}
        | expr DIV expr             { reg[26] = $1 / $3; $$ = $1 / $3; }
        
        
        | expr AND expr             { reg[26] = $1 & $3; $$ = $1 & $3; }
        | expr OR expr              { reg[26] = $1 | $3;  $$ = $1 | $3; }
        | NOT expr                  { reg[26] = ~$2; $$ = ~$2; }

	| OP expr CP                { $$ = $2; }
	| SUB expr                  { reg[26] = -$2; $$ = -$2;}
        
        | IF number EQL number      { if($2 == $4) printf("EQ"); else printf("NOT EQ"); }
        | VAR_IND VAR EQL expr    { makeVar($2, $4); }

        | PRINT expr                { $$ = printf("%d\n", $2); }
        ;

number: DEC                    
        | HEC                   
        ;


 
%%

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}

int main()
{
	while(1)
	{	
        yyparse();
	}
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

// node* getnode(int val, node *next){
//     node *tmp = (node*)malloc(sizeof(node));
//     tmp->val = val;
//     tmp->next = next;
//     return tmp;
// }

// node* insert(int val, node **p){
//     if(*p)
//         *p = (*p)->next = getnode(val,NULL);
// }

// node* delet(node *p){
//     if(p){
//         if(p->next){
//             node *q = p->next;
//             p->next = q->next;
//             free(q);
//         }
//     }
// }

// void push(int index){
//    if( index == 28 || index == 27){ 
//         yylval = -1;
//         printf("Error!! Wrong Parameter!! Parameter is read only\n");
//     }
//     else{ 
//         reg[27]++;
//         insert(reg[index],&t);
//         reg[28] = t->val;
//     }
//     status = 1;
// }   

// void pop(int index){
//     if( reg[27] == 0) 
//         printf("Error!! Stack is empty\n");
//     else {
//         reg[27]--;
//         reg[index] = t->val;
//         delet(t);
//         reg[28] = t->val;
//     }
//     status = 1;
// }

// void load(int index1,int index2){
//     if(index1 == 27 || index1 == 28) 
//         printf("Error!! Wrong Parameter!! Parameter is read only\n");
//     else{
//         reg[index1] = reg[index2];
//     }    
//     status = 1;
// }


// int main(void) {
//     h = getnode(0,NULL);
//     t = h;
//     yyparse();
//     return 0;
// }



