require "./block"
require "./else"
require "./expression"

module Liquid::Block
  class If < BeginBlock
    SIMPLE_EXP = /^\s*if (?<expr>.+)\s*$/

    @if_expression : Expression
    @elsif : Array(ElsIf)?
    @else : Else?

    def initialize(content : String)
      if match = content.strip.match SIMPLE_EXP
        @if_expression = Expression.new match["expr"]
      else
        raise InvalidNode.new "Invalid if node"
      end
    end

    def render(data, io)
      if @if_expression.eval(data).as_bool?
        @children.each &.render(data, io)
      else
        found = false
        if elsifpart = @elsif
          elsifpart.each do |alt|
            if alt.eval(data).as_bool?
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

    def <<(node : ElsIf)
      @elsif ||= Array(ElsIf).new
      @elsif.not_nil! << node
    end

    def <<(node : Else)
      @else = node
    end

    def_equals @elsif, @else, @children
  end
end
