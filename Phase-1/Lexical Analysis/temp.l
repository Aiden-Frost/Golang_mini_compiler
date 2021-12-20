%option noyywrap

%{
	#include <stdio.h>
	#include <stdlib.h> 
	#include <string.h>
    void display(char *token_type);
	extern FILE *yyin;
	
	int line = 1; 
	void yyerror();
%}

alpha     [a-zA-Z]
digit     [0-9]
ascii     [ -~]

ID        {alpha}({alpha}|{digit})*
INVALID_ID ({digit}|{@})+({alpha}|{digit}|{_}|{@})*
CONST_INT    {digit}+
CONST_FLOAT    [-+]?{digit}*\.?{digit}+([eE][-+]?{digit}+)?
STRING    \"{ascii}*\"

%%

"var"           { display("KEYWORD_VAR"); }
"const"         { display("KEYWORD_CONST"); }
"int"			{ display("KEYWORD_INT"); }
"float32"		{ display("KEYWORD_FLOAT"); }
"bool"          { display("KEYWORD_BOOL"); }
":="            { display("KEYWORD_DECL"); }
"if"			{ display("KEYWORD_IF"); }
"else"			{ display("KEYWORD_ELSE"); }
"for"			{ display("KEYWORD_FOR"); }
"continue"  	{ display("KEYWORD_CONTINUE"); }
"break"			{ display("KEYWORD_BREAK"); }

"//".*			{;}
[ \t\r\f]+  {;}		

"+"     {display("T_ADD"); }
"-"     {display("T_SUB"); }
"*"     {display("T_MUL"); }
"/"     {display("T_DIV");  }
"%"     {display("T_MOD"); }
"<"     {display("T_LT"); }
"<="    {display("T_LTEQ"); }
">"     {display("T_GT"); }
">="    {display("T_GTEQ"); }
"="     {display("T_EQ"); }
"=="    {display("T_EQEQ"); }
"!="    {display("T_NEQ"); }
"&&"    {display("T_AND");  }
"||"    {display("T_OR"); }
"!"     {display("T_NOT"); }
"("     {display("T_LPAREN"); }
")"     {display("T_RPAREN");  }
"]"     {display("T_RBRACK");  }
"["     {display("T_LBRACK");  }
"{"     {display("T_LBRACE");  }
"}"     {display("T_RBRACE");  }
";"     {display("T_SEMI");  }
"."     {display("T_DOT");  }
","     {display("T_COMMA");  }
"\n"    {line++;  }

{ID}            {display("T_ID"); }
{INVALID_ID}	{yyerror("Invalid");}
{CONST_INT}     {display("T_CONST_INT");  }
{CONST_FLOAT}   {display("T_CONST_FLOAT");  }
{STRING}        {display("T_STRING");  }

.       { yyerror("Unrecognized character"); }

%%


void display(char *token_type){
	printf("token: %s\t\t\t line_num: %d\t\t\t token_id: %s\n", yytext, line, token_type);
}

void yyerror(char *message){
	printf("\nError: \"%s\" in line %d. Token = %s\n\n", message, line, yytext);
	//exit(1);
}

int main(int argc, char *argv[]){
	yyin = fopen(argv[1], "r");
	yylex();
	fclose(yyin);
	
	return 0;
}