require "./context"

require "./nodes/*"

module Liquid::Nodes
  class Root < Node
    def initialize
    end

    def initialize(token : Tokens::Token)
    end

    def render(data, io)
      @children.each &.render(data, io)
    end
  end

  class Raw < Node
    @content : String

    def initialize(token : Tokens::Raw)
      @content = token.content
    end

    def render(data, io)
      io << @content
    end

    def_equals @children, @content
  end

  class If < Node
    SIMPLE_EXP = /^\s*if (?<expr>.+)\s*$/

    @if_expression : Expression
    @elsif : Array(ElsIf)?
    @else : Else?

    def initialize(token : Tokens::IfStatement)
      if match = token.content.match SIMPLE_EXP
        @if_expression = Expression.new match["expr"]
      else
        pp token
        raise Exception.new "Invalid If node"
      end
    end

    def render(data, io)
      if @if_expression.eval(data)
        @children.each &.render(data, io)
      else
        found = false
        if elsifpart = @elsif
          elsifpart.each do |alt|
            if alt.eval(data)
              found = true
              alt.render(data, io)
              break
            end
          end
        end
        if (elsepart = @else) && !found
          elsepart.render data, io
        end
      end
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

    def render(data, io)
      @children.each &.render(data, io)
    end
  end

  class ElsIf < Node
    SIMPLE_EXP = /^\s*elsif (?<expr>.+)\s*$/
    @if_expression : Expression

    def initialize(token : Tokens::ElsIfStatement)
      if match = token.content.match SIMPLE_EXP
        @if_expression = Expression.new match["expr"]
      else
        raise Exception.new "Invalid Elsif Node"
      end
    end

    def eval(data)
      @if_expression.eval data
    end

    def render(data, io)
      @children.each &.render(data, io)
    end
  end
end
