%{
	#include <stdio.h>
	#include <string.h>
	#include<stdlib.h>
	void yyerror(const char *);
	FILE *yyin;
	int yylex();
	extern int yylineno;
	FILE *yyin;

	typedef struct symbol_table_node
	{
		char name[30];
		char value[30];
		int sim;
		const char* similar[30];
	}NODE;

	typedef struct operand_table_node
	{
		char res[30];
		char op1[30];
		char op2[30];
		char oper[30];
	}opNODE;

	typedef struct reference_table
	{
		char name[30];
		int ref;
	}refNODE;

	opNODE cse[100];
	NODE table[100];
	refNODE refTable[100];
	int top = -1;
	int topCse = -1;
	int topRef = -1;
	void updateTable(char*,char*);
	char* getVal(char*);
	char* calculate(char*,char*,char*);
	char* commonSubExpr(char*, char*, char*, char*);
	void updateReference(char*);
	void referenceEntry(char*);
	void unusedVar();
%}

%error-verbose

%union {
    char* val;
}

%token T_NEWLINE T_GOTO T_IFFALSE
%token<val> T_LOR T_LAND
%token<val> T_EQL T_NEQ T_LEQ T_GEQ
%token<val> ID '+' '-' '*' '/' '<' '>' 
%token<val> INT_LIT FLOAT_LIT

%type<val> Literal BinOp 
%%
StatementList
    : StatementList Statement 
    | Statement 
;

Statement
	:ID '=' Literal  T_NEWLINE{
		updateTable($1,$3);
		printf("%s = %s\n",$1,$3);
		referenceEntry($1);
	}
	|ID '=' ID T_NEWLINE{
		updateTable($1,getVal($3));
		printf("%s = %s\n",$1,getVal($3));
		referenceEntry($1);
		updateReference($3);	
	}
	|ID '=' ID BinOp ID T_NEWLINE{
		char* check = (char*)malloc(30 * sizeof(char));
		check = commonSubExpr($1, $3, $5, $4);
		if (strcmp(check, $1) == 0) {
			char* res = calculate($4,getVal($3),getVal($5));
			updateTable($1,res);
			printf("%s = %s\n",$1,res);
			referenceEntry($1);
			updateReference($3);
			updateReference($5);
		}
		else
		{
			referenceEntry($1);
		}
	}
	|ID '=' Literal BinOp ID T_NEWLINE		{
		char* check = (char*)malloc(30 * sizeof(char));
		check = commonSubExpr($1, $3, $5, $4);
		if (strcmp(check, $1) == 0) {
			char* res = calculate($4,$3,getVal($5));
			updateTable($1,res);
			printf("%s = %s\n",$1,res);
			referenceEntry($1);
			updateReference($5);
		}
		else
		{
			referenceEntry($1);
		}
	}
	|ID '=' ID BinOp Literal T_NEWLINE		{
		char* check = (char*)malloc(30 * sizeof(char));
		check = commonSubExpr($1, $3, $5, $4);
		if (strcmp(check, $1) == 0) {
			char* res = calculate($4,getVal($3),$5);
			updateTable($1,res);
			printf("%s = %s\n",$1,res);
			referenceEntry($1);
			updateReference($3);
		}
		else
		{
			referenceEntry($1);
		}
	}
	|ID '=' Literal BinOp Literal T_NEWLINE			{	
		char* check = (char*)malloc(30 * sizeof(char));
		check = commonSubExpr($1, $3, $5, $4);
			if (strcmp(check, $1) == 0) {
			char* res = calculate($4,$3,$5);
			updateTable($1,res);
			printf("%s = %s\n",$1,res);
			referenceEntry($1);
		}
		else
		{
			referenceEntry($1);
		}
	}
	|T_GOTO ID T_NEWLINE {printf("GOTO %s\n",$2);}
	|T_IFFALSE ID T_GOTO ID T_NEWLINE {
		printf("IF FALSE %s GOTO %s\n",$2,$4);
		updateReference($2);
	}
	|ID ':' T_NEWLINE {printf("%s:\n",$1);}
	|T_NEWLINE
	;

Literal
    : INT_LIT	{
		$$ = $1;
	}
    | FLOAT_LIT	{
		$$ = $1;
	}
;


BinOp
	:'+'	{
		$$ = $1;
	} 
	|'-'	{
		$$ = $1;
	} 
	|'*'	{
		$$ = $1;
	} 
	|'/'	{
		$$ = $1;
	} 
	|'<'	{
		$$ = $1;
	} 
	|'>'	{
		$$ = $1;
	} 
	|T_LEQ	{
		$$ = $1;
	} 
	|T_GEQ	{
		$$ = $1;
	} 
	|T_EQL	{
		$$ = $1;
	} 
	|T_NEQ	{
		$$ = $1;
	} 
	|T_LOR	{
		$$ = $1;
	} 
	|T_LAND	{
		$$ = $1;
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
	yyparse();
	fclose(yyin);
	unusedVar();
	return 0;
}

void yyerror(const char *msg)
{

	printf("\n");
  	printf("------\n");
	printf("ERROR\n");
	printf("------\n");
	printf("Parsing Unsuccesful\n");
	printf("Syntax Error at line %d\n\n",yylineno-1);

}

void updateTable(char* name,char* value)
{
	if(top==-1)
	{
		
		top++;
		strcpy(table[top].name,name);
		strcpy(table[top].value,value);
		return;
	}
	for(int i = top;i>=0;i--)
	{
		if(strcmp(table[i].name,name)==0)
		{
			strcpy(table[i].value,value);
			return;
		}
	}
	
	top++;
	
	strcpy(table[top].name,name);
	
	strcpy(table[top].value,value);



}

char* getVal(char* name)
{
	for(int i = top;i>=0;i--)
	{
		if(strcmp(table[i].name,name)==0)
		{
			return table[i].value;
		}
		else if (table[i].sim != 0)
		{
			for (int j=0; j<table[i].sim ; j++)
			{
				if(strcmp(table[i].similar[j],name)==0)
				{
					return table[i].value;
				}
			}
		}
	}
	return "a";
}
char* calculate(char* opr,char* op1,char* op2)
{	
	char* result;
	result = (char*)malloc(sizeof(char)*30);
	int oper1 = atoi(op1);
	int oper2 = atoi(op2);
	int res;
	if(strcmp(opr,"+")==0)
		res = oper1 + oper2;
	if(strcmp(opr,"-")==0)
		res = oper1 - oper2;		
	if(strcmp(opr,"*")==0)
		res = oper1 * oper2;
	if(strcmp(opr,"/")==0)
		res = oper1 / oper2;
	if(strcmp(opr,">")==0)
		res = oper1 > oper2;
	if(strcmp(opr,"<")==0)
		res = oper1 < oper2;
	if(strcmp(opr,">=")==0)
		res = oper1 >= oper2;
	if(strcmp(opr,"<=")==0)
		res = oper1 <= oper2;
	if(strcmp(opr,"mod")==0)
		res = oper1 % oper2;
	if(strcmp(opr,"==")==0)
		res = oper1 == oper2;
	if(strcmp(opr,"!=")==0)
		res = oper1 != oper2;
	if(strcmp(opr,"&&")==0)
		res = oper1 && oper2;
	if(strcmp(opr,"||")==0)
		res = oper1 || oper2;


	snprintf(result,30*sizeof(char),"%d",res);
	return result;
}

char* commonSubExpr(char* rres, char* oop1, char* oop2, char* ooper) {
	
	if(topCse==-1)
	{
		
		topCse++;
		strcpy(cse[topCse].res, rres);
		strcpy(cse[topCse].op1, oop1);
		strcpy(cse[topCse].op2, oop2);
		strcpy(cse[topCse].oper, ooper);
		//printf("DEMO : %s = %s %s %s\n", cse[topCse].res, cse[topCse].op1, cse[topCse].oper, cse[topCse].op2);
		return rres;
	}
	for(int i = topCse ; i>=0 ; i--)
	{
		//printf("%s %s\n", cse[i].op1, oop1);
		//printf("%s %s\n", cse[i].op2, oop2);
		//printf("%s %s\n", cse[i].oper, ooper);
		if(strcmp(cse[i].op1, oop1)==0 && strcmp(cse[i].op2, oop2)==0 && strcmp(cse[i].oper, ooper)==0)
		{
			//printf("HERE\n");
			for(int j = top;j>=0;j--)
			{
				if(strcmp(table[j].name,cse[i].res)==0)
				{
					table[j].similar[table[j].sim++] = rres;
				}
			}

			return cse[i].res;
		}
	}
	
	topCse++;
	strcpy(cse[topCse].res, rres);
	strcpy(cse[topCse].op1, oop1);
	strcpy(cse[topCse].op2, oop2);
	strcpy(cse[topCse].oper, ooper);
	//printf("DENO : %s = %s %s %s\n", cse[topCse].res, cse[topCse].op1, cse[topCse].oper, cse[topCse].op2);
	return rres;
}

void referenceEntry(char* name)
{
	if(topRef==-1)
	{
		
		topRef++;
		strcpy(refTable[topRef].name, name);
		refTable[topRef].ref = 0;
		return;
	}
	for(int i = topRef;i>=0;i--)
	{
		if(strcmp(refTable[i].name, name)==0)
		{
			return;
		}
	}
	topRef++;
	strcpy(refTable[topRef].name, name);
	refTable[topRef].ref = 0;
	return;
}

void updateReference(char* name)
{
	if(topRef==-1)
	{
		
		topRef++;
		strcpy(refTable[topRef].name, name);
		refTable[topRef].ref = 0;
		return;
	}
	for(int i = topRef;i>=0;i--)
	{
		if(strcmp(refTable[i].name, name)==0)
		{
			refTable[i].ref++;
			return;
		}
	}
	
	topRef++;
	strcpy(refTable[topRef].name, name);
	refTable[topRef].ref = 0;
	return;
}

void unusedVar()
{
	for (int i=0; i<=topRef; i++)
	{
		if(refTable[i].ref == 0)
		{
			printf("Unused Variable : %s\n", refTable[i].name);
		}
		//printf("%s : %d\n", refTable[i].name, refTable[i].ref);
	}
}