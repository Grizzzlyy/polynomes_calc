#ifndef FUNCS_H_
#define FUNCS_H_

#include "structs.h"

void printError	(const char *, const char *);
void addVariableToList (char *, struct Polynom );
struct Polynom* getVariable (char *);
struct Mononom* setMononom (int, char *, int);
struct Polynom* initPolynom (void);
struct Polynom* addMononomToPolynom (struct Polynom, struct Mononom);
struct Node* deleteNode (struct Polynom *, struct Node *);
struct Polynom* deleteSimilarSummands (struct Polynom);
struct Polynom* sumPolynoms (struct Polynom, struct Polynom);
struct Polynom* subPolynoms (struct Polynom, struct Polynom);
struct Polynom* mulPolynoms (struct Polynom, struct Polynom);
struct Polynom* unaryMinus (struct Polynom *);
void printMononom (struct Mononom *);
void printPolynom (struct Polynom *);

#endif