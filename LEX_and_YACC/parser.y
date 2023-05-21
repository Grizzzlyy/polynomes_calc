%{
	#include <stdio.h> /* for printf */
	#include <stdlib.h> /* for free */
	#include "../structs.h" /* Polynomes, etc */
	int yydebug = 1; /* for debug */
%}

 /* YACC declarations */
%union
{
	int 				num_y;
	char 				str_y[50];
	struct Mononom*		monomial_t;
	struct Polynom*		polinomial_t;
}

 /* start */
%start beginning

%token EQS DLLR LBKT RBKT EOO EOL
%token <num_y> 	NUM
%token <str_y> 	STR PRINT

%left PLUS SUB
%left MULT  /* DIV */
%right UMINUS
%left PWR

 /* like typedef */
%type <str_y>	varib
%type <polinomial_t> 	polinomial
%type <monomial_t> 	monomial

 /* End of YACC declarations */
%%

beginning:
	| beginning EOL
	| beginning EOO
	| beginning '\r'
	| beginning statement
	;
statement:
	PRINT polinomial EOO
	{
		//printf("[POLY] poly\n");
		printf("\nRESULT: ");
		printPolynom($2);
		free($2);
	}
	| varib EQS polinomial EOO
	{
		//printf("$p = poly;\n");
		addVariableToList($1, *$3);
		free($3);
	}
	;
varib:
	DLLR STR
	{
		//printf("var\n");
		strncpy($$, $2, MAX_L);
	}
	;
polinomial:
	varib
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
	| monomial
	{
		//printf("mononom\n");
		$$ = initPolynom();
		$$ = addMononomToPolynom(*$$, *$1);
		free($1);
	}
	| LBKT polinomial RBKT
	{
		//printf("()\n");
		$$ = $2;
	}
	| polinomial PLUS polinomial
	{
		//printf("+\n");
		$$ = sumPolynoms(*$1, *$3);
		free($1);
		free($3);
	}
	| polinomial SUB polinomial
	{
		//printf("-\n");
		$$ = subPolynoms(*$1, *$3);
		$$ = deleteSimilarSummands(*$$);
		free($1);
		free($3);
	}
	| polinomial MULT polinomial
	{
		//printf("*\n");
		$$ = mulPolynoms(*$1, *$3);
		free($1);
		free($3);
	}
	| polinomial polinomial %prec MULT
	{
		$$ = mulPolynoms(*$1, *$2);
		free($1);
		free($2);
	}
	/* | polinomial DIV polinomial
	{
		printf("warning: division is not realized, so the operation is skipped\n");
		//printf("/\n");
		// todo
	} */
	| SUB polinomial %prec UMINUS
	{
		//printf("U-\n");
		$$ = unaryMinus($2);
	}
	| polinomial PWR polinomial
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
monomial:
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

%%
