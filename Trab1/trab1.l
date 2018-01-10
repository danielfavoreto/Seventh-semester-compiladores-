%option nounput
%option noinput

%{

#include <stdio.h>

#include "token.h"

/* funcao generica para processar os tokens capturados, fazendo a impressao na tela */
void process_token(TipoToken);

/* funcao para imprimir na tela o nao reconhecimento de um token */
void process_error();

%}

numero		[0-9]+
identificador	[a-zA-Z]([a-zA-Z]|[0-9])*

%x C_COMMENT

%%

"\n" 		{ yylineno++; } // a cada \n conta-se uma linha

[ ^\t]+ 	// ignorar espacos em branco

"else"		{ process_token(ELSE); }
"if"		{ process_token(IF); }
"input" 	{ process_token(INPUT); }
"int" 		{ process_token(INT); }
"output"	{ process_token(OUTPUT); }
"return" 	{ process_token(RETURN); }
"void" 		{ process_token(VOID); }
"while" 	{ process_token(WHILE); }
"write" 	{ process_token(WRITE); }

"+" 		{ process_token(PLUS); }
"-" 		{ process_token(MINUS); }
"*" 		{ process_token(TIMES); }
"/" 		{ process_token(OVER); }
"<" 		{ process_token(LT); }
"<=" 		{ process_token(LE); }
">" 		{ process_token(GT); }
">=" 		{ process_token(GE); }
"==" 		{ process_token(EQ); }
"!=" 		{ process_token(NEQ); }
"=" 		{ process_token(ASSIGN); }

";" 		{ process_token(SEMI); }
"," 		{ process_token(COMMA); }
"(" 		{ process_token(LPAREN); }
")" 		{ process_token(RPAREN); }
"[" 		{ process_token(LBRACK); }
"]" 		{ process_token(RBRACK); }
"{" 		{ process_token(LBRACE); }
"}" 		{ process_token(RBRACE); }

\".*\" 		{ process_token(STRING); }


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

{numero} 	{ process_token(NUM); }

{identificador} { process_token(ID); }

[_.#] 		{ process_error(); } // qualquer outro caracter eh considerado desconhecido

%%

void process_token(TipoToken tk) {
    	printf("%d: %s -> %s\n", yylineno, yytext, TIPO_TOKEN_STRING[tk]);
}

void process_error() {
    	printf("%d: %s -> %s\n", yylineno, yytext, "UNKNOWN");
}

int main() {
	yylex(); // getToken 
	return 0; 
}

int yywrap() { // chamada pelo lex quando o input ja foi exaurido
	return 1;
}
