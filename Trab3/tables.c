
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "tables.h"

// Literals Table
// ----------------------------------------------------------------------------

#define LITERAL_MAX_SIZE 128
#define LITERALS_TABLE_MAX_SIZE 100

struct lit_table {
    char t[LITERALS_TABLE_MAX_SIZE][LITERAL_MAX_SIZE];
    int size;
};

LitTable* create_lit_table() {
    LitTable *lt = malloc(sizeof * lt);
    lt->size = 0;
    return lt;
}

int add_literal(LitTable* lt, char* s) {
    for (int i = 0; i < lt->size; i++) {
        if (strcmp(lt->t[i], s) == 0) {
            return i;
        }
    }
    strcpy(lt->t[lt->size], s);
    int old_side = lt->size;
    lt->size++;
    return old_side;
}

char* get_literal(LitTable* lt, int i) {
    return lt->t[i];
}

void print_lit_table(LitTable* lt) {
    printf("Literals table:\n");
    for (int i = 0; i < lt->size; i++) {
        printf("Entry %d -- %s\n", i, get_literal(lt, i));
    }
}

void free_lit_table(LitTable* lt) {
    free(lt);
}

// Symbols Table
// ----------------------------------------------------------------------------

#define SYMBOL_MAX_SIZE 128
#define SYMBOL_TABLE_MAX_SIZE 100

typedef struct {
  char name[SYMBOL_MAX_SIZE];
  int line;
  int scope;
} Entry;

struct sym_table {
    Entry t[SYMBOL_TABLE_MAX_SIZE];
    int size;
};

SymTable* create_sym_table() {
    SymTable *st = malloc(sizeof * st);
    st->size = 0;
    return st;
}

int lookup_var(SymTable* st, char* s) {
    for (int i = 0; i < st->size; i++) {
        if (strcmp(st->t[i].name, s) == 0)  {
            return i;
        }
    }
    return -1;
}

int add_var(SymTable* st, char* s, int line) {
    strcpy(st->t[st->size].name, s);
    st->t[st->size].line = line;
    int old_side = st->size;
    st->size++;
    return old_side;
}

void insert_var(SymTable* st, char* s, int line, int scope) {
    strcpy(st->t[st->size].name, s);
    st->t[st->size].line = line;
    st->t[st->size].scope = scope;
    st->size++;
}

char* get_name(SymTable* st, int i) {
    return st->t[i].name;
}

int get_line(SymTable* st, int i) {
    return st->t[i].line;
}

int get_scope(SymTable* st, int i){
    return st->t[i].scope;
}

void print_sym_table(SymTable* st) {
    printf("Variables table:\n");
    for (int i = 0; i < st->size; i++) {
         printf("Entry %d -- name: %s, line: %d, scope: %d\n", i, get_name(st, i), get_line(st, i), get_scope(st,i));
    }
}

void free_sym_table(SymTable* st) {
    free(st);
}

// Function Table
// ----------------------------------------------------------------------------

#define FUNCTION_MAX_SIZE 128
#define FUNCTION_TABLE_MAX_SIZE 100

typedef struct {
  char name[FUNCTION_MAX_SIZE];
  int line;
  int arity;
} FunctionEntry;

struct func_table {
    FunctionEntry t[FUNCTION_TABLE_MAX_SIZE];
    int size;
};

FuncTable* create_func_table() {
    FuncTable *ft = malloc(sizeof * ft);
    ft->size = 0;
    return ft;
}

int lookup_func(FuncTable* ft, char* s) {
    for (int i = 0; i < ft->size; i++) {
        if (strcmp(ft->t[i].name, s) == 0)  {
            return i;
        }
    }
    return -1;
}

int add_func(FuncTable* ft, char* s, int line, int arity) {
    strcpy(ft->t[ft->size].name, s);
    ft->t[ft->size].line = line;
    ft->t[ft->size].arity = arity;
    int old_side = ft->size;
    ft->size++;
    return old_side;
}

char* get_funcName(FuncTable* ft, int i) {
    return ft->t[i].name;
}

int get_funcLine(FuncTable* ft, int i) {
    return ft->t[i].line;
}

int get_arity(FuncTable* ft, int i) {
    return ft->t[i].arity;
}

void print_func_table(FuncTable* ft) {
    
    printf("Functions table:\n");
    
    for (int i = 0; i < ft->size; i++) {
        
         printf("Entry %d -- name: %s, line: %d, arity: %d\n", i, get_funcName(ft, i), get_funcLine(ft, i), get_arity(ft,i));
         
    }
}

void free_func_table(FuncTable* ft) {
    
    free(ft);
    
}
