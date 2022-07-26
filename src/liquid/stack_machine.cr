require "string_scanner"

module Liquid
  # :nodoc:
  # This is used by `Context` to evaluate expressions like `variable.attribute[0]`
  struct StackMachine
    enum Action
      PushInvertion # Like in -var
      PushNegation  # Like in !var
      PushVar       # Like in var
      PushLiteral   # Like in "var" or 'var'
      Call          # Like in var.call
      IndexCall     # Like in var[index]
    end

    struct OpCode
      getter action : Action
      getter! value : String?

      def initialize(@action, @value = nil)
      end

      def to_s(io : IO)
        io << action
        io << ' ' << @value if @value
        io << ';'
      end
    end

    @expr : String
    @opcodes : Array(OpCode)?

    def initialize(@expr : String)
    end

    def compile : Array(OpCode)
      opcodes = @opcodes
      return opcodes unless opcodes.nil?

      @opcodes = opcodes = [] of OpCode
      scanner = StringScanner.new(@expr)
      calling_method = false

      loop do
        scanner.skip(/\s*/)
        break if scanner.eos?

        next_char = @expr[scanner.offset]
        case next_char
        when '.'
          calling_method = true
          scanner.offset += 1
        when '-'
          value = scanner.scan(/-?\d+/)
          if value
            opcodes << OpCode.new(:push_literal, value)
          else
            opcodes << OpCode.new(:push_invertion)
            scanner.offset += 1
          end
        when .ascii_number?
          value = scanner.scan(/\d+/)
          opcodes << OpCode.new(:push_literal, value)
        when '!'
          scanner.offset += 1
          opcodes << OpCode.new(:push_negation)
        when '['
          scanner.offset += 1
        when ']'
          scanner.offset += 1
          opcodes << OpCode.new(:index_call)
        when '"', '\''
          value = parse_string(scanner, next_char)
          opcodes << OpCode.new(:push_literal, value)
        else
          value = scanner.scan(/\w+\??/)
          raise Exception.new("Expecting a word, got #{@expr[scanner.offset]}.") if value.nil?

          if calling_method
            calling_method = false
            opcodes << OpCode.new(:call, value)
          else
            opcodes << OpCode.new(:push_var, value)
          end
        end
      end
      opcodes
    end

    private def parse_string(scanner : StringScanner, limit : Char) : String
      reader = Char::Reader.new(scanner.string, scanner.offset + 1)
      parse_completed = false
      string = String.build do |str|
        handling_escape = false

        reader.each do |char|
          if handling_escape
            handle_escape_sequence(char, limit, str)
            handling_escape = false
          elsif char == '\\'
            handling_escape = true
          elsif char == limit
            parse_completed = true
            break
          else
            str << char
          end
        end

        if parse_completed
          next
        else
          raise Exception.new("Unterminated string literal.")
        end
      end

      scanner.offset = reader.pos + 1
      string
    end

    private def handle_escape_sequence(char : Char, limit : Char, str : IO)
      case char
      when 'n'
        str << '\n'
      when 't'
        str << '\t'
      when limit
        str << limit
      else
        str << '\\' << char
      end
    end

    def reset
      @opcodes.clear
    end

    private enum Prefix
      Invert
      Negate
    end

    alias Stack = Deque(Any | String | Prefix)

    def evaluate(vars : Hash(String, Any)) : Any
      # Fast path for single variables
      value = vars[@expr]?
      return value if value

      opcodes = compile
      stack = Stack.new
      compile.each do |opcode|
        case opcode.action
        in .push_var?
          value = vars[opcode.value]?
          value ||= if opcode.value.ends_with?('?')
                      vars[opcode.value.rchop]? || Any.new(nil)
                    elsif opcode.value.to_i?
                      opcode.value
                    else
                      raise KeyError.new("Key \"#{opcode.value}\" not found.")
                    end
          stack.push(value)
        in .push_invertion?
          stack.push(Prefix::Invert)
        in .push_negation?
          stack.push(Prefix::Negate)
        in .push_literal?
          stack.push(opcode.value)
        in .call?
          var = stack.pop.as(Any)
          stack.push(call_method(var, opcode.value))
        in .index_call?
          index = stack.pop
          var = stack.pop
          raise Exception.new("Unexpected prefix: #{index}") if index.is_a?(Prefix)
          raise Exception.new("Unexpected prefix: #{var}") if var.is_a?(Prefix)
          raise Exception.new("Unexpected string literal: #{var}") if var.is_a?(String)

          var = apply_prefix(var, stack)
          stack.push(call_index(var, index))
        end
      end

      return Any.new(nil) if stack.empty?

      apply_prefix(stack.pop, stack)
    end

    private def apply_prefix(any : Any, stack : Stack)
      loop do
        prefix = stack.last?
        break unless prefix.is_a?(Prefix)

        any = case prefix
              in .negate? then Any.new(!any.raw)
              in .invert? then -any
              end
        stack.pop
      end
      any
    end

    private def apply_prefix(str : String, stack : Stack)
      apply_prefix(Any.new(str), stack)
    end

    private def apply_prefix(_prefix : Prefix, stack : Stack)
      raise Exception.new("Unexpected prefix.")
    end

    private def call_index(any : Any, index : String) : Any
      raw = any.raw
      return call_hash_method(raw, index) if raw.is_a?(Hash)
      return call_drop_method(raw, index) if raw.is_a?(Drop)

      raise Exception.new("Tried to index a non-array object with \"#{index}\".") unless raw.is_a?(Array)

      i = index.to_i?
      raise Exception.new("Tried to index an array object with a #{raw.class.name}.") if i.nil?

      raw[i]? || raise Exception.new("\"Index out of bounds: #{i}.")
    end

    private def call_index(any : Any, index : Any) : Any
      raw = any.raw
      return call_hash_method(raw, index.to_s) if raw.is_a?(Hash)

      raise Exception.new("Tried to index a non-array object with \"#{index}\".") unless raw.is_a?(Array)

      i = index.as_i?
      raise Exception.new("Tried to index an array object with a #{raw.class.name}.") if i.nil?

      raw[i]? || raise Exception.new("\"Index out of bounds: #{i}.")
    end

    private def call_method(any : Any, method : String) : Any
      raw = any.raw
      return call_drop_method(raw, method) if raw.is_a?(Drop)
      return call_hash_method(raw, method) if raw.is_a?(Hash)

      if !raw.responds_to?(:size) || raw.nil?
        raise Exception.new("Tried to call ##{method} on a #{raw.class.name}.")
      end

      case method
      when "present", "present?"
        Any.new(raw.size > 0)
      when "blank", "blank?"
        Any.new(raw.try(&.size.zero?))
      when "size"
        Any.new(raw.size)
      else
        raise Exception.new("Tried to access property \"#{method}\" of a non-hash/non-drop object.")
      end
    end

    private def call_drop_method(drop : Drop, method : String) : Any
      drop.call(method)
    end

    private def call_hash_method(hash : Hash, method : String) : Any
      case method
      when "present", "present?"
        Any.new(hash.size > 0)
      when "blank", "blank?"
        Any.new(hash.size.zero?)
      when "size"
        Any.new(hash.size)
      else
        value = hash[method]?
        raise KeyError.new("Key \"#{method}\" not found.") if value.nil?

        value
      end
    end

    def to_s(io : IO)
      compile.each do |instr|
        io << instr
      end
    end
  end
end
