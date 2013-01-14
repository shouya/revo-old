
require_relative 'sexpr'
require_relative 'context'

class Revo::SExpr
  public
  def eval(env = Context.global)
    return SExpr.new(@val) if literal?
    return @val.eval if list?

    procedure = env.lookup(@val.val) if @val.is_a? Revo::Symbol

    case procedure
#    when Function
#    when Macro
    when BuiltInFunctionType
      evaled_args = @next.eval_chain(env)
      procedure.call(env, evaled_args)
#    when BuiltInMacro
#      procedure.call(env, @next).eval(env)
    end
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


