require "string_scanner"
require "./expression_compiler"

module Liquid
  # This represent a liquid expression used in under `{{ }}` or passed to statements like if, case, etc... including
  # filter and their arguments.
  #
  # The Expression is reentrant and doesn't store any state besides the compiled expression.
  #
  # To evaluate a expression call the `evaluate` method with the desired `Context`.
  struct Expression
    getter expression : String
    @opcodes : Array(ExpressionOpCode)

    private enum Operator
      Equals
      NotEqual
      Greater
      GreaterEqual
      Less
      LessEqual
      Contains
      And
      Or
      Filter
      FilterOption

      def self.from_string(str : String) : self
        case str
        when "=="       then Equals
        when "!="       then NotEqual
        when ">"        then Greater
        when ">="       then GreaterEqual
        when "<"        then Less
        when "<="       then LessEqual
        when "contains" then Contains
        when "and"      then And
        when "or"       then Or
        else
          raise LiquidException.new("Invalid operator: #{str}.")
        end
      end

      def eval(left : Any, right : Any) : Bool
        case self
        when .equals?        then left == right
        when .not_equal?     then left != right
        when .greater?       then left > right
        when .greater_equal? then left >= right
        when .less?          then left < right
        when .less_equal?    then left <= right
        when .contains?      then left.contains?(right)
        when .and?           then left.logical_and(right)
        when .or?            then left.logical_or(right)
        else
          false
        end
      end
    end

    private alias Stack = Array(Any | Operator)

    def initialize(@expression : String)
      @opcodes = ExpressionCompiler.compile(@expression)
    end

    def_equals @expression

    def eval(ctx : Context) : Any
      # Fast path for single variables
      value = ctx[@expression]?
      return value if value

      # Once a filter is detected, filter_stack is instantiated and we point the `stack` variable to it.
      # Later we solve the code_stack, then apply the filters in filter_stack.
      stack = code_stack = Stack.new
      filter_stack = nil

      @opcodes.each do |opcode|
        case opcode.action
        in .push_var?
          opcode_value = opcode.value.as_s
          value = ctx[opcode_value]?
          value ||= if opcode_value.ends_with?('?')
                      ctx.get(opcode_value.rchop)
                    else
                      ctx.get(opcode_value)
                    end
          stack.push(value)
        in .push_literal?
          stack.push(opcode.value)
        in .operator?
          stack.push(Operator.from_string(opcode.value.as_s))
        in .filter?
          stack = filter_stack = Stack.new if filter_stack.nil?
          stack.push(Operator::Filter)
          stack.push(opcode.value)
        in .filter_option?
          return expression_error(ctx, "Unexpected filter option: #{opcode.value}.") if filter_stack.nil?

          stack.push(Operator::FilterOption)
          stack.push(opcode.value)
        in .call?
          obj = stack.pop.as(Any)
          method = opcode.value.as_s
          stack.push(call_method(ctx, obj, method))
        in .index_call?
          index = stack.pop
          var = stack.pop
          if index.is_a?(Operator)
            return expression_error(ctx, "Unexpected operator: #{index}.")
          elsif var.is_a?(Operator)
            return expression_error(ctx, "Unexpected operator: #{var}.")
          end

          retval = call_index(ctx, var, index.as(Any))
          stack.push(retval)
        end
      end

      return expression_error(ctx, "Empty expression.") if code_stack.empty?
      return expression_error(ctx, "Bad values left on stack.") if code_stack.size == 2 || !code_stack.first.is_a?(Any)

      result = code_stack.size == 1 ? code_stack.first.as(Any) : apply_operators(ctx, code_stack)
      apply_filters(ctx, result, filter_stack)
    end

    def apply_operators(ctx : Context, stack : Stack) : Any
      while stack.size >= 3
        result = apply_binary_operator(ctx, stack)
        stack << result
      end
      return expression_error(ctx, "Bad values left on stack.") if stack.size != 1

      result = stack.first.as?(Any)
      return expression_error(ctx, "Bad values left on stack.") if result.nil?

      result
    end

    private def apply_binary_operator(ctx : Context, stack : Stack) : Any
      right_operand = stack.pop
      operator = stack.pop
      left_operand = stack.pop
      return expression_error(ctx, "Unexpected operator: #{operator}.") unless operator.is_a?(Operator)
      return expression_error(ctx, "Unexpected left operand: #{left_operand}.") unless left_operand.is_a?(Any)
      return expression_error(ctx, "Unexpected right operand: #{right_operand}.") unless right_operand.is_a?(Any)

      result = operator.eval(left_operand, right_operand)
      Any.new(result)
    rescue e : InvalidExpression
      ctx.add_error(e)
    end

    private def apply_filters(ctx : Context, operand : Any, filter_stack : Stack?) : Any
      return operand if filter_stack.nil?

      while !filter_stack.empty?
        item = filter_stack.shift
        return expression_error(ctx, "Expected a filter, got #{item}.") if !item.is_a?(Operator) || !item.filter?

        item = filter_stack.shift?
        return expression_error(ctx, "Expected a filter name, got #{item}.") unless item.is_a?(Any)

        filter_name = item.as_s
        filter = Filters::FilterRegister.get(filter_name)
        return ctx.add_error(UndefinedFilter.new(filter_name)) if filter.nil?

        setup_context_filter_args_and_options(ctx, filter_stack)
        operand = filter.filter(operand, ctx.filter_args, ctx.filter_options)
      end

      operand
    rescue e : Liquid::FilterArgumentException
      ctx.add_error(e)

      # Shopify liquid returns the filter error message instead of nil, so do we.
      Any.new(e.message)
    end

    private def setup_context_filter_args_and_options(ctx : Context, stack : Stack) : Nil
      ctx.reset_filter_context

      filter_args = ctx.filter_args
      filter_options = ctx.filter_options

      while !stack.empty?
        item = stack.first
        return if item.is_a?(Operator) && item.filter?

        stack.shift
        if item.is_a?(Any)
          filter_args << item
        elsif item.is_a?(Operator)
          name = stack.shift?.as?(Any)
          value = stack.shift?.as?(Any)
          return expression_error(ctx, "Missing filter option name or value.") if name.nil? || value.nil?

          filter_options[name.to_s] = value
        end
      end
    end

    private def call_index(ctx : Context, any : Any, index : Any) : Any
      raw = any.raw
      return call_hash_method(ctx, raw, index.as_s) if raw.is_a?(Hash)
      return call_drop_method(ctx, raw, index.as_s) if raw.is_a?(Drop)

      return expression_error(ctx, "Tried to index a non-array object with \"#{index}\".") unless raw.is_a?(Array)

      i = index.as_i?
      return expression_error(ctx, "Tried to index an array object with a #{raw.class.name}.") if i.nil?

      raw[i]? || Any.new(nil)
    end

    private def call_method(ctx : Context, obj : Any, method : String) : Any
      raw = obj.raw
      return call_drop_method(ctx, raw, method) if raw.is_a?(Drop)
      return call_hash_method(ctx, raw, method) if raw.is_a?(Hash)
      return call_nil_method(ctx, method) if raw.nil?

      return expression_error(ctx, "Tried to call ##{method} on a #{raw.class.name}.") if !raw.responds_to?(:size)

      case method
      when "present", "present?"
        Any.new(raw.size > 0)
      when "blank", "blank?"
        Any.new(raw.try(&.size.zero?))
      when "size"
        Any.new(raw.size)
      else
        expression_error(ctx, "Tried to access property \"#{method}\" of a non-hash/non-drop object.")
      end
    end

    private def call_drop_method(ctx : Context, drop : Drop, method : String) : Any
      drop.call(method)
    rescue e : Liquid::InvalidExpression
      ctx.add_error(e)
    end

    private def call_hash_method(ctx : Context, hash : Hash, method : String) : Any
      case method
      when "present", "present?"
        Any.new(hash.size > 0)
      when "blank", "blank?"
        Any.new(hash.size.zero?)
      when "size"
        Any.new(hash.size)
      else
        value = hash[method]?
        return expression_error(ctx, "Method \"#{method}\" not found.") if value.nil?

        value
      end
    end

    private def call_nil_method(ctx : Context, method : String) : Any
      case method
      when "present", "present?"
        Any.new(false)
      when "blank", "blank?"
        Any.new(true)
      else
        expression_error(ctx, "Method \"#{method}\" not found for Nil.")
      end
    end

    def expression_error(ctx : Context, message : String)
      ctx.add_error(InvalidExpression.new(message))
    end

    def to_s(io : IO)
      compile.each do |instr|
        io << instr
      end
    end
  end
end
