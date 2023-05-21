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

 /*operators*/
sum			[+]
sub			[-]
mult			[*]
div			[/]
pwr			['^']
l_bkt			[(]
r_bkt			[)]

 /*space*/
newline			[\n]
singleline_comment	[/][/].* 
empty			[ \t\r]

 /*other*/
end_of_operation	[;]
eqs			[=]
dllr			[$]
print			(print)+

 /*vars*/
str			[a-zA-Z_][a-zA-Z0-9_]*
num			[0-9]+


%% 
 /* RULES */

 /*operators*/
{sum}			{printf("+");	}	{return PLUS;}
{sub}			{printf("-");	}	{return MINUS;}
{mult}			{printf("*");	}	{return MULTI;}
{div}			{printf("/");	}	{return DIVIS;}
{pwr}			{printf("^");	}	{return POWER;}
{l_bkt}			{printf("(");	}	{return LBR;}
{r_bkt}			{printf(")");	}	{return RBR;}

 /*space*/
{newline}		{printf("\n"); }	{line_count++;return LEND;}
{singleline_comment}	{printf("COMMENT");} 	{;}
{empty}			/*{printf("EMPTY");}*/ 	{;}

 /*other*/
{end_of_operation}	{printf(";");	}	{return IEND;}
{eqs}			{printf("=");	}	{return ASSING;}
{dllr}			{printf("$");	}	{return POLYADV;}
{print}			{printf("print");}	{return IPRINT;}

 /*vars*/
{num}			{printf("num");	}	{yylval.num = atoi(yytext); return NUMBER;}
{str}			{printf("str");	}	{memset(yylval.str, 0, 32); strncpy(yylval.str, yytext, 32); return STRING;}



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
