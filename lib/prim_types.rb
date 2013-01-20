#
# Primitive Types of Revo
#

require_relative 'value'

module Revo
  class String < ValueClass
    def to_s
      @val
    end
  end

  class Number < ValueClass
    def to_s
      @val.to_s
    end
  end

  # Not supported yet.
  class Char < ValueClass
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
  class Bool < ValueClass
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
