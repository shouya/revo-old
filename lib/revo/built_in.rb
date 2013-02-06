
require_relative 'prim_types'
require_relative 'sexpr'
require_relative 'context'
require_relative 'macro'
require_relative 'lambda'
require_relative 'parser.tab'
require_relative 'code'
require_relative 'procedure'
require_relative 'prim_proc'
require_relative 'prim_macro'


module Revo::BuiltInFunctions
  include Revo

  class << self
    include Revo
    attr_reader :table
    attr_reader :custom_func_table
    attr_reader :helpers

    def def_procedure(name, params, &block)
      @table[name.to_s] = PrimitiveProcedure.new(Parser.parse(params),
                                                 block, name.to_s)
    end

    def def_macro(name, params, &block)
      @table[name.to_s] = PrimitiveMacro.new(Parser.parse(params),
                                             block, name.to_s)
    end

    def def_lambda(name, params_source, body_source)
      params = Parser.parse(params_source)
      body = Parser.parse(body_source)
      @table[name.to_s] = UserLambda.new(Context.global,
                                         params, body, name.to_s)
    end

    def def_user_macro(name, params_source, body_source)
      params = Parser.parse(params_source)
      body = Parser.parse(body_source)

      @table[name.to_s] = UserMacro.new(params, body, name.to_s)
    end

    def def_alias(new_name, old_name)
      @table[new_name.to_s] = @table[old_name.to_s]
    end

    def def_helper(helper_name, &block)
      @helpers[helper_name] = block
    end

    def load_symbols(context = Context.global)
      @table.each do |k,v|
        context.store(k, v)
      end
    end
  end
  self.instance_variable_set(:@table, {})
  self.instance_variable_set(:@helpers, {})
end

module Revo::BuiltInFunctions
  include Revo

  def_procedure(:+, '(a . b)') do
    sum = param[:a].val
    param[:b].each do |x|
      sum += x.val
    end
    Number.new(sum)
  end
  def_procedure(:-, '(a . b)') do
    diff = param[:a].val
    return Number.new(-diff) if param[:b].null?

    param[:b].each do |x|
      diff -= x.val
    end
    Number.new(diff)
  end
  def_procedure(:*, '(a . b)') do
    prod = param[:a].val
    param[:b].each do |x|
      prod *= x.val
    end
    Number.new(prod)
  end
  def_procedure(:/, '(a . b)') do
    quot = param[:a].val
    param[:b].each do |x|
      quot /= x.val
    end
    Number.new(quot)
  end

  def_procedure(:'=', '(lhs rhs)') do
    Bool.new(param[:lhs].val == param[:rhs].val)
  end
  def_procedure(:!=, '(lhs rhs)') do
    Bool.new(param[:lhs].val != param[:rhs].val)
  end
  def_procedure(:<, '(lhs rhs)') do
    Bool.new(param[:lhs].val < param[:rhs].val)
  end
  def_procedure(:<=, '(lhs rhs)') do
    Bool.new(param[:lhs].val <= param[:rhs].val)
  end
  def_procedure(:>, '(lhs rhs)') do
    Bool.new(param[:lhs].val > param[:rhs].val)
  end
  def_procedure(:>=, '(lhs rhs)') do
    Bool.new(param[:lhs].val >= param[:rhs].val)
  end

  def_procedure(:car, '(x)') { param[:x].car }
  def_procedure(:cdr, '(x)') { param[:x].cdr }

  def_procedure(:display, '(x)') { print param[:x].to_s; NULL }

  def_macro(:quote, '(x)') { param[:x] }

  def_macro(:define, '(k . v)') do |env|
    assert((param[:k].is_a?(Symbol) && (param[:v].list_length == 1)) |p|
           param[:k].list?)

    if param[:k].is_a? Revo::Symbol
      v = param[:v].car.eval(env)
      v.name = param[:k].val if v.is_a? Code
      Context.global.store(param[:k].val, v)
      return v
    else
      # syntatic sugar for lambda definition
      lamb_name = param[:k].car
      lamb_params = param[:k].cdr
      lamb_body = param[:v]
      lamb = call_proc(:lambda, env,
                       cons(lamb_params, lamb_body))
      return call_proc(:define, env,
                       list(lamb_name, quote(lamb)))
    end
  end

  def_macro(:set!, '(k v)') do |env|
    assert(param[:k].is_a? Revo::Symbol)
    orig_context = env.lookup_context(param[:k].val)
    raise NameError, "symbol '#{name}' not found" if orig_context.nil?
    val = param[:v].eval(env)
    orig_context.store(param[:k].val, val)
    val
  end

  def_macro(:'set-car!', '(k v)') do |env|
    assert(param[:k].is_a? Revo::Symbol)
    name = param[:k].val
    orig_context = env.lookup_context(name)
    val = orig_context.lookup(name)

    assert(val.list?)

    new_val = SExpr.new(param[:v].eval(env)).cons!(val.cdr)

    orig_context.store(name, new_val)
    NULL
  end
  def_macro(:'set-cdr!', '(k v)') do |env|
    assert(param[:k].is_a? Revo::Symbol)
    name = param[:k].val
    orig_context = env.lookup_context(name)
    val = orig_context.lookup(name)

    assert(val.list?)

    new_val = SExpr.new(val.car).cons!(param[:v].eval(env))

    orig_context.store(name, new_val)
    NULL
  end

  def_macro(:begin, 'exprs') do |env|
    lastval = NULL

    param[:exprs].each do |x|
      lastval = x.eval(env)
    end
    lastval
  end

  def_macro(:lambda, '(params . body)') do |env|
    lamb_params = param[:params]
    lamb_body = param[:body]

    lamb_body = case lamb_body.list_length
                when 0 then NULL
                when 1 then lamb_body.car
                else        begin_cons(lamb_body)
                end

    UserLambda.new(env, lamb_params, lamb_body)
  end

  def_macro(:if, '(cond t f)') do |env|
    cond = param[:cond].eval(env)
    true_part = param[:t]
    false_part = param[:f]

    if cond.is_false?
      false_part.eval(env)
    else
      true_part.eval(env)
    end
  end

  def_macro(:'define-macro', '(k v)') do |env|
    assert(param[:k].is_a? Revo::Symbol)

    lambda_ = param[:v].eval(env)
    assert(lambda_.is_a? Revo::UserLambda)

    lambda_.name = param[:k].val
    Context.global.store(param[:k].val, lambda_.to_macro)
    lambda_
  end

  def_procedure(:cons, '(a b)') do
    SExpr.new(param[:a]).cons!(param[:b])
  end
  def_procedure(:list, 'x') do
    param[:x]
  end

  def_procedure(:eval, '(x)') do |env|
    param[:x].eval(env)
  end
  def_procedure(:'type-of', '(x)') do |env|
    type = param[:x].type_string
    Revo::Symbol.new(type)
  end

  # TODO: The following

  def_macro(:let, '(x . body)') do |env|
    name = vars = body = nil
    local_scope = Context.new(env)

    if param[:x].is_a? Symbol
      name = param[:x].val
      vars = param[:body].car
      body = param[:body].cdr

      params = SExpr.construct_list(vars.map(&:car))

      lamb = call_proc(:lambda, local_scope, SExpr.new(params).cons!(body))
      lamb.name = name

      local_scope.store(name, lamb)
    else
      vars = param[:x]
      body = param[:body]
    end

    vars.each do |x|
      local_scope.store(x.car.val, x.cdr.car.eval(env))
    end

    body = begin_cons(body)

    body.eval(local_scope)
  end

  def_macro(:'let*', '(vars . body)') do |env|
    vars = param[:vars]
    body = SExpr.new(Revo::Symbol.new('begin')).cons!(param[:body])

    context = env
    vars.each do |x|
      context = Context.new(context)
      context.store(x.car.val, x.cdr.car.eval(context))
    end

    body.eval(context)
  end

  def_macro(:letrec, '(vars . body)') do |env|
    vars = param[:vars]
    body = SExpr.new(Revo::Symbol.new('begin')).cons!(param[:body])

    local_scope = Context.new(env)
    vars.each do |x|
      local_scope.store(x.car.val, x.cdr.car.eval(local_scope))
    end

    body.eval(local_scope)
  end

=begin
  def_macro(:'fluid-let') do |env, args|
    tmp_area = Context.new(nil)

    keys = []; args.car.each {|x| keys << x.car.val }
    vals = []; args.car.each {|x| vals << x.cdr.car.eval(env) }
    keys.zip(vals).each do |k,v|
      tmp_area.store(k, Context.global.lookup(k))
      Context.global.store(k, v)
    end
    retval = call(:let, env, SExpr.new(NULL).cons!(args.cdr))

    tmp_area.each do |k, v|
      Context.global.store(k, v)
    end
    retval
  end
=end

  def_procedure(:newline, '()') do
    puts
    NULL
  end
  def_procedure(:not, 'v') do
    Bool.new(param[:v].is_false?)
  end
  def_macro(:or, 'xs') do |env|
    result = Bool.new(false)
    param[:xs].each do |x|
      result = x.eval(env)
      return result if result.is_true?
    end
    result
  end

  def_macro(:and, 'xs') do |env|
    result = Bool.new(true)
    param[:xs].each do |x|
      result = x.eval(env)
      return result if result.is_false?
    end
    result
  end

  def_procedure(:map, '(proc . lists)') do |env|
    proc = param[:proc]
    lists = param[:lists]

    new_list = []
    lists.to_ruby_list.map(&:to_ruby_list).transpose.each do |x|
      new_list << proc.call(env, list(*x.map{|x| quote(x)}))
    end

    list(*new_list)
  end

  def_macro(:'for-each', 'args') do |env|
    call_proc(:map, env, param[:args])
    NULL
  end

  def_user_macro(:when, '(cond . body)', <<-'end')
    `(if ,cond (begin ,@body) '())
  end
  def_user_macro(:unless, '(cond . body)', <<-'end')
    `(if ,cond '() (begin ,@body))
  end
  def_lambda(:'+1', '(op)', <<-'end')
    (+ 1 op)
  end

  def_procedure(:reverse, '(xs)') do
    assert(param[:xs].list?)
    SExpr.construct_list(param[:xs].to_ruby_list.reverse)
  end

  def_lambda(:null?, '(op)', <<-'end')
    (= (type-of op) 'null)
  end
  def_procedure(:quit, '()') do |env, args|
    exit
    nil
  end

  def_procedure(:'fold-left', '(proc init list)') do |env|
    func = param[:proc]
    initval = param[:init]
    list = param[:list]

    assert(func.is_a? Code)

    val = initval
    list.each do |x|
      args = SExpr.construct_list([quote(val), quote(x)])
      val = func.call(env, args)
    end
    val
  end

  def_procedure(:'fold-right', '(proc init list)') do |env|
    func = param[:proc]
    initval = param[:init]
    list = param[:list]

    assert(func.is_a? Code)

    val = initval
    list.to_ruby_list.reverse.each do |x|
      args = SExpr.construct_list([quote(x), quote(val)])
      val = func.call(env, args)
    end
    val
  end

  def_macro(:quasiquote, '(expr)') do |env|
    unquote = lambda do |arg|
      if arg.is_a? SExpr
        v = arg.val
        if v.is_a? Symbol and v.val == 'unquote'
          return arg.cdr.car.eval(env)
        elsif v.is_a? SExpr
          if v.val.is_a? Symbol and v.val.val == 'unquote-splicing'
            return v.cdr.car.eval(env).tap do |x|
              x = x.next until x.next.null?
              x.next = unquote.call(arg.cdr)
            end
          else
            v = SExpr.new(unquote.call(v))
          end
        else
          v = SExpr.new(v)
        end
        v.cons!(unquote.call(arg.cdr))
      else
        arg
      end # end of if arg.is_a? SExpr
    end # end of lambda

    unquote.call(param[:expr])
  end

  def_alias(:progn, :begin)
  def_alias(:exit, :quit)

  def_macro(:cond, 'conds') do |env|
    param[:conds].each do |list|
      if (list.car.is_a? Symbol and
          list.car.val == 'else') or
          list.car.eval(env).is_true?
        return list.cdr.car.eval(env)
      end
    end
    return NULL
  end

  def_procedure(:'list->vector', '(list)') do
    assert(param[:list].list?)
    param[:list].to_vector
  end
  def_procedure(:'vector->list', '(vector)') do
    assert(param[:vector].is_a? Vector)
    param[:vector].to_list
  end
  def_procedure(:'vector-ref', '(vector n)') do
    assert((param[:n].is_a? Number) && (param[:vector].is_a? Vector))
    param[:vector].ref(param[:n].val)
  end

  def_procedure(:remainder, '(a b)') do |env|
    return Revo::Number.new(param[:a].val % param[:b].val)
  end

  def_procedure(:'context-probe', '(a . rst)') do |env|
    hash = env.snapshot
    if param[:rst].list_length >= 1
      global_vars = Context.global.snapshot.keys
      hash.delete_if {|k,_| global_vars.include? k }
    end
    p hash
    param[:a]
  end

  def_procedure(:append, 'lists') do
    lists = param[:lists].to_ruby_list
    assert(lists[0..-2].all?(&:list?))
    last = lists.pop

    SExpr.construct_list(lists.map(&:to_ruby_list)
                           .inject([], &:concat)).append!(last)
  end
  def_procedure(:length, '(lst)') do
    assert(param[:lst].list?)
    Number.new(param[:lst].list_length)
  end

  def_procedure(:apply, '(proc . objs)') do |env|
    assert(param[:proc].is_a? Code)
    objs = param[:objs].to_ruby_list
    assert(objs.last.list?)
    last = objs.pop

    args = SExpr.construct_list(objs.map {|x| quote(x) })
      .append!(list(*last.map {|x| quote(x) }))

    param[:proc].apply(env, args)
  end

=begin
  def_procedure(:'debug-format') do |env, args|
    String.new(args.car.inspect)
  end


  def_procedure(:'number->string') do |env, args|
    Revo::String.new(args.car.val.to_s)
  end
  def_procedure(:'string->number') do |env, args|
    base = args.cdr.car.null? ? 10 : args.cdr.car.val
    Revo::Number.new(args.car.val.to_i(base))
  end
  def_procedure(:'symbol->string') do |env, args|
    Revo::String.new(args.car.val)
  end
  def_procedure(:'string->symbol') do |env, args|
    Revo::Symbol.new(args.car.val)
  end

  def_procedure(:string?) do |env, args|
    Revo::Bool.new(args.car.is_a? Revo::String)
  end
  def_procedure(:'string-length') do |env, args|
    Revo::Number.new(args.car.val.length)
  end
  def_procedure(:substring) do |env, args|
    start = args.cdr.car.val
    end_ = args.cdr.cdr.car.null? ? -1 : args.cdr.cdr.car.val
    Revo::String.new(args.car.val[start..end_])
  end
  def_procedure(:'string-append') do |env, args|
    result = ''
    args.each do |x|
      result << x.val
    end
    Revo::String.new(result)
  end

=end

end
