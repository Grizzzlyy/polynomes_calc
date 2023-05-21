#define _CRT_SECURE_NO_WARNINGS

#include "structs.h"

extern int line_count;
#define false 0
#define true 1

struct LanguageVar* gVariableList = NULL;

struct Polinomial* initPolynom(struct Monomial mono)
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


void addVariableToList(char *letter, struct Polinomial polynom)
{
	struct LanguageVar* var = (struct LanguageVar *)malloc(sizeof(struct LanguageVar));
	var->var_ = (char*) malloc(MAX_LEN);
	strncpy(var->var_, letter, MAX_LEN);
	var->poly_ = polynom;
	var->after_ = NULL;
	var->before_ = NULL;

	if (gVariableList == NULL)
	{
		gVariableList = var;
		return;
	}

	struct LanguageVar *varList = gVariableList;
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
	struct LanguageVar* varList = gVariableList;
	while (varList != NULL)
	{
		if (!strcmp(varList->var_, variable))
		{
			return &(varList->poly_);
		}
		varList = varList->after_;
	}
	printError("[ERROR] Variable is not initialized: $", variable);
}

struct Monomial* createMonomial(int coefficient, char* variable, int degree, bool is_number){
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

struct Part * deleteNode(struct Polinomial *polynom, struct Part *node)
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

				j = deleteNode(&polynom, j);
			}
		}

		i = deleteNode(&polynom, i);
		if (new_poly == NULL){
			new_poly = initPolynom(mononom);
		}
		else{
			addMononomToPolynom(new_poly, mononom);
		}
		
	}

	return new_poly;
}

struct Polinomial* sumPolynoms(struct Polinomial p1, struct Polinomial p2)
{
	for (struct Part* i = p1.begin_; i != NULL; i = i->after_)
	{
		char varI[MAX_LEN] = {0};
		strncpy(varI, i->mono_.var_, MAX_LEN);
		for (struct Part* j = p2.begin_; j != NULL; j = j->after_)
		{
			char varJ[MAX_LEN] = {0};
			strncpy(varJ, j->mono_.var_, MAX_LEN);

			if (strncmp(varI, varJ, MAX_LEN) != 0 && strncmp(varI, "", MAX_LEN) != 0 && strncmp(varJ, "", MAX_LEN) != 0)//Если переменные не совпадают и ни одна из переменных не является числом, то ошибка
			{
				printError("[ERROR] Different variables in polynom", "");
			}
		}
	}

	struct Polinomial *result = (struct Polinomial *)malloc(sizeof(struct Polinomial));
	(*result) = p1;
	struct Polinomial *freePtr;
	for (struct Part *node = p2.begin_; node != NULL; node = node->after_)
	{
		addMononomToPolynom (result, node->mono_);
	}

	freePtr = result;
	result = RemoveSimilarTerms(*result);
	free(freePtr);
	return result;
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

struct Polinomial * subPolynoms(struct Polinomial p1, struct Polinomial p2)
{
	for (struct Part *i = p1.begin_; i != NULL; i = i->after_)
	{
		for (struct Part *j = p2.begin_; j != NULL; j = j->after_)
		{
			char varI[MAX_LEN] = {0};
			strncpy(varI, i->mono_.var_, MAX_LEN);
			char varJ[MAX_LEN] = {0};
			strncpy(varJ, j->mono_.var_, MAX_LEN);

			if (strncmp(varI, varJ, MAX_LEN) != 0 && strncmp(varI, "", MAX_LEN) != 0 && strncmp(varJ, "", MAX_LEN) != 0) //Если переменные не совпадают и ни одна из переменных не является числом, то
			{
				printError("[ERROR] Different variables in polynom", "");
			}
		}
	}

	struct Polinomial *minusP2 = MinusUnar(&p2);
	struct Polinomial * result = sumPolynoms(p1, *minusP2);
	result = RemoveSimilarTerms(*result);

	return result;
}

struct Polinomial * mulPolynoms(struct Polinomial p1, struct Polinomial p2)
{
	struct Polinomial * result = NULL;
		
	for (struct Part *i = p1.begin_; i != NULL; i = i->after_)
	{
		for (struct Part *j = p2.begin_; j != NULL; j = j->after_)
		{
			struct Monomial mononom = i->mono_;

			mononom.coef_ *= j->mono_.coef_;

			bool IisNumber = (strncmp(mononom.var_, "", MAX_LEN) == 0);
			bool JisNumber = (strncmp(j->mono_.var_, "", MAX_LEN) == 0);
			bool varMatch = (strcmp(mononom.var_, j->mono_.var_) == 0);

			if (!IisNumber && varMatch) //у обоих одинаковая переменная
			{
				mononom.degree_ += j->mono_.degree_;
			}
			else if (IisNumber && !JisNumber)//У мононома нет переменной, у второго есть
			{
				strncpy(mononom.var_, j->mono_.var_, MAX_LEN);
				mononom.degree_ += j->mono_.degree_;
				}
			else if (!IisNumber && !JisNumber && !varMatch)//у обоих разные переменные
			{
				printError("[ERROR] Different variables in polynom", "");
			}

			if (mononom.coef_ == 0)
			{
				strncpy(mononom.var_, "", MAX_LEN);
				mononom.degree_ = 0;
			}

			if (result == NULL){
				result = initPolynom(mononom);
			}
			else{
				addMononomToPolynom(result, mononom);
			}
		}
	}

	struct Polinomial *freePtr = result;
	result = RemoveSimilarTerms(*result);
	free(freePtr);
	return result;
}

void printMononom(struct Monomial *mononom)
{
	if (!strcmp(mononom->var_, ""))
	{
		printf("%d", mononom->coef_);
	}
	else
	{
		if (abs(mononom->coef_) == 1)
		{
			if (mononom->coef_ == -1)
			{
				printf("-");
			}
			if (mononom->degree_ == 1)
			{
				printf("%s", mononom->var_);
			}
			else
			{
				printf("%s^%d", mononom->var_, mononom->degree_);
			}
		}
		else
		{
			if (mononom->degree_ == 1)
			{
				printf("%d%s", mononom->coef_, mononom->var_);
			}
			else
			{
				printf("%d%s^%d", mononom->coef_, mononom->var_, mononom->degree_);
			}
		}
	}
}

void printPolynom(struct Polinomial *polynom)
{
	struct Part *begin = polynom->begin_;
	// printf("= ");
	
	while (begin->mono_.coef_ == 0 && begin->after_ != NULL)
	{
		begin = begin->after_;
	}

	int itemNum = 0;
	for (struct Part *node = begin; node != NULL; node = node->after_)
	{
		itemNum++;
	}

	bool *itemWasPrinted = (bool *)calloc(sizeof(bool), itemNum);

	char varName[MAX_LEN] = { 0 };
	for (struct Part *node = begin; node != NULL; node = node->after_)
	{
		if (strncmp(node->mono_.var_, "", MAX_LEN) != 0)//Если это не число
		{
			strncpy(varName, node->mono_.var_, MAX_LEN);	
		}
	}

	bool firstWasPrinted = false;
	//Вывести все одночлены с этой переменной
	for (int i = 0; i < itemNum; i++)
	{
		//Найти самую старшую невыведенную степень
		int maxPower = 0;
		int currentItemIndex = 0;
		int itemIndex = 0;
		struct Part *result = begin;
		for (struct Part *node = begin; node != NULL; node = node->after_)
		{
			if (strncmp(node->mono_.var_, varName, MAX_LEN) == 0 && //Если совпадает имя переменной
				!itemWasPrinted[currentItemIndex] &&					  //Эта переменная не была выведена
				node->mono_.degree_ > maxPower)					  //Cтепень выше других
			{
				result = node;
				maxPower = node->mono_.degree_;
				itemIndex = currentItemIndex;
			}

			currentItemIndex++;
		}

		if (maxPower != 0)//Если был найден хоть один подходящий элемент, то
		{
			//Вывести найденный элемент
			if (firstWasPrinted && result->mono_.coef_ > 0)//Если уже были выведены значения и коэффициент положительный
			{
				printf("+");
			}

			firstWasPrinted = true;
			printMononom(&result->mono_);
			itemWasPrinted[itemIndex] = true;
		}
		else
		{
			break;//Если нового невыведенного элемента не было найдено, то можно перейти к следующей переменной
		}
	}
	
	//Вывести константное значение
	for (struct Part *node = begin; node != NULL; node = node->after_)
	{
		if (strncmp(node->mono_.var_, "", MAX_LEN) == 0 && node->mono_.coef_ != 0)
		{
			if (firstWasPrinted && node->mono_.coef_ > 0) //Если уже были выведены значения и коэффициент положительный
			{
				printf("+");
			}

			firstWasPrinted = true;
			printMononom(&node->mono_);
			break;
		}
	}

	//Вывести 0, если совсем ничего не было выведено
	if (!firstWasPrinted)
	{
		printf("0");
	}
	printf(".\n");
}

#ifdef __unix__
	#include "Build/y.tab.h"
#elif defined _WIN32 
	#include "y_tab.h"
#endif

	void yyerror(char const *s)
{
	printf("[ERROR] Line %d: '%s'\n", line_count + 1, s);
}

void printError(const char *s1, const char *s2)
{
	printf("[ERROR] Line %d: %s%s\n", line_count + 1, s1, s2);
	exit(-1);
}