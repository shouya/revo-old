
require_relative 'prim_types'
require_relative 'sexpr'
require_relative 'context'
require_relative 'function'
require_relative 'macro'



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

    diff = args.car
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
    return 0 if args.nil?
    quot = args.car
    args.cdr.each do |x|
      quot /= x
    end
    Number.new(quot)
  end
  def_function(:%) do |env, args|
    return 0 if args.nil?
    rem = args.car
    args.cdr.each do |x|
      rem %= x
    end
    Number.new(rem)
  end

  def_function(:car) do |env, args|
    args.car.car
  end
  def_function(:cdr) do |env, args|
    args.car.cdr
  end


  def_function(:write) do |env, args|
<<<<<<< Updated upstream
    puts args.car.to_s
    nil
=======
<<<<<<< Updated upstream
    puts args.val
    SExpr.new(args)
=======
    case args.car
    when nil
      puts '()'
    else
      puts args.car.to_s
    end
    nil
>>>>>>> Stashed changes
>>>>>>> Stashed changes
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
    
  end

end
