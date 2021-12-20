%option noyywrap

%{
	#include <stdio.h>
	#include <stdlib.h> 
	#include <string.h>
	#include "y.tab.h"
	extern FILE *yyin;
	void display(char *token_type);
	int line = 1; 
	void yyerror();
%}

alpha     [a-zA-Z]
digit     [0-9]
ascii     [ -~]

ID        {alpha}({alpha}|{digit})*
CONST_INT    {digit}+
CONST_FLOAT    {digit}*"."{digit}+
STRING    \"{ascii}*\"

%%

"var"           { display("KEYWORD_VAR"); return T_VAR;}
"const"         { display("KEYWORD_CONST"); return T_CONST;}
"int"			{ display("KEYWORD_INT"); return T_INT;}
"float32"		{ display("KEYWORD_FLOAT"); return T_FLOAT;}
"bool"          { display("KEYWORD_BOOL"); return T_BOOL;}
":="            { display("KEYWORD_DECL"); return T_DECL;}
"if"			{ display("KEYWORD_IF"); return T_IF;}
"else"			{ display("KEYWORD_ELSE"); return T_ELSE;}
"for"			{ display("KEYWORD_FOR"); return T_FOR;}
"continue"  	{ display("KEYWORD_CONTINUE"); return T_CONT;}
"break"			{ display("KEYWORD_BREAK"); return T_BREAK;}

"//".*          {;}

"+"     {display("T_ADD"); return T_ADD;}
"-"     {display("T_SUB"); return T_SUB;}
"*"     {display("T_MUL"); return T_MUL;}
"/"     {display("T_DIV"); return T_DIV; }
"%"     {display("T_MOD"); return T_MOD;}
"<"     {display("T_LT"); return T_LT;}
"<="    {display("T_LTEQ"); return T_LTEQ;}
">"     {display("T_GT"); return T_GT;}
">="    {display("T_GTEQ"); return T_GTEQ;}
"="     {display("T_EQ"); return T_EQ;}
"=="    {display("T_EQEQ"); return T_EQEQ;}
"!="    {display("T_NEQ"); return T_NEQ;}
"&&"    {display("T_AND"); return T_AND; }
"||"    {display("T_OR"); return T_OR;}
"!"     {display("T_NOT"); return T_NOT;}
"("     {display("T_LPAREN"); return T_LPAREN;}
")"     {display("T_RPAREN");  return T_RPAREN;}
"]"     {display("T_RBRACK");  return T_RBRACK;}
"["     {display("T_LBRACK");  return T_LBRACK;}
"{"     {display("T_LBRACE");  return T_LBRACE;}
"}"     {display("T_RBRACE");  return T_RBRACE;}
";"     {display("T_SEMI");  return T_SEMI;}
"."     {display("T_DOT");  return T_DOT;}
","     {display("T_COMMA");  return T_COMMA;}
"\n"    {display("T_NL"); line++;  return T_NL;}

{ID}            {display("T_ID"); return T_ID;}
{CONST_INT}     {display("T_CONST_INT"); return T_CONST_INT; }
{CONST_FLOAT}   {display("T_CONST_FLOAT"); return T_CONST_FLOAT; }
{STRING}        {display("T_STRING"); return T_STRING; }


[ \t\r\f]+  {;}

.       { printf("Unrecognized character"); }

%%


void display(char *token_type){
	printf("yytext: %s\ttoken: %s\tlineno: %d\n", yytext, token_type, line);
}

int main(int argc, char *argv[]){
	yyin = fopen(argv[1], "r");
    printf("-------------------------------------------------------------------");
    printf("\nSNo \t|\tToken \t\t|\tToken Type \t\n");
    printf("-------------------------------------------------------------------\n");

	yylex();
	fclose(yyin);
	
	return 0;
}