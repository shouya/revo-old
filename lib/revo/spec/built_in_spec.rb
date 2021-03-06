

require_relative '../../revo'

describe Revo do
  before :each do
    def parse(str)
      Revo::Parser.parse(str)
    end
    def eval(str)
      parser = Revo::Parser.new(Revo::Scanner.new
                                  .tap {|x| x.scan_string(str) })
      Revo::Context.global.clear
      Revo::BuiltInFunctions.load_symbols(Revo::Context.global)
      parser.do_parse.eval(Revo::Context.global)
    end

    def assert_equal(estr, pstr)
      eval(estr).should == parse(pstr)
    end
  end

  it 'does basis correctly' do
    assert_equal('', '()')
    assert_equal('1', '1')
    assert_equal('2', '2')
    assert_equal('""', '""')
    assert_equal('"1"', '"1"')
    assert_equal('\'()', '()')
    assert_equal('#t', '#t')
    assert_equal('#f', '#f')
  end

  it 'does arithmetic' do
    assert_equal('(+ 1 2 3)', '6')

    # TODO: support negative integer parsing
    # assert_equal('(- 1)', '-1')
    assert_equal('(- 3 2 1)', '0')
    assert_equal('(* 3 3)', '9')
    assert_equal('(* 3)', '3')
    assert_equal('(/ 6 2)', '3')
  end

  it 'starts a block' do
    assert_equal('(begin 1)', '1')
    assert_equal('(begin 1 2)', '2')
    assert_equal('(begin 1 (+ 1 1))', '2')
  end

  it 'does c{a,d}r' do
    assert_equal('(car \'(1 . 2))', '1')
    assert_equal('(car \'((1) . 2))', '(1)')
    assert_equal('(cdr \'(1 . 2))', '2')
    assert_equal('(cdr \'(1 2 3))', '(2 3)')
  end

  it 'supports lambda' do
    assert_equal('((lambda (a) (+ a 1)) 1)',  '2')
    assert_equal('((lambda (a b) (+ a b)) 2 3)', '5')
    assert_equal("((lambda (a . b) (eval (cons '+ (cons a b)))) 1 2 3)", '6')

    assert_equal('((lambda a a) 1 2 3)',  '(1 2 3)')
  end

  it 'supports global vars' do
    assert_equal('(define a 1)', '1')
    assert_equal('(begin (define a 1) a)', '1')
    assert_equal("(begin (define a '(1 2 3)) a)", '(1 2 3)')
    assert_equal("(begin (define a (+ 2 3)) a)", '5')
    assert_equal("(begin (define a (lambda (x) x)) (a 2))", '2')
  end

  it 'has bool values' do
    assert_equal('#t', '#t')
    assert_equal('#f', '#f')
  end

  it 'supports condictional expr' do
    assert_equal('(= 1 1)', '#t')
    assert_equal('(= "1" "1")', '#t')
    assert_equal('(= 1 2)', '#f')

    # TODO: support better intertype comparisons
    assert_equal('(= 1 "1")', '#f')

    assert_equal('(!= 1 1)', '#f')
    assert_equal('(!= 1 2)', '#t')

    assert_equal('(< 1 2)', '#t')
    assert_equal('(< 2 1)', '#f')
    assert_equal('(< 1 1)', '#f')

    assert_equal('(<= 1 2)', '#t')
    assert_equal('(<= 2 1)', '#f')
    assert_equal('(<= 1 1)', '#t')

    assert_equal('(> 1 2)', '#f')
    assert_equal('(> 2 1)', '#t')
    assert_equal('(> 1 1)', '#f')

    assert_equal('(>= 1 2)', '#f')
    assert_equal('(>= 2 1)', '#t')
    assert_equal('(>= 1 1)', '#t')
  end

  it 'does recursion' do
    assert_equal(<<-'ss', '3628800')
(begin
  (define factorial
    (lambda (x)
      (if (= x 1)
	  1
	  (* x (factorial (- x 1))))))
  (factorial 10))
    ss
  end

  it 'supports macros' do
    assert_equal(<<-'ss', "((1 2 3) ((4 5 6) (7 8 9)))")
(begin
  (define-macro mymacro
    (lambda (head . body)
      (list 'list
	    (cons 'quote (cons head '()))
	    (cons 'quote (cons body '())))))
  (mymacro (1 2 3) (4 5 6) (7 8 9)))
    ss
  end

  it 'supports local scope' do
    assert_equal('(let ((a 1) (b 2)) (+ a b))', '3')
    assert_equal('(begin (define a 5) (let ((a 1) (b 2)) (+ a b)))', '3')
    assert_equal('(begin (define a 5) (let ((a 1) (b a)) (+ a b)))', '6')
  end

  it 'supports branching' do
    assert_equal('(if 0 2 3)', '2')
    assert_equal('(if "" 2 3)', '2')

    assert_equal("(if '() 2 3)", '3')
    assert_equal("(if #f 2 3)", '3')

    assert_equal('(if 1 2 3)', '2')
    assert_equal('(if "a" 2 3)', '2')

    assert_equal('(if (= 1 1) 2 3)', '2')
    assert_equal('(if (= 1 1) (+ 1 2) (+ 2 3))', '3')
    assert_equal('(if (= 1 2) (+ 1 2) (+ 2 3))', '5')
  end

  it 'supports when and unless' do
    assert_equal('(when (= 1 1) 3)', '3')
    assert_equal('(when (= 1 1) (+ 1 2))', '3')
    assert_equal('(when (= 1 1) (+ 1 2) (+ 4 5))', '9')
    assert_equal('(when (= 1 2) (+ 1 2) (+ 4 5))', "()")

    assert_equal('(unless (= 1 2) 3)', ' 3')
    assert_equal('(unless (= 1 2) (+ 1 2))', ' 3')
    assert_equal('(unless (= 1 2) (+ 1 2) (+ 4 5))', '9')
    assert_equal('(unless (= 1 1) (+ 1 2) (+ 4 5))', "()")
  end

  it 'supports mapping and for-each' do
    assert_equal("(map (lambda (x) (+ 1 x)) '(1 2 3))", "(2 3 4)")
    assert_equal("(map (lambda (x y) (+ x y)) '(1 2 3) '(3 2 1))", "(4 4 4)")

    assert_equal("(for-each (lambda (x y) (+ x y)) '(1 2 3) '(3 2 1))", "()")
    assert_equal("(begin (for-each (lambda (x) (define a x)) '(1 2)) a)", "2")
  end

  it 'supports let* and fluid-let' do
    # FIXME: fluid-let doesn't work
=begin fluid-let
    assert_equal(<<-'ss', '101')
(begin
  (define counter 1)
  (define bump-counter
    (lambda ()
      (set! counter (+ counter 1))
; (display counter)(newline)
      counter))
  (fluid-let ((counter 99))
    (bump-counter)
    (define x (bump-counter)))
  x)
    ss

    assert_equal(<<-'ss', '1')
(begin
  (define counter 1)
  (define bump-counter
    (lambda ()
      (define counter (+ counter 1))
      counter))
  (fluid-let ((counter 99))
    (bump-counter)
    (bump-counter)) counter)
    ss
=end
    assert_equal('(let* ((x 1) (y x)) (+ x y))', '2')
    assert_equal('(let* ((x 1) (y x) (z y)) (+ y z))', '2')
  end

  it 'evaluates' do
    assert_equal("(eval '(+ 1 2))", '3')

    # TODO: Add value class methods for Context
    #+in order to access it in Revo program
=begin comment
    assert_equal(<<-'ss', '1')
(begin
  (let ((x 1))
    (define ctx (current-context)))
  (define x 2)
  (eval x ctx))
    ss
=end
  end

  it 'supports letrec' do
    assert_equal(<<-'ss', '(#f #t)')
(letrec ((local-even? (lambda (n)
                        (if (= n 0) #t
                            (local-odd? (- n 1)))))
         (local-odd? (lambda (n)
                        (if (= n 0) #f
                            (local-even? (- n 1))))))
  (list (local-even? 23) (local-odd? 23)))
    ss
  end

  it 'supports let as recusion syntatic sugar' do
    assert_equal(<<-'ss', 'liftoff')
(let countdown ((i 10))
  (if (= i 0) 'liftoff
      (countdown (- i 1))))
    ss
  end

  it 'reverses lists' do
    assert_equal("(reverse '(1 2 (3 4)))", '((3 4) 2 1)')
  end

  it 'supports type-of' do
    assert_equal('(type-of 1)', 'number')
    assert_equal("(type-of 'a)", 'symbol')
    assert_equal('(type-of "str")', 'string')
    assert_equal('(type-of #t)', 'bool')
    assert_equal('(type-of #f)', 'bool')
    assert_equal("(type-of '())", 'null')
    assert_equal("(type-of let)", 'primitive-macro')
    assert_equal("(type-of +)", 'primitive-procedure')
    assert_equal("(type-of '(1 2))", 'list')
    assert_equal('(type-of (lambda (a) 1))', 'user-lambda')

    assert_equal("(type-of '1)", 'number')
  end

  it 'folds' do
    assert_equal("(fold-left + 0 '(1 2 3))", '6')
    assert_equal("(fold-right + 0 '(1 2 3))", '6')

    assert_equal("(fold-left (lambda (x y) y) 5 '(1 2 3))", '3')
    assert_equal("(fold-right (lambda (x y) x) 5 '(1 2 3))", '1')

    assert_equal("(fold-left (lambda (x y) x) 5 '(1 2 3))", '5')
    assert_equal("(fold-right (lambda (x y) y) 5 '(1 2 3))", '5')

    assert_equal("(fold-left cons '() '(1 2 3))", "(((() . 1) . 2) . 3)")
    assert_equal("(fold-right cons '() '(1 2 3))", "(1 2 3)")
  end

  it 'does type assertions' do
    assert_equal("(null? '())", '#t')

    # TODO: other type's assertions
    #    assert_equal("(number? '())", '1')
  end

  it 'works with alias' do
    assert_equal('(progn 1 2)', '2') # alias -> begin
  end


  it 'supports quasiquote' do
    assert_equal('`1', '1')
    assert_equal('`,1', '1')
    assert_equal('`(1)', '(1)')
    assert_equal('``(1)', '`(1)')
    assert_equal('`(,1)', '(1)')
    assert_equal('`()', '()')
    assert_equal('`(,(+ 1 1))', '(2)')
    assert_equal('`(1 ,(+ 1 1))', '(1 2)')
    assert_equal('`(1 (+ 1 1))', '(1 (+ 1 1))')
    assert_equal('`(1 ,(+ 1 1) ,(+ 2 2))', '(1 2 4)')
    assert_equal('`(,(+ 1 1) 1 ,(+ 2 2))', '(2 1 4)')
    assert_equal('`((1 2 3))', '((1 2 3))')
    assert_equal('`((1 ,(+ 1 1) 3))', '((1 2 3))')
    assert_equal('`(1 . 2)', '(1 . 2)')
    assert_equal('`(1 . ,(+ 1 1))', '(1 . 2)')
    assert_equal('`(,(+ 1 2) . ,(+ 1 1))', '(3 . 2)')
    assert_equal('`(1 ,@\'(2 3))', '(1 2 3)')
    assert_equal('`(1 ,@\'(2 3) 4)', '(1 2 3 4)')
    assert_equal('`(,@\'(2 3) 4)', '(2 3 4)')
    assert_equal('`(,@\'(2 3))', '(2 3)')
    assert_equal('`(,@(list 1 2))', '(1 2)')
    assert_equal('\'(,@(list 1 2))', '((unquote-splicing (list 1 2)))')
  end

  it 'does logics correctly' do
    assert_equal('(and #t #t)', '#t')
    assert_equal('(and #t #f)', '#f')
    assert_equal('(and #f #t)', '#f')
    assert_equal('(and 1 1)', '1')
    assert_equal('(and 0 0)', '0')
    assert_equal('(and 0 1)', '1')
    assert_equal('(and 0 "")', '""')
    assert_equal('(and "" 1)', '1')
    assert_equal('(and #f "")', '#f')
    assert_equal('(and "" #f)', '#f')
    # assert_equal('(and "" cdr)', eval('cdr'))
    assert_equal('(and \'() car)', '()')
    assert_equal('(and car \'())', '()')
    assert_equal('(and \'() #f)', '()')
    assert_equal('(and 1 2 3 4 5)', '5')
    assert_equal('(and 1 2 3 4 #f)', '#f')

    assert_equal('(or 1 2)', '1')
    assert_equal('(or #f 1)', '1')
    assert_equal('(or #f #f)', '#f')
    assert_equal('(or #f \'())', '()')
    assert_equal('(or "1" #f)', '"1"')
    assert_equal('(or #f #f)', '#f')
  end

  it 'supports cond' do
    assert_equal(<<'end', '1')
(cond
  ((= 1 1) 1))
end
    assert_equal(<<'end', '()')
(cond
  ((= 1 2) 1))
end
    assert_equal(<<'end', '1')
(cond
  (else 1))
end
    assert_equal(<<'end', '1')
(cond
  ((= 1 2) 2)
  (else 1))
end
    assert_equal(<<'end', '4')
(cond
  ((= 1 2) 1)
  ((= 3 2) 2)
  (#f 3)
  (else 4))
end
    assert_equal(<<'end', '2')
(cond
  (else (+ 1 1)))
end

  end

  it 'supports closures' do
    assert_equal(<<'end', '(15 15)')
(define gen_adder (lambda (x) (lambda (y) (+ x y))))
(define add3 (gen_adder 5))
(define add4 (gen_adder 4))
(list (add3 10) (add4 11))
end

    # Y combinator!
    assert_equal(<<'end', '10')
(((lambda (f) (f f))
  (lambda (a)
    (lambda (x)
      (if (= x 0) 0
	  (+ x ((a a) (- x 1))))))) 4)
end

  end


end


