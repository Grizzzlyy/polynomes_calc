OUT = ./App/compiler
OUT_YACC = ./y.tab.c
OUT_YACC_H = ./y.tab.h
LY=LEX_and_YACC

all: clean yacc lex cc
	@echo "make done!"
	
cc:
	@gcc -g -w lex.yy.c main.c structs.h $(OUT_YACC_H) $(OUT_YACC) -o $(OUT)
lex:
	@lex $(LY)/lexer.l
yacc:
	@yacc -d $(LY)/parser.y
clean:
	@rm -rf $(OUT) $(OUT_YACC) $(OUT_YACC_H) lex.yy.c
