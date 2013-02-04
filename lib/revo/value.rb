

module Revo
  class Value
    def atom?
      true
    end
    def list?
      !atom?
    end
    alias_method :pair?, :list?
    def is_true?
      true
    end
    def is_false?
      !is_true?
    end

    def code?
      false
    end
    def data?
      !code?
    end

    def null?
      false
    end

    def ==(another)
      raise RuntimeError, "Not implmented `==' for" <<
        " #{inspect}::#{self.class.to_s}"
    end

    def inspect
      "unimplemented 'inspect' for <#{self.class.to_s}::#{self.object_id}>"
    end
    def to_s
      "unimplemented 'to_s' for <#{self.class.to_s}::#{self.object_id}>"
    end

    def type_string
      self.class.to_s
        .sub(/.*::/, '')
        .each_char.inject('') {|s,x| s << (x=~/[a-z]/ ? x : "-#{x.downcase}")}
        .sub(/^-/, '')
    end
  end
end
