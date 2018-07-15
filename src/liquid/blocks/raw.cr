require "./block"

module Liquid::Block
  class Raw < RawBlock
    getter content

    @content : String

    def initialize(@content)
    end

    def_equals @children, @content
  end
end
