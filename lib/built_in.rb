
require_relative 'prim_types'
require_relative 'sexpr'
require_relative 'context'


module Revo::BuiltInFunctions

  class << self
    include Revo
    attr_reader :table

    def def_function(name, &block)
      @table ||= {}
      @table[name.to_s] = BuiltInFunctionType.new(proc2lambda(&block))
    end

    def def_macro(name, &block)
      # TODO: finish this function
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
    sum = 0
    args.each do |x|
      sum += x.val
    end
    SExpr.new(sum)
  end

  def_function(:write) do |env, args|
    puts args.val
    SExpr.new(args.val)
  end
end
