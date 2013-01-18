
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
; (write (+ 1 (+ 2 3)))
;(begin
;   (define a '(1 . 3))
;   (write (cdr a)))

;(begin
;  (define p (lambda (a b) (+ a b)))
;  (write (p (p 1 2) 3)))

(begin
  (define factorial (lambda (x)
    (write x)
    (if (== x 1) 1 (* x (factorial (- x 1))))))
  (write (factorial 2)))




