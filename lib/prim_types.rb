#
# Primitive Types of Revo
#


module Revo
  class EndOfList # '()
    class << self
      private :new
      public
      def instance
        @_singleton ||= new
      end
    end
    def to_s
      "NIL"
    end
  end

  class String
    attr_accessor :val
    def initialize(str)
      @val = str
    end
    def to_s
      "\"#@val\""
    end
  end

  class Symbol
    attr_accessor :val
    def initialize(symbol)
      @val = symbol
    end
    def to_s
      ":#@val"
    end
  end

  class Name
    attr_accessor :val
    def initialize(name)
      @val = name
    end
    def to_s
      @val
    end
  end

  class Number
    attr_accessor :val
    def initialize(num)
      @val = num
    end
    def to_s
      @val.to_s
    end
  end

  class Char
    attr_accessor :val
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

end