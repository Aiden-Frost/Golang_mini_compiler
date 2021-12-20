%{
    #include "common.h"
    #include "y.tab.h"

%}

letter [a-zA-Z_]
digit [0-9]
id {letter}+({letter}|{digit})*
inumber {digit}+
fnumber {digit}*\.?{digit}+([eE][-+]?{digit}+)?

%x CMT
%x STR
%option yylineno

%%

"/*"        { BEGIN(CMT); }
<CMT>"*/"   { BEGIN(INITIAL); }
<CMT>\n     {;}
<CMT>.      {;}
"//".*      {;}
"\""        { BEGIN(STR);
                return '"';
            }
<STR>"\""   { BEGIN(INITIAL);
                return '"';
            }
<STR>[^\"]* { yylval.val= strdup(yytext);
                return STRING_LIT;
            }
"+"         { return '+'; }
"-"         { return '-'; }
"*"         { return '*'; }
"/"         { return '/'; }
"%"         { return '%'; }
"++"        { return T_INC; }
"--"        { return T_DEC; }

">"         { return '>'; }
"<"         { return '<'; }
">="        { return T_GEQ; }
"<="        { return T_LEQ; }
"=="        { return T_EQL; }
"!="        { return T_NEQ; }

"="         { return '='; }

"&&"        { return T_LAND; }
"||"        { return T_LOR; }
"!"         { return '!'; }

"("         { return '('; }
")"         { return ')'; }
"["         { return '['; }
"]"         { return ']'; }
"{"         { return '{'; }
"}"         { return '}'; }

";"         { return ';'; }
","         { return ','; }
"\n"        { return T_NEWLINE; }

"print"     { return PRINT; }
"println"   { return PRINTLN; }
"if"        { return IF; }
"else"      { return ELSE; }
"for"       { return FOR; }
"package"   {return PACKAGE; }
"import"    {return IMPORT; }
"\"fmt\""   {return FMT; }
"main"      {return MAIN; }
"func"      {return FUNC; }

"int32"     {return INT; }
"float32"   {return FLOAT;}
"string"    {return STRING; }
"bool"      {return BOOL; }
"true"      {return BOOL_LIT;}
"false"     {return BOOL_LIT;}
"var"       { return VAR; }



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
