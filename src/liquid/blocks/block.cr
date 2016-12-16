module Liquid::Block
  abstract class Node
    getter children
    @children : Array(Node)
    @children = Array(Node).new

    abstract def initialize(content)

    abstract def render(data : Context, io)

    def <<(node : Node)
      @children << node
    end

    def_equals @children
  end

  class Root < Node
    def initialize
    end

    def initialize(content)
    end

    def render(data, io)
      @children.each &.render(data, io)
    end
  end

  abstract class InlineBlock < Node
  end

  class BeginBlock < Node
    @check = true

    def initialize(content)
    end

    def render(data, io)
    end
  end

  class EndBlock < Node
    @begin_block : BeginBlock.class
    getter begin_block

    def initialize(@begin_block)
    end

    def render(data, io)
    end
  end
end
