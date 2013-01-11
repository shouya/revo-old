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

         main: expr

      literal: STRING   { String.new(val[0]) }
             | INTEGER  { Number.new(val[0]) }
             | FLOAT    { Number.new(val[0]) }
             | NAME     { Name.new(val[0]) }
             | SYMBOL   { Symbol.new(val[0]) }
             | QUOTE LBRACKET RBRACKET { EndOfList.instance }

         expr: literal  { val[0] }
             | list     { val[0] }
             | pair     { val[0] }

         pair: LBRACKET  pair_content RBRACKET { val[1] }

 pair_content: literal PERIOD literal {
                 SExpr.new(val[0]).cons(SExpr.new(val[2]))
               }
             | literal PERIOD pair    {
                 SExpr.new(val[0]).cons(val[2])
               }
             | expr pair_content      {
                 SExpr.new(val[0]).cons(val[1])
               }

         list: LBRACKET list_content RBRACKET  { val[1] }

 list_content: /* empty */       { SExpr.new }
             | expr list_content { SExpr.new(val[0]).cons(val[1]) }


---- header
require_relative 'prim_types'
require_relative 'sexpr'

---- inner
attr :scanner
def initialize(scanner)
  @scanner = scanner
end

def next_token
  @scanner.next_token
end


