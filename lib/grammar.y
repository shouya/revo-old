# -*- racc -*-
#
# command to compile release:
#   $ racc -oparser.tab.rb -vg grammar.y
# command to compile debug:
#   $ racc -oparser.tab.rb grammar.y
#



class Revo::Parser
options no_result_var
start main
rule

         main: atom

      literal: STRING   { val[0] }
             | INTEGER  { val[0] }
             | FLOAT    { val[0] }
             | NAME     { val[0] }
             | SYMBOL   { val[0] }

         atom: literal  { val[0] }
             | list     { val[0] }

         list: LBRACKET list_content RBRACKET  { val[1] }

 list_content: /* empty */       { Array.new }
             | list_content atom { val[0] << val[1] }


---- inner
attr :scanner
def initialize(scanner)
  @scanner = scanner
end

def next_token
  @scanner.next_token
end


