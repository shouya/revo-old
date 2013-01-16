

require_relative 'prim_types'
require_relative 'context'

module Revo
  class Symbol < Literal
    def to_s
      "#@val"
    end

    def eval(env)
      env.lookup(@val)
    end
  end
end

