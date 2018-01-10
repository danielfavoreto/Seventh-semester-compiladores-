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
#include "tree.h"
#include "parser.h"
#include "tables.h"

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

program: func_decl_list {}
;

func_decl_list: func_decl_list func_decl { tree = new_subtree(FUNC_DECL_LIST_NODE,2, $1, $2); }
 | func_decl { tree = new_subtree(FUNC_DECL_LIST_NODE,1,$1); }
;

func_decl: func_header func_body { $$ = new_subtree(FUNC_DECL_NODE, 2, $1,$2); scope++; arityDeclared = 0; }
;

func_header: ret_type ID LPAREN params RPAREN { $$ = new_subtree(FUNC_HEADER_NODE,3, $1,$2,$4); new_func($2->data,arityDeclared); }
;

func_body: LBRACE opt_var_decl opt_stmt_list RBRACE { $$ = new_subtree(FUNC_BODY_NODE, 2, $2,$3); }
;

opt_var_decl: { $$ = new_subtree(VAR_LIST_NODE,0);}
 | var_decl_list { $$ = new_subtree(OPT_VAR_DECL_NODE,1,$1);}
;

opt_stmt_list: { $$ = new_subtree(OPT_STMT_LIST_NODE,0);}
 | stmt_list { $$ = new_subtree(OPT_STMT_LIST_NODE,1,$1); }
;

ret_type: INT { $$ = new_subtree(RET_TYPE_NODE, 0); }
 | VOID { $$ = new_subtree(VOID_NODE, 0); }
;

params: VOID { $$ = new_subtree(PARAM_LIST_NODE,0);}
 | param_list { $$ = new_subtree(PARAMS_NODE,1,$1); }
;

param_list: param_list COMMA param { $$ = new_subtree(PARAM_LIST_NODE,2, $1,$3); arityDeclared++;}
 | param { $$ = new_subtree(PARAM_LIST_NODE,1,$1); arityDeclared++;}
;

param: INT ID { $$ = new_subtree(PARAM_NODE, 1, $2); new_var($2->data);}
 | INT ID LBRACK RBRACK {  $$ = new_subtree(PARAM_NODE, 1, $2); new_var($2->data);}
;

var_decl_list: var_decl_list var_decl { $$ = new_subtree(VAR_DECL_LIST_NODE,2, $1,$2); }
 | var_decl { $$ = new_subtree(VAR_DECL_NODE,1,$1); }
;

var_decl: INT ID SEMI { $$ = new_subtree(SVAR_NODE,0);  new_var($2->data); }
 | INT ID LBRACK NUM RBRACK SEMI {  $$ = new_subtree(CVAR_NODE,0); new_var($2->data); }
;

stmt_list: stmt_list stmt { $$ = new_subtree(STMT_LIST_NODE,2, $1,$2); }
 | stmt { $$ = new_subtree(STMT_LIST_NODE,1,$1); }
;

stmt: assign_stmt { $$ = new_subtree(STMT_NODE,1,$1);}
 | if_stmt { $$ = new_subtree(IF_STMT_NODE,1,$1); }
 | while_stmt { $$ = new_subtree(WHILE_STMT_NODE,1,$1);}
 | return_stmt { $$ = new_subtree(RETURN_NODE,1,$1); }
 | func_call SEMI { $$ = new_subtree(STMT_NODE,1,$1); }
;

assign_stmt: lval ASSIGN arith_expr SEMI { $$ = new_subtree(ASSIGN_NODE,2,$1,$3);}
;

lval: ID { $$ = new_subtree(SVAR_NODE,0); check_var($1->data); }
 | ID LBRACK NUM RBRACK { $$ = new_subtree(CVAR_NODE, 2, $1,$3);  check_var($1->data); }
 | ID LBRACK ID RBRACK { $$ = new_subtree(CVAR_NODE,2, $1,$3);  check_var($1->data); check_var($3->data); }
;

if_stmt: IF LPAREN bool_expr RPAREN block { $$ = new_subtree(IF_NODE, 2,$3,$5); }
 | IF LPAREN bool_expr RPAREN block ELSE block { $$ = new_subtree(IF_NODE, 3,$3,$5,$7); }
;

block: LBRACE opt_stmt_list RBRACE { $$ = new_subtree(BLOCK_NODE, 1, $2); }
;

while_stmt: WHILE LPAREN bool_expr RPAREN block { $$ = new_subtree(WHILE_STMT_NODE,2,$3,$5);}
;

return_stmt: RETURN SEMI { $$ = new_subtree(RETURN_STMT_NODE,0); }
 | RETURN arith_expr SEMI { $$ = new_subtree(RETURN_STMT_NODE, 1, $2); }
;

func_call: output_call { $$ = new_subtree(FUNC_CALL_NODE,1,$1);}
 | write_call { $$ = new_subtree(WRITE_CALL_NODE,1,$1);}
 | user_func_call { $$ = new_subtree(USER_FUNC_CALL_NODE,1,$1); }
;

input_call: INPUT LPAREN RPAREN { $$ = new_subtree(INPUT_CALL_NODE, 0); }
;

output_call: OUTPUT LPAREN arith_expr RPAREN { $$ = new_subtree(OUTPUT_CALL_NODE,1,$3);}
;

write_call: WRITE LPAREN STRING RPAREN { $$ = new_subtree(WRITE_NODE,1,$3);}
;

user_func_call: ID LPAREN opt_arg_list RPAREN { $$ = new_subtree(USER_FUNC_CALL_NODE, 2, $1,$3); check_func($1->data,arityCalled); arityCalled = 0;}
;

opt_arg_list: {$$ = new_subtree(OPT_ARG_LIST_NODE,0);}
 | arg_list { $$ = new_subtree(OPT_ARG_LIST_NODE,1,$1); }
;

arg_list: arg_list COMMA arith_expr { $$ = new_subtree(ARG_LIST_NODE,2, $1,$3); arityCalled++; }
 | arith_expr { $$ = new_subtree(ARG_LIST_NODE,1,$1); arityCalled++; }
;

bool_expr: arith_expr bool_op arith_expr { $$ = new_subtree(BOOL_EXPR_NODE, 3, $1,$2,$3); }
;

bool_op: LT { $$ = new_subtree(LT_NODE,0); }
 | LE { $$ = new_subtree(LE_NODE,0); }
 | GT { $$ = new_subtree(GT_NODE,0); }
 | GE { $$ = new_subtree(GE_NODE,0); }
 | EQ { $$ = new_subtree(EQ_NODE,0); }
 | NEQ { $$ = new_subtree(NEQ_NODE,0); }
;

arith_expr: arith_expr PLUS arith_expr { $$ = new_subtree(PLUS_NODE,2, $1,$3); }
 | arith_expr MINUS arith_expr { $$ = new_subtree(MINUS_NODE, 2, $1,$3); }
 | arith_expr TIMES arith_expr { $$ = new_subtree(TIMES_NODE, 2, $1,$3); }
 | arith_expr OVER arith_expr { $$ = new_subtree(OVER_NODE,2, $1,$3); }
 | LPAREN arith_expr RPAREN { $$ = new_subtree(ARITH_EXPR_NODE,1, $2); }
 | lval  { $$ = new_subtree(LVAL_NODE,1, $1); }
 | input_call  { $$ = new_subtree(INPUT_NODE,0); }
 | user_func_call { $$ = new_subtree(ARITH_EXPR_NODE, 1, $1); }
 | NUM { $$ = new_subtree(NUMBER_NODE, 0); }
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

// handler error
void yyerror (char const *s) {

    printf("PARSE ERROR (%d): %s\n", yylineno, s);
    
    exit(1);
  
}

int main() {

  //yydebug = 1; // Enter debug mode.
  
    literalTable = create_lit_table();
    symbolTable = create_sym_table();
    auxTableSym = create_sym_table();
    functionTable = create_func_table();

    int resultado = yyparse();
  
    if (resultado == 0){
  
        printf("PARSE SUCESSFUL!\n");

	print_dot(tree);
    
    }

//  printf("\n");
//  print_lit_table(literalTable); printf("\n\n");
//  print_sym_table(symbolTable); printf("\n\n");
//  print_func_table(functionTable);

    return 0;
  
}
