
require_relative 'built_in'


require 'ap'
require_relative 'scanner'
require_relative 'parser.tab'
require_relative 'sexpr_eval'

include Revo

scanner = Scanner.new
scanner.scan_string(DATA.read)
#ap scanner.to_a
parser = Parser.new(scanner)
lisp = parser.do_parse

global_context = Context.global
BuiltInFunctions.load_symbols(global_context)


lisp.eval(global_context)

__END__
<<<<<<< Updated upstream
; (write (+ 1 (+ 2 3)))
(write '(+ 1 (+ 2 3)))

=======
<<<<<<< Updated upstream
(write (quote (+ 1 1)))
=======
; (write (+ 1 (+ 2 3)))
(begin
   (define a '(1 . 3))
   (write (cdr a)))

>>>>>>> Stashed changes
>>>>>>> Stashed changes


