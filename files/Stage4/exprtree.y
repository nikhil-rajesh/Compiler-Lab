%{
	#include <stdlib.h>
	#include <stdio.h>
	#include "exprtree.h"
	#include "ast.c"
        #include "symboltable.h"
        #include "symboltable.c"
        #include "codegen.c"
        #include "initialize.c"
        #include "typecheck.c"
        // For testing
        #include "printAbsTree.c"
	int yylex(void);
        extern FILE *yyin;
        FILE *fp;
        FILE *intermediate;
        void print(int);
%}

%union {
    struct tnode *nptr;
}

%token START END READ WRITE PLUS MINUS MUL DIV MOD ASSGN NUM ID
%token IF THEN ELSE ENDIF WHILE DO ENDWHILE EQ NEQ LE GE LT GT
%token BREAK CONT DECL ENDDECL INT STR STRVAL

%nonassoc LT GT LE GE
%right EQ NEQ
%left PLUS MINUS
%left MUL DIV MOD
%right ASSGN

%type <nptr> NUM ID START END READ WRITE PLUS MINUS MUL DIV ASSGN
%type <nptr> IF THEN ELSE ENDIF WHILE DO ENDWHILE EQ NEQ LE GE LT 
%type <nptr> GT BREAK CONT DECL ENDDECL INT STR STRVAL MOD
%type <nptr> program Slist Stmt InputStmt OutputStmt AsgStmt expr id
%type <nptr> BrkStmt ContStmt IfStmt WhileStmt Declarations DeclList
%type <nptr> Type Decl VarList 

%%

program: Declarations START Slist END ';'   {
                                                $$ = $3;
                                                //printSymbolTable();
                                                //print_dot($2);
                                                initialize();
                                                fprintf(intermediate, "MAIN:\n");
                                                codegen($3); 
                                                fprintf(intermediate, "RET\n");
                                                fclose(intermediate);
                                            }
       | Declarations START END ';'         {$$ = $2;}
       ;

Slist: Slist Stmt       {$$ = createTree(TYPE_VOID, 0, NODE_CONNECTOR, NULL, $1, $2, NULL);}
    | Stmt              {$$ = $1;}
    ;

Stmt: InputStmt         {$$ = $1;}
    | OutputStmt        {$$ = $1;}
    | AsgStmt           {$$ = $1;}
    | IfStmt            {$$ = $1;}
    | WhileStmt         {$$ = $1;}
    | BrkStmt           {$$ = $1;}
    | ContStmt          {$$ = $1;}
    ;

Declarations: DECL DeclList ENDDECL ';'
            | DECL ENDDECL ';'
            ;

DeclList: DeclList Decl
        | Decl
        ;

Decl: Type VarList ';'
    ;

Type: INT   {declaration_type = TYPE_INT;}
    | STR   {declaration_type = TYPE_STR;}
    ;

VarList: VarList ',' VarList
       | ID '[' NUM ']'     {GInstall($1->varname, declaration_type, $3->val);}
       | ID                 {GInstall($1->varname, declaration_type, 1);}
       ;

IfStmt: IF '(' expr ')' THEN Slist ELSE Slist ENDIF ';'     {
                                                                typecheck($3->type, TYPE_BOOL, 'e');
                                                                $$ = createTree(TYPE_VOID, 0, NODE_IF_ELSE, NULL, $3, $8, $6);
                                                            }
      | IF '(' expr ')' THEN Slist ENDIF ';'                {
                                                                typecheck($3->type, TYPE_BOOL, 'i');
                                                                $$ = createTree(TYPE_VOID, 0, NODE_IF, NULL, $3, $6, NULL);
                                                            }
      ;

WhileStmt: WHILE '(' expr ')' DO Slist ENDWHILE ';'         {
                                                                typecheck($3->type, TYPE_BOOL, 'w');
                                                                $$ = createTree(TYPE_VOID, 0, NODE_WHILE, NULL, $3, $6, NULL);
                                                            }
         ;
BrkStmt: BREAK ';'                  {$$ = createTree(TYPE_VOID, 0, NODE_BREAK, NULL, NULL, NULL, NULL);}
       ;

ContStmt: CONT ';'                  {$$ = createTree(TYPE_VOID, 0, NODE_CONT, NULL, NULL, NULL, NULL);}
        ;

InputStmt: READ '(' id ')' ';'      {$$ = createTree(TYPE_VOID, 0, NODE_READ, NULL, $3, NULL, NULL);}
         ;

OutputStmt: WRITE '(' expr ')' ';'  {$$ = createTree(TYPE_VOID, 0, NODE_WRITE, NULL, $3, NULL, NULL);}
          ;

AsgStmt: id ASSGN expr ';'          {
                                        typecheck($1->type, $3->type, '=');
                                        $$ = createTree(TYPE_VOID, 0, NODE_ASSGN, NULL, $1, $3, NULL);
                                    }
       ;

expr : expr PLUS expr	{
                            typecheck($1->type, $3->type, 'a');
                            $$ = createTree(TYPE_INT, 0, NODE_PLUS, NULL, $1, $3, NULL);
                        }
     | expr MINUS expr  {
                            typecheck($1->type, $3->type, 'a');
                            $$ = createTree(TYPE_INT, 0, NODE_MINUS, NULL, $1, $3, NULL);
                        }
     | expr MUL expr	{
                            typecheck($1->type, $3->type, 'a');
                            $$ = createTree(TYPE_INT, 0, NODE_MUL, NULL, $1, $3, NULL);
                        }
     | expr DIV expr	{
                            typecheck($1->type, $3->type, 'a');
                            $$ = createTree(TYPE_INT, 0, NODE_DIV, NULL, $1, $3, NULL);
                        }
     | expr MOD expr	{
                            typecheck($1->type, $3->type, 'a');
                            $$ = createTree(TYPE_INT, 0, NODE_MOD, NULL, $1, $3, NULL);
                        }
     | expr LT expr     {
                            typecheck($1->type, $3->type, 'b');
                            $$ = createTree(TYPE_BOOL, 0, NODE_LT, NULL, $1, $3, NULL);
                        }
     | expr GT expr     {
                            typecheck($1->type, $3->type, 'b');
                            $$ = createTree(TYPE_BOOL, 0, NODE_GT, NULL, $1, $3, NULL);
                        }
     | expr LE expr     {
                            typecheck($1->type, $3->type, 'b');
                            $$ = createTree(TYPE_BOOL, 0, NODE_LE, NULL, $1, $3, NULL);
                        }
     | expr GE expr     {
                            typecheck($1->type, $3->type, 'b');
                            $$ = createTree(TYPE_BOOL, 0, NODE_GE, NULL, $1, $3, NULL);
                        }
     | expr NEQ expr    {
                            typecheck($1->type, $3->type, 'b');
                            $$ = createTree(TYPE_BOOL, 0, NODE_NEQ, NULL, $1, $3, NULL);
                        }
     | expr EQ expr     {
                            typecheck($1->type, $3->type, 'b');
                            $$ = createTree(TYPE_BOOL, 0, NODE_EQ, NULL, $1, $3, NULL);
                        }
     | '(' expr ')'	{$$ = $2;}
     | NUM		{$$ = $1;}
     | STRVAL           {$$ = $1;}
     | id		{$$ = $1;}
     ;

id: ID                  {
                            $1->Gentry = GLookup($1->varname);
                            if($1->Gentry == NULL) {
                                printf("Variable '%s' not declared!", $1->varname);
                                exit(1);
                            }
                            $1->type = $1->Gentry->type;
                            $$ = $1;
                        }
  | ID '[' NUM ']'      {
                            $1->Gentry = GLookup($1->varname);
                            if($1->Gentry == NULL) {
                                printf("Variable '%s' not declared!", $1->varname);
                                exit(1);
                            } else if($1->Gentry->size <= $3->val || $3->val < 0) {
                                printf("Array '%s' out of bounds!", $1->varname);
                                exit(1);
                            }
                            $1->type = $1->Gentry->type;
                            $$ = createTree($1->type, 0, NODE_ARRAY, NULL, $1, $3, NULL);
                        }
  | ID '[' id ']'       {
                            $1->Gentry = GLookup($1->varname);
                            if($1->Gentry == NULL) {
                                printf("Variable '%s' not declared!", $1->varname);
                                exit(1);
                            }
                            $1->type = $1->Gentry->type;
                            $$ = createTree($1->type, 0, NODE_ARRAY, NULL, $1, $3, NULL);
                        }
  ;

%%

yyerror(char const *s) {
    printf("yyerror %s",s);
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Please provide an input filename\n");
        exit(1);
    } else {
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

