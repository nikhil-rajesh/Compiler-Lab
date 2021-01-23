%option noyywrap
%{
    #include "y.tab.h"
%}

digit [0-9]
char [a-zA-Z]

%%

(<=|>=|<|>|==|!=) {return RELOP;}
if {return IF;}
(S|s) {return STMT;}
{char}({char}|{digit}|_)* {return ID;}
{digit}* {return NUM;}
. {return yytext[0];}
\n {return NL;}

%%
