#
# Primitive Types of Revo
#


module Revo
  module ValueMethods
    def list?
      !atom?
    end
  end
  class String
    include ValueMethods
    attr_accessor :val
    def initialize(str)
      @val = str
    end
    def to_s
      "\"#@val\""
    end
    def atom?
      true
    end
  end

  class Symbol
    include ValueMethods
    attr_accessor :val
    def initialize(symbol)
      @val = symbol
    end
    def to_s
      "'#@val"
    end
    def atom?
      true
    end
  end

  class Number
    include ValueMethods
    attr_accessor :val
    def initialize(num)
      @val = num
    end
    def to_s
      @val.to_s
    end
    def atom?
      true
    end
  end

  # Not supported yet.
  class Char
    include ValueMethods
    attr_accessor :val
    def initialize(chr)
      if chr.is_a? Integer
        @val = chr
      else
        @val = chr[0].ord
      end
    end
    def to_s
      # TODO: Give a suitable represence for char
    end
    def atom?
      true
    end
  end

  class BuiltInFunctionType
    attr_accessor :val
    def initialize(lambda_)
      @val = lambda_
    end
    def call(env = Context.global, args = SExpr.eol_sexpr)
      evaled_args = args.eval_chain(env)
      @val.call(env, args)
    end
  end

  class BuiltInMacroType
    attr_accessor :val
    def initialize(lambda_)
      @val = lambda_
    end
    def call(env = Context.global, args = SExpr.eol_sexpr)
      @val.call(env, args)
    end
  end

end
