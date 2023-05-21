%{
	#include <stdio.h> /* for printf */
	#include <stdlib.h> /* for free */
	#include "../structs.h" /* Polynomes, etc */
	int yydebug = 1; /* for debug */
%}

 /* YACC declarations */
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

%token <num> 	NUM
%token <str> 	STR PRINT

%left PLUS SUB
%left MULT DIV
%right UMINUS
%left PWR

%start start
%token EQS DLLR LBKT RBKT EOO EOL
 /* End of YACC declarations */
%%

start:
	| start EOO
	| start EOL
	| start '\r'
	| start command
	;
command:
	variable EQS poly EOO
	{
		//printf("$p = poly;\n");
		addVariableToList($1, *$3);
		free($3);
	}
	| PRINT poly EOO
	{
		//printf("[POLY] poly\n");
		printf("RESULT: ");
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
	| LBKT poly RBKT
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
	| poly SUB poly
	{
		//printf("-\n");
		$$ = subPolynoms(*$1, *$3);
		$$ = deleteSimilarSummands(*$$);
		free($1);
		free($3);
	}
	| poly MULT poly
	{
		//printf("*\n");
		$$ = mulPolynoms(*$1, *$3);
		free($1);
		free($3);
	}
	| poly poly %prec MULT
	{
		$$ = mulPolynoms(*$1, *$2);
		free($1);
		free($2);
	}
	| poly DIV poly
	{
		//printf("/\n");
		// todo
	}
	| SUB poly %prec UMINUS
	{
		//printf("U-\n");
		$$ = unaryMinus($2);
	}
	| poly PWR poly
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
	NUM STR %prec MULT
	{
		$$ = sumPolynoms(*(setMononom($1, "", 0)), *(setMononom(1, $2, 1)));
		free($1);
		free($2);
	}	
	| */
	NUM
	{
		//printf("num\n");
		$$ = setMononom($1, "", 0);
	}
	| STR
	{
		//printf("Mstr\n");
		$$ = setMononom(1, $1, 1);
	}
	;
variable:
	DLLR STR
	{
		//printf("var\n");
		strncpy($$, $2, 32);
	}
	;
%%
