lex lexer.l
yacc -d parser.y
gcc lex.yy.c y.tab.c -ll -ly
./a.out < icg.txt
rm lex.yy.c
rm y.tab.c
rm y.tab.h
rm a.out
