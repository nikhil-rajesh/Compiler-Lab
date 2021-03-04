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
        extern int lineno;
        FILE *fp;
        FILE *intermediate;
        void print(int);
%}

%union {
    struct ASTNode *nptr;
}

%token START END READ WRITE PLUS MINUS MUL DIV MOD ASSGN NUM ID
%token IF THEN ELSE ENDIF WHILE DO ENDWHILE EQ NEQ LE GE LT GT
%token BREAK CONT DECL ENDDECL INT STR STRVAL MAIN RETURN

%nonassoc LT GT LE GE
%right EQ NEQ
%left PLUS MINUS
%left MUL DIV MOD
%right ASSGN

%type <nptr> NUM ID START END READ WRITE PLUS MINUS MUL DIV ASSGN
%type <nptr> IF THEN ELSE ENDIF WHILE DO ENDWHILE EQ NEQ LE GE LT
%type <nptr> GT BREAK CONT DECL ENDDECL INT STR STRVAL MOD MAIN RETURN
%type <nptr> program Slist Stmt InputStmt OutputStmt AsgStmt expr id
%type <nptr> BrkStmt ContStmt IfStmt WhileStmt Type GDeclBlock FDefBlock
%type <nptr> MainBlock GDeclList GDecl GIdList GId ParamList FDef
%type <nptr> LDeclBlock Body Param LDecList LDecl IdList RetStmt
%type <nptr> ExprList func

%%

program: GDeclBlock FDefBlock MainBlock {fclose(intermediate);}
       | GDeclBlock MainBlock           {fclose(intermediate);}
       | MainBlock                      {fclose(intermediate);}
       ;

GDeclBlock: DECL GDeclList ENDDECL      {initialize();}
          | DECL ENDDECL                {initialize();}
          ;

GDeclList: GDeclList GDecl
         | GDecl
         ;

GDecl: Type GIdList ';'
     ;

Type: INT   {declaration_type = TYPE_INT;}
    | STR   {declaration_type = TYPE_STR;}
    ;

FType: INT   {FDeclaration_type = TYPE_INT;}
     | STR   {FDeclaration_type = TYPE_STR;}
     ;


GIdList: GIdList ',' GId
       | GId
       ;

GId: ID '(' ParamList ')'   {
                                checkAvailability($1->name, 1);
                                GInstall($1->name, declaration_type, -1, Phead);
                                Phead = NULL;
                                Ptail = NULL;
                            }
   | ID                     {
                                checkAvailability($1->name, 1);
                                GInstall($1->name, declaration_type, 1, NULL);
                            }
   | ID '[' NUM ']'         {
                                checkAvailability($1->name, 1);
                                if($3->value.intval < 1) {
                                    yyerror("Invalid array size", NULL);
                                    exit(1);
                                }
                                GInstall($1->name, declaration_type, $3->value.intval, NULL);
                            }
   ;

FDefBlock: FDefBlock FDef
         | FDef
         ;

FDef: Type ID '(' ParamList ')' '{' LDeclBlock Body '}' {
                                                            printLSymbolTable();
                                                            print_dot($8, $2->name);
                                                            Phead = NULL;
                                                            Ptail = NULL;
                                                            Lhead = NULL;
                                                            Ltail = NULL;
                                                        }
    ;

ParamList: ParamList ',' Param
         | Param
         |
         ;

Param: Type ID  {
                    checkAvailability($2->name, 0);
                    PInstall($2->name, declaration_type);
                }
     ;

MainBlock: Type MAIN '(' ')' '{' LDeclBlock Body '}'   {
                                                            printGSymbolTable();
                                                            printLSymbolTable();
                                                            print_dot($7, "main");
                                                            //fprintf(intermediate, "MAIN:\n");
                                                            //codegen($3); 
                                                            //fprintf(intermediate, "RET\n");

                                                            Lhead = NULL;
                                                            Ltail = NULL;
                                                        }
         ;

LDeclBlock: DECL LDecList ENDDECL   {InstallParamsInLocal();}
          | DECL ENDDECL            {InstallParamsInLocal();}
          ;

LDecList: LDecList LDecl
        | LDecl
        ;

LDecl: FType IdList ';'
     ;

IdList: IdList, IdList
      | ID      {
                    checkAvailability($1->name, 0);
                    LInstall($1->name, FDeclaration_type);
                }
      ;

Body: START Slist RetStmt END   {$$ = TreeCreate(TYPE_VOID, NODE_CONNECTOR, NULL, NULL, NULL, $2, $3, NULL);}
    | START RetStmt END         {$$ = $2;}
    ;

RetStmt: RETURN expr ';'    {
                                if(declaration_type == $2->type) {
                                    $$ = TreeCreate(TYPE_VOID, NODE_RET, NULL, NULL, NULL, $2, NULL, NULL);
                                } else {
                                    yyerror("Return type mismatch", NULL);
                                    exit(1);
                                }
                            }
       ;

Slist: Slist Stmt       {$$ = TreeCreate(TYPE_VOID, NODE_CONNECTOR, NULL, NULL, NULL, $1, $2, NULL);}
    | Stmt              {$$ = $1;}
    ;

Stmt: InputStmt         {$$ = $1;}
    | OutputStmt        {$$ = $1;}
    | AsgStmt           {$$ = $1;}
    | IfStmt            {$$ = $1;}
    | WhileStmt         {$$ = $1;}
    | BrkStmt           {$$ = $1;}
    | ContStmt          {$$ = $1;}
    | func ';'          {$$ = $1;}
    ;

IfStmt: IF '(' expr ')' THEN Slist ELSE Slist ENDIF ';'     {
                                                                typecheck($3->type, TYPE_BOOL, 'e');
                                                                $$ = TreeCreate(TYPE_VOID, NODE_IF_ELSE, NULL, NULL, NULL, $3, $8, $6);
                                                            }
      | IF '(' expr ')' THEN Slist ENDIF ';'                {
                                                                typecheck($3->type, TYPE_BOOL, 'i');
                                                                $$ = TreeCreate(TYPE_VOID, NODE_IF, NULL, NULL, NULL, $3, $6, NULL);
                                                            }
      ;

WhileStmt: WHILE '(' expr ')' DO Slist ENDWHILE ';'         {
                                                                typecheck($3->type, TYPE_BOOL, 'w');
                                                                $$ = TreeCreate(TYPE_VOID, NODE_WHILE, NULL, NULL, NULL, $3, $6, NULL);
                                                            }
         ;
BrkStmt: BREAK ';'                  {$$ = TreeCreate(TYPE_VOID, NODE_BREAK, NULL, NULL, NULL, NULL, NULL, NULL);}
       ;

ContStmt: CONT ';'                  {$$ = TreeCreate(TYPE_VOID, NODE_CONT, NULL, NULL, NULL, NULL, NULL, NULL);}
        ;

InputStmt: READ '(' id ')' ';'      {$$ = TreeCreate(TYPE_VOID, NODE_READ, NULL, NULL, NULL, $3, NULL, NULL);}
         ;

OutputStmt: WRITE '(' expr ')' ';'  {$$ = TreeCreate(TYPE_VOID, NODE_WRITE, NULL, NULL, NULL, $3, NULL, NULL);}
          ;

AsgStmt: id ASSGN expr ';'          {
                                        typecheck($1->type, $3->type, '=');
                                        $$ = TreeCreate(TYPE_VOID, NODE_ASSGN, NULL, NULL, NULL, $1, $3, NULL);
                                    }
       ;

ExprList: ExprList ',' expr {
                                $3->arglist = $1;
                                $$ = $3;
                            }
        | expr              {$$ = $1;}
        |                   {$$ = NULL;}
        ;

expr : expr PLUS expr	{
                            typecheck($1->type, $3->type, 'a');
                            $$ = TreeCreate(TYPE_INT, NODE_PLUS, NULL, NULL, NULL, $1, $3, NULL);
                        }
     | expr MINUS expr  {
                            typecheck($1->type, $3->type, 'a');
                            $$ = TreeCreate(TYPE_INT, NODE_MINUS, NULL, NULL, NULL, $1, $3, NULL);
                        }
     | expr MUL expr	{
                            typecheck($1->type, $3->type, 'a');
                            $$ = TreeCreate(TYPE_INT, NODE_MUL, NULL, NULL, NULL, $1, $3, NULL);
                        }
     | expr DIV expr	{
                            typecheck($1->type, $3->type, 'a');
                            $$ = TreeCreate(TYPE_INT, NODE_DIV, NULL, NULL, NULL, $1, $3, NULL);
                        }
     | expr MOD expr	{
                            typecheck($1->type, $3->type, 'a');
                            $$ = TreeCreate(TYPE_INT, NODE_MOD, NULL, NULL, NULL, $1, $3, NULL);
                        }
     | expr LT expr     {
                            typecheck($1->type, $3->type, 'b');
                            $$ = TreeCreate(TYPE_BOOL, NODE_LT, NULL, NULL, NULL, $1, $3, NULL);
                        }
     | expr GT expr     {
                            typecheck($1->type, $3->type, 'b');
                            $$ = TreeCreate(TYPE_BOOL, NODE_GT, NULL, NULL, NULL, $1, $3, NULL);
                        }
     | expr LE expr     {
                            typecheck($1->type, $3->type, 'b');
                            $$ = TreeCreate(TYPE_BOOL, NODE_LE, NULL, NULL, NULL, $1, $3, NULL);
                        }
     | expr GE expr     {
                            typecheck($1->type, $3->type, 'b');
                            $$ = TreeCreate(TYPE_BOOL, NODE_GE, NULL, NULL, NULL, $1, $3, NULL);
                        }
     | expr NEQ expr    {
                            typecheck($1->type, $3->type, 'b');
                            $$ = TreeCreate(TYPE_BOOL, NODE_NEQ, NULL, NULL, NULL, $1, $3, NULL);
                        }
     | expr EQ expr     {
                            typecheck($1->type, $3->type, 'b');
                            $$ = TreeCreate(TYPE_BOOL, NODE_EQ, NULL, NULL, NULL, $1, $3, NULL);
                        }
     | '(' expr ')'	{$$ = $2;}
     | NUM		{$$ = $1;}
     | MINUS NUM        {
                            $2->value.intval = -1*($2->value.intval);
                            $$ = $2;
                        }
     | STRVAL           {$$ = $1;}
     | id		{$$ = $1;}
     | func             {$$ = $1;}
     ;

func: ID '(' ExprList ')'   {
                                assignType($1, 1); 
                                $1->nodetype = NODE_FUNC;
                                $1->ptr1 = reverseList($3);
                                $$ = $1;
                            }

id: ID                  {
                            assignType($1, 0);
                            $$ = $1;
                        }
  | ID '[' NUM ']'      {
                            assignType($1, 0);
                            $$ = TreeCreate($1->type, NODE_ARRAY, NULL, NULL, NULL, $1, $3, NULL);
                        }
  | ID '[' id ']'       {
                            assignType($1, 0);
                            $$ = TreeCreate($1->type, NODE_ARRAY, NULL, NULL, NULL, $1, $3, NULL);
                        }
  ;

%%

yyerror(char const *s, char const *var) {
    printf("\033[0;31mERR:%d\033[0m : ", lineno);
    printf(s, var);
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        yyerror("Please provide an input filename\n", NULL);
        exit(1);
    } else {
        fp = fopen(argv[1], "r");
        if (!fp) {
            yyerror("Invalid input file specified\n", NULL);
            exit(1);
        } else {
            yyin = fp;
        }
    }
    yyparse();
    return 0;
}

