
require_relative 'context'
require_relative 'sexpr_eval'

module Revo
  class FunctionType
    attr_accessor :val
    def initialize(lambda_)
      @val = lambda_
    end
    def raw_call(env = Context.global, args = nil)
      @val.call(env, args)
    end
    def call(env = Context.global, args = nil)
      evaled_args = args.nil? ? nil : args.eval_chain(env)
      @val.call(env, evaled_args)
    end
  end

  class CustomFunctionType < FunctionType; end
  class BuiltInFunctionType < FunctionType;  end
end

