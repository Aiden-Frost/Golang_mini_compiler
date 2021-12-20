%{
    #include "common.h" 

    int yylineno;
    int yylex();
    FILE *yyin;

    t_table globalTable = {
        .level = 0,
        .tableSize = 0,
        .head = NULL,
        .next = NULL
    };

    t_table *newest = &globalTable;
    int tCount = 1;
    void yyerror (char const *s)
    {
        printf("error:%d: %s\n", yylineno, s);
    }

    void insertSymbol(t_entry *e);
    void CreateNewTable();
    void DeleteNewestTable();
    void initEntry(t_entry *e, int index, char *name, char *type, int lineNo);
    t_varType findIdType(const char* id);
    int findId(const char* id);
    int findIdAllTables(const char* id);
    void validateExpression(t_varType l, t_varType r, t_varType *allowed, size_t listSize);
    t_varType parseTypeNameStringToEnum(const char* type_name);
    const char* parseEnumToTypeNameString(t_varType type);
    
%}

%union {
    int i_val;
    float f_val;
    char *s_val;
    int b_val;
    char *type_name;
    char *operator;
    struct TypeInfo type_info;
    struct OperandInfo operand_info;
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


%token <i_val> INT_LIT
%token <f_val> FLOAT_LIT
%token <s_val> STRING_LIT
%token <b_val> BOOL_LIT
%token <operand_info> ID 
%token <type_info> INT FLOAT STRING BOOL 


%type <type_info> Type TypeName ArrayType
%type <operator> IncDecOp UnaryOp 
%type <operand_info> Literal Operand 
%type <operand_info> PrimaryExpr UnaryExpr IndexExpr
%type <operand_info> ExprA ExprB ExprC ExprD ExprE ExprF

%start Program

%%
Program
    : StatementList         { DeleteNewestTable(); }
    | packageFunctionDeclaration    { DeleteNewestTable(); }
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
	: VAR ID Type                   { 
        t_entry *ptr = calloc(1, sizeof(t_entry));
        if (strlen($2.info) >= 31){
            printf("Identifier length can not be greater than 31\n");
        }
        if(findId($2.info) == -1){
            yyerror("Redeclare ID");
        }
        else{
            initEntry(ptr, newest->nextIndex++, $2.info, $3.type_name, yylineno); 
            insertSymbol(ptr); 
        }
    }    
	| VAR ID Type '=' ExprA    { 
        t_entry *ptr = calloc(1, sizeof(t_entry));
        if (strlen($2.info) >= 31){
            printf("Identifier length can not be greater than 31\n");
        }
        if (strcmp($3.type_name, parseEnumToTypeNameString($5.type))){
            yyerror("Type Mismatch");
        }
        if(findId($2.info) == -1){
            yyerror("Redeclare ID");
        }
        else{
            initEntry(ptr, newest->nextIndex++, $2.info, $3.type_name, yylineno);
            insertSymbol(ptr);
        }
    }    
;

Type
    : TypeName
    | ArrayType     
;

TypeName
    : INT           { 
        $$.type_name = "int32"; 
    }
    | FLOAT         { 
        $$.type_name = "float32"; 
    }
    | STRING        { 
        $$.type_name = "string"; 
    }
    | BOOL          { 
        $$.type_name = "bool"; 
    }  
;

ArrayType
    : '[' ExprA ']' Type { 
        $$.type_name = "array";
    }
;

ExprA
    : ExprA T_LOR ExprB   { 
        t_varType allowed[] = {t_BOOL};
        validateExpression($1.type, $3.type, allowed, 2);
        $$.type = t_BOOL;
        printf("LOR\n"); 
    }
    | ExprB
;

ExprB
    : ExprB T_LAND ExprC  { 
        t_varType allowed[] = {t_BOOL};
        validateExpression($1.type, $3.type, allowed, 2);
        $$.type = t_BOOL;
        printf("LAND\n"); 
    }
    | ExprC
;

ExprC
    : ExprC '<' ExprD   { 
        t_varType allowed[] = {t_INT, t_FLOAT};
        validateExpression($1.type, $3.type, allowed, 2);
        $$.type = t_BOOL;
        printf("LSS\n"); 
    }
    | ExprC '>' ExprD   { 
        t_varType allowed[] = {t_INT, t_FLOAT};
        validateExpression($1.type, $3.type, allowed, 2);
        $$.type = t_BOOL;
        printf("GTR\n"); 
    }
    | ExprC T_LEQ ExprD   { 
        t_varType allowed[] = {t_INT, t_FLOAT};
        validateExpression($1.type, $3.type, allowed, 2);
        $$.type = t_BOOL;
        printf("LEQ\n"); 
    }
    | ExprC T_GEQ ExprD   { 
        t_varType allowed[] = {t_INT, t_FLOAT};
        validateExpression($1.type, $3.type, allowed, 2);
        $$.type = t_BOOL;
        printf("GEQ\n"); 
    }
    | ExprC T_EQL ExprD   { 
        t_varType allowed[] = {t_INT, t_FLOAT};
        validateExpression($1.type, $3.type, allowed, 2);
        $$.type = t_BOOL;
        printf("EQL\n"); 
    }
    | ExprC T_NEQ ExprD   { 
        t_varType allowed[] = {t_INT, t_FLOAT};
        validateExpression($1.type, $3.type, allowed, 2);
        $$.type = t_BOOL;
        printf("NEQ\n"); 
    }
    | ExprD
;

ExprD
    : ExprD '+' ExprE   {
        t_varType allowed[] = {t_INT, t_FLOAT};
        validateExpression($1.type, $3.type, allowed, 2);
        printf("ADD\n");    
    }
    | ExprD '-' ExprE   { 
        t_varType allowed[] = {t_INT, t_FLOAT};
        validateExpression($1.type, $3.type, allowed, 2);
        printf("SUB\n"); 
    }
    | ExprE
;

ExprE
    : ExprE '*' ExprF   { 
        t_varType allowed[] = {t_INT, t_FLOAT};
        validateExpression($1.type, $3.type, allowed, 2);
        printf("MUL\n"); 
    }
    | ExprE '/' ExprF   { 
        t_varType allowed[] = {t_INT, t_FLOAT};
        validateExpression($1.type, $3.type, allowed, 2);
        printf("QUO\n"); 
    }
    | ExprE '%' ExprF   { 
        t_varType allowed[] = {t_INT};
        validateExpression($1.type, $3.type, allowed, 2);
        printf("REM\n"); 
    }
    | ExprF
;

ExprF
    : UnaryExpr
;

UnaryExpr
    : PrimaryExpr
    | UnaryOp UnaryExpr     { 
        printf("%s\n", $1); 
        $$.info = $2.info;
        $$.type = $2.type;
    }
;

UnaryOp
    : '+'   { $$ = "POS"; }
    | '-'   { $$ = "NEG"; }
    | '!'   { $$ = "NOT"; }
;

PrimaryExpr
    : Operand
    | IndexExpr
;

Operand
    : Literal               { 
       
        $$.info = "Literal";
        $$.type = $1.type;
    }
    | ID                    { 
        int temp = findIdAllTables($1.info);
        if(temp == 0){
            ++yylineno;
            yyerror("Undefined Variable");
            --yylineno;
        }
        else{
            
            char* part[3] = { "IDENT (name=", strdup($1.info), ")" };
            size_t sum = 0;
            for(int i = 0;i < 3;++i){
                sum += strlen(part[i]);
            }

            char* str = calloc(1, sizeof(char) * (++sum));
            str[0] = '\0';
            for(int i = 0;i < 3;++i){
                strcat(str, part[i]);
            }
            printf("%s\n", str);
            free(str);
            $$.info = strdup($1.info);
            $$.type = findIdType($1.info);
        }
    }
    |  '(' ExprA ')'   { 
        $$.info = strdup($2.info);
        $$.type = $2.type;
    }
;

Literal
    : INT_LIT       { 
        printf("INT_LIT %d\n", $1);
        $$.info = "INT_LIT";
        $$.type = t_INT;
    }
    | FLOAT_LIT     { 
        printf("FLOAT_LIT %f\n", $1);
        $$.info = "FLOAT_LIT";    
        $$.type = t_FLOAT;
    }
    | '"' STRING_LIT '"'   { 
        int len = strlen("STRING_LIT ") + strlen($2) + 2;
        char *str;
        str = calloc(len, sizeof(char));
        strcat(str, "STRING_LIT ");
        strcat(str, $2);
        $$.info = strdup(str);
        $$.type = t_STRING;
        free(str);
    }
    | BOOL_LIT      { 
        char *str;
        if($1){
            str = "TRUE";
        }
        else{
            str = "FALSE";
        }
        $$.info = strdup(str);
        $$.type = t_BOOL;
    }
;

IndexExpr
    : PrimaryExpr '[' ExprA ']' { 
        $$.info = "array"; 
        $$.type = parseTypeNameStringToEnum($$.info);;
    }
;

SimpleStmt
    : AssignmentStmt
    | IncDecStmt
;


AssignmentStmt
    : PrimaryExpr '=' ExprA {
        if(!strcmp($1.info, "Literal")){
            yyerror("Literal Error");
        }
        if ($1.type != $3.type){
            yyerror("Type Mismatch");
        }
        printf("ASSIGN\n"); 
    }
;

IncDecStmt
    : ExprA IncDecOp 
;

IncDecOp
    : T_INC   { printf("INC\n"); }
    | T_DEC   { printf("DEC\n"); }
;

Block
    : BlockStart T_NEWLINE StatementList BlockEnd
    | BlockStart BlockEnd
;

BlockStart
    : '{'   { CreateNewTable(); }
;

BlockEnd
    : '}'   { DeleteNewestTable(); }
;


IfStmt
    : IF Condition Block Else
;

Else
    : 
    | ELSE IfStmt
    | ELSE Block

Condition
    : ExprA {
        if($1.type != t_BOOL){
            ++yylineno;
            yyerror("Expression Error");
            --yylineno;
        }
    }
;

ForStmt
    : FOR Condition Block   
    | FOR ForClause Block
;

ForClause
    : InitStmt ';' Condition ';' PostStmt
;

InitStmt
    : SimpleStmt
;

PostStmt
    : SimpleStmt
;

PrintStmt
    : PRINT '(' ExprA ')'      { 
        printf("PRINT %s\n", parseEnumToTypeNameString($3.type)); 
    }
    | PRINTLN '(' ExprA ')'    { 
        printf("PRINTLN %s\n", parseEnumToTypeNameString($3.type)); 
        
    }
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

	printf("Total lines: %d\n", yylineno);
    fclose(yyin);
    return 0;
}


void insertSymbol(t_entry *e) {
    printf("> Insert {%s} into symbol table (scope level: %d)\n", e->name, newest->level);
    if(newest->head == NULL){
        newest->head = e;
    }
    else{
        t_entry *ptr = newest->head;
        for(int i = 1;i < newest->tableSize;++i){
            ptr = ptr->next;
        }

        ptr->next = e;
    }
    ++newest->tableSize;

    return;
}

void CreateNewTable(){
    // Get Newest table
    t_table *newTable = calloc(1, sizeof(t_table));

    // Initialize
    newTable->next = NULL;
    newTable->level = newest->level + 1;
    newTable->tableSize = 0;
    newTable->head = NULL;
    newest->next = newTable;
    newest = newTable;
    ++tCount;

    return;
}

void DeleteNewestTable(){

    printf("> symbol table (scope level: %d)\n", newest->level);
    printf("%-10s%-10s%-10s%-10s\n", 
           "Index", "Name", "Type", "Lineno");

    for(int i = 0;i < newest->tableSize;++i){
        printf("%-10d%-10s%-10s%-10d\n",
           newest->head->index, newest->head->name, newest->head->type, newest->head->lineNo);
    
        t_entry *ptr = newest->head->next;
        free(newest->head);
        newest->head = ptr;
    }
    // Free memory of deleted table
    if(newest->level){
        free(newest);
    }
    --tCount;
    newest = &globalTable;
    for(int i = 1;i < tCount;++i){
        newest = newest->next;
    }
    
    return;
}


void initEntry(t_entry *e, int index, char *name, char *type, int lineNo){
    e->index = index;
    e->name = name;
    e->type = type;
    e->lineNo = lineNo;
    e->next = NULL;
    return;
}

void validateExpression(t_varType l, t_varType r, t_varType *allowed, size_t listSize)
{
    if (l == r)
    {
        for(size_t i = 0;i < listSize;++i){
            if(l == allowed[i]){
                return;
            }
        }
    }
    yyerror("Expression Error ");
    return;
}

t_varType findIdType(const char* id){
    // If id not found in newest table, find in 1 level less.
    //global->next = for->next = if->next = NULL
    //tcount = 3
    //tcoutn = 2
    //tcount = 1
    for(int i = tCount - 1; i >= 0;--i){
        t_table *t = &globalTable;
        for(int j = 0;j < i;++j){
            t = t->next;
        }
        t_entry *e = t->head;
        for(int j = 0;j < t->tableSize;++j){
            if(!strcmp(e->name, id)){
                return parseTypeNameStringToEnum(e->type);
                break;
            }
            e = e->next;
        }
    }
    
    return t_NONE;
}


int findId(const char* id){
    t_entry *e = newest->head;
    for(int i = 0;i < newest->tableSize;++i){
        if(!strcmp(e->name, id)){
            return -1;
        }
        e = e->next;
    }
    return 0;
}

int findIdAllTables(const char* id){
    for(int i = tCount - 1; i >= 0;--i){
        t_table *t = &globalTable;
        for(int j = 0;j < i;++j){
            t = t->next;
        }
        t_entry *e = t->head;
        for(int i = 0;i < t->tableSize;++i){
            if(!strcmp(e->name, id)){
                return -1;
            }
            e = e->next;
        }
    }
    return 0;
}

t_varType parseTypeNameStringToEnum(const char* type_name){
    if(!strcmp(type_name, "int32")){
        return t_INT;
    }
    else if(!strcmp(type_name, "float32")){
        return t_FLOAT;
    }
    else if(!strcmp(type_name, "bool")){
        return t_BOOL;
    }
    else if(!strcmp(type_name, "string")){
        return t_STRING;
    }
    else if(!strcmp(type_name, "array")){
        return t_ARRAY;
    }
    return t_NONE;
}

const char* parseEnumToTypeNameString(t_varType type){
    switch(type){
        case t_INT:
            return "int32";
            break;
        case t_FLOAT:
            return "float32";
            break;
        case t_BOOL:
            return "bool";
            break;
        case t_STRING:
            return "string";
            break;
        case t_ARRAY:
            return "array";
            break;
        default:
            return "Error.";
    }
}
