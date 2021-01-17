%option noyywrap
%{
	#include <stdlib.h>
	#include <stdio.h>
        int wr=0, sen=0, ch=0, para=0, space=0;
%}
	
sentence ([a-zA-Z0-9]+)[.]
word ([a-zA-Z0-9,]+)[ ]
 
%%
 
{word} {ch+=yyleng;wr+=1;}
{sentence} {ch+=yyleng;wr+=1;sen+=1;}
[\n] {para++;}
[' '] {} /*Ignore rest of the spaces*/

 
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
        printf("Words - %d\n", wr);
        printf("Characters - %d\n", ch);
        printf("Sentences - %d\n", sen);
        printf("Paragraphs - %d\n", para);
	return 1;
}
