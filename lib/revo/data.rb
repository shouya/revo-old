#
#
# Data  ----|>  Value
#
#

require_relative 'value'

module Revo
  class Data < Value
    def code?
      false
    end

    attr_accessor :val
    def initialize(val)
      @val = val
    end

    def eval(_)
      self
    end

    def ==(another)
      @val == another.val
    end

    def to_s
      @val.to_s
    end
    def inspect
      @val.inspect
    end
  end
end

