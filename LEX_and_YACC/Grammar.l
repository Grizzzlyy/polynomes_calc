%option noyywrap
%{
	#include <stdlib.h>
	#include <stdio.h>
	#include <string.h>
	#include "y.tab.h"
	#include "polynom.h"
	extern int yylex();
	int gLineNum;
%}

comment		[/][/].*
emptySpace	[ \t\r]
endAfterInstr	[\n]
instructEnd	[;]
opAssing	[=]
advert		[$]
opPower		['^']
leftBracket	[(]
rightBracket[)]
opMulti		[*]
opDivis		[/]
opPlus		[+]
opMinus		[-]
number		[0-9]+
print		(print)+
string		[a-zA-Z_][a-zA-Z0-9_]*
%%

{comment}	;
{emptySpace}	;
{endAfterInstr}	{printf("\n"); }{gLineNum++;return LEND;}
{instructEnd}	{printf(";");	}{return IEND;}
{opAssing}	{printf("=");	}{return ASSING;}
{advert}	{printf("$");	}{return POLYADV;}
{opPower}	{printf("^");	}{return POWER;}
{leftBracket}	{printf("(");	}{return LBR;}
{rightBracket}	{printf(")");	}{return RBR;}
{opMulti}	{printf("*");	}{return MULTI;}
{opDivis}	{printf("/");	}{return DIVIS;}
{opPlus}	{printf("+");	}{return PLUS;}
{opMinus}	{printf("-");	}{return MINUS;}
{number}	{printf("num");	}{yylval.num = atoi(yytext);return NUMBER;}
{print}		{printf("pnt");	}{return IPRINT;}
{string}	{printf("str");	}{memset(yylval.str, 0, 32); strncpy(yylval.str, yytext, 32);return STRING;}

%%

int isPolynomFile(char *file_name) {
	if (!strcmp(strrchr(file_name, '.'), ".polynom"))
		return 1;
	else
		return 0;
}
 
int main(int argc, char* argv[])
{
	yyin = fopen(argv[1], "r");

	if (yyin == NULL)
	{
		printf("[Error] File not found!\n");
		return 1;
	}
	else if (!isPolynomFile(argv[1]))
	{
		printf("[Error] Incorrect file's format! (you need .polynom)\n");
		return 1;
	}

	//yylex();
	yyparse();

	fclose(yyin);
	return 0;
}
