%option noyywrap
%{
	#include <stdlib.h>
	#include <stdio.h>
        int word = 0;
%}

%%

[A].{2}[ |.] {word++;}
.|[\n] {} /*Ignore rest of the spaces*/

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
        printf("Words starting with 'A' - %d\n", word);
	return 1;
}
