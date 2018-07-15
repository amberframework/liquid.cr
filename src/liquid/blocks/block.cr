require "../visitor"

module Liquid::Block
  enum BlockType
    Inline
    Begin
    End
    Raw
  end

  abstract def type : BlockType

  abstract class Node
    getter children
    @children : Array(Node)
    @children = Array(Node).new

    abstract def initialize(content)

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

    def self.type
      BlockType::Inline
    end
  end

  abstract class BeginBlock < Node
    extend Block

    def self.type
      BlockType::Begin
    end
  end

  abstract class EndBlock < Node
    extend Block

    def self.type
      BlockType::End
    end
  end

  abstract class RawBlock < Node
    extend Block

    def self.type
      BlockType::Raw
    end
  end
end
