require "../blocks"

module Liquid::Block
  class Increment < Liquid::Block::InlineBlock
    getter var_name : String

    def initialize(content : String)
      if content =~ VAR
        @var_name = content
      else
        raise InvalidNode.new "increment block needs an argument"
      end
    end
  end
end
