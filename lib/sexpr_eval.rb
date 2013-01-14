
require_relative 'sexpr'
require_relative 'context'

class Revo::SExpr
  def eval(env = Context.global)
    procedure = @val.eval(env)
    procedure.call(@next)
  end
end
