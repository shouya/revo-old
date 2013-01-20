

module Revo
  class ValueClass
    attr_accessor :val
    def initialize(val)
      @val = val
    end
    def atom?
      true
    end
    def list?
      !atom?
    end
    def is_true?
      true
    end
    def is_false?
      !is_true?
    end

    def null?
      false
    end

    def inspect
      @val.inspect
    end
    def to_s
      @val.to_s
    end

    def eval(_)
      self
    end
  end
end
