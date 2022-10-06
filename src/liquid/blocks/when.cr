require "./block"

module Liquid::Block
  class When < InlineBlock
    SIMPLE_EXP = /^\s*when ((?:\s*"([^"]+)",?)+)\s*$/

    getter when_values
    @when_values : Array(String)

    def initialize(@when_values)
    end

    def initialize(content : String)
      if match = content.match(SIMPLE_EXP)
        @when_values = match[1].split(",").map { |value| /.*"(.*)".*/.match(value).not_nil![1] }
      else
        raise InvalidNode.new("Invalid When Node")
      end
    end

    def eval(data)
      @when_values.includes?(data)
    end
  end
end
