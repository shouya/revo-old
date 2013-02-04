
require_relative 'value'

module Revo
  class Null < Value
    class << self
      def null
        @instance ||= new
      end

      private :new
    end

    def inspect
      '()'
    end
    alias_method :to_s, :inspect

    def ==(another)
      another.null?
    end

    def atom?
      false
    end
    def list?
      false
    end
    def is_true?
      false
    end

    def null?
      true
    end

    # Simulating List
    include Enumerable
    def each(*)
      NULL
    end
    def to_ruby_list(tail_truncate = true)
      tail_truncate and [] or [NULL]
    end
    def list_length
      0
    end
    def eval_chain(*)
      NULL
    end
    def eval(*)
      NULL
    end
    def apply(*)
      NULL
    end


  end

  NULL = Null.null
end

