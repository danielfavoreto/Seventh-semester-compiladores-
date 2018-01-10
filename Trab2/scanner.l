%option outfile="scanner.c"
%option noyywrap
%option nounput
%option noinput

%{

#include "parser.h"

void processScannerError();

%}

numero		[0-9]+
identificador	[a-zA-Z]([a-zA-Z]|[0-9])*

%x C_COMMENT

%%

"\n" 		{ yylineno++; } // a cada \n conta-se uma linha

[ ^\t]+ 	// ignorar espacos em branco

"else"		{ return ELSE; }
"if"		{ return IF; }
"input" 	{ return INPUT; }
"int" 		{ return INT; }
"output"	{ return OUTPUT; }
"return" 	{ return RETURN; }
"void" 		{ return VOID; }
"while" 	{ return WHILE; }
"write" 	{ return WRITE; }

"+" 		{ return PLUS; }
"-" 		{ return MINUS; }
"*" 		{ return TIMES; }
"/" 		{ return OVER; }
"<" 		{ return LT; }
"<=" 		{ return LE; }
">" 		{ return GT; }
">=" 		{ return GE; }
"==" 		{ return EQ; }
"!=" 		{ return NEQ; }
"=" 		{ return ASSIGN; }

";" 		{ return SEMI; }
"," 		{ return COMMA; }
"(" 		{ return LPAREN; }
")" 		{ return RPAREN; }
"[" 		{ return LBRACK; }
"]" 		{ return RBRACK; }
"{" 		{ return LBRACE; }
"}" 		{ return RBRACE; }

\".*\" 		{ return STRING; }


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

{numero} 	{ return NUM; }

{identificador} { return ID; }

[_.#] 		{ processScannerError(); exit(-1);} // qualquer outro caracter eh considerado desconhecido

%%

void processScannerError() {

    	printf("SCANNING ERROR (%d): Unknown symbol %s\n", yylineno, yytext);
    	
}
