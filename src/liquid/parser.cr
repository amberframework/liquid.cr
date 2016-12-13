require "./tokens"
require "./template"

module Liquid
  class Parser
    # Parse a String
    # Run Lexer
    # validate
    # Build tree
    # returns Template
    def self.parse(str : String) : Template
      lexer = Lexer.new
      tokens = lexer.tokenize str
      self.validate tokens
      root = self.build tokens
      Template.new root
    end

    def self.validate(tokens : Array(Tokens::Token))
    end

    def self.build(tokens : Array(Tokens::Token))
      root = Root.new
      stack = [root] of Node
      tokens.each do |token|
        case token
        when Tokens::IfStatement
          node = If.new token
          stack.last << node
          stack << node
        when Tokens::ElsIfStatement
          if stack.last.is_a? If
            elsifnode = stack.last.as(If).add_elsif token
            stack << elsifnode
          end
        when Tokens::ElseStatement
          if stack.last.is_a? If
            elsenode = stack.last.as(If).set_else token
            stack << elsenode
          elsif (s = stack[-2]?) && s.is_a?(If)
            elsenode = stack[-2].as(If).set_else token
            stack << elsenode
          end
        when Tokens::EndIfStatement
          stack.size.times do
            pop = stack.pop
            break if pop.is_a? If
          end
        when Tokens::ForStatement
          node = For.new token
          stack.last << node
          stack << node
        when Tokens::EndForStatement
          stack.pop
        when Tokens::Expression
          stack.last << Expression.new token
        when Tokens::AssignStatement
          stack.last << Assign.new token
        when Tokens::Raw
          stack.last << Raw.new token
        end
      end
      root
    end
  end
end
