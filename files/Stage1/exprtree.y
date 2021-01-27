%{
	#include <stdlib.h>
	#include <stdio.h>
	#include "exprtree.h"
	#include "exprtree.c"
        #include "codegen.c"
	int yylex(void);
        extern FILE *yyin;
        FILE *fp;
        FILE *intermediate;
        void print(int);
%}

%union {
	struct tnode *no;
}
%type <no> expr NUM program END
%token NUM END
%left '+' '-'
%left '*' '/'

%%

program : expr END	{
                            $$ = $2;
                            int r = codegen($1);
                            print(r);
			}
	;

expr : expr '+' expr	{$$ = makeOperatorNode('+',$1,$3);}
     | expr '-' expr  	{$$ = makeOperatorNode('-',$1,$3);}
     | expr '*' expr	{$$ = makeOperatorNode('*',$1,$3);}
     | expr '/' expr	{$$ = makeOperatorNode('/',$1,$3);}
     | '(' expr ')'	{$$ = $2;}
     | NUM		{$$ = $1;}
     ;

%%

yyerror(char const *s) {
    printf("yyerror %s",s);
}

void print(int r) {
    fprintf(intermediate, "MOV R2, \"Write\"\n");
    fprintf(intermediate, "PUSH R2\n");
    fprintf(intermediate, "MOV R2, -1\n");
    fprintf(intermediate, "PUSH R2\n");
    fprintf(intermediate, "PUSH R%d\n", r);
    fprintf(intermediate, "PUSH R2\n");
    fprintf(intermediate, "PUSH R2\n");
    fprintf(intermediate, "CALL 0\n");
    fprintf(intermediate, "POP R0\n");
    fprintf(intermediate, "POP R1\n");
    fprintf(intermediate, "POP R1\n");
    fprintf(intermediate, "POP R1\n");
    fprintf(intermediate, "POP R1\n");
    fprintf(intermediate, "MOV R2, \"Exit\"\n");
    fprintf(intermediate, "PUSH R2\n");
    fprintf(intermediate, "PUSH R2\n");
    fprintf(intermediate, "PUSH R2\n");
    fprintf(intermediate, "PUSH R2\n");
    fprintf(intermediate, "PUSH R2\n");
    fprintf(intermediate, "CALL 0\n");
    exit(1);
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Please provide an input filename\n");
        exit(1);
    } else {
        intermediate = fopen("intermediate.xsm", "w");
        fprintf(intermediate, "0\n2056\n0\n0\n0\n0\n0\n0\n");
        fp = fopen(argv[1], "r");
        if (!fp) {
            printf("Invalid input file specified\n");
            exit(1);
        } else {
            yyin = fp;
        }
    }
    yyparse();
    return 0;
}

