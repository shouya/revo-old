#
# Primitive Types of Revo
#


module Revo
  class Literal
    attr_accessor :val
    def initialize(val)
      @val = val
    end
    def atom?
      true
    end
    def list?
      false
    end
    def is_true?
      true
    end
    def is_false?
      !is_true?
    end

    def eval(_)
      self
    end
  end

  class String < Literal
    def to_s
      "\"#@val\""
    end
  end

  class Number < Literal
    def to_s
      @val.to_s
    end
  end

  # Not supported yet.
  class Char < Literal
    def initialize(chr)
      if chr.is_a? Integer
        @val = chr
      else
        @val = chr[0].ord
      end
    end
    def to_s
      # TODO: Give a suitable represence for char
    end
  end
  class Bool < Literal
    def is_true?
      @val
    end
    def to_s
      if @val
        "#t"
      else
        "#f"
      end
    end
  end

end
