module Liquid::Nodes
  VAR = /[a-z]\w*(\.[a-z]\w*)*/
  UVAR = /[a-z]\w*(?:\.[a-z]\w*)*/

  abstract class Node
    getter children
    @children = Array(Node).new

    abstract def initialize(token)

    abstract def render(data, io)

    def <<(node : Node)
      @children << node
    end

    def_equals @children
  end
end
