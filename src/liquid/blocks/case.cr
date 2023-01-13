require "./block"
require "./else"
require "../expression"
require "./when"

module Liquid::Block
  class Case < BeginBlock
    SIMPLE_EXP = /^\s*case (?<expr>.+)\s*$/

    enum PutInto
      Case
      When
      Else
    end

    getter expression : Expression
    getter when : Array(When)?
    getter else : Else?

    @last = PutInto::Case

    def initialize(@expression)
    end

    def initialize(content : String)
      if match = content.strip.match SIMPLE_EXP
        @expression = Expression.new match["expr"]
      else
        raise InvalidNode.new "Invalid case node"
      end
    end

    def <<(node : Node)
      case @last
      when PutInto::Case
        # Probbly white space between {% case %} and {% when %}
      when PutInto::When
        @when.not_nil!.last << node
      when PutInto::Else
        @else.not_nil! << node
      end
    end

    def <<(node : When)
      raise InvalidNode.new "When statement must preceed Else!" if @else
      @when ||= Array(When).new
      @when.not_nil! << node
      @last = PutInto::When
    end

    def <<(node : Else)
      raise InvalidNode.new "Multiple Else in Case statement!" if @else

      @else = node
      @last = PutInto::Else
    end

    def inspect(io : IO)
      inspect(io) { io << @expression.expression.inspect }
    end

    def_equals @when, @else, @children
  end
end
