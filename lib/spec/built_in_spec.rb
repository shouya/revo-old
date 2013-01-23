
require_relative '../revo'

describe Revo do
  before :each do
    def parse(str)
      Revo::Parser.parse(str)
    end
    def eval(str)
      parser = Revo::Parser.new(Revo::Scanner.new.tap {|x| x.scan_string(str) })
      Revo::BuiltInFunctions.load_symbols(Revo::Context.global)
      parser.do_parse.eval(Revo::Context.global)
    end

    def assert_equal(estr, pstr)
      eval(estr).should == parse(pstr)
    end

    def p(*a); parse(*a); end
    def e(*a); eval(*a); end

  end

  it 'do arithmetic' do
    assert_equal('(+ 1 2 3)', '6')

    # TODO: support negative integer parsing
    #    assert_equal('(- 1)', '-1')
    assert_equal('(- 3 2 1)', '0')
    assert_equal('(* 3 3)', '9')
    assert_equal('(* 3)', '3')
    assert_equal('(/ 6 2)', '3')
  end

  it 'start a block' do
    assert_equal('(begin 1)', '1')
    assert_equal('(begin 1 2)', '2')
    assert_equal('(begin 1 (+ 1 1))', '2')
  end

  it 'support c{a,d}r' do
    assert_equal('(car \'(1 . 2))', '1')
    assert_equal('(car \'((1) . 2))', '(1)')
    assert_equal('(cdr \'(1 . 2))', '2')
    assert_equal('(cdr \'(1 2 3))', '(2 3)')
  end

  it 'support lambda' do
    assert_equal('((lambda (a) (+ a 1)) 1)',  '2')
    assert_equal('((lambda (a b) (+ a b)) 2 3)', '5')
    assert_equal("((lambda (a . b) (eval (cons '+ (cons a b)))) 1 2 3)", '6')
  end
  
end


