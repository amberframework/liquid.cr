require "./block"

module Liquid::Block
  class Capture < BeginBlock
    getter var_name : String

    def initialize(@var_name)
    end

    def initialize(content : String)
      if content =~ VAR
        @var_name = content
      else
        raise InvalidNode.new "capture block needs an argument"
      end
    end
  end
end
