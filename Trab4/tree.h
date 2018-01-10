#ifndef TREE_H
#define TREE_H

#define CHILDREN_LIMIT 7
#define TEXT_LIMIT 256

typedef enum {
    OUTPUT_NODE,
    RETURN_NODE,
    INPUT_NODE,
    WHILE_NODE,
    WRITE_NODE,
    ELSE_NODE,
    VOID_NODE,
    IF_NODE,
    INT_NODE,
    NUMBER_NODE,
    ID_NODE,
    STRING_NODE,
    EQ_NODE,
    NEQ_NODE,
    LE_NODE,
    GE_NODE,
    ASSIGN_NODE,
    PLUS_NODE,
    MINUS_NODE,
    TIMES_NODE,
    OVER_NODE,
    LT_NODE,
    GT_NODE,
    SEMI_NODE,
    COMMA_NODE,
    LPAREN_NODE,
    RPAREN_NODE,
    LBRACK_NODE,
    RBRACK_NODE,
    LBRACE_NODE,
    RBRACE_NODE,
    FUNC_DECLIST,
    FUNC_DECL,
    FUNC_HEADER,
    FUNC_BODY,
    VAR_DEC_LIST,
    PARAM_LIST,
    STMT_LIST,
    ARG_LIST,
    PARAM_NODE,
    BLOCK_NODE,
    USER_FUNC_CALL,
    CVAR_NODE,
    SVAR_NODE,
    FUNC_NODE
} NodeType;

struct node;

typedef struct node Tree;

struct node {
    	NodeType kind; 
	int data;
	struct node* next;
	struct node* firstchild;
};

Tree* new_node(NodeType kind);

Tree* new_nodeData(NodeType kind, int data);

void node2Tree(Tree *node, NodeType kind, char* s);

Tree* add_child(Tree *parent, Tree *child);

int get_child_count(Tree *node);

Tree* get_child(Tree *parent, int idx);

void print_dot(Tree *tree);

int print_node_dot(Tree *node, FILE *file);

void free_tree(Tree *tree);

#endif
