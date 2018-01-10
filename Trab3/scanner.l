%option outfile="scanner.c"
%option noyywrap
%option nounput
%option noinput

%{

#include "tree.h"
#include "parser.h"
#include "tables.h"

void processScannerError();
int process_id();
int process_string();

extern LitTable *literalTable;
extern SymTable *auxTableSym;

%}

numero		[0-9]+
identificador	[a-zA-Z]([a-zA-Z]|[0-9])*

%x C_COMMENT

%%

"\n" 		{ yylineno++; } // a cada \n conta-se uma linha

[ ^\t]+ 	// ignorar espacos em branco

"else"		{ yylval = new_node(ELSE_NODE); return ELSE; }
"if"		{ yylval = new_node(IF_NODE); return IF; }
"input" 	{ yylval = new_node(INPUT_NODE); return INPUT; }
"int" 		{ yylval = new_node(INT_NODE); return INT; }
"output"	{ yylval = new_node(OUTPUT_NODE); return OUTPUT; }
"return" 	{ yylval = new_node(RETURN_NODE); return RETURN; }
"void" 		{ yylval = new_node(VOID_NODE); return VOID; }
"while" 	{ yylval = new_node(WHILE_NODE); return WHILE; }
"write" 	{ yylval = new_node(WRITE_NODE); return WRITE; }

"+" 		{ yylval = new_node(PLUS_NODE); return PLUS; }
"-" 		{ yylval = new_node(MINUS_NODE); return MINUS; }
"*" 		{ yylval = new_node(TIMES_NODE); return TIMES; }
"/" 		{ yylval = new_node(OVER_NODE); return OVER; }
"<" 		{ yylval = new_node(LT_NODE); return LT; }
"<=" 		{ yylval = new_node(LE_NODE); return LE; }
">" 		{ yylval = new_node(GT_NODE); return GT; }
">=" 		{ yylval = new_node(GE_NODE); return GE; }
"==" 		{ yylval = new_node(EQ_NODE); return EQ; }
"!=" 		{ yylval = new_node(NEQ_NODE); return NEQ; }
"=" 		{ yylval = new_node(ASSIGN_NODE); return ASSIGN; }

";" 		{return SEMI; }
"," 		{return COMMA; }
"(" 		{return LPAREN; }
")" 		{return RPAREN; }
"[" 		{return LBRACK; }
"]" 		{return RBRACK; }
"{" 		{return LBRACE; }
"}" 		{return RBRACE; }

\".*\" 		{ yylval = new_nodeData(STRING_NODE,process_string()); return STRING; }


<INITIAL>{ // trata o inicio de comentarios com '/*'
"/*"              BEGIN(C_COMMENT);
}
<C_COMMENT>{ // trata os finais de comentarios com '*/'
"*/"      BEGIN(INITIAL);
[^*\n]+   	// consome tudo que nao for '*' '\n'
"*"       	// consome '*'
\n        yylineno++; // incrementa linha quando encontrar '\n'
}

"//".*		{  } // trata comentarios single line '//'

{numero} 	{ yylval = new_nodeData(NUMBER_NODE,atoi(yytext)); return NUM; }

{identificador} { yylval = new_nodeData(ID_NODE,process_id()); return ID; }

[_.#] 		{ processScannerError(); exit(-1);} // qualquer outro caracter eh considerado desconhecido

%%

void processScannerError() {

    printf("SCANNING ERROR (%d): Unknown symbol %s\n", yylineno, yytext);

}

int process_id() {

    return add_var(auxTableSym, yytext, yylineno);
    
}

int process_string() {

    return add_literal(literalTable, yytext);
    
}