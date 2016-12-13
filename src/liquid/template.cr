require "./nodes"
require "./tokens"

include Liquid::Nodes

module Liquid
  class Template
    getter root

    @root : Root

    def initialize(tokens : Array(Tokens::Token))
      @root = Root.new
      build tokens
    end

    def render(data, io = IO::Memory.new)
      @root.render(data, io)
      io.close
      io.to_s
    end

    private def build(tokens : Array(Tokens::Token))
      stack = [@root] of Node
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
        when Tokens::Raw
          stack.last << Raw.new token
        else
          stack.last << Unknow.new token
        end
      end
    end
  end
end
