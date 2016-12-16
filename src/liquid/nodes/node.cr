module Liquid::Nodes
  abstract class Node
    getter children
    @children = Array(Node).new

    abstract def initialize(token)

    abstract def render(data : Context, io)

    def <<(node : Node)
      @children << node
    end

    def_equals @children
  end
end
