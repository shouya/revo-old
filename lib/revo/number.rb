# Revo::Number

require_relative 'data'

module Revo
  class Number < Data
    COMPLEX = 1
    REAL = 2
    FRACTION = 3

    attr_accessor :imag_part, :real_part
    attr_accessor :denominator, :numerator
    attr_accessor :type

    def initialize(init_hash)
      if init_hash.is_a? Integer
        @denominator = 1
        @numerator = init_hash
        @type = FRACTION
      elsif init_hash.is_a? Hash
        case init_hash[:type]
        when :real
          @type = REAL
          @numerator = init_hash[:value]
          @denominator = 1.0
        else
          ;
        end
      end
    end
    def zero?
      case @type
      when COMPLEX
        @real_part == 0 && @imag_part == 0
      when FRACTION, REAL
        @numerator == 0
      end
    end

    def imag_part
      return Number.new(0) unless @type == COMPLEX
      Number.new(:type => :real, :value => @imag_part)
    end

    def real_part
      case @type
      when COMPLEX
        Number.new(:type => :real, :value => @real_part)
      when REAL, FRACTION
        self.dup
      end
    end

    def rational?
      @type == RATIONAL
    end

    def integer?
      if @type == RATIONAL
        return @denominator == 1
      else
        tmp = real_part
        return tmp == tmp.round
      end
    end

    def real?
      @type != COMPLEX or @imag_part == 0
    end

    def complex?
      true
    end

    def number?
      true
    end

    def exact?
      @type == RATIONAL
    end

    def inexact?
      !exact?
    end

    def odd?
      assert(integer?)
      return to_ruby_number % 2 != 0
    end
    def even?
      !odd?
    end

    def positive?
      assert(real?)
      to_ruby_number > 0
    end
    def negative?
      assert(real?)
      to_ruby_number < 0
    end

    def reciprocal
      assert(real?)
      if @type == RATIONAL
        Number.new(:type => :rational,
                   :denominator => @numerator,
                   :numerator => @denominator)
      else
        Number.new(:type => :real,
                   :value => 1.0 / to_ruby_number)
      end
    end

    def to_ruby_number
      case @type
      when RATIONAL
        if @denominator == 1
          return @numerator
        end
        return Rational(@denominator, @numerator)
      when REAL
        return @numerator
      when COMPLEX
        if @imag_part == 0
          return @real_part
        end
        return Complex(@real_part, @imag_part)
      end
    end
    # impossible to run to here
    return 0
  end

  def abs
    assert(real?)
    if @type == RATIONAL
      return Number.new(:type => :rational,
                        :denominator => @denominator.abs,
                        :numerator => @numerator.abs);
    else
      return Number.new(:type => :real,
                        :value => to_ruby_number.abs)
    end
  end

  include Comparable
  def <=>(another)
    assert(real? && another.real?)

    to_ruby_number <=> another.to_ruby_number
  end

  def quotient(another)
    assert(integer? && another.integer?)
    to_ruby_number.to_i / to_ruby_number.to_i
  end
  def remainder(another)
    assert(integer? && another.integer?)
    to_ruby_number.to_i.abs % to_ruby_number.to_i.abs
  end
  def modulo(another)
    assert(integer? && another.integer?)
    to_ruby_number.to_i % to_ruby_number.to_i
  end

  def gcd(another)
    assert(integer?)
    to_ruby_number.to_i
      .gcd(another.to_ruby_number.to_i)
      .to_exact(exact? && another.exact?)
  end
  def lcm(another)
    assert(integer?)
    to_ruby_number.to_i
      .lcm(another.to_ruby_number.to_i)
      .to_exact(exact? && another.exact?)
  end

  def denominator
    assert(rational?)
    Number.new(:type => :integer,
               :value => @denominator)
  end
  def numerator
    assert(rational?)
    Number.new(:type => :integer,
               :value => @numerator)
  end

  def floor
    assert(real?)
    Number.new(:type => :integer,
               :value => to_ruby_number.floor).to_exact(exact?)
  end
  def ceiling
    assert(real?)
    Number.new(:type => :integer,
               :value => to_ruby_number.ceil).to_exact(exact?)
  end

  def round
    assert(real?)
    Number.new(:type => :integer,
               :value => to_ruby_number.round).to_exact(exact?)
  end
  def truncate
    assert(real?)
    Number.new(:type => :integer,
               :value => to_ruby_number.truncate).to_exact(exact?)
  end

  private
  def inexactify
    to_exact(false)
  end

  def to_exact(target = true)
    return self.dup if target == exact?
    if target
      assert(real?)
      exact_fraction = Fraction(to_ruby_number)
      Number.new(:type => :fraction,
                 :numerator => exact_fraction.numerator,
                 :denominator => exact_fraction.denominator)
    else
      Number.new(:type => :real,
                 :value => to_ruby_number.to_f)
    end
  end

end

module Revo::BuiltInFunctions
  include Revo

  def_procedure(:number?, "(obj)") do
    param[:obj].number?
  end
  def_procedure(:complex?, "(obj)") do
    param[:obj].complex?
  end
  def_procedure(:real?, "(obj)") do
    param[:obj].real?
  end
  def_procedure(:rational?, "(obj)") do
    param[:obj].rational?
  end
  def_procedure(:integer?, "(obj)") do
    param[:obj].integer?
  end

  def_procedure(:exact?, "(obj)") do
    param[:obj].exact?
  end
  def_procedure(:inexact?, "(obj)") do
    param[:obj].inexact?
  end
  def_procedure(:zero?, "(obj)") do
    param[:obj].zero?
  end
  def_procedure(:positive?, "(obj)") do
    param[:obj].positive?
  end
  def_procedure(:negative?, "(obj)") do
    param[:obj].negative?
  end
  def_procedure(:odd?, "(obj)") do
    param[:obj].odd?
  end
  def_procedure(:even?, "(obj)") do
    param[:obj].even?
  end

  def_procedure(:abs, "(obj)") do
    param[:obj].abs
  end

  def_procedure(:quotient, "(l r)") do
    param[:l].quotient(param[:r])
  end
  def_procedure(:remainder, "(l r)") do
    param[:l].remainder(param[:r])
  end
  def_procedure(:modulo, "(l r)") do
    param[:l].modulo(param[:r])
  end

  def_procedure(:floor, "(obj)") do
    param[:obj].floor
  end
  def_procedure(:ceiling, "(obj)") do
    param[:obj].ceiling
  end
  def_procedure(:round, "(obj)") do
    param[:obj].round
  end
  def_procedure(:truncate, "(obj)") do
    param[:obj].truncate
  end

end
