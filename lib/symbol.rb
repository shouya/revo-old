

require_relative 'prim_types'
require_relative 'context'

module Revo
  class Symbol < Literal
    def inspect
      "#@val"
    end
    alias_method :to_s, :inspect

    def eval(env)
      env.lookup(@val)
    end
  end
end

