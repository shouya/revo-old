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
    class << self
      def eol_sexpr
        @eol_expr ||= SExpr.new(EndOfList.instance)
      end
    end


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
      !atom?
    end
    def atom?
      @next.nil?
    end
    def eol?
      (@val.is_a? EndOfList).tap {|x| p "#@val #{@val.class} #{x}"}
    end
    def endlist
      cons self.class.eol_sexpr
    end

    def to_s
      if atom?
        @val.inspect
      else
        "(#{to_list_string})"
      end
    end

    def each(&block)
      block.call self
      unless @next.nil? or @next.eol?
        @next.each(&block)
      end
    end

    protected
    def to_list_string
      # (1 2 3 . 4)
      #          ^
      if @next.nil?
        ". #{@val.to_s}"

      # (1 2 3)
      #      ^
      elsif @next.eol?
        "#{@val.to_s}"

      # (1 2 3)
      #    ^
      else
        "#{@val.inspect} #{@next.to_list_string}"
      end
    end

  end
end
