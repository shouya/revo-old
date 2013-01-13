#
# Runtime Context Introducing
#

class Revo::Context
  attr_accessor :parent
  attr_accessor :symbols

  class << self
    attr_accessor :global
    def global
      @global ||= Context.new
    end
  end

  def initialize(parent = self.class.global)
    @symbols = []
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

  def store_lambda_args(hsh)
    hsh.each do |k,v|
      store(k, v)
    end
  end
end



