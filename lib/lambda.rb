#
# Lambda function
#

class Revo::Lambda
  attr_accessor :body, :params

  def call(context = nil, args = nil)
    private_context = Context.new(context || Context.global)

    private_context.store_lambda_args(construct_args_hash(args))
    body.eval(private_context)
  end

  private
  def construct_args_hash(args)
    hsh = {}
    param_ptr = params
    arg_ptr = args

    while param_ptr
      break if param_ptr.eol?

      # (name . body)
      #         ^      deal with this kind of args
      if param_ptr.next.nil?
        hsh[param_ptr.val] = arg_ptr
      end

      arg_ptr = arg_ptr.next
      param_ptr = param_ptr.next
    end
  end

end
