%{
	#include <stdlib.h>
	#include <stdio.h>
	#include "y.tab.h"
	#include "exprtree.h"

	int number, i;
        char *variable;
%}

id [a-zA-Z_][0-9a-zA-Z_]*
str \"(\\.|[^\\\"])*\"

%%

[0-9]+	    {
                number = atoi(yytext);
                yylval.nptr = createTree(TYPE_INT, number, NODE_NUM, NULL, NULL, NULL, NULL);
                return NUM;
            }
"begin"     {return START;}
"end"       {return END;}
"read"      {return READ;}
"write"     {return WRITE;}
"if"        {return IF;}
"then"      {return THEN;}
"else"      {return ELSE;}
"endif"     {return ENDIF;}
"while"     {return WHILE;}
"do"        {return DO;}
"endwhile"  {return ENDWHILE;}
"break"     {return BREAK;}
"continue"  {return CONT;}
"decl"      {return DECL;}
"enddecl"   {return ENDDECL;}
"int"       {return INT;}
"str"       {return STR;}
"=="        {return EQ;}
"!="        {return NEQ;}
"<="        {return LE;}
">="        {return GE;}
"<"         {return LT;}
">"         {return GT;}
"+"         {return PLUS;}
"-"         {return MINUS;}
"*"         {return MUL;}
"/"         {return DIV;}
"%"         {return MOD;}
"="         {return ASSGN;}
{id}        {
                variable = (char*)malloc(sizeof(yytext));
                strcpy(variable, yytext);
                yylval.nptr = createTree(TYPE_INT, 0, NODE_ID, variable, NULL, NULL, NULL);
                return ID;
            }
{str}       {
                variable = (char*)malloc(sizeof(yytext));
                strcpy(variable, yytext);
                yylval.nptr = createTree(TYPE_STR, 0, NODE_STRVAL, variable, NULL, NULL, NULL);
                return STRVAL;
            }
[ \t\n]	    {}
[()\[\];,]       {return *yytext;}
.	    {
                yyerror("unknown character\n");
                exit(1);
            }

%%

int yywrap(void) {
	return 1;
}
