%option noyywrap
%{
	#include <stdlib.h>
	#include <stdio.h>
        int word = 0;
%}
comment (\/\/.*\n)|(\/\*(.|\n)*\*\/)

%%

{comment} {printf("%s\n", yytext);}
.|\n {}

%%

int main(int argc, char* argv[])
{
	if(argc > 1)
	{
		FILE *fp = fopen(argv[1], "r");
		if(fp)
			yyin = fp;
	}
	yylex();
	return 1;
}
