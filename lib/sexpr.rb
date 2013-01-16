#
# S expression nodes
#
#
# An s-expression is classically defined[1] inductively as
#   1. an atom, or
#   2. an expression of the form (x . y) where x and y are s-expressions.
# (source: Wikipedia)
#


require_relative 'prim_types'

module Revo
  class SExpr
    include ValueMethods
    attr_accessor :next, :val

    def initialize(val = nil, next_ = nil)
      @val = val
      @next = next_
    end

    def cons(next_)
      @next = next_
      self
    end

    def atom?
      false
    end

    def to_s
      "(#{to_list_string})"
    end

    protected
    def to_list_string
      # (1 2 3)
      #      ^
      if @next.nil?
        "#{@val.to_s}"

      # (1 2 3 . 4)     or (1 2 3 . (1 2))
      #      ^                  ^
      elsif @next.atom? or @next.next.nil?
        "#{@val.to_s} . #{@next.to_s}"

      # (1 2 3)
      #    ^
      else
        "#{@val.to_s} #{@next.to_list_string}"
      end
    end

  end
end
