

require_relative 'macro'
require_relative 'lambda'

module Revo
  class UserMacro < Macro
    def call(env, args)
      check_arity(args)

      hash = self.class.transpose_param_arg(@params, args)

      ctx = Context.new(env)
      ctx.store_mass(hash)

      @body.eval(ctx).eval(env)
    end
  end

  def to_lambda
    UserLambda.new(Context.global, @body, @name)
  end
end
