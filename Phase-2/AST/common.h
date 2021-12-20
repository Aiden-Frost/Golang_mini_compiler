#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

typedef struct tree
{
	char opr[100];
	char value[100];
	struct tree* c1;
	struct tree* c2;
	struct tree* c3;
}TREE;

typedef struct ast
{
	TREE* root;
}AST;

typedef struct Base
{
	TREE* ptr;

}Base;

