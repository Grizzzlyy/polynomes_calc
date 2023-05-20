 /* usage: lex filename.l 
 or flex filename.l
 >> lex.yy.c */
 
 /* DECLARATIONS */

 /* Auxiliary declarations start here */
%option noyywrap 
%{
	#include <stdio.h> /* for printf */
	#include <stdlib.h> /* for atoi */
	#include <string.h> /* for strncpy */
	#include "y.tab.h" /* for yylval, yyparse */
	int line_count;
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
 /* RULES */

{comment}	;
{emptySpace}	;
{endAfterInstr}	{printf("\n"); }{line_count++;return LEND;}
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
 /* AUXILIARY FUNCTIONS */
 
int main(int argc, char* argv[])
{
	FILE *fp;
	
	if(argc > 1)
	{
		fp = fopen(argv[1], "r");
		if(fp)
		{
			yyin = fp;
		}
		else
		{
			printf("[E] Cannot find file %s\n", argv[1]);
			return 1;
		}
			
	}
	else
	{
		printf("argument is not provided\nusage: ./exe polynome.txt");
		return 1;
	}

	yyparse();
	fclose(fp);
	return 0;
}
