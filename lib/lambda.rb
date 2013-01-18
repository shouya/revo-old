#
# Lambda function
#

class Revo::Lambda
  attr_accessor :body, :params

  def initialize(params, body)
    @params = params
    @body = body
  end

  def call(context = nil, args = nil)
    evaled_args = args.nil? ? nil : args.eval_chain(context)
    raw_call(context, evaled_args)
  end

  def raw_call(context = nil, args = nil)
    private_context = Context.new(context || Context.global)

    construct_args_hash(args).each do |k, v|
      private_context.store(k.val, v)
    end
    body.eval(private_context)
  end


  private
  def construct_args_hash(args)
    hsh = {}
    param_ptr = params
    arg_ptr = args

    while param_ptr
      hsh[param_ptr.val] = arg_ptr.car
      param_ptr = param_ptr.cdr
      arg_ptr = arg_ptr.cdr
    end

    hsh
  end

end
