require "string_scanner"

require "./stack_machine"
require "./exceptions"

module Liquid
  struct StackMachineOpCode
    enum Action
      PushVar     # Like in var
      PushLiteral # Like in "var" or 'var'
      Call        # Like in var.call
      IndexCall   # Like in var[index]
      Operator    # ==, >=, <=, <, >, !=, contains, or, and
      Filter
    end

    getter action : Action
    getter value : Any

    def initialize(@action, value : Any::Type = nil)
      @value = Any.new(value)
    end

    def inspect(io : IO)
      io << action
      unless @value.raw.nil?
        io << ' ' << (action.push_literal? ? @value.inspect : @value)
      end
      io << ';'
    end
  end

  class StackMachineCompiler
    private OPERATOR        = /(?:==|!=|<>|<=?|>=?|contains|or|and)(?=\s)/
    private IDENTIFIER      = /[a-zA-Z_][\w-]*\??/
    private INTEGER_LITERAL = /-?\d+/
    private FLOAT_LITERAL   = /-?\d+\.\d+/
    private BOOLEAN_LITERAL = /(true|false)\b/
    private FILTER          = /\|\s*([a-zA-Z_][\w-]+):?/

    def self.compile(expr : String) : Array(StackMachineOpCode)
      opcodes = [] of StackMachineOpCode
      scanner = StringScanner.new(expr)
      calling_method = false

      loop do
        scanner.skip(/\s*/)
        break if scanner.eos?

        if value = scanner.scan(FLOAT_LITERAL)
          opcodes << StackMachineOpCode.new(:push_literal, value.to_f)
        elsif value = scanner.scan(INTEGER_LITERAL)
          opcodes << StackMachineOpCode.new(:push_literal, value.to_i)
        elsif value = scanner.scan(BOOLEAN_LITERAL)
          opcodes << StackMachineOpCode.new(:push_literal, value == "true")
        elsif value = scanner.scan(OPERATOR)
          opcodes << StackMachineOpCode.new(:operator, value)
        elsif value = scanner.scan(IDENTIFIER)
          if calling_method
            calling_method = false
            opcodes << StackMachineOpCode.new(:call, value)
          else
            opcodes << StackMachineOpCode.new(:push_var, value)
          end
        elsif scanner.scan(FILTER)
          opcodes << StackMachineOpCode.new(:filter, scanner[1])
        else
          next_char = expr[scanner.offset]
          case next_char
          when '.'
            calling_method = true
            scanner.offset += 1
          when '['
            scanner.offset += 1
          when ']'
            scanner.offset += 1
            opcodes << StackMachineOpCode.new(:index_call)
          when '"', '\''
            value = parse_string(scanner, next_char)
            opcodes << StackMachineOpCode.new(:push_literal, value)
          when ','
            # TODO: Do some syntax check using the current opcodes array
            scanner.offset += 1
          else
            raise InvalidExpression.new("Unexpected character: #{expr[scanner.offset]}.") if value.nil?
          end
        end
      end
      opcodes
    end

    private def self.parse_number(scanner : StringScanner) : StackMachineOpCode?
      value = scanner.scan(/-?\d+(\.\d+)?/)
      return if value.nil?

      StackMachineOpCode.new(:push_literal, value.index('.') ? value.to_f : value.to_i)
    end

    private def self.parse_string(scanner : StringScanner, limit : Char) : String
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
          raise InvalidExpression.new("Unterminated string literal.")
        end
      end

      scanner.offset = reader.pos + 1
      string
    end

    private def self.handle_escape_sequence(char : Char, limit : Char, str : IO)
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
  end
end
