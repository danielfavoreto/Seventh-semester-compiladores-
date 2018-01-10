
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tree.h"

void node2Tree(Tree *node, NodeType s) {
    switch(s) {
        case NUMBER_NODE:       strcpy(node->text, "num"); break;
        case PLUS_NODE:         strcpy(node->text, "+"); break;
        case MINUS_NODE:        strcpy(node->text, "-"); break;
        case TIMES_NODE:        strcpy(node->text, "*"); break;
        case OVER_NODE:         strcpy(node->text, "/"); break;
        case ELSE_NODE:         strcpy(node->text, "else"); break;
        case IF_NODE:           strcpy(node->text, "if"); break;
	case INPUT_NODE:        strcpy(node->text,"input");break;
	case INT_NODE:          strcpy(node->text,"int");break;
	case OUTPUT_NODE:       strcpy(node->text,"output");break;
	case RETURN_NODE:       strcpy(node->text,"return");break;
	case VOID_NODE:         strcpy(node->text,"void");break;
	case WHILE_NODE:        strcpy(node->text,"while");break;
	case WRITE_NODE:        strcpy(node->text,"write");break;
	case LT_NODE:           strcpy(node->text,"<");break;
	case LE_NODE:           strcpy(node->text,"<=");break;
	case GT_NODE:           strcpy(node->text,">");break;
	case GE_NODE:           strcpy(node->text,">=");break;
	case EQ_NODE:           strcpy(node->text,"==");break;
	case NEQ_NODE:          strcpy(node->text,"!=");break;
	case ASSIGN_NODE:       strcpy(node->text,"=");break;
	case STRING_NODE:       strcpy(node->text,"string");break;
	case ID_NODE:           strcpy(node->text,"id");break;
        case FUNC_DECL_LIST_NODE:strcpy(node->text,"func_list");break;
        case FUNC_DECL_NODE:    strcpy(node->text,"func_decl");break;
        case FUNC_HEADER_NODE:  strcpy(node->text,"func_header");break;
        case FUNC_BODY_NODE:    strcpy(node->text,"func_body");break;
        case OPT_VAR_DECL_NODE: strcpy(node->text,"opt_var_decl");break;
        case OPT_STMT_LIST_NODE:strcpy(node->text,"opt_stmt_list");break;
        case RET_TYPE_NODE:     strcpy(node->text,"ret_type");break;
        case PARAMS_NODE:       strcpy(node->text,"params");break;
        case PARAM_LIST_NODE:   strcpy(node->text,"param_list");break;
        case PARAM_NODE:        strcpy(node->text,"param_");break;
        case VAR_DECL_LIST_NODE:strcpy(node->text,"var_decl_list");break;
        case VAR_DECL_NODE:     strcpy(node->text,"var_decl");break;
        case STMT_LIST_NODE:    strcpy(node->text,"stmt_list");break;
        case STMT_NODE:         strcpy(node->text,"stmt");break;
        case ASSIGN_STMT_NODE:  strcpy(node->text,"assign_stmt");break;
        case LVAL_NODE:         strcpy(node->text,"lval");break;
        case IF_STMT_NODE:      strcpy(node->text,"if_stmt");break;
        case BLOCK_NODE:        strcpy(node->text,"block_node");break;
        case WHILE_STMT_NODE:   strcpy(node->text,"while_stmt");break;
        case RETURN_STMT_NODE:  strcpy(node->text,"return_stmt");break;
        case FUNC_CALL_NODE:    strcpy(node->text,"func_call");break;
        case INPUT_CALL_NODE:   strcpy(node->text,"input");break;
        case OUTPUT_CALL_NODE:  strcpy(node->text,"output_call");break;
        case WRITE_CALL_NODE:   strcpy(node->text,"write_call");break;
        case USER_FUNC_CALL_NODE:strcpy(node->text,"user_func_call");break;
        case OPT_ARG_LIST_NODE: strcpy(node->text,"opt_arg_list");break;
        case VAR_LIST_NODE:     strcpy(node->text,"var_list");break;
        case ARG_LIST_NODE:     strcpy(node->text,"arg_list");break;
        case BOOL_EXPR_NODE:    strcpy(node->text,"bool_expr");break;
        case BOOL_OP_NODE:      strcpy(node->text,"bool_op");break;
        case ARITH_EXPR_NODE:   strcpy(node->text,"arith_expr");break;
        case SVAR_NODE:         strcpy(node->text,"svar");break;
        case CVAR_NODE:         strcpy(node->text,"cvar");break;
        default: printf("Invalid node kind: %d!\n", node->type);
    }
}

Tree* new_nodeData(NodeType node, int data){
    
    Tree* new = new_node(node);
    
    new->data = data;
    
    return new;
}

Tree* new_node(NodeType node) {
    
    Tree* no = (Tree*) malloc(sizeof (Tree));
    
    no->type = node;
    
    no->data = 0;
    
    no->count = 0;
    
    node2Tree(no,node);
    
    int i;
    
    for (i = 0; i < CHILDREN_LIMIT; i++) {
        
        no->child[i] = NULL;
        
    }
    
    return no;
}

void add_child(Tree *parent, Tree *child) {
    
    if (parent->count == CHILDREN_LIMIT) {
        
        fprintf(stderr, "Cannot add another child!\n");
        
        exit(1);
        
    }
    
    parent->child[parent->count] = child;
    
    parent->count++;
}

Tree* new_subtree(NodeType headNode, int child_count, ...) {
    
    if (child_count > CHILDREN_LIMIT) {
        
        fprintf(stderr, "Too many children as arguments!\n");
        
        exit(1);
        
    }

    Tree* node = new_node(headNode);
    
    va_list ap;
    
    va_start(ap, child_count);
    
    int i;
    
    for (i = 0; i < child_count; i++) {
        
        add_child(node, va_arg(ap, Tree*));
        
    }
    
    va_end(ap);
    
    return node;
}

void free_tree(Tree *tree) {
    
    int i;
    
    for (i = 0; i < tree->count; i++) {
        
        free_tree(tree->child[i]);
        
    }
    
    free(tree);
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

/* printa cada node da AST */
int print_node_dot(Tree *node, FILE *file) {
    
    int my_nr = nr++;
     
    if (node != NULL){
        
        if (node->type == STRING_NODE || node->type == ID_NODE){
        
            fprintf(file,"node%d[label=\"%s,%d\"];\n", my_nr, node->text,node->data);
        
        }
        else {
               fprintf(file,"node%d[label=\"%s\"];\n", my_nr, node->text);
        }
        
        int i;
    
        for (i = 0; i < node->count; i++) {
            
            if (node->child[i] != NULL){
            
                int child_nr = print_node_dot(node->child[i],file);
            
                fprintf(file,"node%d -> node%d;\n", my_nr, child_nr);
            
            }
        }        
    }
    
    return my_nr;
}