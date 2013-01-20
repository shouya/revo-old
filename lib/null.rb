

module Revo
  class NullClass
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

    def list?
      true
    end
    def atom?
      false
    end
    def is_true?
      false
    end
    def is_false?
      true
    end
    def null?
      true
    end

    # blackholes
    def each(*)
      NULL
    end
    def eval(*)
      NULL
    end
    def eval_chain(*)
      NULL
    end

  end

  NULL = NullClass.null
end

