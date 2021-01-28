%{
	#include <stdlib.h>
	#include <stdio.h>
	#include "y.tab.h"
	#include "exprtree.h"

	int number;
        char *variable;
%}

%%

[0-9]+	    {
                number = atoi(yytext);
                yylval.nptr = createTree(0, number, NODE_NUM, NULL, NULL, NULL);
                return NUM;
            }
"begin"     {return START;}
"end"       {return END;}
"read"      {return READ;}
"write"     {return WRITE;}
"+"         {return PLUS;}
"-"         {return MINUS;}
"*"         {return MUL;}
"/"         {return DIV;}
"="         {return ASSGN;}
[a-z]       {
                variable = (char*)malloc(sizeof(yytext));
                strcpy(variable, yytext);
                yylval.nptr = createTree(1, 0, NODE_ID, variable, NULL, NULL);
                return ID;
            }
[ \t\n]	    {}
[();]       {return *yytext;}
.	    {
                yyerror("unknown character\n");
                exit(1);
            }

%%

int yywrap(void) {
	return 1;
}
