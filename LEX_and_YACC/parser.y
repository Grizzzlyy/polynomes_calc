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
	struct Monomial*		monomial_t;
	struct Polinomial*		polinomial_t;
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
		printf("\nRESULT: ");
		printPolynom($2);
		free($2);
	}
	| varib EQS polinomial EOO
	{
		addVariableToList($1, *$3);
		free($3);
	}
	;
varib:
	DLLR STR
	{
		strncpy($$, $2, MAX_LEN);
	}
	;
polinomial:
	monomial
	{
		$$ = initPolynom(*$1);
		free($1);
	}
	| LBKT polinomial RBKT
	{
		$$ = $2;
	}
	| polinomial PLUS polinomial
	{
		$$ = sumPolynoms(*$1, *$3);
		free($1);
		free($3);
	}
	| polinomial SUB polinomial
	{
		$$ = subPolynoms(*$1, *$3);
		$$ = RemoveSimilarTerms(*$$);
		free($1);
		free($3);
	}
	| polinomial MULT polinomial
	{
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
	| SUB polinomial %prec UMINUS
	{
		$$ = unaryMinus($2);
	}
	| polinomial PWR polinomial
	{
		if (strcmp($3->begin_->mono_.var_, "") != 0)
		{
			printError("[ERROR] Wrong degree: ^", $3->begin_->mono_.var_);
			free($1);
			free($3);
			return -1;
		}
		
		int pow = $3->begin_->mono_.coef_;
		if (pow == 0)
		{
			if ($1->begin_->mono_.coef_ == 0)
			{
				printError("[ERROR] Get out Hacker! (0^0)", "");
			}
			struct Monomial *mono = createMonomial(1, "", 0, false);
			$$ = initPolynom(*mono);
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
			printError("[ERROR] degree cannot be less than 0", "");
		}
	}
	|varib
	{
		struct Polinomial * poly;
		struct Monomial *mono = createMonomial(1, "", 0, true);
		poly = initPolynom(*mono);
		free(mono);

		$$ = initVariable($1); 

		$$ = mulPolynoms(*$$, *poly);
		free(poly);
	}
	;
monomial:
	NUM
	{
		$$ = createMonomial($1, "", 0, true);
	}
	| STR
	{
		$$ = createMonomial(1, $1, 1, false);
	}
	;

%%
