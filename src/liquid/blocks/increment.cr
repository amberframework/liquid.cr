require "../blocks"

module Liquid::Block
  class Increment < Liquid::Block::InlineBlock
    REGEXP = /increment (?<varname>#{VAR})/

    getter :var_name

    @var_name : String

    def initialize(content : String)
      if match = content.strip.match REGEXP
        @var_name = match["varname"]
      else
        raise InvalidNode.new "increment block needs an argument"
      end
    end
  end
end
