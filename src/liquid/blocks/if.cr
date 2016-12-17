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

    getter :elsif

    @if_expression : Expression?
    @elsif : Array(ElsIf)?
    @else : Else?

    @last = PutInto::If

    def initialize(content : String)
      if match = content.strip.match SIMPLE_EXP
        @if_expression = Expression.new match["expr"]
      else
        raise InvalidNode.new "Invalid if node"
      end
    end

    def render(data, io)
      if @if_expression.not_nil!.eval(data).as_bool?
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
