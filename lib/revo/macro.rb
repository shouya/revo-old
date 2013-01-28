



module Revo
  class MacroType < ValueClass
    def call(env = Context.global, args = NULL)
      @val.call(env, args)
    end
    alias_method :raw_call, :call
  end

  class BuiltInMacroType < MacroType; end
end


