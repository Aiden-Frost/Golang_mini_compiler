%{
    #include "common.h" 
    int yylineno;
    int yylex();
    FILE *yyin;

    void yyerror (char const *s)
    {
        printf("error:%d: %s\n", yylineno, s);
    }
    AST* ast;
	TREE* nptr = NULL;

    TREE* newnode(char* o,TREE* cc1,TREE* cc2,TREE* cc3);
    TREE* newleaf(char* o, char* v);
    void inorder(TREE*);
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

%type<base> Program StatementList Statement DeclarationStmt Type TypeName Operand IDList
%type<base> ExprA ExprB ExprC ExprD ExprE ExprF UnaryExpr PrimaryExpr Literal
%type<base> SimpleStmt AssignmentStmt IncDecOp IncDecStmt UnaryOp
%type<base> Block IfStmt Else Condition ForClause ForStmt InitStmt PostStmt IndexExpr ArrayType

%start Program

%%
Program
    : StatementList         {
            $$.ptr = newnode("MAIN", $1.ptr, nptr, nptr);
            ast->root = $$.ptr;
    }
    | packageFunctionDeclaration    { }
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
    : StatementList Statement {
        $$.ptr = newnode("STMTLIST", $1.ptr, $2.ptr, nptr);
    }
    | Statement {
        $$.ptr = $1.ptr;
    }
;

Statement
	: DeclarationStmt T_NEWLINE {
        $$.ptr = $1.ptr;
    }
	| SimpleStmt T_NEWLINE  {
        $$.ptr = $1.ptr;
    }
	| Block T_NEWLINE   {
        $$.ptr = $1.ptr;
    }
	| IfStmt T_NEWLINE  {
        $$.ptr = $1.ptr;
    }
	| ForStmt T_NEWLINE {
        $$.ptr = $1.ptr;
    }
	| PrintStmt T_NEWLINE   {
        $$.ptr = nptr;
    }
	| T_NEWLINE {
        $$.ptr = nptr;
    }
;

DeclarationStmt
	: VAR IDList Type                   { 
        $$.ptr = newnode("DECL", $2.ptr, $3.ptr, nptr);
    }    
	| VAR IDList Type '=' ExprA    { 
        $$.ptr = newnode("DECL", $2.ptr, $3.ptr, $5.ptr);
    }   
;

IDList
    : IDList ',' ID {
        TREE* idLeaf = newleaf("id", $3);
        $$.ptr = newnode("MULDECL", $1.ptr, idLeaf, nptr);
        
    }
    | ID    {
        TREE* idLeaf = newleaf("id", $1);
        $$.ptr = idLeaf;
    }
;

Type
    : TypeName  {
       $$.ptr = $1.ptr;
    }
    | ArrayType {
        $$.ptr = $1.ptr;
    }   
;

TypeName
    : INT           { 
        $$.ptr = newleaf("type","int");
    }
    | FLOAT         { 
        $$.ptr = newleaf("type","float");
    }
    | STRING        { 
        $$.ptr = newleaf("type","string");
    }
    | BOOL          { 
        $$.ptr = newleaf("type","bool");
    }  
;

ArrayType
    : '[' ExprA ']' Type {
        $$.ptr = newnode("ARRAY", $2.ptr, $4.ptr, nptr);
    }
;

ExprA
    : ExprA T_LOR ExprB   {
        $$.ptr = newnode("||", $1.ptr, $3.ptr, nptr);
    }
    | ExprB {
        $$.ptr = $1.ptr;
    }
;

ExprB
    : ExprB T_LAND ExprC  { 
        $$.ptr = newnode("&&", $1.ptr, $3.ptr, nptr);
    }
    | ExprC {
        $$.ptr = $1.ptr;
    }
;

ExprC
    : ExprC '<' ExprD   {
        $$.ptr = newnode("<", $1.ptr, $3.ptr, nptr);
    }
    | ExprC '>' ExprD   {
        $$.ptr = newnode(">", $1.ptr, $3.ptr, nptr);
    }
    | ExprC T_LEQ ExprD   {
        $$.ptr = newnode("<=", $1.ptr, $3.ptr, nptr);
    }
    | ExprC T_GEQ ExprD   {
        $$.ptr = newnode(">=", $1.ptr, $3.ptr, nptr);
    }
    | ExprC T_EQL ExprD   {
        $$.ptr = newnode("==", $1.ptr, $3.ptr, nptr);
    }
    | ExprC T_NEQ ExprD   {
        $$.ptr = newnode("!=", $1.ptr, $3.ptr, nptr);
    }
    | ExprD {
        $$.ptr = $1.ptr;
    }
;

ExprD
    : ExprD '+' ExprE   {
        $$.ptr = newnode("+", $1.ptr, $3.ptr, nptr);
    }
    | ExprD '-' ExprE   {
        $$.ptr = newnode("(-)", $1.ptr, $3.ptr, nptr);
    }
    | ExprE {
        $$.ptr = $1.ptr;
    }
;

ExprE
    : ExprE '*' ExprF   {
        $$.ptr = newnode("*", $1.ptr, $3.ptr, nptr);
    }
    | ExprE '/' ExprF   {
        $$.ptr = newnode("/", $1.ptr, $3.ptr, nptr);
    }
    | ExprE '%' ExprF   {
        $$.ptr = newnode("%", $1.ptr, $3.ptr, nptr);
    }
    | ExprF {
        $$.ptr = $1.ptr;
    }
;

ExprF
    : UnaryExpr {
        $$.ptr = $1.ptr;
    }
;

UnaryExpr
    : PrimaryExpr   {
        $$.ptr = $1.ptr;
    }
    | UnaryOp UnaryExpr     {
        $$.ptr = newnode("UNARY", $1.ptr, $2.ptr, nptr);
    }
;

UnaryOp
    : '+'   {
        $$.ptr = newleaf("OP", "+");
    }
    | '-'   {
        $$.ptr = newleaf("OP", "-");
    }
    | '!'   {
        $$.ptr = newleaf("OP", "!");
    }
;

PrimaryExpr
    : Operand   {
        $$.ptr = $1.ptr;
    }
    | IndexExpr {
        $$.ptr = $1.ptr;
    }
;

Operand
    : Literal               {
        $$.ptr = $1.ptr;
    }
    | ID                    { 
        $$.ptr = newleaf("id", $1);
    }
    |  '(' ExprA ')'   {
        $$.ptr = $2.ptr;
    }
;

Literal
    : INT_LIT       {
        $$.ptr = newleaf("int_lit", $1);
    }
    | FLOAT_LIT     {
        $$.ptr = newleaf("float_lit", $1);
    }
    | '"' STRING_LIT '"'   {
        $$.ptr = newleaf("string_lit", $2);
    }
    | BOOL_LIT      {
        $$.ptr = newleaf("bool_lit", $1);
    }
;

IndexExpr
    : PrimaryExpr '[' ExprA ']' {
        $$.ptr = newnode("ARRAY", $1.ptr, $3.ptr, nptr);
    }
;

SimpleStmt
    : AssignmentStmt    {
        $$.ptr = $1.ptr;
    }
    | IncDecStmt    {
        $$.ptr = $1.ptr;
    }
;


AssignmentStmt
    : PrimaryExpr '=' ExprA {
        $$.ptr = newnode("ASSGIN", $1.ptr, $3.ptr, nptr);
    }
;

IncDecStmt
    : ExprA IncDecOp    {
        $$.ptr = newnode("POST", $1.ptr, $2.ptr, nptr);
    }
    | IncDecOp ExprA    {
        $$.ptr = newnode("PRE", $1.ptr, $2.ptr, nptr);
    }
;

IncDecOp
    : T_INC   {
        $$.ptr = newleaf("Inc", "++");
    }
    | T_DEC   {
        $$.ptr = newleaf("Dec", "--");
    }
;

Block
    : BlockStart T_NEWLINE StatementList BlockEnd   {
        $$.ptr = newnode("BLOCK", $3.ptr, nptr, nptr);
    }
    | BlockStart BlockEnd   {
        $$.ptr = nptr;
    }
;

BlockStart
    : '{'  
;

BlockEnd
    : '}'  
;


IfStmt
    : IF Condition Block Else   {
        $$.ptr = newnode("IF", $2.ptr, $3.ptr, $4.ptr);
    }
;

Else
    :   {
        $$.ptr = nptr;
    }
    | ELSE IfStmt   {
        $$.ptr = newnode("ELSEIF", $2.ptr, nptr, nptr);
    }
    | ELSE Block    {
        $$.ptr = newnode("ELSE", $2.ptr, nptr, nptr);

    }

Condition
    : ExprA {
        $$.ptr = $1.ptr;
    }
;

ForStmt
    : FOR Condition Block   {
        $$.ptr = newnode("FOR", $2.ptr, $3.ptr, nptr);
    }
    | FOR ForClause Block   {
        $$.ptr = newnode("FOR", $2.ptr, $3.ptr, nptr);
    }
;

ForClause
    : InitStmt ';' Condition ';' PostStmt   {
        $$.ptr = newnode("INIT", $1.ptr, $3.ptr, $5.ptr);
    }
;

InitStmt
    : SimpleStmt    {
        $$.ptr = $1.ptr;
    }
;

PostStmt
    : SimpleStmt    {
        $$.ptr = $1.ptr;
    }
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
    ast = (AST*)malloc(sizeof(AST));
	ast->root = NULL;

    yylineno = 0;
    yyparse();

    fclose(yyin);
    inorder(ast->root);
    return 0;
}

TREE* newnode(char* o,TREE* cc1,TREE* cc2,TREE* cc3)
{
    TREE* temp = (TREE*)malloc(sizeof(TREE));
    strcpy(temp->opr,o);
    strcpy(temp->value,"N/A");
    temp->c1 = cc1;
    temp->c2 = cc2;
    temp->c3 = cc3;

    return temp;
}

TREE* newleaf(char* o, char* v)
{
    TREE* temp = (TREE*)malloc(sizeof(TREE));
    strcpy(temp->opr,o);
    strcpy(temp->value,v);
    temp->c1 = NULL;
    temp->c2 = NULL;
    temp->c3 = NULL;

    return temp;
}

void inorder(TREE* r)
{
    if (r == NULL)
        return;

    inorder(r->c1);
    if (r->c3 == NULL)
    {
        if (strcmp(r->value,"N/A") == 0){
        printf("%s\n",r->opr);
        }
        else {
            printf("(%s\t%s)\n",r->opr,r->value);
        }
    }
    inorder(r->c2);
 
    if (r->c3 != NULL)
    {
        if (strcmp(r->value,"N/A") == 0){
            printf("%s\n",r->opr);
        }
        else {
            printf("(%s\t%s)\n",r->opr,r->value);
        }
    }
    
    inorder(r->c3);
}
