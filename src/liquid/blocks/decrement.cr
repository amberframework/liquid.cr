require "../blocks"

module Liquid::Block
  class Decrement < Liquid::Block::InlineBlock
    getter var_name : String

    def initialize(content @var_name)
      raise SyntaxError.new if @var_name !~ VARIABLE_SIGNATURE
    end
  end
end
