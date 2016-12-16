require "./block"

module Liquid::Block
  class Raw < Node
    @content : String

    def initialize(@content)
    end

    def render(data, io)
      io << @content
    end

    def_equals @children, @content
  end
end
