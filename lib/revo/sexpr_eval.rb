
require_relative 'sexpr'
require_relative 'context'

module Revo
  class WrongTypeToApply < RuntimeError; end

  class SExpr
    public
    def eval(env = Context.global)
      proc_ = car.eval(env)
#      unless proc_.code?
#        p proc_
#        raise RuntimeError
#      end
      proc_.apply(env, cdr)
    end

    def eval_chain(env)
      ary = to_ruby_list.map {|x| x.eval(env) }
      self.class.construct_list(ary)
    end

  end
end
