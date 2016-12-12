module Liquid::Tokens
  abstract class Token
    @class : String = {{@type.class.stringify}}
    def_equals @class
  end

  class Raw < Token
    getter content
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

  class EndForStatement < Token
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

  class ElseStatement < Token
  end

  class EndIfStatement < Token
  end
end
