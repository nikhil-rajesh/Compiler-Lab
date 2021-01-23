all: 
	lex *.l
	yacc -d *.y
	gcc lex.yy.c y.tab.c -w

clean: 
	rm a.out lex.yy.c y.tab.c y.tab.h
