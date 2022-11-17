require "./block"

module Liquid::Block
  class When < InlineBlock
    SIMPLE_EXP = /^\s*when \s*(["'])(\\\1|[^\1]+)*\1/

    getter when_values
    @when_values : Array(String)

    def initialize(@when_values)
    end

    def initialize(content : String)
      if match = content.match(SIMPLE_EXP)
        @when_values = match[2].gsub("\"", "").gsub("'", "").split(/\s*,\s*/).map { |value| value.strip }
      else
        raise InvalidNode.new("Invalid When Node")
      end
    end

    def eval(data)
      @when_values.includes?(data)
    end
  end
end
