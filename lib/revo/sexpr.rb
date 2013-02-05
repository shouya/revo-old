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
require_relative 'null'
require_relative 'vector'

module Revo

  class InvalidPairError < RuntimeError; end
  class SExpr < Data
    class << self
      def construct_list(array, add_null_tail = true)
        val_ary = array
        val_ary << NULL if add_null_tail

        list = val_ary[-1]
        val_ary[0..-2].reverse_each do |x|
          list = SExpr.new(x).cons!(list)
        end
        list
      end
    end

    attr_accessor :next, :val

    def initialize(val = nil, next_ = NULL)
      @val = val
      @next = next_
    end

    def ==(another)
      return false unless another.is_a? SExpr
      @val == another.val and @next == another.next
    end

    def cons!(next_)
      @next = next_
      self
    end

    def atom?
      false
    end
    def is_true?
      true
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

    include Enumerable
    def each(truncate_tail = true, &block)
      return to_ruby_list(truncate_tail).each unless block_given?
      to_ruby_list(truncate_tail).each(&block)
    end

    def list_tail?
      # (1 2 3) === (1 2 3 . ())
      #      ^           ^
      @next.null?
    end
    def pair_tail?
      # (1 2 3 . 4)
      #      ^
      @next.atom?
    end


    def to_ruby_list(tail_truncate = true)
      iter = self
      result_list = []

      until iter.null? or iter.atom?
        result_list << iter.val
        iter = iter.next
      end

      if tail_truncate
        raise InvalidPairError if iter.atom?
      else
        result_list << iter
      end

      result_list
    end

    def list_length
      to_ruby_list(true).count
    end

    def append!(tail)
      tail_node.next = SExpr.new(tail).cons!(NULL)
      self
    end

    def type_string
      'list'
    end

    def to_vector
      Vector.new(to_ruby_list)
    end

    protected
    def to_list_string
      if pair_tail?
        "#{@val.inspect} . #{@next.inspect}"
      elsif list_tail?
        "#{@val.inspect}"
      else
        "#{@val.inspect} #{@next.to_list_string}"
      end
    end

    def tail_node
      iter = self
      iter = iter.next while iter.next.list?
      raise InvalidPairError if iter.next.atom?
      iter
    end

  end
end
