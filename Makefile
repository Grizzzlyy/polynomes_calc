OUT = ./App/compiler
OUT_YACC = ./y.tab.c
OUT_YACC_H = ./y.tab.h
LY=LEX_and_YACC

all: clean yacc lex cc
	@echo "all done!"
	
cc:
	@gcc -g -w lex.yy.c source.c polynom.h $(OUT_YACC_H) $(OUT_YACC) -o $(OUT)
lex:
	@lex $(LY)/Grammar.l 
yacc:
	@yacc -d $(LY)/Grammar.y
clean:
	@rm -rf $(OUT) $(LY)/$(OUT_YACC) $(LY)/$(OUT_YACC_H) $(LY)/lex.yy.c
