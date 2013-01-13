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
             | NAME     { Name.new(val[0])   }
             | SYMBOL   { Symbol.new(val[0]) }

         expr: literal  { SExpr.new(val[0]) }
             | list     { val[0] }
             | pair     { val[0] }

         pair: LBRACKET pair_content RBRACKET { SExpr.new(val[1]) }

 pair_content: expr PERIOD expr {
                 val[0].cons(val[2])
               }
             | expr pair_content      {
                 val[0].cons(val[1])
               }

         list: LBRACKET list_content RBRACKET  { SExpr.new(val[1]) }
             | quoted_expr         { SExpr.new(val[0]) }


 list_content: /* empty */       { SExpr.new }
             | expr list_content { val[0].cons(val[1]) }

  quoted_expr: QUOTE expr        {
                 SExpr.new(Name.new('quote')).cons(val[1].endlist)
               }



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


