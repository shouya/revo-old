
require_relative 'context'
require_relative 'sexpr_eval'
require_relative 'value'

module Revo
  class FunctionType < ValueClass
    def raw_call(env = Context.global, args = NULL)
      @val.call(env, args)
    end
    def call(env = Context.global, args = NULL)
      evaled_args = args.eval_chain(env)
      @val.call(env, evaled_args)
    end
  end

  class CustomFunctionType < FunctionType; end
  class BuiltInFunctionType < FunctionType;  end
end

