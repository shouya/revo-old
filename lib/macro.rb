



module Revo
  class MacroType
    attr_accessor :val

    def initialize(lambda_)
      @val = lambda_
    end
    def call(env = Context.global, args = nil)
      @val.call(env, args)
    end
    alias_method :raw_call, :call
  end

  class BuiltInMacroType < MacroType; end
end


