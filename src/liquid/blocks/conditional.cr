require "./block"
require "./else"
require "./elsif"
require "./expression"

module Liquid::Block
  # Base class for if/unless tags
  abstract class Conditional < BeginBlock
    enum PutInto
      Conditional
      Elsif
      Else
    end

    getter expression : Expression
    getter elsif : Array(ElsIf)?
    getter else : Else?

    @put_into = PutInto::Conditional

    def initialize(@expression)
    end

    def initialize(content : String)
      @expression = expression_from_content(content)
    end

    protected abstract def expression_from_content(content : String) : Expression

    def <<(node : Node)
      case @put_into
      when PutInto::Conditional
        @children << node
      when PutInto::Elsif
        @elsif.not_nil!.last << node
      when PutInto::Else
        @else.not_nil! << node
      end
    end

    def <<(node : ElsIf)
      elsif_arr = @elsif ||= Array(ElsIf).new
      elsif_arr << node
      @put_into = PutInto::Elsif
    end

    def <<(node : Else)
      raise InvalidNode.new "Multiple Else in If statement !" if @else

      @else = node
      @put_into = PutInto::Else
    end

    def inspect(io : IO)
      inspect(io) do
        io << @expression.expression.inspect
      end
    end

    def_equals @expression, @elsif, @else, @children
  end
end
