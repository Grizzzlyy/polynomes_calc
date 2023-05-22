#ifndef STRUCT_H_
#define STRUCT_H_

#include <stdio.h>	
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>

#define MAX_LEN 32

struct Monomial
{
	char var_[MAX_LEN];
	int coef_;
	int degree_;
};

struct Polinomial
{
	struct Part* begin_;
	struct Part* end_;
	int count_parts_;
};

struct Part
{
	struct Part* before_;
	struct Monomial mono_;
	struct Part* after_;
};

struct LanguageVar
{
	
	struct LanguageVar* before_;
	char* var_;	
	struct Polinomial poly_; 
	struct LanguageVar* after_;
};

void addMononomToPolynom (struct Polinomial*, struct Monomial);
void printError	(const char *, const char *);
void addVariableToList (char *, struct Polinomial );
struct Polinomial* initVariable (char *);
struct Monomial* createMonomial(int, char *, int, bool);
struct Polinomial* initPolynom (struct Monomial mono);
struct Part* deleteNode (struct Polinomial *, struct Part *);
struct Polinomial* RemoveSimilarTerms (struct Polinomial);
struct Polinomial* PolinomialSum (struct Polinomial, struct Polinomial);
struct Polinomial* PolinomialMinus (struct Polinomial, struct Polinomial);
struct Polinomial* mulPolynoms (struct Polinomial, struct Polinomial);
struct Polinomial* MinusUnar (struct Polinomial *);
void printMononom (struct Monomial *);
void printPolynom (struct Polinomial *);
#endif