#define _CRT_SECURE_NO_WARNINGS

#include "structs.h"

extern int line_count;

#ifdef __unix__
	#include "Build/y.tab.h"
#elif defined _WIN32 
	#include "y_tab.h"
#endif

struct LanguageVar* ListOfVariables = NULL;

struct Polinomial* InitPolinom(struct Monomial mono)
{
	struct Polinomial *new_poly = (struct Polinomial *)malloc(sizeof(struct Polinomial));

	new_poly->begin_ = (struct Part *) malloc(sizeof(struct Part));
	new_poly->begin_->before_= NULL;
	new_poly->begin_->after_ = NULL;

	new_poly->begin_->mono_ = mono; //first monomial

	new_poly->end_ = new_poly->begin_;

	new_poly->count_parts_ = 1;

	return new_poly;
}


void VarToList(char *letter, struct Polinomial polynom)
{
	struct LanguageVar* var = (struct LanguageVar *)malloc(sizeof(struct LanguageVar));
	var->var_ = (char*) malloc(MAX_LEN);
	strncpy(var->var_, letter, MAX_LEN);
	var->poly_ = polynom;
	var->after_ = NULL;
	var->before_ = NULL;

	if (ListOfVariables == NULL)
	{
		ListOfVariables = var;
		return;
	}

	struct LanguageVar *varList = ListOfVariables;
	for (; varList->after_ != NULL; varList = varList->after_)
	{
		if (!strcmp(varList->var_, letter))
		{
			varList->poly_ = polynom;
			return;
		}
	}

	if (!strcmp(varList->var_, letter))
	{
		varList->poly_ = polynom;
		return;
	}

	var->before_ = varList;
	varList->after_ = var;
}

struct Polinomial* initVariable(char *variable)
{
	struct LanguageVar* varList = ListOfVariables;
	while (varList != NULL)
	{
		if (!strcmp(varList->var_, variable))
		{
			return &(varList->poly_);
		}
		varList = varList->after_;
	}
	ErrorPrint("[ERROR] Variable is not initialized: $", variable);
}

struct Monomial* CreateMonomial(int coefficient, char* variable, int degree, bool is_number){
	struct Monomial* mono = (struct Monomial *) malloc(sizeof(struct Monomial));
	
	mono->coef_ = coefficient;
	mono->degree_ = degree;
	if(is_number){
		memset(mono->var_,0,MAX_LEN );
	}
	else{
		strncpy(mono->var_,variable,MAX_LEN);
	}

	return mono;
}

void addMononomToPolynom(struct Polinomial* poly, struct Monomial mono)
{
	poly->end_->after_ = (struct Part *) malloc(sizeof(struct Part));

	poly->end_->after_->before_ = poly->end_;
	poly->end_->after_->after_ = NULL;
	poly->end_->after_->mono_ = mono;

	poly->end_ = poly->end_->after_;
	poly->count_parts_++;
}
struct Polinomial* PolinomialSum(struct Polinomial poly_a, struct Polinomial poly_b)
{
	for (struct Part* i = poly_a.begin_; i != NULL; i = i->after_)
	{
		char variable_i[MAX_LEN] = {0};
		strncpy(variable_i, i->mono_.var_, MAX_LEN);
		for (struct Part* j = poly_b.begin_; j != NULL; j = j->after_)
		{
			char variable_j[MAX_LEN] = {0};
			strncpy(variable_j, j->mono_.var_, MAX_LEN);

			if (strncmp(variable_i, variable_j, MAX_LEN) != 0 && strncmp(variable_i, "", MAX_LEN) != 0 && strncmp(variable_j, "", MAX_LEN) != 0){
				ErrorPrint("[ERROR] Different variables in polynom", "");
			}
		}
	}

	struct Polinomial *result = (struct Polinomial *)malloc(sizeof(struct Polinomial));
	(*result) = poly_a;
	for (struct Part *node = poly_b.begin_; node != NULL; node = node->after_)
	{
		addMononomToPolynom (result, node->mono_);
	}

	result = RemoveSimilarTerms(*result);
	return result;
}

struct Part * RemoveTerm(struct Polinomial *polynom, struct Part *node)
{
	struct Part * result = node;

	if (node != polynom->begin_ ){
		if(node->after_ != NULL){
			node->after_->before_ = node->before_;
		}
		node->before_->after_ = node->after_;
		
		result = node->before_;
		free(node);
	}
	else if (polynom->begin_ == node)
	{
		if (node->after_ == NULL)
		{
			free(node);
			return NULL;
		}

		node->after_->before_ = NULL;
		result = node->after_;
		free(node);

		polynom->begin_ = result;
		return result;
	}
	return result;
}

struct Polinomial* RemoveSimilarTerms(struct Polinomial polynom)
{
	struct Polinomial* new_poly = NULL;
	for (struct Part *i = polynom.begin_; i != NULL;)
	{
		struct Monomial mononom = i->mono_;
		for (struct Part *j = polynom.begin_; j != NULL; j = j->after_)
		{
			if (strncmp(i->mono_.var_, j->mono_.var_, MAX_LEN) == 0 &&
				i->mono_.degree_ == j->mono_.degree_ &&
				i != j)
			{
				mononom.coef_ += j->mono_.coef_;
				if (mononom.coef_ == 0)
				{
					mononom.degree_ = 0;
					strncpy(mononom.var_, "", MAX_LEN);
				}

				j = RemoveTerm(&polynom, j);
			}
		}

		i = RemoveTerm(&polynom, i);
		if (new_poly == NULL){
			new_poly = InitPolinom(mononom);
		}
		else{
			addMononomToPolynom(new_poly, mononom);
		}
		
	}

	return new_poly;
}



struct Polinomial* MinusUnar(struct Polinomial *polynom)
{
	for (struct Part *node = polynom->begin_; node != NULL; node = node->after_)
	{
		node->mono_.coef_ *= (-1);
	}
	struct Polinomial * result = RemoveSimilarTerms(*polynom);
	return result;
}

struct Polinomial * PolinomialMinus(struct Polinomial poly_a, struct Polinomial poly_b)
{
	for (struct Part *i = poly_a.begin_; i != NULL; i = i->after_)
	{
		for (struct Part *j = poly_b.begin_; j != NULL; j = j->after_)
		{
			char variable_i[MAX_LEN] = {0};
			strncpy(variable_i, i->mono_.var_, MAX_LEN);
			char variable_j[MAX_LEN] = {0};
			strncpy(variable_j, j->mono_.var_, MAX_LEN);
			if (strncmp(variable_i, variable_j, MAX_LEN) != 0 && strncmp(variable_i, "", MAX_LEN) != 0 && strncmp(variable_j, "", MAX_LEN) != 0) 
			{
				ErrorPrint("[ERROR] Different variables in polynom", "");
			}
		}
	}

	struct Polinomial *minus_poly_b = MinusUnar(&poly_b);
	struct Polinomial *result = PolinomialSum(poly_a, *minus_poly_b);
	result = RemoveSimilarTerms(*result);

	return result;
}

struct Polinomial * PolinomialUmnozh(struct Polinomial poly_a, struct Polinomial poly_b)
{
	struct Polinomial * result_poly = NULL;
		
	for (struct Part *i = poly_a.begin_; i != NULL; i = i->after_)
	{
		for (struct Part *j = poly_b.begin_; j != NULL; j = j->after_)
		{
			struct Monomial mono = i->mono_;

			mono.coef_ *= j->mono_.coef_;

			bool mon_a_is_num = (strncmp(mono.var_, "", MAX_LEN) == 0);
			bool mon_b_is_num = (strncmp(j->mono_.var_, "", MAX_LEN) == 0);
			bool a_sim_b = (strcmp(mono.var_, j->mono_.var_) == 0);

			if (!mon_a_is_num && !mon_b_is_num && !a_sim_b)
			{
				ErrorPrint("[ERROR] Different variables in polynom", "");
			}
			else if (!mon_a_is_num && a_sim_b) 
			{
				mono.degree_ += j->mono_.degree_;
			}
			else if (mon_a_is_num && !mon_b_is_num)
			{
				strncpy(mono.var_, j->mono_.var_, MAX_LEN);
				mono.degree_ += j->mono_.degree_;
			}

			if (mono.coef_ == 0)
			{
				strncpy(mono.var_, "", MAX_LEN);
				mono.degree_ = 0;
			}

			if (result_poly == NULL){
				result_poly = InitPolinom(mono);
			}
			else{
				addMononomToPolynom(result_poly, mono);
			}
		}
	}

	struct Polinomial *tmp = result_poly;
	result_poly = RemoveSimilarTerms(*result_poly);
	free(tmp);
	return result_poly;
}

void MonomialPrint(struct Monomial *mono)
{
	if (!strcmp(mono->var_, ""))
	{
		printf("%d", mono->coef_);
	}
	else
	{
		if (abs(mono->coef_) == 1){
			if (mono->coef_ == -1){
				printf("-");
			}
			if (mono->degree_ != 1){
				printf("%s^%d", mono->var_, mono->degree_);
			}
			else{
				printf("%s", mono->var_);
			}
			
		}
		else{
			if (mono->degree_ != 1){
				printf("%d%s^%d", mono->coef_, mono->var_, mono->degree_);
			}
			else{
				printf("%d%s", mono->coef_, mono->var_);
			}
		}
	}
}

void printPolynom(struct Polinomial *polynom)
{
	struct Part *begin = polynom->begin_;
	while (begin->mono_.coef_ == 0 && begin->after_ != NULL)
	{
		begin = begin->after_;
	}

	int mono_num = 0;
	for (struct Part *part = begin; part != NULL; part = part->after_)
	{
		mono_num++;
	}

	bool *if_mono_printed = (bool *)calloc(sizeof(bool), mono_num);

	char varName[MAX_LEN] = { 0 };
	for (struct Part *node = begin; node != NULL; node = node->after_)
	{
		if (strncmp(node->mono_.var_, "", MAX_LEN) != 0)
		{
			strncpy(varName, node->mono_.var_, MAX_LEN);	
		}
	}

	bool SomethingWasPrinted = false;
	for (int i = 0; i < mono_num; i++)
	{
		int max_degree = 0;
		int cur_mono_ind = 0;
		int mono_ind = 0;
		struct Part *result = begin;
		for (struct Part *node = begin; node != NULL; node = node->after_)
		{
			if (strncmp(node->mono_.var_, varName, MAX_LEN) == 0 && 
				!if_mono_printed[cur_mono_ind] &&					  
				node->mono_.degree_ > max_degree)					 
			{
				result = node;
				max_degree = node->mono_.degree_;
				mono_ind = cur_mono_ind;
			}

			cur_mono_ind++;
		}

		if (max_degree != 0)
		{
			if (SomethingWasPrinted && result->mono_.coef_ > 0)
			{
				printf("+");
			}

			SomethingWasPrinted = true;
			MonomialPrint(&result->mono_);
			if_mono_printed[mono_ind] = true;
		}
		else
		{
			break;
		}
	}
	
	for (struct Part *node = begin; node != NULL; node = node->after_)
	{
		if (strncmp(node->mono_.var_, "", MAX_LEN) == 0 && node->mono_.coef_ != 0)
		{
			if (SomethingWasPrinted && node->mono_.coef_ > 0) 
			{
				printf("+");
			}
			SomethingWasPrinted = true;
			MonomialPrint(&node->mono_);
			break;
		}
	}
	if (!SomethingWasPrinted)
	{
		printf("0");
	}
	printf(";\n");
}

	void yyerror(char const *s)
{
	printf("[ERROR] Line: %d in input file '%s'\n", line_count+1, s);
}

void ErrorPrint(const char *s1, const char *s2)
{
	printf("[ERROR] Line: %d in input file%s%s\n", line_count+1, s1, s2);
	exit(-1);
}