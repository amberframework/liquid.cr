require "./block"
require "./else"
require "./elsif"
require "./expression"

module Liquid::Block
  class If < BeginBlock
    SIMPLE_EXP = /^\s*if (?<expr>.+)\s*$/

    enum PutInto
      If
      Elsif
      Else
    end

    getter if_expression : Expression
    getter elsif : Array(ElsIf)?
    getter else : Else?

    @last = PutInto::If

    def initialize(@if_expression)
    end

    def initialize(content : String)
      if match = content.strip.match SIMPLE_EXP
        @if_expression = Expression.new match["expr"]
      else
        raise InvalidNode.new "Invalid if node"
      end
    end

    def <<(node : Node)
      case @last
      when PutInto::If
        @children << node
      when PutInto::Elsif
        @elsif.not_nil!.last << node
      when PutInto::Else
        @else.not_nil! << node
      end
    end

    def <<(node : ElsIf)
      @elsif ||= Array(ElsIf).new
      @elsif.not_nil! << node
      @last = PutInto::Elsif
    end

    def <<(node : Else)
      raise InvalidNode.new "Multiple Else in If statement !" if @else
      @else = node
      @last = PutInto::Else
    end

    def_equals @elsif, @else, @children
  end
end
