
require_relative 'macro'
require_relative 'prim_proc'

module Revo
  class PrimitiveMacro < Macro
    def call(env, args)
      check_arity(args)

      ctx = Context.new(env)

      hash = self.class.transpose_param_arg(@params, args)
      hash = hash.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}

      Object.new
        .tap {|x| x.singleton_class.send :define_method, :'_xxx_', &@body }
        .tap {|x| x.singleton_class.send(:include, PrimitiveCodeHelpers) }
        .tap {|x| x.singleton_class.send(:define_method, :param) { hash } }
        .tap {|x| return (@body.arity == 1 ? x._xxx_(ctx) : x._xxx_) }
    end

    def to_prim_proc
      PrimitiveProcedure.new(@params, @body, @name)
    end
  end

end
