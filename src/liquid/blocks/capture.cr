require "./block"

module Liquid::Block
  class Capture < BeginBlock
    REGEXP = /capture (?<varname>#{VAR})/

    getter var_name

    @var_name : String

    def initialize(content : String)
      if match = content.strip.match REGEXP
        @var_name = match["varname"]
      else
        raise InvalidNode.new "capture block needs an argument"
      end
    end

  end
end
