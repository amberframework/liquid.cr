require "./node"
require "./expression"

module Liquid::Nodes
  class Assign < Node
    ASSIGN = /^\s*assign (?<varname>#{VAR}) ?= ?(?<value>.+)\s*$/

    @varname : String
    @value : Expression

    def initialize(tok : Tokens::AssignStatement)
      if match = tok.content.match ASSIGN
        @varname = match["varname"]
        @value = Expression.new match["value"]
      else
        raise InvalidNode.new "Invalid assignment Node"
      end
    end

    def initialize(str : String)
      if match = str.match ASSIGN
        @varname = match["varname"]
        @value = Expression.new match["value"]
      else
        raise InvalidNode.new "Invalid assignment Node"
      end
    end

    def render(data, io)
      data.set @varname, @value.eval(data)
    end
  end
end
