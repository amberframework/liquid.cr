require "./template"

module Liquid
  class Parser
    RAW        = /^(?<raw>[^{]+)/
    STATEMENT  = /^\{%(?<full> ?(?<keyword>[a-z]+)([^%]*))%}/
    EXPRESSION = /^\{{(?<expr>[^}]*)}}/

    # Parse a String
    # Run Lexer
    # validate
    # Build tree
    # returns Template
    def self.parse(str : String) : Template
      root = self.build str
      Template.new root
    end

    def self.consume(str, fin)
      fin = fin.not_nil!
      str[fin..-1]
    end

    def self.consume_statement(str, match)
      keyword = match["keyword"]
      block = BlockRegister.for_name keyword
      str = consume(str, match.end)
      return str, block
    end

    def self.consume_expression(str, match)
      expr = Expression.new match["expr"]
      return consume(str, match.end), expr
    end

    def self.build(str : String)
      prev = nil?
      root = Root.new
      stack = [root]

      while !str.empty? && prev != str
        prev = str
        if match = str.match RAW
          stack.last << Raw.new match["raw"]
          str = consume(str, match.end)
        elsif match = str.match STATEMENT
          str, block = consume_statement(str, match)
          pp block, match, block.is_a? BeginBlock
          case block
          when Block::InlineBlock
            stack.last << block.new match["full"]
          when Block::BeginBlock
            stack.last << block
            stack << block
          when Block::EndBlock
            while (pop = stack.pop) && !pop.class == block.begin_block.class
            end
          end
        elsif match = str.match EXPRESSION
          str, expr = consume_expression str, match
          stack.last << expr
        end
      end
      root
    end

    def self.validate(tokens : Array(Tokens::Token))
    end

    def self.build_tree(tokens : Array(Tokens::Token))
      root = Root.new
      stack = [root] of Node
      tokens.each do |token|
        case token
        when Tokens::CaptureStatement
          node = Capture.new token
          stack.last << node
          stack << node
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
        when Tokens::EndCaptureStatement
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
