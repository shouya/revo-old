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
    def is_true?
      true
    end
    def is_false?
      false
    end

    def inspect
      "(#{to_list_string})"
    end
    alias_method :to_s, :inspect

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
      def @val.inspect ; '()'; end if @val.nil?

      if list_tail?
        "#{@val.inspect}"

      elsif pair_tail?
        "#{@val.inspect} . #{@next.inspect}"

      # (1 2 3)
      #    ^
      else
        "#{@val.inspect} #{@next.to_list_string}"
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
