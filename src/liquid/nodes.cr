module Liquid
  abstract class Node
    @class : String = {{@type.class.stringify}}
    def_equals @class
  end

  class Raw < Node
    @content : String

    def initialize(@content)
    end

    def_equals @content

  end

  class Statement < Raw
    def initialize(@content : String)
      @content = @content.strip
    end
  end

  class ForStatement < Statement
    def initialize(@content : String)
      @content = @content.strip
    end
  end

  class EndForStatement < Node
  end

  class Expression < Raw
    def initialize(@content)
      @content = @content.strip
    end
  end

  class Comment < Raw
  end

  class IfStatement < Statement
  end

  class ElsIfStatement < Statement
  end

  class ElseStatement < Node
  end

  class EndIfStatement < Node
  end

  class Template < Node
    @children = Array(Node).new

    def <<(node : Node)
      @children << node
    end

    def_equals @children

    def initialize
    end

    def initialize(node : Node)
      @children << node
    end
  end
end
