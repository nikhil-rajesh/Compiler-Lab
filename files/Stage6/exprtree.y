%{
	#include <stdlib.h>
	#include <stdio.h>
	#include "exprtree.h"
        #include "symboltable.h"
        #include "symboltable.c"
	#include "ast.c"
        #include "codegen.c"
        #include "initialize.c"
        #include "typecheck.h"
        #include "typecheck.c"

	int yylex(void);
        extern FILE *yyin;
        extern int lineno;
        FILE *fp;
        FILE *intermediate;
        void print(int);
        struct Paramstruct *argList1, *argList2;
        int declCount = 0, defCount = 0; // Definition and Declaration count of functions

        // For testing
        #include "printAbsTree.c"
        int testing = 1; // can use to test ASTree
%}

%union {
    struct ASTNode *nptr;
}

%token START END READ WRITE PLUS MINUS MUL DIV MOD ASSGN NUM ID
%token IF THEN ELSE ENDIF WHILE DO ENDWHILE EQ NEQ LE GE LT GT
%token BREAK CONT DECL ENDDECL INT STR STRVAL MAIN RETURN TYPE
%token ENDTYPE NILL FREE ALLOC

%nonassoc LT GT LE GE
%right EQ NEQ
%left PLUS MINUS
%left MUL DIV MOD
%right ASSGN

%type <nptr> NUM ID START END READ WRITE PLUS MINUS MUL DIV ASSGN
%type <nptr> IF THEN ELSE ENDIF WHILE DO ENDWHILE EQ NEQ LE GE LT
%type <nptr> GT BREAK CONT DECL ENDDECL INT STR STRVAL MOD MAIN RETURN
%type <nptr> TYPE ENDTYPE NILL FREE ALLOC
%type <nptr> program Slist Stmt expr id Type
%type <nptr> BrkStmt ContStmt IfStmt WhileStmt InputStmt OutputStmt AsgStmt
%type <nptr> MainBlock FDefBlock FDef ParamList Param ExprList func 
%type <nptr> LDeclBlock Body LDecList LDecl IdList RetStmt
%type <nptr> GDeclBlock GDeclList GDecl GIdList GId
%type <nptr> TypeDefBlock TypeDefList TypeDef UserDefinedType 
%type <nptr> FieldDeclList FieldDecl Field

%%

program: TypeDefBlock GDeclBlock FDefBlock MainBlock {fclose(intermediate);}
       | TypeDefBlock GDeclBlock MainBlock           {fclose(intermediate);}
       ;

TypeDefBlock: TYPE TypeDefList ENDTYPE
            | TYPE ENDTYPE
            |
            ;

TypeDefList: TypeDefList TypeDef
           | TypeDef
           ;

TypeDef: UserDefinedType '{' FieldDeclList '}'  { TInstall($1->name, Fhead); }
       ;

UserDefinedType: ID {
                        tempASTNode = $1;
                        $$ = $1;
                    }
               ;

FieldDeclList: FieldDeclList FieldDecl 
             | FieldDecl 
             ;

FieldDecl: FieldType ID ';' {
                                if(FLookup($2->name, Fhead) != NULL) {
                                    yyerror("Re-declaration of Field element %s\n", $2->name);
                                    exit(1);
                                }
                                FInstall($2->name, declarationType);
                            }
         ;

GDeclBlock: DECL GDeclList ENDDECL      {
                                            initialize();
                                            if(testing) {
                                                printTypeTable();
                                                printGSymbolTable();
                                            }
                                        }
          | DECL ENDDECL                {
                                            initialize();
                                            if(testing) {
                                                printTypeTable();
                                                printGSymbolTable();
                                            }
                                        }
          |                             {
                                            initialize();
                                            if(testing) {
                                                printTypeTable();
                                                printGSymbolTable();
                                            }
                                        }
          ;

GDeclList: GDeclList GDecl
         | GDecl
         ;

GDecl: Type GIdList ';'
     ;

FieldType: INT  {declarationType = TLookup("integer");}
         | STR  {declarationType = TLookup("string");}
         | ID   {
                    declarationType = TLookup($1->name);
                    if(declarationType == NULL) {
                        if(strcmp(tempASTNode->name, $1->name) != 0) {
                            yyerror("Undefined User Defined Type %s\n", $1->name);
                            exit(1);
                        } else {
                            declarationType = TLookup("dummy");
                        }
                    }
                }
        ;

Type: INT   {declarationType = TLookup("integer");}
    | STR   {declarationType = TLookup("string");}
    | ID    {
                declarationType = TLookup($1->name);
                if(declarationType == NULL) {
                    yyerror("Unknown user-defined type %s\n", $1->name);
                    exit(1);
                }
            }
    ;

FType: INT  {FDeclarationType = TLookup("integer");}
     | STR  {FDeclarationType = TLookup("string");}
     | ID   {
                declarationType = TLookup($1->name);
                if(declarationType == NULL) {
                    yyerror("Unknown user-defined type %s\n", $1->name);
                    exit(1);
                }
            }
     ;


GIdList: GIdList ',' GId
       | GId
       ;

GId: ID '(' ParamList ')'   {
                                declCount++;
                                checkAvailability($1->name, 1);
                                GInstall($1->name, declarationType, -1, Phead);
                                Phead = NULL;
                                Ptail = NULL;
                            }
   | ID                     {
                                checkAvailability($1->name, 1);
                                GInstall($1->name, declarationType, 1, NULL);
                            }
   | ID '[' NUM ']'         {
                                checkAvailability($1->name, 1);
                                if($3->value.intval < 1) {
                                    yyerror("Invalid array size", NULL);
                                    exit(1);
                                }
                                GInstall($1->name, declarationType, $3->value.intval, NULL);
                            }
   ;

FDefBlock: FDefBlock FDef
         | FDef
         ;

FDef: Type ID '(' ParamList ')' '{' LDeclBlock Body '}' {
                                                            defCount++;
                                                            Gtemp = GLookup($2->name);

                                                            if(Gtemp == NULL) {
                                                                yyerror("Function %s not declared", $2->name);
                                                                exit(1);
                                                            }

                                                            if(Gtemp->type != declarationType) {
                                                               yyerror("%s : Function type does not match declaration", $2->name);
                                                               exit(1);
                                                            }

                                                            argList1 = Phead;
                                                            argList2 = Gtemp->paramlist;

                                                            while(argList1 != NULL && argList2 != NULL) {
                                                                if(argList1->type != argList2->type) {
                                                                    yyerror("%s : Conflict in argument types", $2->name);
                                                                    exit(1);
                                                                }

                                                                if(strcmp(argList1->name, argList2->name)) {
                                                                    yyerror("%s : Conflict in argument names", $2->name);
                                                                    exit(1);
                                                                }

                                                                argList1 = argList1->next;
                                                                argList2 = argList2->next;
                                                            }

                                                            if ((argList1 != NULL) || (argList2 != NULL)) {
                                                                yyerror("Not enough arguments", NULL);
                                                                exit(1);
                                                            }

                                                            if(testing) {
                                                                printLSymbolTable($2->name);
                                                                print_dot($8, $2->name);
                                                            } else {
                                                                fprintf(intermediate, "F%d:\n",Gtemp->flabel);
                                                                fprintf(intermediate, "PUSH BP\n");
                                                                fprintf(intermediate, "MOV BP,SP\n");

                                                                Ltemp = Lhead;
                                                                while(Ltemp != NULL) {
                                                                    if(Ltemp->binding > 0)
                                                                        fprintf(intermediate, "PUSH R0\n");
                                                                    Ltemp = Ltemp->next;
                                                                }

                                                                codegen($8);
                                                            }

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

Param: FType ID  {
                    checkAvailability($2->name, 0);
                    PInstall($2->name, FDeclarationType);
                }
     ;

MainBlock: Type MAIN '(' ')' '{' LDeclBlock Body '}'   {
                                                            if(defCount != declCount) {
                                                                yyerror("All functions declared need to be defined\n", NULL);
                                                                exit(1);
                                                            }

                                                            if(declarationType != TLookup("integer")) {
                                                                yyerror("Main return type should be of integer type\n");
                                                                exit(1);
                                                            }

                                                            if(testing) {
                                                                printLSymbolTable("main");
                                                                print_dot($7, "main");
                                                            } else {
                                                                fprintf(intermediate, "MAIN:\n");
                                                                fprintf(intermediate, "PUSH BP\n");
                                                                fprintf(intermediate, "MOV BP,SP\n");

                                                                Ltemp = Lhead;
                                                                while (Ltemp != NULL)
                                                                {
                                                                    fprintf(intermediate, "PUSH R0\n");
                                                                    Ltemp = Ltemp->next;
                                                                }

                                                                codegen($7);
                                                            }

                                                            Lhead = NULL;
                                                            Ltail = NULL;
                                                        }
         ;

LDeclBlock: DECL LDecList ENDDECL   {InstallParamsInLocal();}
          | DECL ENDDECL            {InstallParamsInLocal();}
          |                         {InstallParamsInLocal();}
          ;

LDecList: LDecList LDecl
        | LDecl
        ;

LDecl: FType IdList ';'
     ;

IdList: IdList ',' IdList
      | ID      {
                    checkAvailability($1->name, 0);
                    LInstall($1->name, FDeclarationType);
                }
      ;

Body: START Slist RetStmt END   {$$ = TreeCreate(TLookup("void"), NODE_CONNECTOR, NULL, NULL, NULL, $2, $3, NULL);}
    | START RetStmt END         {$$ = $2;}
    ;

RetStmt: RETURN expr ';'    {
                                if(declarationType == $2->type) {
                                    $$ = TreeCreate(TLookup("void"), NODE_RET, NULL, NULL, NULL, $2, NULL, NULL);
                                } else {
                                    yyerror("Return type mismatch", NULL);
                                    exit(1);
                                }
                            }
       ;

Field: ID '.' ID        {
                            assignType($1, 0);
                            assignTypeField($3, $1->type->fields);
                            $$ = TreeCreate($3->type, NODE_FIELD, NULL, NULL, NULL, $1, $3, NULL);
                        }
     | Field '.' ID     {
                            $$ = insertFieldId($1, $3);
                        }
     ;

Slist: Slist Stmt       {$$ = TreeCreate(TLookup("void"), NODE_CONNECTOR, NULL, NULL, NULL, $1, $2, NULL);}
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
    | FREE '(' ID ')' ';'       {
                                    assignType($3, 0);
                                    if($3->type == TLookup("integer") || $3->type == TLookup("string")) {
                                        yyerror("Cannot FREE a string or integer variable\n", NULL);
                                        exit(1);
                                    }
                                    $$ = TreeCreate(TLookup("void"), NODE_FREE, NULL, NULL, NULL, $3, NULL, NULL);
                                }
    | FREE '(' Field ')' ';'    {
                                    if($3->type == TLookup("integer") || $3->type == TLookup("string")) {
                                        yyerror("Cannot FREE a string or integer variable\n", NULL);
                                        exit(1);
                                    }
                                    $$ = TreeCreate(TLookup("void"), NODE_FREE, NULL, NULL, NULL, $3, NULL, NULL);
                                }
    ;

IfStmt: IF '(' expr ')' THEN Slist ELSE Slist ENDIF ';'     {
                                                                typecheck($3->type, TLookup("boolean"), 'e');
                                                                $$ = TreeCreate(TLookup("void"), NODE_IF_ELSE, NULL, NULL, NULL, $3, $8, $6);
                                                            }
      | IF '(' expr ')' THEN Slist ENDIF ';'                {
                                                                typecheck($3->type, TLookup("boolean"), 'i');
                                                                $$ = TreeCreate(TLookup("void"), NODE_IF, NULL, NULL, NULL, $3, $6, NULL);
                                                            }
      ;

WhileStmt: WHILE '(' expr ')' DO Slist ENDWHILE ';'         {
                                                                typecheck($3->type, TLookup("boolean"), 'w');
                                                                $$ = TreeCreate(TLookup("void"), NODE_WHILE, NULL, NULL, NULL, $3, $6, NULL);
                                                            }
         ;
BrkStmt: BREAK ';'                  {$$ = TreeCreate(TLookup("void"), NODE_BREAK, NULL, NULL, NULL, NULL, NULL, NULL);}
       ;

ContStmt: CONT ';'                  {$$ = TreeCreate(TLookup("void"), NODE_CONT, NULL, NULL, NULL, NULL, NULL, NULL);}
        ;

InputStmt: READ '(' id ')' ';'      {
                                        if($3->type != TLookup("integer") && $3->type != TLookup("string")) {
                                            yyerror("Cannot READ a udt type\n", NULL);
                                            exit(1);
                                        }
                                        $$ = TreeCreate(TLookup("void"), NODE_READ, NULL, NULL, NULL, $3, NULL, NULL);
                                    }
         | READ '(' Field ')' ';'   {
                                        if($3->type != TLookup("integer") && $3->type != TLookup("string")) {
                                            yyerror("Cannot READ a udt type\n", NULL);
                                            exit(1);
                                        }
                                        $$ = TreeCreate(TLookup("void"), NODE_READ, NULL, NULL, NULL, $3, NULL, NULL);
                                    }
         ;

OutputStmt: WRITE '(' expr ')' ';'  {$$ = TreeCreate(TLookup("void"), NODE_WRITE, NULL, NULL, NULL, $3, NULL, NULL);}
          ;

AsgStmt: id ASSGN expr ';'          {
                                        typecheck($1->type, $3->type, '=');
                                        $$ = TreeCreate(TLookup("void"), NODE_ASSGN, NULL, NULL, NULL, $1, $3, NULL);
                                    }
       | ID ASSGN expr ';'          {
                                        assignType($1, 0);
                                        typecheck($1->type, $3->type, '=');
                                        $$ = TreeCreate(TLookup("void"), NODE_ASSGN, NULL, NULL, NULL, $1, $3, NULL);
                                    }
       | Field ASSGN ALLOC '(' ')' ';'  {
                                            if($1->type == TLookup("integer") || $1->type == TLookup("string")) {
                                                yyerror("Cannot ALLOC to string or integer variable\n", NULL);
                                                exit(1);
                                            }
                                            $$ = TreeCreate(TLookup("void"), NODE_ASSGN, NULL, NULL, NULL, $1, $3, NULL);
                                        }
       | ID ASSGN ALLOC '(' ')' ';'     {
                                            assignType($1, 0);
                                            if($1->type == TLookup("integer") || $1->type == TLookup("string")) {
                                                yyerror("Cannot ALLOC to string or integer variable\n", NULL);
                                                exit(1);
                                            }
                                            $$ = TreeCreate(TLookup("void"), NODE_ASSGN, NULL, NULL, NULL, $1, $3, NULL);
                                        }
       | Field ASSGN expr ';'           {
                                            typecheck($1->type, $3->type, '=');
                                            $$ = TreeCreate(TLookup("void"), NODE_ASSGN, NULL, NULL, NULL, $1, $3, NULL);
                    
                                        }
       | ID ASSGN NILL ';'              {
                                            assignType($1, 0);
                                            if($1->type == TLookup("integer") || $1->type == TLookup("string")) {
                                                yyerror("Cannot assign NULL to string or integer variable\n", NULL);
                                                exit(1);
                                            }
                                            $$ = TreeCreate(TLookup("void"), NODE_ASSGN, NULL, NULL, NULL, $1, $3, NULL);
                                        }
       | Field ASSGN NILL ';'           {
                                            if($1->type == TLookup("integer") || $1->type == TLookup("string")) {
                                                yyerror("Cannot assign NULL to string or integer variable\n", NULL);
                                                exit(1);
                                            }
                                            $$ = TreeCreate(TLookup("void"), NODE_ASSGN, NULL, NULL, NULL, $1, $3, NULL);
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
                            $$ = TreeCreate(TLookup("integer"), NODE_PLUS, NULL, NULL, NULL, $1, $3, NULL);
                        }
     | expr MINUS expr  {
                            typecheck($1->type, $3->type, 'a');
                            $$ = TreeCreate(TLookup("integer"), NODE_MINUS, NULL, NULL, NULL, $1, $3, NULL);
                        }
     | expr MUL expr	{
                            typecheck($1->type, $3->type, 'a');
                            $$ = TreeCreate(TLookup("integer"), NODE_MUL, NULL, NULL, NULL, $1, $3, NULL);
                        }
     | expr DIV expr	{
                            typecheck($1->type, $3->type, 'a');
                            $$ = TreeCreate(TLookup("integer"), NODE_DIV, NULL, NULL, NULL, $1, $3, NULL);
                        }
     | expr MOD expr	{
                            typecheck($1->type, $3->type, 'a');
                            $$ = TreeCreate(TLookup("integer"), NODE_MOD, NULL, NULL, NULL, $1, $3, NULL);
                        }
     | expr LT expr     {
                            typecheck($1->type, $3->type, 'b');
                            $$ = TreeCreate(TLookup("boolean"), NODE_LT, NULL, NULL, NULL, $1, $3, NULL);
                        }
     | expr GT expr     {
                            typecheck($1->type, $3->type, 'b');
                            $$ = TreeCreate(TLookup("boolean"), NODE_GT, NULL, NULL, NULL, $1, $3, NULL);
                        }
     | expr LE expr     {
                            typecheck($1->type, $3->type, 'b');
                            $$ = TreeCreate(TLookup("boolean"), NODE_LE, NULL, NULL, NULL, $1, $3, NULL);
                        }
     | expr GE expr     {
                            typecheck($1->type, $3->type, 'b');
                            $$ = TreeCreate(TLookup("boolean"), NODE_GE, NULL, NULL, NULL, $1, $3, NULL);
                        }
     | expr NEQ expr    {
                            typecheck($1->type, $3->type, 'b');
                            $$ = TreeCreate(TLookup("boolean"), NODE_NEQ, NULL, NULL, NULL, $1, $3, NULL);
                        }
     | expr EQ expr     {
                            typecheck($1->type, $3->type, 'b');
                            $$ = TreeCreate(TLookup("boolean"), NODE_EQ, NULL, NULL, NULL, $1, $3, NULL);
                        }
     | '(' expr ')'	{$$ = $2;}
     | NUM		{
                            $$ = $1;
                            $$->type = TLookup("integer");
                        }
     | MINUS NUM        {
                            $2->value.intval = -1*($2->value.intval);
                            $$ = $2;
                            $$->type = TLookup("integer");
                        }
     | STRVAL           {
                            $$ = $1;
                            $$->type = TLookup("string");
                        }
     | id		{$$ = $1;}
     | func             {$$ = $1;}
     | Field            {$$ = $1;}
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
                            $3->type = TLookup("integer");
                            assignType($1, 2);
                            $$ = TreeCreate($1->type, NODE_ARRAY, NULL, NULL, NULL, $1, $3, NULL);
                        }
  | ID '[' id ']'       {
                            assignType($1, 2);
                            $$ = TreeCreate($1->type, NODE_ARRAY, NULL, NULL, NULL, $1, $3, NULL);
                        }
  ;

%%

yyerror(char const *s, char const *var) {
    printf("\033[0;31mERR:%d\033[0m : ", lineno);
    printf(s, var);
}

int main(int argc, char *argv[]) {
    TInstall("integer", NULL);
    TInstall("string", NULL);
    TInstall("boolean", NULL);
    TInstall("void", NULL);
    TInstall("dummy", NULL); // This is for creating the fieldlist in case of udt

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

