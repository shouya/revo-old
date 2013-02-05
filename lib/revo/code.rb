#
#
# Code  ----|>  Value
#
#

require_relative 'value'

module Revo
  class InvalidParameters < RuntimeError; end
  class Code < Value
    def code?
      true
    end

    attr_accessor :name, :params, :body, :arity

    def initialize(params, body, name = nil)
      check_params(params)

      @params = params
      @body = body
      @name = name

      @arity = self.class.calculate_arity(params)
    end

    def self.raw_new
      allocate
    end

    def apply(env, args)
      call(env, args)
    end

    def call(env, args)
      raise RuntimeError  # unknown code type instance called
    end

    def check_arity(args)
      arg_len = args.list_length
      unless self.class.check_arity_compatibility(arg_len, @arity)
        self.class.report_arity_mismatch(arg_len, @arity)
      end
    end

    def check_params(params)
      return if params.atom? and params.is_a? Symbol
      prm = params.to_ruby_list(false)
      prm = prm[0..-2] if prm.last.null?
      raise InvalidParameters unless prm.all? {|x| x.atom? and x.is_a? Symbol }
      prm.map(&:val).reject {|x| x == '_'}.sort
        .tap {|x| raise InvalidParameters unless x.uniq.length == x.length }
      nil
    end

  end


  class ArityMismatchError < RuntimeError; end
  module CodeUtilities
    def calculate_arity(params)
      return -1 if params.atom?
      prm = params.to_ruby_list(false)
      case
      when prm.length == 1 then 0
      when prm.last.null?  then prm.length - 1
      when prm.last.atom?  then -prm.length
      else raise RuntimeError # should never run to there
      end
    end

    def check_arity_compatibility(given, accepted)
      if accepted >= 0 && given == accepted or
          accepted < 0 && given >= -(accepted + 1)
        return true
      end
      false
    end

    def format_arity_string(arity)
      case
      when arity == 0 then '0'
      when arity < 0 then "#{-(arity + 1)}+"
      when arity > 0 then arity.to_s
      end
    end

    def report_arity_mismatch(given, accepted)
      msg = "wrong number of arguments (#{given} for " <<
        "#{format_arity_string(accepted)})"
      raise ArityMismatchError, msg
    end

    def transpose_param_arg(params, args)
      # test basis
      # params          args          expected result
      #  a b            1 2           a: 1, b: 2
      #  a . b          1 2           a: 1, b: (2)
      #  a . b          1             a: 1, b: ()
      #  a . b          1 2 3         a: 1, b: (2 3)
      #  a              1 2 3         a: (1 2 3)
      #  a b c          1 2 3         a: 1, b: 2, c: 3
      #  a a c          1 2 3         a: 2, c: 3
      #  _ _ c          1 2 3         c: 3
      #  _ . _          1 2 3         ; nothing

      if params.atom?
        return ({}) if params.val == '_'
        return ({ params.val => args })
      end

      hash = {}
      prm  = params.to_ruby_list(false)
      argx = args.to_ruby_list

      if prm.last.atom?
        var_len = argx.length - prm.length + 1
        var_len_list = SExpr.construct_list(argx.pop(var_len))
        key = prm.last.val

        hash.merge!({key => var_len_list}) unless key == '_'
      end
      prm.pop

      # till here prm.length should == argx.length

      hash.merge!(Hash[prm.map(&:val).zip(argx)])
      hash
    end
  end

  module PrimitiveCodeHelpers
    class AssertionFailure < RuntimeError; end

    def assert(expr)
      raise AssertionFailure unless expr
    end

    def call_proc(proc_name, env, args)
      env.lookup(proc_name.to_s).call(env, args)
    end

    def cons(car, cdr)
      SExpr.new(car).cons!(cdr)
    end
    def list(*eles)
      SExpr.construct_list(eles)
    end

    def quote(val)
      SExpr.construct_list([Symbol.new('quote'), val])
    end
    def begin_cons(exprs)
      SExpr.new(Symbol.new('begin')).cons!(exprs)
    end
  end

  Code.extend(CodeUtilities)
end
