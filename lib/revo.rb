
RubyVM::InstructionSequence.compile_option = {
  :tailcall_optimization => true,
  :trace_instruction => false
}



require_relative 'revo/built_in'
require_relative 'revo/scanner'
require_relative 'revo/parser.tab'
require_relative 'revo/sexpr_eval'




