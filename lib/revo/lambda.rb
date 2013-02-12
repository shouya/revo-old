
require_relative 'procedure'
require_relative 'user_macro'

module Revo
  class UserLambda < Procedure
    attr_accessor :binding

    def initialize(binding, *rest)
      @binding = binding

      super(*rest)
    end


    def call(env, args)
      check_arity(args)

      ctx = Context.new(@binding)
      args = args.eval_chain(env)
      hash = self.class.transpose_param_arg(@params, args)

      ctx.store_mass(hash)

      @body.eval(ctx)
    end

    def to_macro
      UserMacro.new(@params, @body, @name)
    end
  end
end
