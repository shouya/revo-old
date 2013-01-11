#
# S expression nodes
#

require_relative 'prim_types'

module Revo
  class SExpr
    attr_accessor :next, :val

    def initialize(val = nil, next_ = nil)
      @val = val ? val : EndOfList.instance
      @next = next_
    end

    def cons(next_)
      @next = next_
      self
    end
    def list?
      val.is_a? SExpr
    end
    def atom?
      !list?
    end
    def eol?
      val.is_a? EndOfList
    end

    def inspect
      if @val.is_a? EndOfList
        @val.to_s
      else
        "(#{@val.inspect} . #{@next.inspect})"
      end
    end
    def to_s
      "(#{@val.inspect} #{@next.sub_to_s}"
    end

    protected
    def sub_to_s
      if eol?
        "\b)"
      else
        "#{@val.to_s} #{@next.sub_to_s}"
      end
    end

  end
end
