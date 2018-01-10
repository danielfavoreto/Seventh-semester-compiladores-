
all: bison flex gcc
	@echo "Done."

bison: parser.y
	bison parser.y

flex: scanner.l
	flex scanner.l

tables: tables.c
	gcc -Wall -c tables.c

tree: tree.c
	gcc -Wall -c tree.c

gcc: scanner.c parser.c tree tables
	gcc -Wall -o trab3 scanner.c parser.c tree.o tables.o -ly

clean:
	@rm -f *.o *.output scanner.c parser.h parser.c trab3 *.dot *.pdf
