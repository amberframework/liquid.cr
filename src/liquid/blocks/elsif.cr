require "./block"

module Liquid::Block
  class ElsIf < InlineBlock
    SIMPLE_EXP = /^\s*elsif (?<expr>.+)\s*$/

    getter if_expression
    @if_expression : Expression

    def initialize(@if_expression)
    end

    def initialize(content : String)
      if match = content.match SIMPLE_EXP
        @if_expression = Expression.new match["expr"]
      else
        raise InvalidNode.new "Invalid Elsif Node"
      end
    end

    def eval(data)
      @if_expression.eval data
    end
  end
end
