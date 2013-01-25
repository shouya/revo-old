
RubyVM::InstructionSequence.compile_option = {
  :tailcall_optimization => true,
  :trace_instruction => false
}

require_relative 'built_in'
require_relative 'scanner'
require_relative 'parser.tab'
require_relative 'sexpr_eval'




