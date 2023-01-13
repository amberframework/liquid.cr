require "../blocks"

module Liquid::Block
  class Decrement < Liquid::Block::InlineBlock
    getter var_name : String

    def initialize(content : String)
      if content =~ VAR
        @var_name = content
      else
        raise InvalidNode.new "decrement block needs an argument"
      end
    end
  end
end
