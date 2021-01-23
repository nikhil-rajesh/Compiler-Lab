%{
    #include<stdio.h>
    int valid=1;
%}

%token DIGIT VAR

%%

start : VAR s
s :     VAR s
      | DIGIT s
      |
      ;

%%

int yyerror() {
    printf("\nIts not a identifier!\n");
    valid=0;
    return 0;
}

int main() {
    printf("\nEnter:");
    yyparse();
    if(valid) {
        printf("\nIt is a identifier!\n");
    }
}

