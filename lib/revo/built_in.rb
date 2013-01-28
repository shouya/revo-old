
require_relative 'prim_types'
require_relative 'sexpr'
require_relative 'context'
require_relative 'function'
require_relative 'macro'
require_relative 'lambda'
require_relative 'parser.tab'


module Revo::BuiltInFunctions
  include Revo

  class << self
    include Revo
    attr_reader :table
    attr_reader :custom_func_table

    def def_function(name, &block)
      @table[name.to_s] = BuiltInFunctionType.new(proc2lambda(&block))
    end

    def def_macro(name, &block)
      @table[name.to_s] = BuiltInMacroType.new(proc2lambda(&block))
    end

    def def_custom_function(name, params_source, body_source)
      params = Parser.parse(params_source)
      body = Parser.parse(body_source)
      @table[name.to_s] = Lambda.new(params, body)
    end
    def def_custom_macro(name, params_source, body_source)
      params = Parser.parse(params_source)
      body = Parser.parse(body_source)
      @table[name.to_s] = Lambda.new(params, body, true)
    end
    def def_alias(new_name, old_name)
      @table[new_name.to_s] = @table[old_name.to_s]
    end


    def load_symbols(context = Context.global)
      @table.each do |k,v|
        context.store(k, v)
      end
    end

    private
    def proc2lambda(&block)
      @private_funcs ||= {
        :call => lambda {|name, env, args|
          BuiltInFunctions.table[name.to_s].raw_call(env, args)
        }
      }

      Object.new
        .tap {|x| x.define_singleton_method(:x_x, &block) }
        .tap {|x| @private_funcs
          .each {|k,v| x.define_singleton_method(k, &v) } }
        .method(:x_x).to_proc
    end

  end
  self.instance_variable_set(:@table, {})


  def_function(:+) do |env, args|
    sum = 0
    args.each do |x|
      sum += x.val
    end
    Number.new(sum)
  end
  def_function(:-) do |env, args|
    diff = args.car.val
    return Number.new(-diff) if args.cdr.null?

    args.cdr.each do |x|
      diff -= x.val
    end
    Number.new(diff)
  end
  def_function(:*) do |env, args|
    prod = 1
    args.each do |x|
      prod *= x.val
    end
    Number.new(prod)
  end
  def_function(:/) do |env, args|
    quot = args.car.val
    args.cdr.each do |x|
      quot /= x.val
    end
    Number.new(quot)
  end

  def_function(:'=') do |env, args|
    lhs = args.car
    rhs = args.cdr.car

    return Bool.new(lhs.val == rhs.val)
  end
  def_function(:<) do |env, args|
    lhs = args.car
    rhs = args.cdr.car

    return Bool.new(lhs.val < rhs.val)
  end
  def_custom_function(:<=, '(lhs rhs)', <<-'end')
    (or (= lhs rhs) (< lhs rhs))
  end
  def_custom_function(:>, '(lhs rhs)', <<-'end')
    (not (<= lhs rhs))
  end
  def_custom_function(:>=, '(lhs rhs)', <<-'end')
    (not (< lhs rhs))
  end

  def_function(:car) do |env, args|
    args.car.car
  end
  def_function(:cdr) do |env, args|
    args.car.cdr
  end


  def_function(:display) do |env, args|
    unless args.null?
      print args.car.to_s
    end
    NULL
  end


  def_macro(:quote) do |env, args|
    args.car
  end

  def_macro(:define) do |env, args|
    name = args.car.val
    val = args.cdr.car.eval(env)
    #    Context.global.lookup(name)
    Context.global.store(name, val)
    val
  end
  def_macro(:'set-car!') do |env, args|
    name = args.car.val
    orig_context = env.lookup_context(name)
    val = orig_context.lookup(name)
    new_val = SExpr.new(args.cdr.car.eval(env)).cons(val.cdr)

    orig_context.store(name, new_val)
    NULL
  end
  def_macro(:'set-cdr!') do |env, args|
    name = args.car.val
    orig_context = env.lookup_context(name)
    val = orig_context.lookup(name)
    new_val = SExpr.new(val.car).cons(args.cdr.car.eval(env))

    orig_context.store(name, new_val)
    NULL
  end

  def_macro(:begin) do |env, args|
    lastval = NULL

    args.each do |x|
      lastval = x.eval(env)
    end
    lastval
  end

  def_macro(:lambda) do |env, args|
    lamb_params = args.car
    lamb_body = SExpr.new(Revo::Symbol.new('begin')).cons(args.cdr)

    Lambda.new(lamb_params, lamb_body)
  end
  def_macro(:if) do |env, args|
    cond = args.car.eval(env)
    true_part = args.cdr.car
    false_part = args.cdr.cdr.car

    if cond.is_false?
      false_part.eval(env)
    else
      true_part.eval(env)
    end
  end

  def_macro(:'define-macro') do |env, args|
    lambda_ = args.cdr.car.eval(env)
    lambda_.is_macro = true
    Context.global.store(args.car.val, lambda_)
    lambda_
  end

  def_function(:cons) do |env, args|
    SExpr.new(args.car).cons(args.cdr.car)
  end
  def_function(:list) do |env, args|
    args
  end

  def_function(:eval) do |env, args|
    args.car.eval(env)
  end
  def_function(:'type-of') do |env, args|
    type = case args.car
           when NULL
             'null'
           when Revo::String
             'string'
           when Revo::Symbol
             'symbol'
           when Revo::Bool
             'bool'
           when Revo::Number
             'number'
           when Revo::SExpr
             'list'
           when Revo::MacroType
             'macro'
           when Revo::FunctionType
             'function'
           when Revo::Lambda
             'lambda'
           else
             'unknown'
           end
    Revo::Symbol.new(type)
  end

  def_macro(:let) do |env, args|
    named_let = nil
    if args.car.atom?
      named_let = args.car.val
      args = args.cdr
    end
    vars = args.car
    body = SExpr.new(Revo::Symbol.new('begin')).cons(args.cdr)

    context = Context.new(env)
    params = []
    vars.each do |x|
      params << x.car unless named_let.nil?
      context.store(x.car.val, x.cdr.car.eval(env))
    end unless vars.null?

    unless named_let.nil?
      context.store(named_let,
                    Lambda.new(SExpr.construct_list(params), body))
    end

    body.eval(context)
  end
  def_macro(:'let*') do |env, args|
    vars = args.car
    body = SExpr.new(Revo::Symbol.new('begin')).cons(args.cdr)

    context = Context.global
    vars.each do |x|
      context = Context.new(context)
      context.store(x.car.val, x.cdr.car.eval(context))
    end unless vars.null?

    body.eval(context)
  end
  def_macro(:letrec) do |env, args|
    vars = args.car
    body = SExpr.new(Revo::Symbol.new('begin')).cons(args.cdr)

    context = Context.new(env)
    vars.each do |x|
      context.store(x.car.val, x.cdr.car.eval(context))
    end unless vars.null?

    body.eval(context)
  end
  def_macro(:'fluid-let') do |env, args|
    tmp_area = Context.new(nil)

    keys = []; args.car.each {|x| keys << x.car.val }
    vals = []; args.car.each {|x| vals << x.cdr.car.eval(env) }
    keys.zip(vals).each do |k,v|
      tmp_area.store(k, Context.global.lookup(k))
      Context.global.store(k, v)
    end

    retval = call(:let, env, SExpr.new(NULL).cons(args.cdr))

    tmp_area.each do |k, v|
      Context.global.store(k, v)
    end
    retval
  end

  def_function(:newline) do |env, args|
    puts
    NULL
  end
  def_function(:not) do |env, args|
    if args.car.is_true?
      Bool.new(false)
    else
      Bool.new(true)
    end
  end
  def_macro(:or) do |env, args|
    result = nil
    args.each do |x|
      result = x.eval(env)
      return result if result.is_true?
    end
    result
  end
  def_macro(:and) do |env, args|
    result = nil
    args.each do |x|
      result = x.eval(env)
      return result if result.is_false?
    end
    result
  end
  def_function(:map) do |env, args|
    proc = args.car
    lists = args.cdr
    rubified_lists = []

    lists.each do |x|
      tmp = []
      x.each {|xx| tmp << xx }
      rubified_lists << tmp
    end

    pairs = rubified_lists.first
      .zip(*rubified_lists[1..-1]).map {|x| SExpr.construct_list(x) }

    new_list = SExpr.new(Revo::Symbol.new('head'))
    new_list_head = new_list

    pairs.each do |x|
      new_list.cons(SExpr.new(proc.call(env, x)))
      new_list = new_list.cdr
    end
    new_list_head.cdr
  end
  def_function(:'for-each') do |env, args|
    call(:map, env, args)
    NULL
  end

  def_custom_macro(:when, '(cond . body)', <<-'end')
    (eval (list 'if cond (cons 'begin body) ''()))
  end
  def_custom_macro(:unless, '(cond . body)', <<-'end')
    (eval (list 'if cond ''() (cons 'begin body)))
  end
  def_custom_function(:!=, '(lhs rhs)', <<-'end')
    (not (= lhs rhs))
  end
  def_custom_function(:'+1', '(op)', <<-'end')
    (+ 1 op)
  end
  def_custom_function(:reverse, '(s)', <<-'end')
    (let loop ((s s) (r '()))
      (if (null? s) r
	  (let ((d (cdr s)))
            (set-cdr! s r)
	    (loop d s))))
  end
  def_custom_function(:null?, '(op)', <<-'end')
    (= (type-of op) 'null)
  end
  def_function(:quit) do |env, args|
    exit
    nil
  end

  def_function(:'fold-left') do |env, args|
    func = args.car
    initval = args.cdr.car
    list = args.cdr.cdr.car

    list.inject(initval) do |a,b|
      func.call(env, SExpr.construct_list([a, b]))
    end
  end

  def_function(:'fold-right') do |env, args|
    func = args.car
    initval = args.cdr.car
    list = args.cdr.cdr.car

    list.to_a.reverse.inject(initval) do |a,b|
      func.call(env, SExpr.construct_list([b, a]))
    end
  end

  def_macro(:quasiquote) do |env, args|
    unquote = lambda do |arg|
      if arg.is_a? SExpr
        v = arg.val
        if v.is_a? Symbol and v.val == 'unquote'
          return arg.cdr.car.eval(env)
        elsif v.is_a? SExpr
          if v.val.is_a? Symbol and v.val.val == 'unquote-splicing'
            return v.cdr.car.eval(env).tap do |x|
              x = x.next until x.next.null?
              x.next = unquote.call(arg.cdr)
            end
          else
            v = SExpr.new(unquote.call(v))
          end
        else
          v = SExpr.new(v)
        end
        v.cons(unquote.call(arg.cdr))
      else
        arg
      end # end of if arg.is_a? SExpr
    end # end of lambda

    unquote.call(args.car)
  end

  def_alias(:progn, :begin)
  def_alias(:exit, :quit)

  def_function(:'debug-format') do |env, args|
    String.new(args.car.inspect)
  end
end