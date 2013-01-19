
RubyVM::InstructionSequence.compile_option = {
  :tailcall_optimization => true,
  :trace_instruction => false
}


require_relative 'built_in'


require 'ap'
require_relative 'scanner'
require_relative 'parser.tab'
require_relative 'sexpr_eval'

include Revo

scanner = Scanner.new
scanner.scan_file('test_run.ss')
#ap scanner.to_a
parser = Parser.new(scanner)
lisp = parser.do_parse

global_context = Context.global
BuiltInFunctions.load_symbols(global_context)


lisp.eval(global_context)

__END__
