require "./block"

module Liquid::Block
  class Comment < RawHiddenBlock
    @content : String

    def initialize(@content)
    end

    def content
      ""
    end

    def_equals @children, content
  end
end
