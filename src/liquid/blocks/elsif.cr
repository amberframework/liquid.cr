require "./block"

module Liquid::Block
  class ElsIf < InlineBlock
    getter expression : Expression

    def initialize(@expression)
    end

    def initialize(content : String)
      @expression = Expression.new(content)
    end

    delegate eval, to: @expression
  end
end
