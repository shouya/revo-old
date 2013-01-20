#
# Runtime Context Introducing
#

class Revo::Context
  include Enumerable
  attr_accessor :parent
  attr_accessor :symbols

  class << self
    attr_accessor :global
    def global
      @global ||= Context.new(nil)
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

    # TODO: Create a custom exception class
    raise "Symbol '#{name}' is not found."
  end

  def lookup_context(name)
    return self if @symbols.key? name
    return @parent.lookup_context(name) if @parent

    raise "Symbol '#{name}' is not found."
  end

  def each(&block)
    if block_given?
      @symbols.each &block
    else
      @symbols.each
    end
  end
end



