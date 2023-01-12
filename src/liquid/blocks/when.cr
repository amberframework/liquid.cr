require "./block"

module Liquid::Block
  class When < InlineBlock
    @when_expressions : Array(StackMachine)

    def initialize(content : String)
      @when_expressions = Array(StackMachine).new

      scanner = StringScanner.new(content)
      raise InvalidNode.new("Invalid When Node") unless scanner.scan(/\A\s*when\s+/)

      while expr = scanner.scan(/("[^"]*"|'[^']*'|(?:\w|\.)+)/)
        @when_expressions << StackMachine.new(expr)
        break unless scanner.scan(/\s*(?:,|or)\s*/)
      end

      raise InvalidNode.new("No expression for When tag") if @when_expressions.empty?
    end

    # Return the number of matches in when clause
    def match?(ctx : Context, value : Any) : Int32
      @when_expressions.count do |expr|
        expr.evaluate(ctx) == value
      end
    end

    def inspect(io : IO)
      inspect(io) { io << @when_expressions.map(&.inspect).join(", ") }
    end
  end
end
