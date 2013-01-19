
RACC = racc
GRAMMAR_FILE = grammar.y
PARSER_OUTPUT_FILE = parser.tab.rb
OPTIONS = -v
DEBUGGING = yes
PROFILING = no

ifeq ($(DEBUGGING), yes)
	OPTIONS += -t
endif
ifeq ($(PROFILING), yes)
	OPTIONS += -P
endif

all: yacc

yacc: $(PARSER_OUTPUT_FILE)

$(PARSER_OUTPUT_FILE): $(GRAMMAR_FILE)
	$(RACC) $(OPTIONS) -o$@ $<


.PHONY : clean
clean:
	rm -f *.output $(PARSER_OUTPUT_FILE)


