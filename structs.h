#ifndef STRUCTS_H_
#define STRUCTS_H_

#include <stdio.h>	
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define MAX_L 50 // VAR_MAX_LENGTH

struct Mononom
{
	int coefficient;
	char variable[MAX_L];
	int power;
};

struct Polynom
{
	struct Node* begin;
	int count;
};

struct Node
{
	struct Mononom item;
	struct Node* next;
	struct Node* prev;
};

struct Variable
{
	char* variable;	
	struct Polynom polynom; 
	struct Variable* next;
	struct Variable* prev;
};

#endif