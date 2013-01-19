
require_relative 'prim_types'
require_relative 'sexpr'
require_relative 'context'
require_relative 'function'
require_relative 'macro'
require_relative 'lambda'



module Revo::BuiltInFunctions

  class << self
    include Revo
    attr_reader :table

    def def_function(name, &block)
      @table ||= {}
      @table[name.to_s] = BuiltInFunctionType.new(proc2lambda(&block))
    end

    def def_macro(name, &block)
      @table ||= {}
      @table[name.to_s] = BuiltInMacroType.new(proc2lambda(&block))
    end

    def call(name, env, args)
      @table[name.to_s].call(env, args)
    end

    def load_symbols(context = Context.global)
      @table.each do |k,v|
        context.store(k, v)
      end
    end

    private
    def proc2lambda(&block)
      Object.new
        .tap {|x| x.define_singleton_method(:x_x, &block) }
        .method(:x_x).to_proc
    end
  end


  def_function(:+) do |env, args|
    return 0 if args.nil?
    sum = 0
    args.each do |x|
      sum += x.val
    end
    Number.new(sum)
  end
  def_function(:-) do |env, args|
    return 0 if args.nil?

    diff = args.car.val
    args.cdr.each do |x|
      diff -= x.val
    end
    Number.new(diff)
  end
  def_function(:*) do |env, args|
    return 0 if args.nil?
    prod = 1
    args.each do |x|
      prod *= x.val
    end
    Number.new(prod)
  end
  def_function(:/) do |env, args|
    return Number.new(0) if args.nil?
    quot = args.car.val
    args.cdr.each do |x|
      quot /= x
    end
    Number.new(quot)
  end
  def_function(:%) do |env, args|
    return Number.new(0) if args.nil?
    rem = args.car.val
    args.cdr.each do |x|
      rem %= x
    end
    Number.new(rem)
  end
  def_function(:'=') do |env, args|
    lhs = args.car
    rhs = args.cdr.car

    return Bool.new(lhs.val == rhs.val)
  end

  def_function(:car) do |env, args|
    args.car.car
  end
  def_function(:cdr) do |env, args|
    args.car.cdr
  end


  def_function(:write) do |env, args|
    case args.car
    when nil
      puts '()'
    else
      puts args.car.to_s
    end
    nil
  end


  def_macro(:quote) do |env, args|
    args.car
  end

  def_macro(:define) do |env, args|
    val = args.cdr.car.eval(env)
    Context.global.store(args.car.val, val)
    val
  end
  def_macro(:begin) do |env, args|
    lastval = nil
    args.each do |x|
      lastval = x.eval(env)
    end
    lastval
  end

  def_macro(:lambda) do |env, args|
    lamb_params = args.car
    lamb_body = SExpr.new(Revo::Symbol.new('begin'))
                            .cons(args.cdr)

    Lambda.new(lamb_params, lamb_body)
  end
  def_macro(:if) do |env, args|
    cond = args.car.eval(env)
    true_part = args.cdr.car
    false_part = args.cdr.cdr.car

    if cond.nil? or cond.is_false?
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

  def_macro(:let) do |env, args|
    vars = args.car
    body = SExpr.new(Revo::Symbol.new('begin')).cons(args.cdr)

    context = Context.new(env)
    vars.each do |x|
      context.store(x.car.val, x.cdr.car)
    end

    body.eval(context)
  end

end
