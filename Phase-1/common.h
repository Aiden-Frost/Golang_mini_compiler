#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

typedef struct Entry{
    int index;
    char *name;
    char *type;
    int lineNo;  
    struct Entry* next;
}t_entry;

typedef struct Table{
    int level;
    int nextIndex;
    int tableSize;
    struct Table *next;
    t_entry *head;
}t_table;

typedef enum VarTypes{
    t_INT, t_FLOAT, t_BOOL, t_STRING, t_NONE, t_ERROR, t_ARRAY
}t_varType;

struct OperandInfo{
    char *info;
    enum VarTypes type;  
};

struct TypeInfo{
    char *type_name;
};
