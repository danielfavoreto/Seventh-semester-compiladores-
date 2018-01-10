#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "interpreter.h"
#include "tables.h"

extern LitTable *literalTable;
extern FuncTable *functionTable;
extern SymTable *symbolTable;

// Data stack

#define STACK_SIZE 100

int stack[STACK_SIZE];

int sp; // stack pointer

void push(int x) {
	stack[++sp] = x;
}

int pop() {
	return stack[sp--];
}

void init_stack() {
	int i;

	for (i = 0; i < STACK_SIZE; i++) {
		stack[i] = 0;
	}

	sp = -1;
}

void print_stack() {
	int i;
	printf("*** STACK: ");
	for (i = 0; i <= sp; i++) {
		printf("%d ", stack[i]);
	}
	printf("\n");
}

// Variables memory 

#define MEM_SIZE 100

int mem[MEM_SIZE];

void store(int addr, int val) {
	mem[addr] = val;
}

int load(int addr) {
	return mem[addr];
}

void init_mem() {
	int addr;
	for (addr = 0; addr < MEM_SIZE; addr++) {
		mem[addr] = 0;
	}
}

// STRING FUNCTIONS

/* funcao para remover aspas duplas da string*/
char* removeDoubleQuote(char* s){
	int j = 0;
	char ch;
	char* str1 = malloc(sizeof(char));
	
	for (int i = 0; i < strlen(s); i ++) {
		if (s[i] != '"'){
			ch = s[i];
			str1[j] = ch;
			j++;
		}
	}
	str1[j] = '\0';
	return str1;
}

/* funcao para remover o caracter \n da string e imprimir na tela com new line*/
void removeNewLine (char* str){
	for (int i = 0; i < strlen(str); i++){
		if (str[i] == '\\'){
			if (str[++i] == 'n'){
				printf ("\n");
			}
			else {
				printf ("%c",str[i]);
			}
		}
		else {
			printf ("%c",str[i]);
		}
	}
}

// ------------------------------------------------------------------------------

#ifdef TRACE
#define trace(msg) printf("TRACE: %s\n", msg)
#else
#define trace(msg)
#endif

/*	funcoes para executar cada kind		*/

void rec_run_ast(Tree *ast); // funcao principal

void run_func_declist(Tree *ast){
	trace("func_list");

	rec_run_ast(get_child(ast, 0));
}

void run_func_decl(Tree *ast){
	trace("func_decl");

	rec_run_ast(get_child(ast, 0));

        rec_run_ast(get_child(ast, 1));
}

void run_func_header(Tree *ast){
	trace("func_header");

	rec_run_ast(get_child(ast, 2));
}

void run_param_list(Tree *ast){ // nao sei o que fiz
	trace("param_list");
}

void run_func_body(Tree *ast){
	trace("func_body");

	rec_run_ast(get_child(ast, 0));

	rec_run_ast(get_child(ast, 1));
}

void run_var_dec_list(Tree *ast){ // nao sei o que fiz tb
	trace("var_list");
}

void run_block(Tree *ast){
	trace("block");

	Tree* aux;

	int cont = 0;

	for (aux = ast->firstchild; aux != NULL; aux = aux->next){

		rec_run_ast(get_child(ast, cont));

		cont++;
	}
}

void run_input(Tree *ast){
	trace("input");

	int valor;

	printf("input: ");

	scanf("%d", &valor);

	printf("%d\n",valor);

	push(valor);
}

void run_output(Tree *ast) {
	trace("output");

	rec_run_ast(get_child(ast, 0));

	int x = pop();

	printf("%d", x);
}

void run_write(Tree *ast) {
	trace("write");

	rec_run_ast(get_child(ast, 0));
}

void run_assign(Tree *ast) {
	trace("assign");

	rec_run_ast(get_child(ast, 1));

	Tree *child = get_child(ast, 0);

	int var_idx = child->data;

	store(var_idx, pop());
}

void run_num(Tree *ast){
	trace("num");

	push(ast->data);
}

void run_svar(Tree *ast){
	trace("svar");

	push(ast->data);
}

void run_cvar(Tree *ast){
	trace("cvar");

	Tree *child = get_child(ast, 0);

	int var_idx = child->data;

	push(var_idx);
}

void run_if(Tree *ast) {
	trace("if");

	rec_run_ast(get_child(ast, 0));

	int test = pop();

	if (test == 1) {
		rec_run_ast(get_child(ast, 1));

	} else if (test == 0 && get_child_count(ast) == 3) {
		rec_run_ast(get_child(ast, 2));

	}
}
void run_while(Tree *ast){
	trace("while");

	int again = 1;

	while (again) {
		rec_run_ast(get_child(ast, 0)); 

		rec_run_ast(get_child(ast, 1)); 

		again = !pop();
	}
}

void run_fcall(Tree *ast){
	trace("func");

	rec_run_ast(get_child(ast, 0));

	rec_run_ast(get_child(ast, 1));
}
void run_arg_list(Tree *ast){
	trace("arg_list");
}

#define bin_op() \
	rec_run_ast(get_child(ast, 0)); \
	rec_run_ast(get_child(ast, 1)); \
	int r = pop(); \
	int l = pop()

void run_plus(Tree *ast) {
	trace("plus");

	bin_op();

	push(l + r);
}

void run_minus(Tree *ast) {
	trace("minus");

	bin_op();

	push(l - r);
}

void run_times(Tree *ast) {
	trace("times");

	bin_op();

	push(l * r);
}

void run_over(Tree *ast) {
	trace("over");

	bin_op();

	push((int) l / r);
}

void run_lt(Tree *ast) {
	trace("lt");

	bin_op();

	push(l < r);
}

void run_gt(Tree *ast) {
	trace("gt");

	bin_op();

	push(l > r);
}

void run_eq(Tree *ast) {
	trace("eq");

	bin_op();

	push(l == r);
}

void run_id(Tree *ast) {
	trace("id");

	int var_idx = ast->data;

	push(load(var_idx));
}

void run_string(Tree *ast) {
	trace("string");

	int var_idx = ast->data;

	// modifica a string de saida removendo aspas duplas
	char* string = removeDoubleQuote(get_literal(literalTable, var_idx));

	// apenas remove o caracter \n e imprime a string com new line
	removeNewLine(string);
}

void rec_run_ast(Tree *ast) {
	switch(ast->kind) {
		case FUNC_DECLIST:
			run_func_declist(ast);
			break;
		case FUNC_DECL:
			run_func_decl(ast);
			break;
		case FUNC_HEADER:
			run_func_header(ast);
			break;
		case PARAM_LIST:
			run_param_list(ast);
			break;
		case FUNC_BODY:
			run_func_body(ast);
			break;
		case VAR_DEC_LIST:
			run_var_dec_list(ast);
			break;
		case BLOCK_NODE:
			run_block(ast);
			break;
		case INPUT_NODE:
			run_input(ast);
			break;
		case OUTPUT_NODE:
			run_output(ast);
			break;
		case ASSIGN_NODE:
			run_assign(ast);
			break;
		case SVAR_NODE:
			run_svar(ast);
			break;
		case CVAR_NODE:
			run_cvar(ast);
			break;
		case WHILE_NODE:
			run_while(ast);
			break;
		case FUNC_NODE:
			run_fcall(ast);
			break;
		case ARG_LIST:
			run_arg_list(ast);
			break;
		case IF_NODE:
			run_if(ast);
			break;
		case WRITE_NODE:
			run_write(ast);
			break;
		case PLUS_NODE:
			run_plus(ast);
			break;
		case MINUS_NODE:
			run_minus(ast);
			break;
		case TIMES_NODE:
			run_times(ast);
			break;
		case OVER_NODE:
			run_over(ast);
			break;
		case LT_NODE:
			run_lt(ast);
			break;
		case GT_NODE:
			run_gt(ast);
			break;
		case EQ_NODE:
			run_eq(ast);
			break;
		case NUMBER_NODE:
			run_num(ast);
			break;
		case ID_NODE:
			run_id(ast);
			break;
		case STRING_NODE:
			run_string(ast);
			break;
		default:
			
		exit(1);
	}
}

void run_ast(Tree *ast) {
	init_stack();
	init_mem();
	rec_run_ast(ast);
}
