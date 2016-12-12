module Liquid::Nodes
  abstract class Node
    getter children
    @children = Array(Node).new

    abstract def initialize(token)

    def <<(node : Node)
      @children << node
    end

    def_equals @children
  end

  class Root < Node
    def initialize
    end
    def initialize(token : Tokens::Token)
    end
  end

  class Unknow < Node
    def initialize(token : Tokens::Token)
    end
  end

  class Raw < Node
    @content : String
    def initialize(token : Tokens::Raw)
      @content = token.content
    end

    def_equals @children, @content

  end

  class For < Node
    def initialize(token : Tokens::ForStatement)
    end
  end

  class If < Node

    @elsif : Array(ElsIf)?
    @else : Else?

    def initialize(token : Tokens::IfStatement)
    end

    def add_elsif(token : Tokens::ElsIfStatement) : ElsIf
      @elsif ||= Array(ElsIf).new
      @elsif.not_nil! << ElsIf.new token
      @elsif.not_nil!.last
    end

    def set_else(token : Tokens::ElseStatement) : Else
      @else = Else.new token
    end

     def set_else(node : Else) : Else
      @else = node
    end

    def_equals @elsif, @else, @children
  end

  class Else < Node
    def initialize(token : Tokens::ElseStatement)
    end
  end

  class ElsIf < Node
    def initialize(token : Tokens::ElsIfStatement)
    end
  end

end
