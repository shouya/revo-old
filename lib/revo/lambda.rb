#
# Lambda function
#

require_relative 'value'

class Revo::Lambda < Revo::ValueClass
  include Revo
  attr_accessor :body, :params, :is_macro, :binding

  def initialize(binding, params, body, is_macro = false)
    @binding = binding
    @params = params

    @body = body
    @is_macro = is_macro
  end

  def call(context = nil, args = NULL)
    private_context = Context.new(context || Context.global)

    @binding.each do |k, v|
      private_context.store(k, v)
    end

    evaled_args = is_macro ? args : args.eval_chain(context)

    construct_args_hash(evaled_args).each do |k, v|
      private_context.store(k.val, v)
    end
    body.eval(private_context)
  end

  def to_s
    "<lambda \#(0x#{self.object_id.to_i.to_s(16)})>"
  end
  alias_method :inspect, :to_s

  def val
    {
      :params => @params,
      :body => @body,
      :is_macro => @is_macro
    }
  end

  private
  def construct_args_hash(args)
    hsh = {}
    param_ptr = params
    arg_ptr = args

    loop do
      if param_ptr.atom?
        hsh[param_ptr] = arg_ptr
        break
      end
      break if param_ptr.null?

      hsh[param_ptr.val] = arg_ptr.car
      param_ptr = param_ptr.cdr

      arg_ptr = arg_ptr.cdr
    end

    hsh
  end

end
