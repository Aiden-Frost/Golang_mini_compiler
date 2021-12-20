%{
    #include "common.h" 
    int yylineno;
    int yylex();
    FILE *yyin;

    void yyerror (char const *s)
    {
        printf("error:%d: %s\n", yylineno, s);
    }
    int i;
	int tempc = 1;
	int labelc = 1;
	char* newTemp();
    char* newLabel();
%}

%error-verbose

%union {
    char* val;
    struct Base base;
}

%token PACKAGE IMPORT MAIN FMT FUNC 
%token VAR 
%token T_NEWLINE
%token T_LOR T_LAND
%token T_EQL T_NEQ T_LEQ T_GEQ
%token T_INC T_DEC
%token IF ELSE
%token FOR
%token PRINT PRINTLN
%token<val> ID INT FLOAT STRING BOOL
%token<val> INT_LIT BOOL_LIT STRING_LIT FLOAT_LIT

%type<base> ExprA ExprB ExprC ExprD ExprE ExprF UnaryExpr
%type<base> Literal Operand PrimaryExpr Condition 
%start Program

%%
Program
    : StatementList         
    | packageFunctionDeclaration    
;

packageFunctionDeclaration
    : PACKAGE MAIN otherPackages IMPORT FMT otherImports FUNC MAIN'('')' '{' T_NEWLINE StatementList '}'
;

otherPackages
    : otherPackages packageList 
    | T_NEWLINE
;

packageList
    : PACKAGE ID T_NEWLINE
    | T_NEWLINE
;

otherImports
    : otherImports importList
    | T_NEWLINE
;

importList
    : IMPORT '"' STRING_LIT '"' T_NEWLINE
    | T_NEWLINE
;

StatementList
    : StatementList Statement 
    | Statement 
;

Statement
	: DeclarationStmt T_NEWLINE 
	| SimpleStmt T_NEWLINE  
	| Block T_NEWLINE   
	| IfStmt T_NEWLINE  
	| ForStmt T_NEWLINE 
	| PrintStmt T_NEWLINE   
	| T_NEWLINE 
;

DeclarationStmt
	: VAR ID Type   { 
        printf("%s = %s\n", $2, "0");
    }
	| VAR ID Type '=' ExprA    {
        printf("%s = %s\n", $2, $5.tmp);     

    }    
;

Type
    : TypeName  {}
    | ArrayType {}   
;

TypeName
    : INT           {}
    | FLOAT         {}
    | STRING        {}
    | BOOL          {}  
;

ArrayType
    : '[' ExprA ']' Type {}
;

ExprA
    : ExprA T_LOR ExprB   {
        char temp[10];
        strcpy(temp,newTemp());
        printf("%s = %s || %s\n", temp, $1.tmp, $3.tmp);
        strcpy($$.tmp,temp);
    }
    | ExprB {
        $$.tmp = $1.tmp;
    }
;

ExprB
    : ExprB T_LAND ExprC  {
        char temp[10];
        strcpy(temp,newTemp());
        printf("%s = %s && %s\n", temp, $1.tmp, $3.tmp);
        strcpy($$.tmp,temp);
    }
    | ExprC {
        $$.tmp = $1.tmp;
    }
;

ExprC
    : ExprC '<' ExprD   {
        char temp[10];
        strcpy(temp,newTemp());
        printf("%s = %s < %s\n", temp, $1.tmp, $3.tmp);
        strcpy($$.tmp,temp);
    }
    | ExprC '>' ExprD   {
        char temp[10];
        strcpy(temp,newTemp());
        printf("%s = %s > %s\n", temp, $1.tmp, $3.tmp);
        strcpy($$.tmp,temp);
    }
    | ExprC T_LEQ ExprD   {
        char temp[10];
        strcpy(temp,newTemp());
        printf("%s = %s <= %s\n", temp, $1.tmp, $3.tmp);
        strcpy($$.tmp,temp);
    }
    | ExprC T_GEQ ExprD   {
        char temp[10];
        strcpy(temp,newTemp());
        printf("%s = %s >= %s\n",temp, $1.tmp, $3.tmp);
        strcpy($$.tmp,temp);
    }
    | ExprC T_EQL ExprD   {
        char temp[10];
        strcpy(temp,newTemp());
        printf("%s = %s == %s\n",temp,$1.tmp,$3.tmp);
        strcpy($$.tmp,temp);
    }
    | ExprC T_NEQ ExprD   {
        char temp[10];
        strcpy(temp,newTemp());
        printf("%s = %s != %s\n",temp,$1.tmp,$3.tmp);
        strcpy($$.tmp,temp);
    }
    | ExprD {
        $$.tmp = $1.tmp;
    }
;

ExprD
    : ExprD '+' ExprE   {
        char temp[10];
        strcpy(temp,newTemp());
        printf("%s = %s + %s\n",temp,$1.tmp,$3.tmp);
        strcpy($$.tmp,temp);
    }
    | ExprD '-' ExprE   {
        char temp[10];
        strcpy(temp,newTemp());
        printf("%s = %s - %s\n",temp,$1.tmp,$3.tmp);
        strcpy($$.tmp,temp);
    }
    | ExprE {
        $$.tmp = $1.tmp;
    }
;

ExprE
    : ExprE '*' ExprF   {
        char temp[10];
        strcpy(temp,newTemp());
        printf("%s = %s * %s\n",temp,$1.tmp,$3.tmp);
        strcpy($$.tmp,temp);
    }
    | ExprE '/' ExprF   {
        char temp[10];
        strcpy(temp,newTemp());
        printf("%s = %s / %s\n",temp,$1.tmp,$3.tmp);
        strcpy($$.tmp,temp);
    }
    | ExprE '%' ExprF   {
        char temp[10];
        strcpy(temp,newTemp());
        printf("%s = %s MOD %s\n",temp,$1.tmp,$3.tmp);
        strcpy($$.tmp,temp);
    }
    | ExprF {
        $$.tmp = $1.tmp;
    }
;

ExprF
    : UnaryExpr {
        $$.tmp = $1.tmp;
    }
;

UnaryExpr
    : PrimaryExpr   {
        $$.tmp = $1.tmp;
    }
    | UnaryOp UnaryExpr     {
        $$.tmp = " ";
    }
;

UnaryOp
    : '+'   {}
    | '-'   {}
    | '!'   {}
;

PrimaryExpr
    : Operand   {
        $$.tmp = $1.tmp;
    }
    | IndexExpr {
        $$.tmp = " ";
    }
;

Operand
    : Literal               {
        $$.tmp = $1.tmp;
    }
    | ID                    {
        $$.tmp = $1;
    }
    |  '(' ExprA ')'   {
        $$.tmp = " ";
    }
;

Literal
    : INT_LIT       {
        $$.tmp = $1;
    }
    | FLOAT_LIT     {
        $$.tmp = $1;
    }
    | '"' STRING_LIT '"'   {
        $$.tmp = $2;
    }
    | BOOL_LIT      {
        $$.tmp = $1;
    }
;

IndexExpr
    : PrimaryExpr '[' ExprA ']' {}
;

SimpleStmt
    : AssignmentStmt    {}
    | IncDecStmt    {}
;


AssignmentStmt
    : PrimaryExpr '=' ExprA {
        printf("%s = %s\n", $1.tmp, $3.tmp);
    }
;

IncDecStmt
    : ExprA {
        printf("%s = %s ", $1.tmp, $1.tmp);
    } IncDecOp
;

IncDecOp
    : T_INC   {
        printf("+ 1\n");
    }
    | T_DEC   {
        printf("- 1\n");
    }
;

Block
    : BlockStart T_NEWLINE StatementList BlockEnd   {}
    | BlockStart BlockEnd   {}
;

BlockStart
    : '{'   {
        char label[10];
        strcpy(label,newLabel());
        printf("%s:\n", label);
    }
;

BlockEnd
    : '}'  
;


IfStmt
    : IF Condition  {
        printf("IF FALSE %s GOTO L%d\n", $2.tmp, labelc+1);
    }   Block Else
;

Else
    :{
        char label[10];
        strcpy(label,newLabel());
        printf("%s:\n", label);
    }
    | ELSE IfStmt   {
        char label[10];
        strcpy(label,newLabel());
        printf("%s:\n", label);
    }
    | ELSE  {
        printf("GOTO L%d\n", labelc+1);
    }   Block    {
        char label[10];
        strcpy(label,newLabel());
        printf("%s:\n", label);
    }

Condition
    : ExprA {
        $$.tmp = $1.tmp;
    }
;

ForStmt
    : FOR Condition Block   {}
    | FOR ForClause Block   {
        printf("GOTO L%d\n", labelc-2);
        char label[10];
        strcpy(label,newLabel());
        printf("%s:\n", label);
    }
;

ForClause
    : InitStmt ';' {
        char label[10];
        strcpy(label,newLabel());
        printf("%s:\n", label);
    } Condition ';' {
        printf("IF FALSE %s GOTO L%d\nGOTO L%d\n", $4.tmp,labelc+2, labelc+1);
        char label[10];
        strcpy(label,newLabel());
        printf("%s:\n", label);
    } PostStmt   {
        printf("GOTO L%d\n", labelc-2);
    }
;

InitStmt
    : SimpleStmt    {}
;

PostStmt
    : SimpleStmt    {}
;

PrintStmt
    : PRINT '(' ExprA ')'      { }
    | PRINTLN '(' ExprA ')'    { }
;

%%


int main(int argc, char *argv[])
{
    if (argc == 2) {
        yyin = fopen(argv[1], "r");
    } else {
        yyin = stdin;
    }

    yylineno = 0;
    yyparse();

    fclose(yyin);
    return 0;
}

char* newTemp()
{
	char* temp;
	temp = (char*)malloc(sizeof(char)*20);
	strcpy(temp,"t");
	char digit[20];
	snprintf(digit,20*sizeof(char),"%d",tempc);
	strcat(temp,digit);
	tempc++;
	return temp;
}

char* newLabel()
{
	char* label;
	label = (char*)malloc(sizeof(char)*20);
	strcpy(label,"L");
	char digit[20];
	snprintf(digit,20*sizeof(char),"%d",labelc);
	strcat(label,digit);
	labelc++;
	return label;
}