%{
    #include<stdio.h>
    #include<stdlib.h>
    #include "ltranslate.c"

    int pass = 0; // 0 = First pass; 1 = Second pass
    int temp;
    int linecount = 2048, noNewLine = 0;
    char* Lname;
    FILE *intermediate;
%}

identifier [a-zA-Z0-9]+

%%

\".*\"                          {
                                    if(pass)
                                        fprintf(intermediate, "%s", yytext);
                                }
{identifier}:                   {
                                    if(pass) {
                                        noNewLine = 1;
                                    } else {
                                        Lname = (char*)malloc(yyleng - 1);
                                        yyless(yyleng-1);
                                        strcpy(Lname, yytext);
                                        Lappend(Lname, linecount);
                                        linecount-=2;
                                    }
                                }
"CALL 0"                        {
                                    if(pass)
                                        fprintf(intermediate, "%s", yytext);
                                }
"CALL "{identifier}             {
                                    if(pass) {
                                        temp = LLookup(yytext + 5);
                                        if(temp == -1) {
                                            fprintf(intermediate, "%s", yytext);
                                        } else {
                                            fprintf(intermediate, "CALL %d", LLookup(yytext + 5));
                                        }
                                    }
                                }
"JMP "{identifier}              {
                                    if(pass)
                                        fprintf(intermediate, "JMP %d", LLookup(yytext + 4));
                                }
"MOV R"[0-9]+[,]{identifier}    {
                                    if(pass) {
                                        if(yytext[6] == ',') {
                                            temp = LLookup(yytext + 7);
                                            if(temp == -1) {
                                                fprintf(intermediate, "%s", yytext);
                                            } else {
                                                fprintf(
                                                    intermediate,
                                                    "MOV R%c, %d",
                                                    yytext[5],
                                                    LLookup(yytext + 7)
                                                );
                                            }
                                        } else {
                                            temp = LLookup(yytext + 8);
                                            if(temp == -1) {
                                                fprintf(intermediate, "%s", yytext);
                                            } else {
                                                fprintf(
                                                    intermediate,
                                                    "MOV R%c%c, %d",
                                                    yytext[5],
                                                    yytext[6],
                                                    LLookup(yytext + 8)
                                                );
                                            }
                                        }
                                    }
                                }
"JNZ R"[0-9]+[,]{identifier}    {
                                    if(pass) {
                                        if(yytext[6] == ',') 
                                            fprintf(
                                                intermediate,
                                                "JNZ  R%c, %d",
                                                yytext[5],
                                                LLookup(yytext + 7)
                                            );
                                        else
                                            fprintf(
                                                intermediate,
                                                "JNZ  R%c%c, %d",
                                                yytext[5],
                                                yytext[6],
                                                LLookup(yytext + 8)
                                            );
                                    }
                                }
"JZ R"[0-9]+[,]{identifier}     {
                                    if(pass) {
                                        if(yytext[5] == ',') 
                                            fprintf(
                                                intermediate,
                                                "JZ  R%c, %d",
                                                yytext[4],
                                                LLookup(yytext + 6)
                                            );
                                        else
                                            fprintf(
                                                intermediate,
                                                "JZ  R%c%c, %d",
                                                yytext[4],
                                                yytext[5],
                                                LLookup(yytext + 7)
                                            );
                                    }
                                }
\n                              {
                                    if(pass) {
                                        if(noNewLine)
                                            noNewLine = 0;
                                        else
                                            fprintf(intermediate, "\n");
                                    } else {
                                        if(linecount < 2056)
                                            linecount++;
                                        else
                                            linecount+=2;
                                    }
                                }
.                               {
                                    if(pass)
                                        fprintf(intermediate, "%s", yytext);
                                }

%%

int yywrap(void) {
    if(!pass) {
       pass = 1;
       yyin = fopen("machinecode.xsm", "r");
       intermediate = fopen("intermediate.xsm", "w");
       return 0;
    }

    remove("machinecode.xsm");
    rename("intermediate.xsm", "machinecode.xsm");
    return 1;
}

int main() {
   yyin = fopen("machinecode.xsm", "r");
   yylex();
   return 0;
}
