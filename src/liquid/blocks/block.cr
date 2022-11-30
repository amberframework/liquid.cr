require "../visitor"

module Liquid::Block
  abstract class Node
    getter children = Array(Node).new
    property? rstrip = false
    property? lstrip = false

    abstract def initialize(content : String)

    def accept(visitor : Visitor)
      visitor.visit self
    end

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
  end

  abstract class InlineBlock < Node
    extend Block
  end

  abstract class BeginBlock < Node
    extend Block
  end

  class EndBlock < Node
    extend Block

    def initialize(content)
    end

    def initialize
    end
  end

  abstract class RawBlock < Node
    extend Block
  end
end
