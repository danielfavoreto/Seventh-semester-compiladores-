#ifndef TREE_H
#define TREE_H

#define CHILDREN_LIMIT 7
#define TEXT_LIMIT 256

typedef enum {
	ELSE_NODE,
	IF_NODE,
	INPUT_NODE,
	INT_NODE,
	OUTPUT_NODE,
	RETURN_NODE,
	VOID_NODE,
	WHILE_NODE,
	WRITE_NODE,
    	NUMBER_NODE,
    	PLUS_NODE,
    	MINUS_NODE,
    	TIMES_NODE,
    	OVER_NODE,
	LT_NODE,
	LE_NODE,
	GT_NODE,
	GE_NODE,
	EQ_NODE,
	NEQ_NODE,
	ASSIGN_NODE,
	STRING_NODE,
	ID_NODE,
	PROGRAM_NODE,
	FUNC_DECL_LIST_NODE,
	FUNC_DECL_NODE,
	FUNC_HEADER_NODE,
	FUNC_BODY_NODE,
	OPT_VAR_DECL_NODE,
	OPT_STMT_LIST_NODE,
	RET_TYPE_NODE,
	PARAMS_NODE,
	PARAM_LIST_NODE,
	PARAM_NODE,
	VAR_DECL_LIST_NODE,
        VAR_LIST_NODE,
	VAR_DECL_NODE,
	STMT_LIST_NODE,
	STMT_NODE,
	ASSIGN_STMT_NODE,
	LVAL_NODE,
	IF_STMT_NODE,
	BLOCK_NODE,
	WHILE_STMT_NODE,
	RETURN_STMT_NODE,
	FUNC_CALL_NODE,
	INPUT_CALL_NODE,
	OUTPUT_CALL_NODE,
	WRITE_CALL_NODE,
	USER_FUNC_CALL_NODE,
	OPT_ARG_LIST_NODE,
	ARG_LIST_NODE,
	BOOL_EXPR_NODE,
	BOOL_OP_NODE,
        SVAR_NODE,
        CVAR_NODE,
	ARITH_EXPR_NODE
} NodeType;

struct node;

typedef struct node Tree;

struct node {
    NodeType type; 
    char text[TEXT_LIMIT];
    int count;
    int data;
    Tree* child[CHILDREN_LIMIT];
};

Tree* new_node(NodeType node);

void add_child(Tree *parent, Tree *child);

Tree* new_subtree(NodeType headNode,int child_count, ...);

Tree* new_nodeData(NodeType node, int data);

void node2Tree(Tree *node, NodeType s);

void print_node(Tree *node, int level);

void print_tree(Tree *tree);
void print_dot(Tree *tree);
int print_node_dot(Tree *node, FILE *file);

void free_tree(Tree *tree);

#endif
