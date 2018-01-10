
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tree.h"
extern int scope;
void node2Tree(Tree *node, NodeType kind,char* s) {
    switch(kind) {
	    case OUTPUT_NODE: sprintf(s, "%s", "output"); break;
	    case RETURN_NODE: sprintf(s, "%s", "return"); break;
	    case INPUT_NODE:  sprintf(s, "%s", "input"); break;
	    case WHILE_NODE:  sprintf(s, "%s", "while"); break;
	    case WRITE_NODE:  sprintf(s, "%s", "write"); break;
	    case ELSE_NODE:   sprintf(s, "%s", "else"); break;
	    case VOID_NODE:   sprintf(s, "%s", "void"); break;
	    case IF_NODE:     sprintf(s, "%s", "if"); break;
	    case INT_NODE:    sprintf(s, "%s", "int"); break;
	    case NUMBER_NODE:    sprintf(s, "num,%d", node->data); break;
	    case ID_NODE:     sprintf(s, "id,%d", node->data); break;
	    case SVAR_NODE:     sprintf(s, "svar,%d", node->data); break;
	    case CVAR_NODE:     sprintf(s, "cvar,%d", node->data); break;
	    case FUNC_NODE:     sprintf(s, "func,%d", node->data); break;
	    case STRING_NODE: sprintf(s, "%s", "string"); break;
	    case EQ_NODE:     sprintf(s, "%s", "=="); break;
	    case NEQ_NODE:    sprintf(s, "%s", "!="); break;
	    case LE_NODE:     sprintf(s, "%s", "<="); break;
	    case GE_NODE:     sprintf(s, "%s", ">="); break;
	    case ASSIGN_NODE: sprintf(s, "%s", "="); break;
	    case PLUS_NODE:   sprintf(s, "%s", "+"); break;
	    case MINUS_NODE:  sprintf(s, "%s", "-"); break;
	    case TIMES_NODE:  sprintf(s, "%s", "*"); break;
	    case OVER_NODE:   sprintf(s, "%s", "/"); break;
	    case LT_NODE:     sprintf(s, "%s", "<"); break;
	    case GT_NODE:     sprintf(s, "%s", ">"); break;
	    case SEMI_NODE:   sprintf(s, "%s", ";"); break;
	    case COMMA_NODE:  sprintf(s, "%s", ","); break;
	    case LPAREN_NODE: sprintf(s, "%s", "("); break;
	    case RPAREN_NODE: sprintf(s, "%s", ")"); break;
	    case LBRACK_NODE: sprintf(s, "%s", "["); break;
	    case RBRACK_NODE: sprintf(s, "%s", "]"); break;
	    case LBRACE_NODE: sprintf(s, "%s", "{"); break;
	    case RBRACE_NODE: sprintf(s, "%s", "}"); break;
	    case FUNC_DECLIST: sprintf(s, "%s", "func_list"); break;
	    case FUNC_DECL:    sprintf(s, "%s", "func_decl"); break;
	    case FUNC_HEADER:   sprintf(s, "%s", "func_header"); break;
	    case FUNC_BODY:     sprintf(s, "%s", "func_body"); break;
	    case VAR_DEC_LIST: sprintf(s, "%s", "var_list"); break;
	    case PARAM_LIST: sprintf(s, "%s", "param_list"); break;
	    case BLOCK_NODE: sprintf(s, "%s", "block"); break;
	    case USER_FUNC_CALL: sprintf(s, "%s", "user_func_call"); break;
	    case ARG_LIST: sprintf(s, "%s", "arg_list"); break;
	    default: printf("Invalid node kind: %d!\n", kind); break;
    }
}

Tree* new_node(NodeType kind) {
  Tree* node = (Tree*) malloc(sizeof(Tree));
  node->kind = kind;
  node->data = 0;
  node->next = NULL;
  node->firstchild = NULL;
  return node;
}

Tree* new_nodeData(NodeType kind, int data) {
  Tree* node = new_node(kind);
  node->data = data;
  return node;
}

Tree* add_child(Tree* parent, Tree* child) {
  Tree* aux = parent;
  if (aux->firstchild == NULL) {
    aux->firstchild = child;
  } 
  else {
  	for(aux=parent->firstchild; aux->next!=NULL; aux=aux->next);
    	aux->next = child;
  	}
  return parent;
}

void free_tree(Tree *tree) {
    
    if (tree != NULL)
	{
		Tree* p = tree->firstchild;
		while (p != NULL) {
			Tree* t = p->next;
			free_tree(p);
			p = t;
		}
		free(tree);
	}
}

int nr;

/* printa a AST*/
void print_dot(Tree *tree) {
    
    FILE* file = fopen("AST.dot","w");
    
    nr = 0;
    
    fprintf(file,"digraph {\ngraph [ordering=\"out\"];\n");
    
    print_node_dot(tree,file);
    
    fprintf(file,"}\n");
}

Tree* get_child(Tree *parent, int idx) {
	int count = 0;
	Tree* aux = parent;
	for (aux = parent->firstchild; aux != NULL; aux = aux->next){
		if (idx != count){
			count++;	
		}
		else{
			return aux;
		}
	}
	return aux;
}

int get_child_count(Tree *node) {
    int count = 0;
	Tree* aux = node;
	if (aux->firstchild == NULL){
		return count;
	}
	for (aux = node->firstchild; aux->next != NULL; aux = aux->next){
		count++;
	}
	count++;
    return count;
}

/* printa cada node da AST */
int print_node_dot(Tree *node, FILE *file) {

    char s[100];
    int my_nr = nr++;
    node2Tree(node,node->kind,s);

    if (node != NULL){
        fprintf(file,"node%d[label=\"%s\"];\n", my_nr, s);
        
		Tree* aux;

		for(aux = node->firstchild; aux!= NULL; aux = aux->next) {
		  int l_nr = print_node_dot(aux,file);
		  fprintf(file,"node%d -> node%d;\n", my_nr, l_nr);
		}
	}
    
    return my_nr;
}
