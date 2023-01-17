require "./block"
require "../filters"
require "../context"
require "../expression"

module Liquid::Block
  class ExpressionNode < Block::Node
    @expression : Expression

    def initialize(content : String)
      @expression = Expression.new(content)
    end

    delegate expression, to: @expression
    delegate eval, to: @expression

    def inspect(io : IO)
      inspect(io) { io << expression.inspect }
    end

    def_equals @expression
  end
end
