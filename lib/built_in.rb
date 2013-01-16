
require_relative 'prim_types'
require_relative 'sexpr'
require_relative 'context'
require_relative 'function'


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

  def_function(:write) do |env, args|
    puts args.val.to_s
    nil
  end

  def_macro(:quote) do |env, args|
    SExpr.new(args.val)
  end
end
