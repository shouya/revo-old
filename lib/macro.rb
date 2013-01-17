



module Revo
  class BuiltInMacroType
    attr_accessor :val

    def initialize(lambda_)
      @val = lambda_
    end
    def call(env = Context.global, args = nil)
      @val.call(env, args)
    end

  end
end


