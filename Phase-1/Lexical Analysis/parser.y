%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	extern FILE *yyin;
	extern int line;
	extern int yylex();
	void yyerror();
%}



%token T_VAR T_CONST T_INT T_FLOAT T_BOOL T_DECL T_IF T_ELSE T_FOR T_CONT T_BREAK
%token T_ADD T_SUB T_MUL T_DIV T_MOD T_LT T_LTEQ T_GT T_GTEQ T_EQ T_EQEQ T_NEQ T_AND
%token T_OR T_NOT T_LPAREN T_RPAREN T_RBRACK T_LBRACK T_LBRACE T_RBRACE T_SEMI T_DOT T_COMMA T_NL 
%token T_ID T_CONST_INT T_CONST_FLOAT T_STRING
%start program
%%
program:  ;
%%

void yyerror ()
{
  fprintf(stderr, "Syntax error at line %d\n", line);
  exit(1);
}
/*
int main (int argc, char *argv[]){

	int flag;
	yyin = fopen(argv[1], "r");
	flag = yyparse();
	fclose(yyin);
	
	printf("Parsing finished!");
	
	return flag;
}
*/