
require_relative 'data'
require_relative 'sexpr'

module Revo
  class Vector < Data
    def to_list
      SExpr.construct_list(@val)
    end

    include Enumerable
    def each(&blk)
      @val.each(&blk)
    end

    def [](*args)
      @val[*args]
    end
    alias_method :ref, :[]

    def to_s
      "[#{@val.map(&:to_s).join(' ')}]"
    end
    alias_method :inspect, :to_s
  end
end
