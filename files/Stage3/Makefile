CC = gcc
CFLAGS = -g -fcommon
LEX = lex
YACC = yacc

default: expl-bin

expl-bin: lex.yy.o
	$(CC) $(CFLAGS) -o expl-bin lex.yy.o

y.tab.o: y.tab.c y.tab.h exprtree.h exprtree.c initialize.c codegen.c typecheck.c
	$(CC) $(CFLAGS) -w -c y.tab.c

lex.yy.o: lex.yy.c y.tab.c exprtree.h
	$(CC) $(CFLAGS) -w -c lex.yy.c

lex.yy.c: exprtree.l
	$(LEX) exprtree.l

y.tab.c: exprtree.y
	$(YACC) -d exprtree.y

ltranslate: ltranslate.o
	$(CC) $(CFLAGS) -o ltranslate ltranslate.lex.o

ltranslate.o: ltranslate.lex.c
	$(CC) $(CFLAGS) -w -c ltranslate.lex.c

ltranslate.lex.c: ltranslate.l
	$(LEX) -o ltranslate.lex.c ltranslate.l

clean: 
	rm expl-bin ltranslate *.o lex.yy.c y.* ltranslate.lex.c machinecode.xsm
