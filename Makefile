OUT = ./App/compiler
OUT_YACC = ./y.tab.c
OUT_YACC_H = ./y.tab.h
LY=LEX_and_YACC
BUILD = ./Build/

all: create_folder yacc lex cc
	@echo "make done!"
	
cc:
	@gcc -g -w $(BUILD)lex.yy.c main.c structs.h $(BUILD)$(OUT_YACC_H) $(BUILD)$(OUT_YACC) -o $(OUT)

create_folder:
	@mkdir $(BUILD)
	
lex: 
	@lex $(LY)/lexer.l 
	@mv ./lex.yy.c $(BUILD)

yacc: 
	@yacc -d $(LY)/parser.y
	@mv $(OUT_YACC_H) $(BUILD)
	@mv $(OUT_YACC) $(BUILD)

clean: $(BUILD)
	@rm -r $(BUILD)
