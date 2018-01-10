
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

gcc: scanner.c parser.c tree interpreter.c tables
	gcc -Wall -o trab4 scanner.c parser.c tree.o interpreter.c tables.o -ly

clean:
	@rm -f *.o *.output scanner.c parser.h parser.c trab4 *.dot *.pdf
