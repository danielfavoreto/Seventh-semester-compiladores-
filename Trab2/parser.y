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

int yylex(void);
void yyerror(char const *s);
extern int yylineno;

%}

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

%%

program: func_decl_list
;

func_decl_list: func_decl_list func_decl
 | func_decl
;

func_decl: func_header func_body
;

func_header: ret_type ID LPAREN params RPAREN
;

func_body: LBRACE opt_var_decl opt_stmt_list RBRACE
;

opt_var_decl: /* vazio */ 
 | var_decl_list
;

opt_stmt_list: /* vazio */
 | stmt_list
;

ret_type: INT
 | VOID
;

params: VOID
 | param_list
;

param_list: param_list COMMA param
 | param
;

param: INT ID
 | INT ID LBRACK RBRACK
;

var_decl_list: var_decl_list var_decl
 | var_decl
;

var_decl: INT ID SEMI
 | INT ID LBRACK NUM RBRACK SEMI
;

stmt_list: stmt_list stmt 
 | stmt
;

stmt: assign_stmt
 | if_stmt
 | while_stmt
 | return_stmt
 | func_call SEMI
;

assign_stmt: lval ASSIGN arith_expr SEMI
;

lval: ID
 | ID LBRACK NUM RBRACK
 | ID LBRACK ID RBRACK
;

if_stmt: IF LPAREN bool_expr RPAREN block
 | IF LPAREN bool_expr RPAREN block ELSE block
;

block: LBRACE opt_stmt_list RBRACE
;

while_stmt: WHILE LPAREN bool_expr RPAREN block
;

return_stmt: RETURN SEMI 
 | RETURN arith_expr SEMI
;

func_call: output_call
 | write_call
 | user_func_call
;

input_call: INPUT LPAREN RPAREN
;

output_call: OUTPUT LPAREN arith_expr RPAREN
;

write_call: WRITE LPAREN STRING RPAREN
;

user_func_call: ID LPAREN opt_arg_list RPAREN
;

opt_arg_list: /* vazio */
 | arg_list
;

arg_list: arg_list COMMA arith_expr 
 | arith_expr
;

bool_expr: arith_expr bool_op arith_expr
;

bool_op: LT 
 | LE 
 | GT 
 | GE 
 | EQ 
 | NEQ
;

arith_expr: arith_expr PLUS arith_expr
 | arith_expr MINUS arith_expr
 | arith_expr TIMES arith_expr
 | arith_expr OVER arith_expr
 | LPAREN arith_expr RPAREN
 | lval
 | input_call
 | user_func_call
 | NUM
;


%%

// handler error
void yyerror (char const *s) {

  printf("PARSE ERROR (%d): %s\n", yylineno, s);
  
}

int main() {

  //yydebug = 1; // Enter debug mode.
  
  int resultado = yyparse();
  
  if (resultado == 0){
  
    printf("PARSE SUCESSFUL!\n");
    
  }
  
  return 0;
  
}
