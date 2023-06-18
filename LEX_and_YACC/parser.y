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
%right PWR

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
		VarToList($1, *$3);
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
		$$ = InitPolinom(*$1);
		free($1);
	}
	| LBKT polinomial RBKT
	{
		$$ = $2;
	}
	| polinomial PLUS polinomial
	{
		$$ = PolinomialSum(*$1, *$3);
		free($1);
		free($3);
	}
	| polinomial SUB polinomial
	{
		$$ = PolinomialMinus(*$1, *$3);
		$$ = RemoveSimilarTerms(*$$);
		free($1);
		free($3);
	}
	| polinomial MULT polinomial
	{
		$$ = PolinomialUmnozh(*$1, *$3);
		free($1);
		free($3);
	}
	| polinomial polinomial %prec MULT
	{
		$$ = PolinomialUmnozh(*$1, *$2);
		free($1);
		free($2);
	}
	| SUB polinomial %prec UMINUS
	{
		$$ = MinusUnar($2);
	}
	| polinomial PWR polinomial
	{
		for (struct Part *i = $3->begin_; i != NULL; i = i->after_){
			if (strcmp(i->mono_.var_, "") != 0)
				{
					ErrorPrint("[ERROR] Wrong degree: ^", $3->begin_->mono_.var_);
					free($1);
					free($3);
					return -1;
				}
		}
		
		int degree = $3->begin_->mono_.coef_;
		if (degree == 0)
		{
			if ($1->begin_->mono_.coef_ == 0)
			{
				ErrorPrint("[ERROR] Get out Hacker! (0^0)", "");
			}
			struct Monomial *mono = CreateMonomial(1, "", 0, false);
			$$ = InitPolinom(*mono);
			free(mono);
			free($1);
			free($3);
		}
		else if (degree == 1)
		{
			$$ = $1;
			free($3);
		}
		else if (degree > 1)
		{
			$$ = $1;
			for (int i = 0; i < degree - 1; i++)
			{
				$$ = PolinomialUmnozh(*$$, *$1);
			}
			free($1);
			free($3);
		}
		else
		{
			ErrorPrint("[ERROR] degree cannot be less than 0", "");
		}
	}
	|varib
	{
		struct Polinomial * poly;
		struct Monomial *mono = CreateMonomial(1, "", 0, true);
		poly = InitPolinom(*mono);
		free(mono);

		$$ = initVariable($1); 

		$$ = PolinomialUmnozh(*$$, *poly);
		free(poly);
	}
	;
monomial:
	NUM
	{
		$$ = CreateMonomial($1, "", 0, true);
	}
	| STR
	{
		$$ = CreateMonomial(1, $1, 1, false);
	}
	;

%%
