

require_relative 'procedure'
require_relative 'prim_macro'

module Revo
  class PrimitiveProcedure < Procedure
    def call(env, args)
      check_arity(args)

      ctx = Context.new(env)

      args = args.eval_chain(env)
      hash = self.class.transpose_param_arg(@params, args)
      hash = hash.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}

      Object.new
        .tap {|x| x.singleton_class.send :define_method, :'_xxx_', &@body }
        .tap {|x| x.singleton_class.send(:include, PrimitiveCodeHelpers) }
        .tap {|x| x.singleton_class.send(:define_method, :param) { hash } }
        .tap {|x| return (@body.arity == 1 ? x._xxx_(ctx) : x._xxx_) }

      # ^.tap {|x| hash.each {|k,v| x.singleton_class.define_method(:k) {v} }}
    end

    def to_macro
      PrimitiveMacro.new(@params, @body, @name)
    end
  end
end
