SRC=$(wildcard *.gv)
OUT=$(SRC:.gv=.png)

all: $(OUT)

%.png: %.gv
	dot -Tpng $^ > $@

clean: 
	$(RM) *.png
