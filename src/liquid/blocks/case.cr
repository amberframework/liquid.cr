require "./block"
require "./else"
require "./expression"
require "./when"

module Liquid::Block
  class Case < BeginBlock
    SIMPLE_EXP = /^\s*case (?<expr>.+)\s*$/

    enum PutInto
      Case
      When
      Else
    end

    getter :case, :case_expression, :else, :when

    @case_expression : Expression?
    @when : Array(When)?
    @else : Else?

    @last = PutInto::Case

    def initialize(@case_expression)
    end

    def initialize(content : String)
      if match = content.strip.match SIMPLE_EXP
        @case_expression = Expression.new match["expr"]
      else
        raise InvalidNode.new "Invalid case node"
      end
    end

    def <<(node : Node)
      case @last
      when PutInto::Case
        @children << node
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
      raise InvalidNode.new "Else without When in Case statement!" unless @last == PutInto::When
      @else = node
      @last = PutInto::Else
    end

    def_equals @when, @else, @children
  end
end
