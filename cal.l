%{
    #include <stdlib.h>
    #include "cal.tab.h"
    void yyerror(char *);
    void push(void);
    void pop(void);
 
%}

%%

"$r"[A-Z]      { yylval.number = yytext[2]-'A'; return VAR; }
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
"=="         { return DOUEQL; }
":"         { return COLON; }
"var"	    { return VAR_IND; }
"printD"	    { return PRINTDEC; }
"printH"	    { return PRINTHEX; }
"print"         { return PRINT; }
[iI][fF]				{ return IF; }
[eE][nN][dD][iI][fF]			{ return ENDIF; }
[lL][oO][oO][pP]			{ return LOOP; }
[eE][nN][dD][lL][oO][oO][pP]			{ return ENDLOOP; }
"\""([^\"])*"\""            { yylval.str = strdup(yytext); return MSG; }




\n          { return EOL; }
[ \t]       ; /* skip whitespace */

.           yyerror("invalid character");

%%

