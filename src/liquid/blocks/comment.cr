require "./block"

module Liquid::Block
  class Comment < BeginBlock
    def initialize(content : String)
    end

    def content
      ""
    end

    def <<(node : Node)
    end

    def_equals @children, content
  end
end
