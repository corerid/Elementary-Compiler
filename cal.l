%{
    #include <stdlib.h>
    #include "cal.tab.h"
    void yyerror(char *);
    void push(void);
    void pop(void);
 
%}

%%

[0-9]+      { yylval.number = atoi(yytext); return DEC;}
[0-9a-fA-F]+[hH]  { yylval.number = (int)strtol(yytext,NULL, 16); return HEC;}
"+"         { return ADD; }
"-"         { return SUB; }
"*"         { return MUL; }
"/"         { return DIV; }
"("         { return OP;  }
")"         { return CP;  }
"^"         { return POW; }
"\\"        { return MOD; }
"&"         { return AND; }
"|"         { return OR; }
"!"         { return NOT; }
"="         { return EQL; }
"var"	    { return VAR_IND; }
"print"	    { return PRINT; }
[iI][fF]				{ return IF; }
[eE][lL][sS][eE]			{ return ELSE; }
[lL][oO][oO][pP]			{ return LOOP; }
[a-zA-Z0-9]+      { yylval.str = strdup(yytext); return VAR; }



\n          { return EOL; }
[ \t]       ; /* skip whitespace */

.           yyerror("invalid character");

%%

