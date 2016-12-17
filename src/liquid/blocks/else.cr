require "./block"

module Liquid::Block
  class Else < InlineBlock
    def initialize(str : String)
    end

    def render(data, io)
      @children.each &.render(data, io)
    end
  end
end
