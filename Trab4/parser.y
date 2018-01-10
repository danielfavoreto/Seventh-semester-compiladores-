/* Options to bison */
// File name of generated parser.
%output "parser.c"
// Produces a 'parser.h'
%defines "parser.h"
// Give proper error messages when a syntax error is found.
%define parse.error verbose
// Enable LAC (lookahead correction) to improve syntax error handling.
%define parse.lac full

// Enable the trace option so that debugging is possible.
%define parse.trace

%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tree.h"
#include "parser.h"
#include "tables.h"
#include "interpreter.h"

int yylex(void);
void yyerror(char const *s);

void check_var(int i);
void new_var(int i);
void check_func(int i, int arity);
void new_func(int i, int arity);

extern int yylineno;

Tree* tree;

int scope = 0;
int arityCalled = 0;
int arityDeclared = 0;

LitTable *literalTable;
FuncTable *functionTable;
SymTable *symbolTable;
SymTable *auxTableSym;

%}

%define api.value.type {Tree*}

%token ELSE
%token IF
%token INPUT
%token INT
%token OUTPUT
%token RETURN
%token VOID
%token WHILE
%token WRITE
%token PLUS
%token MINUS
%token TIMES
%token OVER
%token LT
%token LE
%token GT
%token GE
%token EQ
%token NEQ
%token ASSIGN
%token SEMI
%token COMMA
%token LPAREN
%token RPAREN
%token LBRACK
%token RBRACK
%token LBRACE
%token RBRACE
%token STRING
%token NUM
%token ID

%left PLUS MINUS
%left TIMES OVER
%left EQ LT

%start program;

%%

program: func-decl-list                           {tree = $1;}

func-decl-list:
  func-decl-list func-decl                        {add_child($1, $2); $$ = $1;}
  | func-decl                                     {$$ = new_node(FUNC_DECLIST); add_child($$, $1);}
;

func-decl:
  func-header func-body                           {$$ = new_node(FUNC_DECL); add_child($$, $1); add_child($$, $2); scope++; arityDeclared = 0;}
;

func-header:
  INT ID LPAREN params RPAREN                     { $$ = new_node(FUNC_HEADER); add_child($$, new_node(INT_NODE)); add_child($$, $2); add_child($$, $4);new_func($2->data,arityDeclared);}
  | VOID ID LPAREN params RPAREN                  { $$ = new_node(FUNC_HEADER); add_child($$, new_node(VOID_NODE)); add_child($$, $2); add_child($$, $4);new_func($2->data,arityDeclared);}
;

func-body:
  LBRACE opt-var-decl opt-stmt-list RBRACE        {$$ = new_node(FUNC_BODY); add_child($$, $2); add_child($$, $3);}
;

opt-var-decl:
  %empty                                          {$$ = new_node(VAR_DEC_LIST);}
  | var-decl-list                                 {$$ = $1;}
;

opt-stmt-list:
  %empty
  | stmt-list                                     {$$ = $1;}
;

params:
  VOID                                            {$$ = new_node(PARAM_LIST);}
  | param-list                                    {$$ = $1;}
;

param-list:
  param-list COMMA param                          {add_child($1, $3); $$ = $1; arityDeclared++;}
  | param                                         {$$ = new_node(PARAM_LIST); add_child($$, $1); arityDeclared++;}
;

param:
  INT ID                                          {new_var($2->data); $2->kind = SVAR_NODE;$$ = $2;}
  | INT ID LBRACK RBRACK                          {new_var($2->data); $2->kind = CVAR_NODE;$$ = $2;}
;

var-decl-list:
  var-decl-list var-decl                          {add_child($1, $2); $$ = $1;}
  | var-decl                                      {$$ = new_node(VAR_DEC_LIST); add_child($$, $1);}
;

var-decl:
  INT ID SEMI                                     {new_var($2->data); $2->kind = SVAR_NODE; $$ = $2;}
  | INT ID LBRACK NUM RBRACK SEMI                 {new_var($2->data); $2->kind = CVAR_NODE; add_child($2, $4); $$ = $2;}
;

stmt-list:
  stmt-list stmt                                  {add_child($1, $2); $$ = $1;}
  | stmt                                          {$$ = new_node(BLOCK_NODE); add_child($$, $1);}
;

stmt:
  assign-stmt                                     {$$ = $1;}
  | if-stmt                                       {$$ = $1;}
  | while-stmt                                    {$$ = $1;}
  | return-stmt                                   {$$ = $1;}
  | output-call SEMI                              {$$ = $1;}
  | write-call SEMI                               {$$ = $1;}
  | user-func-call SEMI                           {$$ = $1;}
;

lval:
  ID                                              {check_var($1->data); $1->kind = SVAR_NODE; $$ = $1;}
  | ID LBRACK NUM RBRACK                          {check_var($1->data); $1->kind = CVAR_NODE; add_child($1, $3); $$ = $1;}
  | ID LBRACK ID RBRACK                           {check_var($1->data); $1->kind = CVAR_NODE; add_child($1, $3); $$ = $1;}
;

assign-stmt:
  lval ASSIGN arith-expr SEMI                     {$$ = new_node(ASSIGN_NODE); add_child($$, $1); add_child($$, $3);}
;

if-stmt:
  IF LPAREN bool-expr RPAREN block                {$$ = new_node(IF_NODE); add_child($$, $3); add_child($$, $5);}
  | IF LPAREN bool-expr RPAREN block ELSE block   {$$ = new_node(IF_NODE); add_child($$, $3); add_child($$, $5); add_child($$, $7);}
;

block:
  LBRACE opt-stmt-list RBRACE                     {$$ = $2;}
;

while-stmt:
  WHILE LPAREN bool-expr RPAREN block             {$$ = new_node(WHILE_NODE); add_child($$, $3); add_child($$, $5);}
;

return-stmt:
  RETURN SEMI                                     {$$ = new_node(RETURN_NODE);}
  | RETURN arith-expr SEMI                        {$$ = new_node(RETURN_NODE); add_child($$, $2);}
;

input-call:
  INPUT LPAREN RPAREN
;

output-call:
  OUTPUT LPAREN arith-expr RPAREN                 {$$ = new_node(OUTPUT_NODE); add_child($$, $3);}
;

write-call:
  WRITE LPAREN STRING RPAREN                      {$$ = new_node(WRITE_NODE); add_child($$, $3);}
;

user-func-call:
  ID LPAREN opt-arg-list RPAREN                   {check_func($1->data,arityCalled); $1->kind = FUNC_NODE; add_child($1, $3); $$ = $1; arityCalled = 0;}
;

opt-arg-list:
  %empty                                          {$$ = new_node(ARG_LIST);}
  | arg-list                                      {$$ = new_node(ARG_LIST); add_child($$, $1);}
;

arg-list:
  arg-list COMMA arith-expr                       {add_child($1, $3); $$ = $1; arityCalled++;}
  | arith-expr                                    {$$ = $1; arityCalled++;}
;

bool-expr:
  arith-expr LT arith-expr                        {$$ = new_node(LT_NODE); add_child($$, $1); add_child($$, $3);}
  | arith-expr LE arith-expr                      {$$ = new_node(LE_NODE); add_child($$, $1); add_child($$, $3);}
  | arith-expr GT arith-expr                      {$$ = new_node(GT_NODE); add_child($$, $1); add_child($$, $3);}
  | arith-expr GE arith-expr                      {$$ = new_node(GE_NODE); add_child($$, $1); add_child($$, $3);}
  | arith-expr EQ arith-expr                      {$$ = new_node(EQ_NODE); add_child($$, $1); add_child($$, $3);}
  | arith-expr NEQ arith-expr                     {$$ = new_node(NEQ_NODE); add_child($$, $1); add_child($$, $3);}
;

arith-expr:
  arith-expr PLUS arith-expr                      {$$ = new_node(PLUS_NODE); add_child($$, $1); add_child($$, $3);}
  | arith-expr MINUS arith-expr                   {$$ = new_node(MINUS_NODE); add_child($$, $1); add_child($$, $3);}
  | arith-expr TIMES arith-expr                   {$$ = new_node(TIMES_NODE); add_child($$, $1); add_child($$, $3);}
  | arith-expr OVER arith-expr                    {$$ = new_node(OVER_NODE); add_child($$, $1); add_child($$, $3);}
  | input-call                                    {$$ = new_node(INPUT_NODE);}
  | LPAREN arith-expr RPAREN                      {$$ = $2;}
  | lval                                          {$$ = $1;}
  | user-func-call                                {$$ = $1;}
  | NUM                                           {$$ = $1;}
;

%%


void check_var(int i) {

    char* name = get_name(auxTableSym, i);
    
    int line = get_line(auxTableSym, i);
    
    int idx = lookup_var(symbolTable, name);

    if (idx == -1) {
    
        printf("SEMANTIC ERROR (%d): variable '%s' was not declared.\n", line, name);
        
        exit(1);
        
    }
}

void new_var(int i) {

    char* name = get_name(auxTableSym, i);
    
    int line = get_line(auxTableSym, i);
    
    int idx = lookup_var(symbolTable, name);
    
    if (idx != -1) {

        if (scope == get_scope(symbolTable,idx)){

            printf("SEMANTIC ERROR (%d): variable '%s' already declared at line %d.\n", line, name, get_line(symbolTable, idx));

            exit(1);

        }
    }

    insert_var(symbolTable, name, line, scope);
    
}

void check_func(int i, int arity) {

    char* name = get_name(auxTableSym, i);
    
    int line = get_line(auxTableSym, i);
    
    int idx = lookup_func(functionTable, name);
    
    if (idx == -1) {

        printf("SEMANTIC ERROR (%d): function '%s' was not declared.\n", line, name);
        
        exit(1);

    }
    else if (arity != get_arity(functionTable,idx)) {

        printf("SEMANTIC ERROR (%d): function '%s' was called with %d arguments but declared with %d parameters.\n", line, name, arity, get_arity(functionTable,idx));

        exit(1);
        
    }
	
}

void new_func(int i, int arity) {

    char* name = get_name(auxTableSym, i);
    
    int line = get_line(auxTableSym, i);
    
    int idx = lookup_func(functionTable, name);
    
    if (idx != -1) {
    
        printf("SEMANTIC ERROR (%d): function '%s' already declared at line %d.\n", line, name, get_funcLine(functionTable, idx));

        exit(1);

    }

    add_func(functionTable, name, line, arity);
    
}

// error handler
void yyerror (char const *s) {

    printf("PARSE ERROR (%d): %s\n", yylineno, s);
    
    exit(1);
  
}

int main() {
  
    literalTable = create_lit_table();
    symbolTable = create_sym_table();
    auxTableSym = create_sym_table();
    functionTable = create_func_table();

    int resultado = yyparse();
  
    if (resultado == 0){
  
        stdin = fopen(ctermid(NULL), "r");

        run_ast(tree);

		//	print_dot(tree);
	}

	// dar o free
    free(tree);
	
    return 0; 
}
