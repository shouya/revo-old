#
# Runtime Context Introducing
#


class Revo::NameError < RuntimeError; end
class Revo::Context
  include Enumerable
  attr_accessor :parent
  attr_accessor :symbols

  class << self
    attr_accessor :global
    def global
      @global ||= self.new(nil)
    end
  end

  def initialize(parent = self.class.global)
    @symbols = {}
    @parent = parent
  end

  def store(name, data)
    @symbols[name] = data
  end

  def lookup(name)
    return @symbols[name] if @symbols.key? name
    return @parent.lookup(name) if @parent

    raise Revo::NameError, "Symbol '#{name}' is not found."
  end

  def lookup_context(name)
    return self if @symbols.key? name
    return @parent.lookup_context(name) if @parent

    return nil
#    raise Revo::NameError, "Symbol '#{name}' is not found."
  end

  def each(&block)
    if block_given?
      @symbols.each &block
    else
      @symbols.each
    end
  end

  def keys
    @symbols.keys
  end

  def snapshot
    return @parent.snapshot.merge(@symbols) if @parent
    @symbols
  end

  def clear
    @symbols.clear
  end
end



