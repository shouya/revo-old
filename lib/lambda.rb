#
# Lambda function
#

class Revo::Lambda
  attr_accessor :body, :params, :is_macro

  def initialize(params, body, is_macro = false)
    @params = params
    @body = body
    @is_macro = is_macro
  end

  def call(context = nil, args = nil)
    evaled_args = if is_macro
                    args
                  else
                    args.nil? ? nil : args.eval_chain(context)
                  end
    private_context = Context.new(context || Context.global)

    construct_args_hash(evaled_args).each do |k, v|
      private_context.store(k.val, v)
    end
    body.eval(private_context)
  end


  private
  def construct_args_hash(args)
    hsh = {}
    param_ptr = params
    arg_ptr = args

    loop do
      break if param_ptr.nil?
      if param_ptr.atom?
        hsh[param_ptr] = arg_ptr
        break
      end

      hsh[param_ptr.val] = arg_ptr.car
      param_ptr = param_ptr.cdr

      arg_ptr = arg_ptr.cdr
    end

    hsh
  end

end
