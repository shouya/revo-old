
require_relative 'sexpr'
require_relative 'context'

module Revo
  class SExpr
    public
    def eval(env = Context.global)
      proc_ = car.eval(env)
      proc_.call(env, cdr)
    end

    def eval_chain(env)
      return SExpr.new(car.eval(env)) if list_tail?
      #    return SExpr.new(@val.eval(env)).cons(@next.eval(env)) if pair_tail?

      SExpr.new(car.eval(env)).cons(cdr.eval_chain(env))
    end

  end
end
