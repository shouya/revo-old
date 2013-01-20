

require_relative 'context'
require_relative 'value'

module Revo
  class Symbol < ValueClass
    def inspect
      "#@val"
    end
    alias_method :to_s, :inspect

    def eval(env)
      env.lookup(@val)
    end
  end
end

