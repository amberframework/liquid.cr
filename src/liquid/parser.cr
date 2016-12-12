module Liquid

  class Parser

    def parse(str : String)
      lexer = Lexer.new
      tokens = lexer.tokenize str

    end

  end

end
