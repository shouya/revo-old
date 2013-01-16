
require_relative 'sexpr'
require_relative 'context'

class Revo::SExpr
  public
  def eval(env = Context.global)
    case @val
    when Revo::Number, Revo::String
      SExpr.new(@val)
    when Revo::Symbol
      SExpr.new(env.lookup(@val.val))
    end
    return self if eol?
    return SExpr.new(@val) if literal?
    return env.lookup(@val.val) if @val.is_a? Revo::Symbol

#    return @val.eval(env) if @val.is_a?(SExpr) && @val.list?

    procedure = env.lookup(@val.val) if @val.is_a? Revo::Symbol

    procedure.call(env, @next)
  end

  def eval_chain(env)
    return SExpr.new(eval(env)) if @next.nil?
    return SExpr.eol_sexpr if @val.is_a? EndOfList

    eval(env).cons(@next.eval_chain(env))
  end

  def literal?
    [Number, String, Char].any? {|x| @val.is_a? x }
  end
end


