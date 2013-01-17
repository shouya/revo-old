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
    def list?
      true
    end

    def to_s
      "(#{to_list_string})"
    end

    def car
      @val
    end

    def cdr
      @next
    end

    def each(&block)
      yield @val

      return if list_tail?
#      raise 'cannot `each` a pair' if pair_tail?

      @next.each(&block)
    end

    protected
    def to_list_string
      if list_tail?
        "#{@val.to_s}"

      elsif pair_tail?
        "#{@val.to_s} . #{@next.to_s}"

      # (1 2 3)
      #    ^
      else
        "#{@val.to_s} #{@next.to_list_string}"
      end
    end

    def list_tail?
      # (1 2 3)
      #      ^
      @next.nil?
    end
    def pair_tail?
      # (1 2 3 . 4)
      #      ^                  ^
      @next.atom?   # or @next.next.nil?

      # Not (1 2 3 . (1 2)), since it equals to:
      #     (1 2 3 1 . 2)
    end

  end
end
