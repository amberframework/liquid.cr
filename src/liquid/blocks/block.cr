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

    def inspect(io : IO)
      inspect(io) do
      end
    end

    protected def inspect(io : IO, &)
      io << '<'
      io << '-' if lstrip?
      io << ' '
      io << self.class.name.gsub(/(\w*::)*/, "") << ' '
      yield
      io << '-' if rstrip?
      io << '>'
    end
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
end
