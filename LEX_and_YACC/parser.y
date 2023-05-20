%{
	#include<stdio.h>
	#include<stdlib.h>
	#include "structs.h"
	int yydebug = 1;
	extern int line_count;
%}

%union
{
	struct Polynom*		polyn;
	struct Mononom*		mon;
	int 			num;
	char 			str[32];
}

%type <str>	variable
%type <polyn> 	poly
%type <mon> 	mononom

%token <num> 	NUMBER
%token <str> 	STRING IPRINT

%left PLUS MINUS
%left MULTI DIVIS
%right UMINUS
%left POWER

%start start
%token ASSING POLYADV LBR RBR COMMENT IEND LEND
%%

start:
	//empty
	| start IEND
	| start LEND
	| start '\r'
	| start command
	;
command:
	variable ASSING poly IEND
	{
		//printf("$p = poly;\n");
		addVariableToList($1, *$3);
		free($3);
	}
	| IPRINT poly IEND
	{
		//printf("[POLY] poly\n");
		printf("[POLY] ");
		printPolynom($2);
		free($2);
	}
	;
poly:
	variable
	{
		//printf("variable\n");
		struct Polynom * poly;
		poly = initPolynom();
		struct Mononom *mono = setMononom(1, "", 0);
		poly = addMononomToPolynom(*poly, *mono);
		free(mono);

		$$ = getVariable($1); 

		$$ = mulPolynoms(*$$, *poly);
		free(poly);
	}
	| mononom
	{
		//printf("mononom\n");
		$$ = initPolynom();
		$$ = addMononomToPolynom(*$$, *$1);
		free($1);
	}
	| LBR poly RBR
	{
		//printf("()\n");
		$$ = $2;
	}
	| poly PLUS poly
	{
		//printf("+\n");
		$$ = sumPolynoms(*$1, *$3);
		free($1);
		free($3);
	}
	| poly MINUS poly
	{
		//printf("-\n");
		$$ = subPolynoms(*$1, *$3);
		$$ = deleteSimilarSummands(*$$);
		free($1);
		free($3);
	}
	| poly MULTI poly
	{
		//printf("*\n");
		$$ = mulPolynoms(*$1, *$3);
		free($1);
		free($3);
	}
	| poly poly %prec MULTI
	{
		$$ = mulPolynoms(*$1, *$2);
		free($1);
		free($2);
	}
	| poly DIVIS poly
	{
		//printf("/\n");
		// todo
	}
	| MINUS poly %prec UMINUS
	{
		//printf("U-\n");
		$$ = unaryMinus($2);
	}
	| poly POWER poly
	{
		//printf("^\n");
		if (strcmp($3->begin->item.variable, "") != 0)
		{
			printError("incorrect pow: ^", $3->begin->item.variable);
			free($1);
			free($3);
			return -1;
		}
		
		int pow = $3->begin->item.coefficient;
		if (pow == 0)
		{
			if ($1->begin->item.coefficient == 0)
			{
				printError("uncertainty (0^0)", "");
			}

			$$ = initPolynom();
			struct Mononom *mono = setMononom(1, "", 0);
			$$ = addMononomToPolynom(*$$, *mono);
			free(mono);
			free($1);
			free($3);
		}
		else if (pow == 1)
		{
			$$ = $1;
			free($3);
		}
		else if (pow > 1)
		{
			$$ = $1;
			for (int i = 0; i < pow - 1; i++)
			{
				$$ = mulPolynoms(*$$, *$1);
			}
			free($1);
			free($3);
		}
		else
		{
			printError("power cannot be < 0", "");
		}
	}
	;
mononom:
	/*
	NUMBER STRING %prec MULTI
	{
		$$ = sumPolynoms(*(setMononom($1, "", 0)), *(setMononom(1, $2, 1)));
		free($1);
		free($2);
	}	
	| */
	NUMBER
	{
		//printf("num\n");
		$$ = setMononom($1, "", 0);
	}
	| STRING
	{
		//printf("Mstr\n");
		$$ = setMononom(1, $1, 1);
	}
	;
variable:
	POLYADV STRING
	{
		//printf("var\n");
		strncpy($$, $2, 32);
	}
	;
%%
