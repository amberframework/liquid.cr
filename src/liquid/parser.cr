require "./tokens"
require "./template"

module Liquid
  class Parser
    def self.parse(str : String)
      lexer = Lexer.new
      tokens = lexer.tokenize str
      self.validate tokens
      self.build tokens
    end

    def self.validate(tokens : Array(Tokens::Token))
    end

    def self.build(tokens : Array(Tokens::Token))
      template = Template.new tokens
      template
    end
  end
end
