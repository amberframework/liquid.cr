require "./block"

module Liquid::Block
  class ElsIf < InlineBlock
    SIMPLE_EXP = /^\s*elsif (?<expr>.+)\s*$/
    @if_expression : Expression

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

    def render(data, io)
      @children.each &.render(data, io)
    end
  end
end
