require "./block"

module Liquid::Block
  class ElsIf < InlineBlock
    SIMPLE_EXP = /^\s*elsif (?<expr>.+)\s*$/

    getter expression : Expression

    def initialize(@expression)
    end

    def initialize(content : String)
      if match = content.match SIMPLE_EXP
        @expression = Expression.new match["expr"]
      else
        raise InvalidNode.new "Invalid Elsif Node"
      end
    end

    delegate eval, to: @expression
  end
end
