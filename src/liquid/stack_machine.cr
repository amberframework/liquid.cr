require "string_scanner"
require "./stack_machine_compiler"

module Liquid
  # :nodoc:
  # This is used by `Context` to evaluate expressions like `variable.attribute[0]`
  struct StackMachine
    getter expression : String
    @opcodes : Array(StackMachineOpCode)

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
      @opcodes = StackMachineCompiler.compile(@expression)
    end

    def_equals @expression

    def evaluate(ctx : Context) : Any
      # Fast path for single variables
      value = ctx[@expression]?
      return value if value

      stack = Stack.new
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
          stack.push(Operator::Filter)
          stack.push(opcode.value)
        in .call?
          obj = stack.pop.as(Any)
          method = opcode.value.as_s
          stack.push(call_method(ctx, obj, method))
        in .index_call?
          index = stack.pop
          var = stack.pop
          if index.is_a?(Operator)
            return raise?(ctx) { "Unexpected operator: #{index}." }
          elsif var.is_a?(Operator)
            return raise?(ctx) { "Unexpected operator: #{var}." }
          end

          retval = call_index(ctx, var, index.as(Any))
          stack.push(retval)
        end
      end
      case stack.size
      when 0 then raise?(ctx) { "Empty expression." }
      when 1 then stack.first.as(Any)
      when 2 then raise?(ctx) { "Bad values left on stack." }
      else
        apply_operators(ctx, stack)
      end
    end

    def apply_operators(ctx : Context, stack : Stack) : Any
      filters_start = stack.index { |e| e.is_a?(Operator) && e.filter? }
      filters = stack.pop(stack.size - filters_start) if filters_start

      while stack.size >= 3
        result = apply_binary_operator(stack)
        stack << result
      end
      return raise?(ctx) { "Too many items left on stack." } if stack.size != 1

      result = stack.first.as?(Any)
      return raise?(ctx) { "Bad values left on stack." } if result.nil?

      return result if filters.nil?

      apply_filters(ctx, result, filters)
    rescue e : InvalidExpression
      raise?(ctx, e)
    end

    private def apply_binary_operator(stack : Stack) : Any
      right_operand = stack.pop
      operator = stack.pop
      left_operand = stack.pop
      raise LiquidException.new("Unexpected operator: #{operator}.") unless operator.is_a?(Operator)
      raise LiquidException.new("Unexpected left operand: #{left_operand}.") unless left_operand.is_a?(Any)
      raise LiquidException.new("Unexpected right operand: #{right_operand}.") unless right_operand.is_a?(Any)

      result = operator.eval(left_operand, right_operand)
      Any.new(result)
    end

    private def apply_filters(ctx : Context, operand : Any, filter_stack : Stack) : Any
      while filter_stack.any?
        filter_operator = filter_stack.shift
        if !filter_operator.is_a?(Operator) || !filter_operator.filter?
          raise LiquidException.new("Expected a filter, got #{filter_operator}.")
        end

        filter_name = filter_stack.shift
        if !filter_name.is_a?(Any) || !filter_name.raw.is_a?(String)
          raise LiquidException.new("Expected a filter name, got #{filter_name}.")
        end

        filter_args = shift_filter_args(filter_stack)

        filter = Filters::FilterRegister.get(filter_name.as_s)
        return raise?(ctx) { "Unknown filter: #{filter_name}." } if filter.nil?

        filter_args ||= [] of Any # FIXME: Some filters doesn't compile if args is nil, probably because old
        # expression implementation was always sending an array.
        operand = filter.filter(operand, filter_args)
      end

      operand
    end

    private def shift_filter_args(filter_stack : Stack) : Array(Any)?
      return if filter_stack.empty? || filter_stack.first.is_a?(Operator)

      filter_args = Array(Any).new
      while filter_stack.any? && filter_stack.first.is_a?(Any)
        filter_args << filter_stack.shift.as(Any)
      end
      filter_args
    end

    private def call_index(ctx : Context, any : Any, index : Any) : Any
      raw = any.raw
      return call_hash_method(ctx, raw, index.as_s) if raw.is_a?(Hash)
      return call_drop_method(ctx, raw, index.as_s) if raw.is_a?(Drop)

      return raise?(ctx) { "Tried to index a non-array object with \"#{index}\"." } unless raw.is_a?(Array)

      i = index.as_i?
      return raise?(ctx) { "Tried to index an array object with a #{raw.class.name}." } if i.nil?

      raw[i]? || raise?(ctx) { "\"Index out of bounds: #{i}." }
    end

    private def call_method(ctx : Context, obj : Any, method : String) : Any
      raw = obj.raw
      return call_drop_method(ctx, raw, method) if raw.is_a?(Drop)
      return call_hash_method(ctx, raw, method) if raw.is_a?(Hash)
      return call_nil_method(ctx, method) if raw.is_a?(Nil)

      return raise?(ctx) { "Tried to call ##{method} on a #{raw.class.name}." } if !raw.responds_to?(:size)

      case method
      when "present", "present?"
        Any.new(raw.size > 0)
      when "blank", "blank?"
        Any.new(raw.try(&.size.zero?))
      when "size"
        Any.new(raw.size)
      else
        raise?(ctx) { "Tried to access property \"#{method}\" of a non-hash/non-drop object." }
      end
    end

    private def call_drop_method(ctx : Context, drop : Drop, method : String) : Any
      drop.call(method)
    rescue e : Liquid::InvalidExpression
      raise?(ctx, e)
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
        return raise?(ctx) { "Method \"#{method}\" not found." } if value.nil?

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
        raise?(ctx) { "Method \"#{method}\" not found for Nil." }
      end
    end

    private def raise?(ctx : Context) : Any
      case ctx.error_mode
      when .strict? then raise InvalidExpression.new(yield)
      when .warn?   then ctx.errors << yield
      end
      Any.new(nil)
    end

    private def raise?(ctx : Context, exception : LiquidException) : Any
      case ctx.error_mode
      when .strict? then raise exception
      when .warn?   then ctx.errors << exception.message.to_s
      end
      Any.new(nil)
    end

    def to_s(io : IO)
      compile.each do |instr|
        io << instr
      end
    end
  end
end
