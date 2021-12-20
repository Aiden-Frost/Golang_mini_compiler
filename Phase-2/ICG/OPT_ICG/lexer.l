%{
    #include "y.tab.h"
%}

letter [a-zA-Z_]
digit [0-9]
id {letter}+({letter}|{digit})*
inumber {digit}+
fnumber {digit}*\.?{digit}+([eE][-+]?{digit}+)?

%option yylineno

%%

"+"         { yylval.val = (strdup(yytext));return('+');  }
"-"         { yylval.val = (strdup(yytext));return '-'; }
"*"         { yylval.val = (strdup(yytext));return '*'; }
"/"         { yylval.val = (strdup(yytext));return '/'; }
"%"         { yylval.val = (strdup(yytext));return '%'; }

">"         { yylval.val = (strdup(yytext));return '>'; }
"<"         { yylval.val = (strdup(yytext));return '<'; }
">="        { yylval.val = (strdup(yytext));return T_GEQ; }
"<="        { yylval.val = (strdup(yytext));return T_LEQ; }
"=="        { yylval.val = (strdup(yytext));return T_EQL; }
"!="        { yylval.val = (strdup(yytext));return T_NEQ; }

"="         { yylval.val = (strdup(yytext));return '='; }

"&&"        { yylval.val = (strdup(yytext));return T_LAND; }
"||"        { yylval.val = (strdup(yytext));return T_LOR; }

":"         { return ':'; }
"\n"        { return T_NEWLINE; }

"GOTO"      {return T_GOTO;}
"IF FALSE"  {return T_IFFALSE;}


{inumber}   { yylval.val = (strdup(yytext));
            	return INT_LIT;
            }
{fnumber}   { yylval.val = (strdup(yytext));
				return FLOAT_LIT;
			}
{id}        {   
                yylval.val = strdup(yytext);
                return ID;  
            }

<<EOF>>     { static int once = 0;
                if (once++) {
                    yyterminate();
                }
                yylineno++;
                return T_NEWLINE;
            }

[ \t]+      {;}
.           {;}
%%

int yywrap(void)
{
    return 1;
}
