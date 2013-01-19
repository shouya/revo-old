
require_relative 'context'
require_relative 'sexpr_eval'

module Revo
  class FunctionType
    attr_accessor :val
    def initialize(lambda_)
      @val = lambda_
    end
    def call(env = Context.global, args = nil)
      evaled_args = args.list? ? args.eval_chain(env) : args.eval(env)

      @val.call(env, evaled_args)
    end
  end

  class CustomFunctionType < FunctionType; end
  class BuiltInFunctionType < FunctionType;  end
end

