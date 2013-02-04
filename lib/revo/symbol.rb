

require_relative 'context'
require_relative 'data'

module Revo
  class Symbol < Data
    def inspect
      "#@val"
    end
    alias_method :to_s, :inspect

    def eval(env)
      env.lookup(@val)
    end
  end
end

