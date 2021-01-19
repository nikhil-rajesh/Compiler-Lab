%option noyywrap
%{
	#include <stdlib.h>
	#include <stdio.h>
        int integer=0, floating = 0;
%}
	
%%
 
[0-9]+ {integer++;}
([0-9]+)[.]([0-9]+) {floating++;}
[\n] {} /*Ignore rest of the spaces*/
 
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
        printf("Integers - %d\n", integer);
        printf("Floats - %d\n", floating);
	return 1;
}
