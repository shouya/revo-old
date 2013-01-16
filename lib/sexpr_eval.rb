
require_relative 'sexpr'
require_relative 'context'

class Revo::SExpr
  public
  def eval(env = Context.global)
    proc_ = car.eval(env)
    proc_.call(env, cdr)
  end

  def eval_chain(env)
    return SExpr.new(@val.eval(env)) if list_tail?
    #    return SExpr.new(@val.eval(env)).cons(@next.eval(env)) if pair_tail?

    SExpr.new(@val.eval(env)).cons(@next.eval_chain(env))
  end

end


