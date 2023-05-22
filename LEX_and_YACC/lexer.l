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
	#include "../structs.h"
	int line_count;
%}

 /*operators*/
sum			[+]
sub			[-]
mult		[*]
pwr			['^']
l_bkt		[(]
r_bkt		[)]

 /*space*/
newline				[\n]
singleline_comment	[/][/].* 
empty				[ \t\r]

 /*other*/
end_of_operation	[;]
eqs					[=]
dllr				[$]
print				(print)+

 /*vars*/
str			[a-zA-Z_][a-zA-Z0-9_]*
num			[0-9]+


%% 
 /* RULES */

 /*operators*/
{sum}					{return PLUS;}
{sub}					{return SUB;}
{mult}					{return MULT;}
{pwr}					{return PWR;}
{l_bkt}					{return LBKT;}
{r_bkt}					{return RBKT;}

 /*space*/
{newline}				{line_count++; return EOL;}
{singleline_comment} 	{;}
{empty}		 			{;}

 /*other*/
{end_of_operation}		{return EOO;}
{eqs}					{return EQS;}
{dllr}					{return DLLR;}
{print}					{return PRINT;}

 /*vars*/
{num}					{yylval.num_y = atoi(yytext); return NUM;}
{str}					{memset(yylval.str_y, 0, MAX_LEN); strncpy(yylval.str_y, yytext, MAX_LEN); return STR;}



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
